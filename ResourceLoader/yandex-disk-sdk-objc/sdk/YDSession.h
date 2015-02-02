/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import <Foundation/Foundation.h>
#import "YDItemStat.h"
#import "YDSessionDelegate.h"


/**
 @abstract Completion block for fetchStatusForPath:completion: .
 
 @discussion
 A block with this signature is called by fetchStatusForPath:completion: when either completed successfully, or if any error occurred.
 On success, list contains and NSArray of YDItemStat objects.
 If an error occurred the err parameter is not nil and contains information about the error.

 @param err
    Error information or nil.
 @param list
    The result in form of an NSArray of YDItemStat items, or nil.
 */
typedef void (^YDFetchDirectoryHandler)(NSError *err, NSArray *list);

/**
 @abstract Completion block for fetchStatusForPath:completion: .

 @discussion
 A block with this signature is called by fetchStatusForPath:completion: when either completed successfully, or if any error occurred.
 On success, item contains the YDItemStat object for the requested object.
 If an error occurred the err parameter is not nil and contains information about the error.

 @param err
    Error information or nil.
 @param item
    The result in form of an YDItemStat item, or nil.
 */
typedef void (^YDFetchStatusHandler)(NSError *err, YDItemStat *item);

/**
 @abstract Completion block for publishPath:completion: .

 @discussion
 A block with this signature is called by publishPath:completion: when either completed successfully, or if any error occurred.
 On success, url contains an URL which can be used to access the published object.
 If an error occurred the err parameter is not nil and contains information about the error.
 
 @param err
    Error information or nil.
 @param url
    An URL which allows public access to the published object, or nil.
 */
typedef void (^YDPublishHandler)(NSError *err, NSURL *url);

/**
 @abstract Completion block used by several methods of YDSession.
 
 @discussion
 A block with this signature is called by several of methods of YDSession to signal whether or not the method finished execution successful.
 On success err is nil, otherwise it contains information about the error which occurred.

 @param err
    Error information or nil.
 */
typedef void (^YDHandler)(NSError *err);

typedef void (^YDUserLoginHandler)(NSError *err, NSString *login);

typedef void (^YDProgressHandler)(UInt64 totalBytesWritten, UInt64 totalBytesExpectedToWrite);

typedef void (^YDPartialDataHandler)(UInt64 receivedDataLength, UInt64 totalDataLength, NSData *data);

typedef void (^YDDidReceiveResponseHandler)(NSURLResponse *response);

typedef void (^YDDidFinishLoadingHandler)(void);



@protocol YDSessionRequest <NSObject>

- (void)cancel;

@end

/**
 @abstract Session object to access Yandex Disk.

 @discussion
 This class is a wrapper around the Yandex Disk Cloud API.

 Using this class saves the trouble of implementing WebDAV and OAuth2.0 authentication.
 
 The methods of this class makes it easy to:
 - authenticate,
 - list directory content,
 - access file information,
 - up- and download files,
 - publish and unpublish files stored in Yandex Disk

 To use this class you first have to register your app at:
 - [Yandex OAuth app registration page]( https://oauth.yandex.ru/client/new )

 More information about the implemented API can be found at:
 - the [Yandex Disk API page]( http://api.yandex.ru/disk/ )
 - and [Yandex OAuth2 API page]( http://api.yandex.ru/oauth/ ).

 This implementation requires ARC!
 */
@interface YDSession : NSObject

@property (nonatomic, copy) NSString *OAuthToken;
@property (nonatomic, weak) id<YDSessionDelegate> delegate;
@property (nonatomic, readonly) BOOL authenticated;


/**
 @abstract Initialize the Session object

 @param delegate
    A delegate as described in YDSessionDelegate.
 @return
    An initialized YDSession object or nil.
 */
- (instancetype)initWithDelegate:(id<YDSessionDelegate>)delegate callBackQueue:(dispatch_queue_t)queue;

