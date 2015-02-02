/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import <Foundation/Foundation.h>


@class YDSession;

/**
 @abstract Status information for a file or directory in the cloud.
 
 @discussion
 Objects of this type represent properties of a file or directory in the cloud.
 There is no meaning in creating them yourself, their sole purpose is to serve as a result type for YDSession methods.
 */
@interface YDItemStat : NSObject

@property (nonatomic, weak, readonly) YDSession *session;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, copy, readonly) NSString *mimeType;
@property (nonatomic, copy, readonly) NSString *eTag;
@property (nonatomic, strong, readonly) NSURL *publicURL;
@property (nonatomic, strong, readonly) NSDate *mTime;
@property (nonatomic, assign, readonly) unsigned long long size;
@property (nonatomic, assign, readonly) BOOL isFile;
@property (nonatomic, assign, readonly) BOOL isDirectory;
@property (nonatomic, assign, readonly) BOOL isShare;
@property (nonatomic, assign, readonly) BOOL isReadOnly;


/**
 @abstract Initialization

 @discussion
 This should not be used directly. This init method is used by YDSession.
 
 @param session
    The YDSession in which this item exists.
 @param properties
    A NSDictionary with WebDAV properties which will be assigned to the properties of this class.
 @param url
    The URL of this item.
 @return
    Returns an initialized instance of YDItemStat with all appropriate properties set. Returns nil in case an error occurred.
 */
- (instancetype)initWithSession:(YDSession *)session
                     dictionary:(NSDictionary *)properties
                            URL:(NSURL *)url;


@end
