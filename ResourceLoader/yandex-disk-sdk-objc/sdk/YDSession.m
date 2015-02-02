/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#if !(__has_feature(objc_arc))
#   error ARC is required. Add -fobj-arc compiler flag for this file.
#endif


#import "YDSession.h"
#import "YDConstants.h"
#import "NSNotificationCenter+Additions.h"
#import "YDFileListRequest.h"
#import "YDMKCOLRequest.h"
#import "YDMOVERequest.h"
#import "YDDeleteRequest.h"
#import "YDDiskPOSTRequest.h"
#import "YDFileUploadRequest.h"
#import "YDGETRequest.h"


@interface YDSession (){
    dispatch_queue_t _callBackQueue;
}

+ (NSURL *)urlForDiskPath:(NSString *)path;
+ (NSURL *)urlForLocalPath:(NSString *)path;

- (void)prepareRequest:(YDDiskRequest *)request;

- (id<YDSessionRequest>)removePath:(NSString *)path toTrash:(BOOL)trash completion:(YDHandler)block;

@end


@implementation YDSession

- (instancetype)init
{
    NSAssert(YES, @"use initWithDelegate:");
    return nil;
}

- (instancetype)initWithDelegate:(id<YDSessionDelegate>)delegate callBackQueue:(dispatch_queue_t)queue{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _callBackQueue = queue;
    }
    return self;
}

- (BOOL)authenticated
{
    return self.OAuthToken.length > 0;
}

- (id<YDSessionRequest>)fetchDirectoryContentsAtPath:(NSString *)path completion:(YDFetchDirectoryHandler)block
{
    NSURL *url = [YDSession urlForDiskPath:path];
    if (!url) {
        block([NSError errorWithDomain:kYDSessionBadArgumentErrorDomain
                                code:0
                            userInfo:@{@"listPath": path}], nil);
        return nil;
    }

    YDFileListRequest *request = [[YDFileListRequest alloc] initWithURL:url];
    [self prepareRequest:request];
    request.depth = YDWebDAVDepth1;

    request.callbackQueue = _callBackQueue;
    request.props = @[[YDFileListRequest displayNameProp],
                      [YDFileListRequest resourceTypeProp],
                      [YDFileListRequest contentTypeProp],
                      [YDFileListRequest contentLengthProp],
                      [YDFileListRequest lastModifiedProp],
                      [YDFileListRequest eTagProp],
                      [YDFileListRequest readonlyProp],
                      [YDFileListRequest publicUrlProp],
                      [YDFileListRequest sharedProp]];

    __weak typeof (request) weakRequest = request;
    
    request.didFailBlock = ^(NSError *error) {
        if(weakRequest.isCancelled==NO){
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            userInfo[@"URL"] = url;
            if (error) userInfo[@"error"] = error;
            [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidFailWithFetchDirectoryRequestNotification
                                                                               object:self
                                                                             userInfo:userInfo];
            block([NSError errorWithDomain:error.domain code:error.code userInfo:userInfo], nil);
        }
    };

    request.didReceiveMultistatusResponsesBlock = ^(NSArray *responses) {
        if(weakRequest.isCancelled==NO){
            NSMutableArray *fileItems = [NSMutableArray arrayWithCapacity:0];

            for (YDMultiStatusResponse *response in responses) {
                YDItemStat *item = [[YDItemStat alloc] initWithSession:self
                                                            dictionary:response.successPropValues
                                                                   URL:response.URL];

                if (![response.URL.path isEqual:url.path]) {
                    [fileItems addObject:item];
                }
            }

            block(nil, fileItems);
        }
    };
    
    [request start];
    
    return (id<YDSessionRequest>)request;
}

