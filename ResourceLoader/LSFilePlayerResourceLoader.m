//
//  LSFilePlayerResourceLoader.m
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import "LSFilePlayerResourceLoader.h"
#import "LSDataResonse.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSObject+LSAdditions.h"
#import "NSString+LSAdditions.h"
#import "LSContentInformation.h"
#import "YDSession.h"



NSString * const LSFilePlayerResourceLoaderErrorDomain = @"LSFilePlayerResourceLoaderErrorDomain";

@interface LSFilePlayerResourceLoader()

@property (nonatomic,strong)NSMutableArray *pendingRequests;
@property (nonatomic,strong)id<YDSessionRequest> contentInfoOperation;
@property (nonatomic,strong)id<YDSessionRequest> dataOperation;
@property (nonatomic,strong)YDSession *session;
@property (nonatomic,strong)NSURL *resourceURL;
@property (nonatomic,assign)BOOL isCancelled;
@property (nonatomic,copy)NSString *path;
@property (nonatomic,strong)NSString *cachedFilePath;
@property (nonatomic,strong)NSFileHandle *writingFileHandle;
@property (nonatomic,strong)NSFileHandle *readingFileHandle;
@property (nonatomic,assign)unsigned long long receivedDataLength;
@property (nonatomic,strong)LSContentInformation *contentInformation;

@end


@implementation LSFilePlayerResourceLoader


- (instancetype)initWithResourceURL:(NSURL *)url session:(YDSession *)session{
    self = [super init];
    if(self){
        self.resourceURL = url;
        self.path = url.path;
        self.session = session;
        self.isCancelled = NO;
        self.pendingRequests = [[NSMutableArray alloc] init];
        self.receivedDataLength = 0;
    }
    return self;
}

- (void)dealloc{
    [self complete];
}

- (NSArray *)requests{
    return self.pendingRequests;
}

- (void)addRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    if(self.isCancelled==NO){
        NSURL *interceptedURL = [loadingRequest.request URL];
        NSAssert([interceptedURL.absoluteString isEqualToString:self.resourceURL.absoluteString], @"Trying to add request with incorrect URL");
        [self startOperationFromOffset:loadingRequest.dataRequest.requestedOffset length:loadingRequest.dataRequest.requestedLength];
        [self.pendingRequests addObject:loadingRequest];
    }
    else{
        NSAssert(NO, @"Trying to add request while resource loader isCancelled");
        if(loadingRequest.isFinished==NO){
            [loadingRequest finishLoadingWithError:[self loaderCancelledError]];
        }
    }
}

- (void)removeRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    [self.pendingRequests removeObject:loadingRequest];
}

- (void)cancelAllPendingRequests{
    for(AVAssetResourceLoadingRequest *pendingRequest in self.pendingRequests){
        if(pendingRequest.isFinished==NO){
            [pendingRequest finishLoadingWithError:[self loaderCancelledError]];
        }
    }
    [self.pendingRequests removeAllObjects];
}

- (void)cancel{
    self.isCancelled = YES;
    [self cancelAllPendingRequests];
    [self complete];
}

- (void)complete{
    [self cancelOperations];
    [self clearDataCache];
}

- (NSError *)loaderCancelledError{
    NSError *error = [[NSError alloc] initWithDomain:LSFilePlayerResourceLoaderErrorDomain
                                                code:-3
                                            userInfo:@{NSLocalizedDescriptionKey:@"Resource loader cancelled"}];
    return error;
}

- (void)cancelOperations{
    if(self.contentInfoOperation){
        [self.contentInfoOperation cancel];
        self.contentInfoOperation = nil;
    }
    if(self.dataOperation){
        [self.dataOperation cancel];
        self.dataOperation = nil;
    }
}

