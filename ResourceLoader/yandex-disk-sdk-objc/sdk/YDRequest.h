/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import <Foundation/Foundation.h>


typedef NSURLRequest *(^YORequestShouldRedirectBlock)(NSURLResponse *response, NSURLRequest *redirectURLRequest);
typedef void (^YORequestDidReceiveResponseBlock)(NSURLResponse *response, BOOL *accept);
typedef void (^YORequestDidGetPartialDataBlock)(UInt64 receivedDataLength, UInt64 expectedDataLength, NSData *data);
typedef void (^YORequestDidSendBodyDataBlock)(UInt64 totalBytesWritten, UInt64 totalBytesExpectedToWrite);
typedef void (^YORequestDidFinishLoadingBlock)(NSData *receivedData);
typedef void (^YORequestDidFailBlock)(NSError *error);


@interface YDRequest : NSObject

- (instancetype)initWithURL:(NSURL *)theURL;

- (void)start;
- (void)cancel;
- (BOOL)isCancelled;

/** @name Things that are configured by the init method and can't be changed */

@property (nonatomic, strong, readonly) NSURL *URL;

/** @name Things that can be tuned before starting request */

@property (nonatomic, copy) NSString *OAuthToken;
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, copy) NSDictionary *params;
@property (nonatomic, assign)BOOL skipReceivedData;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/** @name Things that you may configure at any time */

// Dispatch queue that used for callback blocks. Main queue used by default.
@property (unsafe_unretained) dispatch_queue_t callbackQueue;

@property (copy) YORequestShouldRedirectBlock shouldRedirectBlock;
@property (copy) YORequestDidReceiveResponseBlock didReceiveResponseBlock;
@property (copy) YORequestDidGetPartialDataBlock didGetPartialDataBlock;
@property (copy) YORequestDidSendBodyDataBlock didSendBodyData;
@property (copy) YORequestDidFinishLoadingBlock didFinishLoadingBlock;
@property (copy) YORequestDidFailBlock didFailBlock;

/** @name Things that are only meaningful after the response received. */

@property (nonatomic, copy, readonly) NSURLRequest *lastRequest;
@property (nonatomic, strong, readonly) NSHTTPURLResponse *lastResponse;

/** @name Things that are only meaningful after the request is finished. */

@property (nonatomic, strong, readonly) NSMutableData *receivedData;

@end

/** @name Private category (should be in separate file) */

@interface YDRequest (Private)
- (NSURLRequest *)buildRequest;
- (void)prepareRequest:(NSMutableURLRequest *)request;
- (NSData *)buildHTTPBody;
- (BOOL)acceptResponseCode:(NSUInteger)statusCode;
- (void)processReceivedData;
@end

typedef enum {
    YDRequestErrorCodeUnknown,
    YDRequestErrorCodeWrongResponseStatusCode,
    YDRequestErrorCodeFileIO,
} YDRequestErrorCode;