- (id<YDSessionRequest>)fetchStatusForPath:(NSString *)path completion:(YDFetchStatusHandler)block
{
    NSURL *url = [YDSession urlForDiskPath:path];
    if (!url) {
        block([NSError errorWithDomain:kYDSessionBadArgumentErrorDomain
                                code:0
                            userInfo:@{@"statPath": path}], nil);
        return nil;
    }

    YDFileListRequest *request = [[YDFileListRequest alloc] initWithURL:url];
    [self prepareRequest:request];
    request.depth = YDWebDAVDepth0;

    request.callbackQueue = _callBackQueue;
    request.props = @[[YDFileListRequest displayNameProp],
                      [YDFileListRequest resourceTypeProp],
                      [YDFileListRequest contentTypeProp],
                      [YDFileListRequest contentLengthProp],
                      [YDFileListRequest lastModifiedProp],
                      [YDFileListRequest eTagProp],
                      [YDFileListRequest readonlyProp],
                      [YDFileListRequest publicUrlProp],
                      [YDFileListRequest sharedProp]];

    request.didFailBlock = ^(NSError *error) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"URL"]=url;
        if (error) userInfo[@"error"] = error;
        [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidFailWithFetchStatusRequestNotification
                                                                           object:self
                                                                         userInfo:userInfo];
        block([NSError errorWithDomain:error.domain code:error.code userInfo:userInfo], nil);
    };

    request.didReceiveMultistatusResponsesBlock = ^(NSArray *responses) {
        for (YDMultiStatusResponse *response in responses) {
            if ([response.URL.path isEqual:url.path]) {
                YDItemStat *item = [[YDItemStat alloc] initWithSession:self
                                                            dictionary:response.successPropValues
                                                                   URL:response.URL];
                block(nil, item);
                return;
            }
        }
        block(nil, nil);
    };

    [request start];
    
    return (id<YDSessionRequest>)request;
}

- (id<YDSessionRequest>)fetchUserLoginWithCompletion:(YDUserLoginHandler)block{
    NSString *path = @"/?userinfo";
    NSURL *url = [YDSession urlForDiskPath:path shouldEscape:NO];
    if (!url) {
        block([NSError errorWithDomain:kYDSessionBadArgumentErrorDomain
                                  code:0
                              userInfo:@{@"statPath": path}], nil);
        return nil;
    }
    
    YDGETRequest *request = [[YDGETRequest alloc] initWithURL:url];
    [self prepareRequest:request];
    
    request.callbackQueue = _callBackQueue;
    
    request.didFailBlock = ^(NSError *error) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"URL"]=url;
        if (error) userInfo[@"error"] = error;
        [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidFailWithFetchUserInfoRequestNotification
                                                                           object:self
                                                                         userInfo:userInfo];
        block([NSError errorWithDomain:error.domain code:error.code userInfo:userInfo], nil);
    };
    
    request.didFinishLoadingBlock = ^(NSData *receivedData){
        NSString *dataStr = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        NSString *login = @"login";
        NSUInteger colomnRange = [dataStr rangeOfString:@":"].location;
        if(colomnRange!=NSNotFound){
            login = [dataStr substringFromIndex:colomnRange+1];
        }
        if(block){
            block(nil,login);
        }
    };

    [request start];
    
    return (id<YDSessionRequest>)request;
}

- (id<YDSessionRequest>)createDirectoryAtPath:(NSString *)path completion:(YDHandler)block
{
    NSURL *url = [YDSession urlForDiskPath:path];
    if (!url) {
        block([NSError errorWithDomain:kYDSessionBadArgumentErrorDomain
                                code:0
                            userInfo:@{@"mkDirAtPath": path}]);
        return nil;
    }

    YDMKCOLRequest *request = [[YDMKCOLRequest alloc] initWithURL:url];
    [self prepareRequest:request];

    request.callbackQueue = _callBackQueue;

    NSURL *requestURL = [request.URL copy];

    request.didFailBlock = ^(NSError *error) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"URL"] = requestURL;
        if (error) userInfo[@"error"] = error;
        [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidFailToCreateDirectoryNotification
                                                                           object:self
                                                                         userInfo:userInfo];
        block([NSError errorWithDomain:error.domain code:error.code userInfo:userInfo]);
    };

    request.didFinishLoadingBlock = ^(NSData *receivedData) {
        NSDictionary *userInfo = @{@"URL": requestURL};
        [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidCreateDirectoryNotification
                                                                           object:self
                                                                         userInfo:userInfo];
        block(nil);
    };

    [request start];

    NSDictionary *userInfo = @{@"URL": request.URL};
    [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidSendCreateDirectoryRequestNotification
                                                                       object:self
                                                                     userInfo:userInfo];
    
    return (id<YDSessionRequest>)request;
}