- (void)startOperationFromOffset:(unsigned long long)requestedOffset length:(unsigned long long)requestedLength{
    
    [self cancelAllPendingRequests];
    [self cancelOperations];
    
    __weak typeof (self) weakSelf = self;
        
    void(^failureBlock)(NSError *error) = ^(NSError *error) {
        [weakSelf performBlockOnMainThreadSync:^{
            if(weakSelf && weakSelf.isCancelled==NO){
                [weakSelf completeWithError:error];
            }
        }];
    };
    
    void(^loadDataBlock)(unsigned long long off, unsigned long long len) = ^(unsigned long long offset,unsigned long long length){
        
        [weakSelf performBlockOnMainThreadSync:^{

            NSString *bytesString = [NSString stringWithFormat:@"bytes=%lld-%lld",offset,(offset+length-1)];
            NSDictionary *params = @{@"Range":bytesString};
            
            id<YDSessionRequest> req = [weakSelf.session partialContentForFileAtPath:weakSelf.path withParams:params response:nil data:^(UInt64 recDataLength, UInt64 totDataLength, NSData *recData) {
                [weakSelf performBlockOnMainThreadSync:^{
                    if(weakSelf && weakSelf.isCancelled==NO){
                        LSDataResonse *dataResponse = [LSDataResonse responseWithRequestedOffset:offset requestedLength:length receivedDataLength:recDataLength data:recData];
                        [weakSelf didReceiveDataResponse:dataResponse];
                    }
                }];
                
            } completion:^(NSError *err) {
                if(err){
                    failureBlock(err);
                }
            }];

            weakSelf.dataOperation = req;
        }];
    };
    
    if(self.contentInformation==nil){
        
        self.contentInfoOperation = [self.session fetchStatusForPath:self.path completion:^(NSError *err, YDItemStat *item) {
            
            if(weakSelf && weakSelf.isCancelled==NO){
                if(err==nil){
                    
                    NSString *mimeType = item.path.mimeTypeForPathExtension;
                    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
                    unsigned long long contentLength = item.size;
                    
                    weakSelf.contentInformation = [[LSContentInformation alloc] init];
                    weakSelf.contentInformation.byteRangeAccessSupported = YES;
                    weakSelf.contentInformation.contentType = CFBridgingRelease(contentType);
                    weakSelf.contentInformation.contentLength = contentLength;
                    
                    [weakSelf prepareDataCache];
                    
                    loadDataBlock(requestedOffset,requestedLength);
                    
                    weakSelf.contentInfoOperation = nil;
                    
                }
                else{
                    failureBlock(err);
                }
            }
            
        }];

    }
    else{
        loadDataBlock(requestedOffset,requestedLength);
    }
    
}

#pragma mark - Data Load Callback`s

- (void)didReceiveDataResponse:(LSDataResonse *)dataResponse{
    
    [self cacheDataResponse:dataResponse];
   
    self.receivedDataLength=dataResponse.currentOffset;
    
    [self processPendingRequests];
    
    if(self.receivedDataLength>=self.contentInformation.contentLength){
        [self performBlockOnMainThreadAsync:^{
            if([self.delegate respondsToSelector:@selector(filePlayerResourceLoader:didLoadResource:)]){
                [self.delegate filePlayerResourceLoader:self didLoadResource:self.resourceURL];
            }
        }];
    }
}

- (void)processPendingRequests{
    NSMutableArray *requestsCompleted = [[NSMutableArray alloc] init];
    for (AVAssetResourceLoadingRequest *loadingRequest in self.pendingRequests){
        [self fillInContentInformation:loadingRequest.contentInformationRequest];
        BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest.dataRequest];
        if (didRespondCompletely){
            [loadingRequest finishLoading];
            [requestsCompleted addObject:loadingRequest];
        }
    }
    [self.pendingRequests removeObjectsInArray:requestsCompleted];
}

- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingDataRequest *)dataRequest{
    
    long long startOffset = dataRequest.requestedOffset;
    if (dataRequest.currentOffset != 0){
        startOffset = dataRequest.currentOffset;
    }
    
    // Don't have any data at all for this request
    if (self.receivedDataLength < startOffset){
        return NO;
    }
    
    // This is the total data we have from startOffset to whatever has been downloaded so far
    NSUInteger unreadBytes = self.receivedDataLength - startOffset;
    
    // Respond with whatever is available if we can't satisfy the request fully yet
    NSUInteger numberOfBytesToRespondWith = MIN(dataRequest.requestedLength, unreadBytes);
    
    BOOL didRespondFully = NO;

    NSData *data = [self readCachedData:startOffset length:numberOfBytesToRespondWith];

    if(data){
        [dataRequest respondWithData:data];
        long long endOffset = startOffset + dataRequest.requestedLength;
        didRespondFully = self.receivedDataLength >= endOffset;
    }

    return didRespondFully;
}

