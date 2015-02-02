/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDRequest.h"
#import "YDConstants.h"

@interface YDRequest (){
    BOOL _isCancelled;
}

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) NSFileHandle *uploadFileHandle;
@property (nonatomic, copy) NSURLRequest *lastRequest;
@property (nonatomic, copy) NSURLRequest *mainRequest;
@property (nonatomic, strong) NSHTTPURLResponse *lastResponse;
@property (nonatomic, assign) UInt64 receivedDataLength;
@property (nonatomic, strong) NSURLConnection *connection;

@end


@implementation YDRequest

@synthesize callbackQueue = _callbackQueue;

#pragma mark - Object lifecycle

- (instancetype)initWithURL:(NSURL *)theURL
{
    self = [super init];
    if (self != nil) {
        _URL = theURL;
    }
    return self;
}

- (NSString *)description
{
	NSMutableString *description = [[NSMutableString alloc] initWithString:super.description];
	[description appendFormat:@", URL: %@",self.URL];
	return description;
}

#pragma mark - Properties

- (dispatch_queue_t)callbackQueue
{
    @synchronized(self) {
        if (!_callbackQueue) {
            return dispatch_get_main_queue();
        }
        return _callbackQueue;
    }
}

- (void)setCallbackQueue:(dispatch_queue_t)newValue
{
    @synchronized(self) {
        _callbackQueue = newValue;
    }
}

#pragma mark - Public interface

- (void)start
{
	YDLog(@"%@ attempts to start", self);
	if (self.hasActiveConnection == YES) {
        YDLog(@"%@ failed to start because it is already running", self);
		return;
	}

    self.receivedDataLength = 0;
    _isCancelled = NO;
    self.receivedData = nil;

	NSURLRequest *req = self.buildRequest;
    self.mainRequest = req;

	NSAssert1(req != nil, @"%@ failed to build HTTP request.", self);
	if (req == nil) {
        YDLog(@"%@ failed to build HTTP request.", self);
		return;
	}

    if ( req.HTTPBody.length > 0) {
        YDLog(@"BODY: %@", [[NSString alloc] initWithData:req.HTTPBody encoding:NSUTF8StringEncoding]);
    }

    YDLog(@"METHOD: %@", req.HTTPMethod);
    
    [req.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        YDLog(@"%@: %@", key,obj);
    }];
    
	self.connection = [[NSURLConnection alloc] initWithRequest:req
												 delegate:self
										 startImmediately:YES];
	if (self.connection == nil) {
        YDLog(@"%@ failed to create request connection.", self);
		return;
	}
}

- (void)cancel
{
    _isCancelled = YES;

	YDLog(@"%@ cancel", self);

	[self closeConnection];
    [self removeFileIfExist];
    
    self.shouldRedirectBlock = nil;
    self.didReceiveResponseBlock = nil;
    self.didGetPartialDataBlock = nil;
    self.didSendBodyData = nil;
    self.didFinishLoadingBlock = nil;
    self.didFailBlock = nil;
}

- (BOOL)isCancelled{
    return _isCancelled;
}

#pragma mark - NSURLConnection delegate callbacks

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (self.isCancelled) {
        [self cancel];
        return;
    }

    if (self.didSendBodyData!= nil) {
        dispatch_async(self.callbackQueue, ^{
            if(self.isCancelled==NO){
                self.didSendBodyData(totalBytesWritten, totalBytesExpectedToWrite);
            }
        });
    }
}