- (id<YDSessionRequest>)removePath:(NSString *)path toTrash:(BOOL)trash completion:(YDHandler)block
{
    NSURL *url = [YDSession urlForDiskPath:path];
    if (!url) {
        block([NSError errorWithDomain:kYDSessionBadArgumentErrorDomain
                                code:0
                            userInfo:@{trash?@"trashPath":@"removePath": path}]);
        return nil;
    }

    NSString *urlstr = url.absoluteString;
    urlstr = [urlstr stringByAppendingFormat:@"?trash=%@", trash?@"true":@"false"];
    url = [NSURL URLWithString:urlstr];

    YDDeleteRequest *request = [[YDDeleteRequest alloc] initWithURL:url];
    request.callbackQueue = _callBackQueue;
    
    [self prepareRequest:request];

    NSURL *requestURL = [request.URL copy];

    void (^successBlock)(NSURL *, NSUInteger) = ^(NSURL *URL, NSUInteger statusCode) {
        NSDictionary *userInfo = @{@"URL": URL,
                                   @"statusCode": @(statusCode)};
        [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidRemoveNotification
                                                                           object:self
                                                                         userInfo:userInfo];
        block(nil);
    };

    void (^failBlock)(NSURL *, NSError *) = ^(NSURL *URL, NSError *error) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"URL"] = url;
        if (error) userInfo[@"error"] = error;
        [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidFailWithRemoveRequestNotification
                                                                           object:self
                                                                         userInfo:userInfo];
        block([NSError errorWithDomain:error.domain code:error.code userInfo:userInfo]);
    };

    request.didFailBlock = ^(NSError *error) {
        failBlock(requestURL, error);
    };

    request.didReceiveResponseBlock = ^(NSURLResponse *response, BOOL *accept) {
        NSUInteger statusCode = [(NSHTTPURLResponse *)response statusCode];

        // Accept all 2xx codes and 404, except 207 – it will be processed in Multistatus response block
        if (statusCode/100 != 2 && statusCode != 404) {
            *accept = NO;
        }
        else if (statusCode != 207) {
            *accept = YES;
            successBlock(requestURL, statusCode);
        }
    };

    request.didReceiveMultistatusResponsesBlock = ^(NSArray *responses) {
        for (YDMultiStatusResponse *response in responses) {
            if (response.statusCode/100 == 2 && response.statusCode != 404) {
                successBlock(requestURL, response.statusCode);
            }
            else {
                failBlock(requestURL, nil);
            }
        }
    };

    [request start];

    NSDictionary *userInfo = @{@"URL": request.URL};
    [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidSendRemoveRequestNotification
                                                                       object:self
                                                                     userInfo:userInfo];
    
    return (id<YDSessionRequest>)request;
}

- (id<YDSessionRequest>)removeItemAtPath:(NSString *)path completion:(YDHandler)block
{
    return [self removePath:path toTrash:NO completion:block];
}

- (id<YDSessionRequest>)trashItemAtPath:(NSString *)path completion:(YDHandler)block
{
    return [self removePath:path toTrash:YES completion:block];
}