- (void)fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest *)contentInformationRequest{
    if (contentInformationRequest == nil || self.contentInformation == nil){
        return;
    }
    contentInformationRequest.byteRangeAccessSupported = self.contentInformation.byteRangeAccessSupported;
    contentInformationRequest.contentType = self.contentInformation.contentType;
    contentInformationRequest.contentLength = self.contentInformation.contentLength;
}

- (void)processPendingRequestsWithError:(NSError *)error{
    for (AVAssetResourceLoadingRequest *loadingRequest in self.pendingRequests){
        if(loadingRequest.isFinished==NO){
            [loadingRequest finishLoadingWithError:error];
        }
    }
    [self.pendingRequests removeAllObjects];
}

- (void)completeWithError:(NSError *)error{
    [self processPendingRequestsWithError:error];
    [self complete];
    
    [self performBlockOnMainThreadAsync:^{
        if([self.delegate respondsToSelector:@selector(filePlayerResourceLoader:didFailWithError:)]){
            [self.delegate filePlayerResourceLoader:self didFailWithError:error];
        }
    }];
}

#pragma mark - Data Caching

+ (NSString *)tempDirectoryPath{
    return NSTemporaryDirectory();
}

+ (NSString*)pathForTemporaryFile{
    return [[[self class] tempDirectoryPath] stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.%@", [NSString uuidString],@"tmp"]];
}

- (void)prepareDataCache{
    
    self.cachedFilePath = [[self class] pathForTemporaryFile];

    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.cachedFilePath] == YES){
        [[NSFileManager defaultManager] removeItemAtPath:self.cachedFilePath error:&error];
    }
    
    if (error == nil && [[NSFileManager defaultManager] fileExistsAtPath:self.cachedFilePath] == NO) {
        NSString *dirPath = [self.cachedFilePath stringByDeletingLastPathComponent];
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        
        if (error == nil) {
            [[NSFileManager defaultManager] createFileAtPath:self.cachedFilePath
                                                    contents:nil
                                                  attributes:nil];
            
            
            self.writingFileHandle = [NSFileHandle fileHandleForWritingAtPath:self.cachedFilePath];
            
            @try {
                [self.writingFileHandle truncateFileAtOffset:self.contentInformation.contentLength];
                [self.writingFileHandle synchronizeFile];
            }
            @catch (NSException *exception) {
                NSLog(@"write to file error");
                NSError *error = [[NSError alloc] initWithDomain:LSFilePlayerResourceLoaderErrorDomain
                                                            code:-1
                                                        userInfo:@{NSLocalizedDescriptionKey:@"can not write to file"}];
                [self completeWithError:error];
                return;
            }
            
            self.readingFileHandle = [NSFileHandle fileHandleForReadingAtPath:self.cachedFilePath];
        }
    }
    
    if (error != nil) {
        [self completeWithError:error];
    }
    
}

- (void)clearDataCache{
    if (self.writingFileHandle != nil){
        [self.writingFileHandle closeFile];
        self.writingFileHandle = nil;
    }
    if (self.readingFileHandle != nil){
        [self.readingFileHandle closeFile];
        self.readingFileHandle = nil;
    }
    if (self.cachedFilePath != nil && [[NSFileManager defaultManager] fileExistsAtPath:self.cachedFilePath]){
        [[NSFileManager defaultManager] removeItemAtPath:self.cachedFilePath error:nil];
    }
}

- (NSData *)readCachedData:(unsigned long long)startOffset length:(unsigned long long)numberOfBytesToRespondWith{
    @try {
        [self.readingFileHandle seekToFileOffset:startOffset];
        NSData *data = [self.readingFileHandle readDataOfLength:numberOfBytesToRespondWith];
        return data;
    }
    @catch (NSException *exception) {
        NSLog(@"read cached data error %@",exception);
    }
    return nil;
}

- (void)cacheDataResponse:(LSDataResonse *)dataResponse{
    unsigned long long offset = dataResponse.dataOffset;
    @try {
        [self.writingFileHandle seekToFileOffset:offset];
        [self.writingFileHandle writeData:dataResponse.data];
        [self.writingFileHandle synchronizeFile];
    }
    @catch (NSException *exception) {
        NSLog(@"write to file error");
        NSError *error = [[NSError alloc] initWithDomain:LSFilePlayerResourceLoaderErrorDomain
                                                    code:-1
                                                userInfo:@{NSLocalizedDescriptionKey:@"can not write to file"}];
        [self completeWithError:error];
    }
}

@end