- (NSURLRequest *)connection:(NSURLConnection *)aConnection
			 willSendRequest:(NSURLRequest *)aRequest
			redirectResponse:(NSURLResponse *)aResponse
{
    if (self.isCancelled) {
        [self cancel];
        return nil;
    }

    
    if (aResponse != nil) {
        self.lastResponse = (NSHTTPURLResponse *)aResponse;
        __block NSURLRequest *redirectRequest = [self buildRedirectRequestUsingDefault:aRequest];
        if (self.shouldRedirectBlock != nil) {
            dispatch_async(self.callbackQueue, ^{
                if(self.isCancelled==NO){
                    redirectRequest = self.shouldRedirectBlock(aResponse, aRequest);
                }
            });
        }

        if (redirectRequest != nil) {
            self.lastRequest = redirectRequest;
        }

        return redirectRequest;
    }

    return aRequest;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    YDLog(@"%@ did receive response %ld %@", self, (long)statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
    
    if (self.isCancelled) {
        [self cancel];
        return;
    }
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    self.lastResponse = httpResponse;
    
    [self.lastResponse.allHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        YDLog(@"%@: %@", key,obj);
    }];

    // By default we accept all 2xx codes, but delegate can override this rule.
    __block BOOL responseAccepted = [self acceptResponseCode:self.lastResponse.statusCode];

    // Call delegate callback
    if (self.didReceiveResponseBlock != nil) {
        NSURLResponse *resp = self.lastResponse;
        dispatch_async(self.callbackQueue, ^{
            if(self.isCancelled==NO){
                self.didReceiveResponseBlock(resp, &responseAccepted);
            }
        });
    }

    if (responseAccepted == NO) {
        YDLog(@"%@: response has not been accepted. Closing connection", self);
        [self closeConnection];

        NSError *error = [NSError errorWithDomain:kYDSessionRequestErrorDomain
                                             code:YDRequestErrorCodeWrongResponseStatusCode
                                         userInfo:@{@"statusCode" : @(self.lastResponse.statusCode)}];

        [self callDelegateWithError:error];
    }
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data
{
	//YDLog(@"%@ did receive some data (%llu)", self, _receivedDataLength + data.length);

    if (self.isCancelled) {
        [self cancel];
        return;
    }

    UInt64 expectedContentLength = self.lastResponse.expectedContentLength;

    if(self.skipReceivedData==NO){
        if (self.fileURL != nil) {
            NSError *error = nil;
            // Delete file if exist
            if (self.receivedDataLength == 0 && [[NSFileManager defaultManager] fileExistsAtPath:self.fileURL.path] == YES)
                [[NSFileManager defaultManager] removeItemAtPath:self.fileURL.path error:&error];

            if (error == nil && [[NSFileManager defaultManager] fileExistsAtPath:self.fileURL.path] == NO) {
                NSURL *dirURL = self.fileURL.URLByDeletingLastPathComponent;
                [[NSFileManager defaultManager] createDirectoryAtPath:dirURL.path
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:&error];

                if (error == nil) {
                    [[NSFileManager defaultManager] createFileAtPath:_fileURL.path
                                                            contents:nil
                                                          attributes:nil];
                    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.fileURL.path];
                }
            }

            // Handle create/delete file errors
            if (error != nil) {
                [self closeConnection];
                [self removeFileIfExist];
                [self callDelegateWithError:error];
                return;
            }

            @try {
                [self.fileHandle seekToEndOfFile];
                [self.fileHandle writeData:data];
            }
            @catch (NSException *exception) {
                if ([exception.name isEqualToString:NSFileHandleOperationException]) {
                    [self closeConnection];
                    [self removeFileIfExist];
                    NSError *error = [NSError errorWithDomain:kYDSessionRequestErrorDomain code:YDRequestErrorCodeFileIO userInfo:exception.userInfo];
                    [self callDelegateWithError:error];
                    return;
                }
                else {
                    @throw exception;
                }
            }
        }
        else {
            if (self.receivedData == nil) {
                self.receivedData = [NSMutableData dataWithCapacity:0];
            }
            [self.receivedData appendData:data];
        }
    }
    
    self.receivedDataLength += data.length;
    UInt64 receivedDataLength = self.receivedDataLength;
    
    // Call delegate callback
    if (self.didGetPartialDataBlock != nil) {
        dispatch_async(self.callbackQueue, ^{
            if(self.isCancelled==NO){
                self.didGetPartialDataBlock(receivedDataLength, expectedContentLength,data);
            }
        });
    }
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error
{
	YDLog(@"%@ did fail with error:\n%@", self, error);

    if (self.isCancelled) {
        [self cancel];
        return;
    }
    
    [self closeConnection];

    [self removeFileIfExist];

    [self callDelegateWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
	YDLog(@"%@ did finish loading.", self);

	[self closeConnection];

    if (self.fileHandle != nil) {
        [self.fileHandle closeFile];
        //YDLog(@"DATA stored at: %@", self.fileURL.path);
    }
    else if (self.receivedData.length > 0) {
        //YDLog(@"DATA: %@", [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding]);
    }

    // Call delegate callback
    if (self.didFinishLoadingBlock != nil) {
        NSData *data = self.fileURL != nil ? nil : self.receivedData;
        dispatch_async(self.callbackQueue, ^{
            if(self.isCancelled==NO){
                self.didFinishLoadingBlock(data);
            }
        });
    }

    [self processReceivedData];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)response {
    return nil;
}

#pragma mark - Private

- (BOOL)hasActiveConnection
{
	return (_connection != nil);
}

- (NSData *)buildHTTPBody
{
    // Can be overwritten by descendants.
    return nil;
}

- (void)prepareRequest:(NSMutableURLRequest *)request
{
    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    
    if (self.OAuthToken.length > 0) {
        NSString *OAuthHeaderField = [NSString stringWithFormat:@"OAuth %@", self.OAuthToken];
        [request setValue:OAuthHeaderField forHTTPHeaderField:@"Authorization"];
    }
    
    if(self.params){
        [self.params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [request setValue:obj forHTTPHeaderField:key];
        }];
    }

    // We never use cookies for authorization!!!
    [request setHTTPShouldHandleCookies:NO];

    if (self.timeoutInterval > 0) {
        request.timeoutInterval = self.timeoutInterval;
    }
    else {
        request.timeoutInterval = 20; // default timeout interval
    }

    NSData *body = [self buildHTTPBody];
    if (body.length > 0) {
        request.HTTPBody = body;
    }
}

- (NSURLRequest *)buildRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL];

    [self prepareRequest:request];

    return request;
}

- (NSURLRequest *)buildRedirectRequestUsingDefault:(NSURLRequest *)request
{
    NSMutableURLRequest *redirectRequest = [request mutableCopy];

    [self prepareRequest:redirectRequest];

    return redirectRequest;
}

- (BOOL)acceptResponseCode:(NSUInteger)statusCode
{
    // Can be overwritten by descendants.

    // Accept all 2xx codes
    return (statusCode/100 == 2);
}

- (void)processReceivedData
{
    // Should be overwritten by descendants (if it needs additional processing of received data)
    // For example, received data can be parsed here.
}

- (void)closeConnection
{
    if (_connection == nil) {
        return;
    }

    [_connection cancel];
    _connection = nil;
}

- (void)removeFileIfExist
{
    if (self.fileHandle != nil)
        [self.fileHandle closeFile];

    if (self.fileURL != nil && [[NSFileManager defaultManager] fileExistsAtPath:self.fileURL.path])
        [[NSFileManager defaultManager] removeItemAtPath:self.fileURL.path error:nil];
}

- (void)callDelegateWithError:(NSError *)error
{
    // Call delegate callback
    if (self.didFailBlock != nil) {
        dispatch_async(self.callbackQueue, ^{
            if(self.isCancelled==NO){
                self.didFailBlock(error);
            }
        });
    }
}

@end