- (id<YDSessionRequest>)moveItemAtPath:(NSString *)path toPath:(NSString *)topath completion:(YDHandler)block
{
    NSURL *fromurl = [YDSession urlForDiskPath:path];
    if (!fromurl) {
        block([NSError errorWithDomain:kYDSessionBadArgumentErrorDomain
                                code:0
                            userInfo:@{@"movePath": path}]);
        return nil;
    }
    NSURL *tourl = [YDSession urlForDiskPath:topath];
    if (!tourl) {
        block([NSError errorWithDomain:kYDSessionBadArgumentErrorDomain
                                code:1
                            userInfo:@{@"toPath": topath}]);
        return nil;
    }

    YDMOVERequest *request = [[YDMOVERequest alloc] initWithURL:fromurl];
    [self prepareRequest:request];

    request.destination = [tourl.path stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];

    request.callbackQueue = _callBackQueue;

    NSDictionary *userInfo = @{@"from": fromurl,
                                 @"to": tourl};

    request.didFailBlock = ^(NSError *error) {
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
        [errorInfo addEntriesFromDictionary:@{@"error": error}];
        [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidFailToMoveNotification
                                                                           object:self
                                                                         userInfo:errorInfo];
        block([NSError errorWithDomain:error.domain code:error.code userInfo:errorInfo]);
    };

    request.didFinishLoadingBlock = ^(NSData *receivedData) {
        [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidMoveNotification
                                                                           object:self
                                                                         userInfo:userInfo];
        block(nil);
    };

    [request start];

    [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidSendMoveRequestNotification
                                                                       object:self
                                                                     userInfo:userInfo];
    
     return (id<YDSessionRequest>)request;
}

- (id<YDSessionRequest>)uploadFile:(NSString *)aFile toPath:(NSString *)aPath progress:(YDProgressHandler)progress completion:(YDHandler)block
{
    NSURL *path = [YDSession urlForDiskPath:aPath];
    if (!path) {
        block([NSError errorWithDomain:kYDSessionBadArgumentErrorDomain
                                code:0
                            userInfo:@{@"putPath": aPath}]);
        return nil;
    }
    NSURL *file = [YDSession urlForLocalPath:aFile];
    if (!file) {
        block([NSError errorWithDomain:kYDSessionBadArgumentErrorDomain
                                code:1
                            userInfo:@{@"fromFile": file}]);
        return nil;
    }

    YDFileUploadRequest *request = [[YDFileUploadRequest alloc] initWithURL:path];
    request.callbackQueue = _callBackQueue;
    request.OAuthToken = self.OAuthToken;
    request.localURL = file;
    request.timeoutInterval = 30;

    NSDictionary *userInfo = @{@"URL": request.URL};
    [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidStartUploadFileNotification
                                                                       object:self
                                                                     userInfo:userInfo];

    request.didFinishLoadingBlock = ^(NSData *receivedData) {
        [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidFinishUploadFileNotification
                                                                           object:self
                                                                         userInfo:userInfo];
        block(nil);
    };

    request.didSendBodyData = ^(UInt64 totalBytesWritten, UInt64 totalBytesExpectedToWrite) {
        progress(totalBytesWritten,totalBytesExpectedToWrite);
    };

    request.didFailBlock = ^(NSError *error) {
        NSDictionary *userInfo = @{@"uploadPath": path,
                                     @"fromFile": file,
                                        @"error": error};
        [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidFailUploadFileNotification
                                                                           object:self
                                                                         userInfo:userInfo];
        block([NSError errorWithDomain:error.domain code:error.code userInfo:userInfo]);
    };

    [request start];
    
    return (id<YDSessionRequest>)request;
}


- (id<YDSessionRequest>)downloadFileFromPath:(NSString *)path toFile:(NSString *)file progress:(YDProgressHandler)progress completion:(YDHandler)block{
    return [self downloadFileFromPath:path toFile:file
                           withParams:nil
                             response:nil
                                 data:nil
                             progress:progress
                           completion:block];
}

+ (NSString *)uuidString {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return uuidStr;
}