/**
 @abstract Fetches the content of a directory in the cloud.
 
 @discussion
 This makes a WebDAV STAT request with recursion depth of 1, and returns an NSArray of YDStatItems as results to the completion handler.

 Notifications sent by this method:
 - kYDSessionDidFailWithFetchDirectoryRequestNotification
 
 @param path
    A NSString in the format @"/path/to/directory", describing a directory inside Yandex Disk.
 @param block
    A handler block as described for YDFetchDirectoryHandler.
 */
- (id<YDSessionRequest>)fetchDirectoryContentsAtPath:(NSString *)path completion:(YDFetchDirectoryHandler)block;

/**
 @abstract Fetches the status of a file or directory in the cloud.
 
 @discussion
 This makes a WebDAV STAT request with recursion depth of 0, and returns the resulting YDStatItem to the completion handler.
                
 Notifications sent by this method:
 - kYDSessionDidFailWithFetchStatusRequestNotification
 
 @param path
    A NSString in the format @"/path/to/directory/or/file", describing a file or directory inside Yandex Disk.
 @param block
    A handler block as described for YDFetchStatusHandler.
 */
- (id<YDSessionRequest>)fetchStatusForPath:(NSString *)path completion:(YDFetchStatusHandler)block;

- (id<YDSessionRequest>)fetchUserLoginWithCompletion:(YDUserLoginHandler)block;

/**
 @abstract Creates a new directory in the cloud.
 
 @discussion
 This makes a WebDAV MKCOL request to create the desired directory in the cloud.

 The completion handler is called to signal the outcome of the operation.

 The parent directory has to exist, and only the last path element is newly created.
 
 Notifications sent by this method:
 - kYDSessionDidFailToCreateDirectoryNotification
 - kYDSessionDidCreateDirectoryNotification
 - kYDSessionDidSendCreateDirectoryRequestNotification

 @param path
    A NSString in the format @"/path/to/new/directory", describing the directory that should be created inside Yandex Disk.
 @param block
    A handler block as described for YDHandler.
 */
- (id<YDSessionRequest>)createDirectoryAtPath:(NSString *)path completion:(YDHandler)block;

/**
 @abstract Removes a file or directory from the cloud.

 @discussion
 This makes a WebDAV DELETE request to remove the object at the given path from the cloud.

 The completion handler is called to signal the outcome of the operation.
 
 Notifications sent by this method:
 - kYDSessionDidRemoveNotification
 - kYDSessionDidFailWithRemoveRequestNotification
 - kYDSessionDidSendRemoveRequestNotification

 @param path
    A NSString in the format @"/path/file.ext", describing the file or directory inside Yandex Disk which should be removed.
 @param block
    A handler block as described for YDHandler.
 */
- (id<YDSessionRequest>)removeItemAtPath:(NSString *)path completion:(YDHandler)block;

/**
 @abstract Moves a file or directory in the cloud to the trash.
 
 @discussion
 This makes a WebDAV DELETE request with some proprietary parameter to move the object at the given path to the trash folder in the cloud.
 
 Note that the trash can not be accessed via WebDAV or this SDK. The trash folder is available to the user only via the web interface.
 
 The completion handler is called to signal the outcome of the operation.
 
 Notifications sent by this method:
 - kYDSessionDidRemoveNotification
 - kYDSessionDidFailWithRemoveRequestNotification
 - kYDSessionDidSendRemoveRequestNotification

 @param path
    A NSString in the format @"/path/file.ext", describing a file or directory inside Yandex Disk which should be moved to trash.
 @param block
    A handler block as described for YDHandler.
 */
- (id<YDSessionRequest>)trashItemAtPath:(NSString *)path completion:(YDHandler)block;

/**
 @abstract Moves a file or directory in the cloud to a new location.

 @discussion
 This makes a WebDAV MOVE request to move the object at the given path to the new location specified by topath.

 The completion handler is called to signal the outcome of the operation.
 
 Notifications sent by this method:
 - kYDSessionDidMoveNotification
 - kYDSessionDidFailToMoveNotification
 - kYDSessionDidSendMoveRequestNotification
 
 @param path
    A NSString in the format @"/path/file.ext", describing a file or directory inside Yandex Disk which should be moved.
 @param topath
    A NSString in the format @"/path/new/file.ext", describing the target of the move operation inside Yandex Disk.
 @param block
    A handler block as described for YDHandler.
 */