+ (NSString*)pathForTemporaryFile{
    return [NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.%@", [[self class] uuidString],@"tmp"]];
}

- (id<YDSessionRequest>)partialContentForFileAtPath:(NSString *)srcRemotePath
                                         withParams:(NSDictionary *)params
                                           response:(YDDidReceiveResponseHandler)response
                                               data:(YDPartialDataHandler)data
                                         completion:(YDHandler)completion{
    return [self downloadFileFromPath:srcRemotePath toFile:nil withParams:params response:response data:data progress:nil completion:completion];
}

- (id<YDSessionRequest>)downloadFileFromPath:(NSString *)path
                                      toFile:(NSString *)aFilePath
                                  withParams:(NSDictionary *)params
                                    response:(YDDidReceiveResponseHandler)responseBlock
                                        data:(YDPartialDataHandler)dataBlock
                                    progress:(YDProgressHandler)progressBlock
                                  completion:(YDHandler)completionBlock{
    
    NSURL *url = [YDSession urlForDiskPath:path];
    if (!url) {
        completionBlock([NSError errorWithDomain:kYDSessionBadArgumentErrorDomain
                                  code:0
                              userInfo:@{@"getPath": path}]);
        return nil;
    }
    
    BOOL skipReceivedData = NO;
    
    if(aFilePath==nil){
        aFilePath = [[self class] pathForTemporaryFile];
        skipReceivedData = YES;
    }
    
    NSURL *filePath = [YDSession urlForLocalPath:aFilePath];
    if (!filePath) {
        completionBlock([NSError errorWithDomain:kYDSessionBadArgumentErrorDomain
                                  code:1
                              userInfo:@{@"toFile": aFilePath}]);
        return nil;
    }
    
    YDDiskRequest *request = [[YDDiskRequest alloc] initWithURL:url];
    request.fileURL = filePath;
    request.params = params;
    request.skipReceivedData = skipReceivedData;
    [self prepareRequest:request];
    
    NSURL *requestURL = [request.URL copy];
    
    request.callbackQueue = _callBackQueue;
    
    request.didReceiveResponseBlock = ^(NSURLResponse *response, BOOL *accept) {
        if(responseBlock){
            responseBlock(response);
        }
    };
    
    request.didGetPartialDataBlock = ^(UInt64 receivedDataLength, UInt64 expectedDataLength, NSData *data){
        if(progressBlock){
            progressBlock(receivedDataLength,expectedDataLength);
        }
        if(dataBlock){
            dataBlock(receivedDataLength,expectedDataLength,data);
        }
    };
    
    request.didFinishLoadingBlock = ^(NSData *receivedData) {
        
        if(skipReceivedData){
            [[self class] removeTemporaryFileAtPath:aFilePath];
        }
        
        NSDictionary *userInfo = @{@"URL": requestURL,
                                   @"receivedDataLength": @(receivedData.length)};
        [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidDownloadFileNotification
                                                                           object:self
                                                                         userInfo:userInfo];
        completionBlock(nil);
    };
    
    request.didFailBlock = ^(NSError *error) {
        
        if(skipReceivedData){
            [[self class] removeTemporaryFileAtPath:aFilePath];
        }
        
        NSDictionary *userInfo = @{@"URL": requestURL};
        [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidFailToDownloadFileNotification
                                                                           object:self
                                                                         userInfo:userInfo];
        
        completionBlock([NSError errorWithDomain:error.domain code:error.code userInfo:userInfo]);
    };
    
    [request start];
    
    NSDictionary *userInfo = @{@"URL": request.URL};
    [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidStartDownloadFileNotification
                                                                       object:self
                                                                     userInfo:userInfo];
    return (id<YDSessionRequest>)request;
}

+ (void)removeTemporaryFileAtPath:(NSString *)path{
    if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]){
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

- (id<YDSessionRequest>)publishItemAtPath:(NSString *)aPath completion:(YDPublishHandler)block
{
    NSURL *path = [YDSession urlForDiskPath:aPath];
    if (!path) {
        block([NSError errorWithDomain:kYDSessionBadArgumentErrorDomain
                                code:0
                            userInfo:@{@"publishPath": aPath}], nil);
        return nil;
    }

    NSString *pathUrl = path.absoluteString;
    pathUrl = [pathUrl stringByAppendingString:@"?publish"];
    NSURL *publishURL = [NSURL URLWithString:pathUrl];

    YDDiskPOSTRequest *request = [[YDDiskPOSTRequest alloc] initWithURL:publishURL];
    request.callbackQueue = _callBackQueue;
    [self prepareRequest:request];
    request.timeoutInterval = 15;

    void (^successBlock)(NSURL *, NSURL *) = ^(NSURL *itemURL, NSURL *locationURL) {
        NSDictionary *userInfo = @{@"URL": itemURL,
                                   @"locationURL": locationURL};
        [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidPublishFileNotification
                                                                           object:self
                                                                         userInfo:userInfo];
        block(nil, locationURL);
    };

    void (^failBlock)(NSURL *, NSError *) = ^(NSURL *itemURL, NSError *error) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"URL"] = itemURL;
        if (error) userInfo[@"error"] = error;
        [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidFailWithPublishRequestNotification
                                                                           object:self
                                                                         userInfo:userInfo];
        block([NSError errorWithDomain:error.domain code:error.code userInfo:userInfo], nil);
    };

    request.shouldRedirectBlock = ^NSURLRequest *(NSURLResponse *urlResponse, NSURLRequest *redirectURLRequest) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) urlResponse;
        if (response.statusCode == 302) {
            NSString *publishURLStr = response.allHeaderFields[@"Location"];
            if (publishURLStr.length > 0) {
                successBlock(path, [NSURL URLWithString:publishURLStr]);
                return nil;
            }
        }

        return redirectURLRequest;
    };

    request.didReceiveResponseBlock = ^(NSURLResponse *urlResponse, BOOL *accept) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) urlResponse;
        *accept = (response.statusCode == 302);
    };

    request.didFailBlock = ^(NSError *error) {
        failBlock(path, error);
    };
    
    [request start];
    
    return (id<YDSessionRequest>)request;
}

- (id<YDSessionRequest>)unpublishItemAtPath:(NSString *)aPath completion:(YDHandler)block
{
    NSURL *path = [YDSession urlForDiskPath:aPath];
    if (!path) {
        block([NSError errorWithDomain:kYDSessionBadArgumentErrorDomain
                                code:0
                            userInfo:@{@"unPublishPath": aPath}]);
        return nil;
    }

    NSString *pathUrl = path.absoluteString;
    pathUrl = [pathUrl stringByAppendingString:@"?unpublish"];
    NSURL *publishURL = [NSURL URLWithString:pathUrl];

    YDDiskPOSTRequest *request = [[YDDiskPOSTRequest alloc] initWithURL:publishURL];
    request.callbackQueue = _callBackQueue;
    [self prepareRequest:request];
    request.timeoutInterval = 15;

    request.didReceiveResponseBlock = ^(NSURLResponse *urlResponse, BOOL *accept) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) urlResponse;
        if (response.statusCode == 200) {
            NSDictionary *userInfo = @{@"path": path};
            [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidUnpublishFileNotification
                                                                               object:self
                                                                             userInfo:userInfo];
            block(nil);
            *accept = YES;
        }
        *accept = NO;
    };

    request.didFailBlock = ^(NSError *error) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"path"] = path;
        if (error) userInfo[@"error"] = error;
        [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidFailWithUnpublishRequestNotification
                                                                           object:self
                                                                         userInfo:userInfo];
        block([NSError errorWithDomain:error.domain code:error.code userInfo:userInfo]);
    };

    [request start];

    return (id<YDSessionRequest>)request;
}

#pragma mark - Private

+ (NSURL *)urlForDiskPath:(NSString *)uri
{
    return [self urlForDiskPath:uri shouldEscape:YES];
}

+ (NSURL *)urlForDiskPath:(NSString *)uri shouldEscape:(BOOL)shouldEscape
{
    NSString *aPath = [NSString stringWithFormat:([uri hasPrefix:@"/"]?@"%@":@"/%@"), uri];
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                  (CFStringRef)aPath,
                                                                  NULL,
                                                                  (shouldEscape)?CFSTR(":?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"):NULL, // otherwise e.g. ? character would be misinterpreted as query
                                                                  kCFStringEncodingUTF8);
    
    
    uri = (__bridge NSString *)escaped;
    
    uri = [@"https://webdav.yandex.ru" stringByAppendingString:uri];
    
    NSURL *result = [NSURL URLWithString:uri];
    
    CFRelease(escaped);
    
    return result;
}

+ (NSURL *)urlForLocalPath:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    return url.isFileURL?url:nil;
}

- (void)prepareRequest:(YDDiskRequest *)request
{
    request.OAuthToken = self.OAuthToken;
    request.userAgent = self.delegate.userAgent;
}

@end