- (id<YDSessionRequest>)moveItemAtPath:(NSString *)path toPath:(NSString *)topath completion:(YDHandler)block;

/**
 @abstract Uploads a new file into the cloud.

 @discussion
 This makes a WebDAV PUT request uploading the file from the given path to the given path in the cloud.
 The progress can be tracked by subscribing to kYDSessionDidSendPartialDataForFileNotification notifications.
 The completion handler is called to signal the outcome of the operation.
 
 Notifications sent by this method:
 - kYDSessionDidStartUploadFileNotification
 - kYDSessionDidFinishUploadFileNotification
 - kYDSessionDidSendPartialDataForFileNotification
 - kYDSessionDidFailUploadFileNotification

 @param file
    A NSString in the format @"/path/file.ext", describing a file in the local filesystem.
 @param path
    A NSString in the format @"/path/to/file.ext", describing the files name and location inside Yandex Disk.
 @param block
    A handler block as described for YDHandler.
 */
- (id<YDSessionRequest>)uploadFile:(NSString *)file toPath:(NSString *)path progress:(YDProgressHandler)progress completion:(YDHandler)block;

/**
 @abstract Downloads a new file from the cloud.
 
 @discussion
 This makes a WebDAV GET request, downloading the file from the given path in the cloud, to the local filesystem.

 The progress can be tracked by subscribing to kYDSessionDidGetPartialDataForFileNotification notifications.

 The completion handler is called to signal the outcome of the operation.
 
 Notifications sent by this method:
 - kYDSessionDidGetPartialDataForFileNotification
 - kYDSessionDidDownloadFileNotification
 - kYDSessionDidFailToDownloadFileNotification
 - kYDSessionDidStartDownloadFileNotification
 
 @param path
    A NSString in the format @"/path/to/file.ext", describing the files inside Yandex Disk.
 @param file
    A NSString in the format @"/path/file.ext", describing the name and location of the new file in the local filesystem.
 @param block
    A handler block as described for YDHandler.
 */
- (id<YDSessionRequest>)downloadFileFromPath:(NSString *)path toFile:(NSString *)file progress:(YDProgressHandler)progress completion:(YDHandler)block;


- (id<YDSessionRequest>)partialContentForFileAtPath:(NSString *)srcRemotePath
                                         withParams:(NSDictionary *)params
                                           response:(YDDidReceiveResponseHandler)response
                                               data:(YDPartialDataHandler)data
                                         completion:(YDHandler)completion;


/**
 @abstract      Publishes a file or directory by providing a valid public URL for it.

 @discussion
 This tells the servers that a file or directory should be shared to the public.
 If successful, the URL that allows to access the published resource is returned to the completion handler.

 The completion handler is called to signal the outcome of the operation.
 
 Notifications sent by this method:
 - kYDSessionDidPublishFileNotification
 - kYDSessionDidFailWithPublishRequestNotification
 
 @param path
    A NSString in the format @"/path/file.ext", describing a file or directory inside Yandex Disk which should be published.
 @param block
    A handler block as described for YDPublishHandler.
 */
- (id<YDSessionRequest>)publishItemAtPath:(NSString *)path completion:(YDPublishHandler)block;

/**
 @abstract      Unpublishes a file or directory by invalidating its public URL.

 @discussion
 This tells the servers that a file or directory should no longer be shared to the public.
 If successful, the URL that allowed to access the published resource is no longer valid.
 
 The completion handler is called to signal the outcome of the operation.
 
 Notifications sent by this method:
 - kYDSessionDidUnpublishFileNotification
 - kYDSessionDidFailWithUnpublishRequestNotification
 
 @param path
    A NSString in the format @"/path/file.ext", describing a file or directory inside Yandex Disk which should be unpublished.
 @param block
    A handler block as described for YDHandler.
 */
- (id<YDSessionRequest>)unpublishItemAtPath:(NSString *)path completion:(YDHandler)block;



@end
