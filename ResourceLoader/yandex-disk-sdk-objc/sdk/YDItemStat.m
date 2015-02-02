/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDItemStat.h"
#import "YDConstants.h"
#import "YDSession.h"
#import "YDFileListRequest.h"
#import "NSNotificationCenter+Additions.h"


@interface YDItemStat ()

@property (nonatomic, weak, readwrite) YDSession *session;
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSString *path;
@property (nonatomic, copy, readwrite) NSString *mimeType;
@property (nonatomic, copy, readwrite) NSString *eTag;
@property (nonatomic, strong, readwrite) NSURL *publicURL;
@property (nonatomic, strong, readwrite) NSDate *mTime;
@property (nonatomic, assign, readwrite) unsigned long long size;
@property (nonatomic, assign, readwrite) BOOL isFile;
@property (nonatomic, assign, readwrite) BOOL isDirectory;
@property (nonatomic, assign, readwrite) BOOL isShare;
@property (nonatomic, assign, readwrite) BOOL isReadOnly;

@end


@implementation YDItemStat

- (instancetype)initWithSession:(YDSession *)s
                     dictionary:(NSDictionary *)propValues
                            URL:(NSURL *)url
{
    self = [super init];
    if (self) {
        NSMutableDictionary * errors = [NSMutableDictionary dictionary];

        _session = s;
        NSNumber *resourceTypeNum = propValues[[[YDFileListRequest resourceTypeProp] fullname]];
        if (resourceTypeNum == nil) errors[@"resourceType"] = @"ResourceType field missing.";

        _isDirectory = resourceTypeNum.intValue == YDWebDAVResourceTypeCollection;
        _isFile = !_isDirectory;

        _name = [propValues[[[YDFileListRequest displayNameProp] fullname]] copy];
        if (_name == nil) errors[@"displayName"] = @"DisplayName field missing.";

        _publicURL = [NSURL URLWithString:propValues[[[YDFileListRequest publicUrlProp] fullname]]];

        _path = [url.path copy];
        if (_isDirectory && [_path hasSuffix:@"/"] == NO) _path = [_path stringByAppendingString:@"/"];

        NSString *readonlyPropValueStr = propValues[[[YDFileListRequest readonlyProp] fullname]];
        _isReadOnly = [[readonlyPropValueStr lowercaseString] isEqualToString:@"true"];

        NSString *sharedPropValueStr = propValues[[[YDFileListRequest sharedProp] fullname]];
        _isShare = [sharedPropValueStr.lowercaseString isEqualToString:@"true"];

        if (_isFile) {
            _mimeType = [propValues[[[YDFileListRequest contentTypeProp] fullname]] copy];
            if (_mimeType == nil) errors[@"contentType"] = @"ContentType field missing.";

            NSNumber *sizeNum = propValues[[[YDFileListRequest contentLengthProp] fullname]];
            if (sizeNum == nil) errors[@"contentLength"] = @"ContentLength field missing.";
            _size = sizeNum.unsignedLongLongValue;

            _mTime = propValues[[[YDFileListRequest lastModifiedProp] fullname]];
            if (_mTime == nil) errors[@"lastModified"] = @"LastModified field missing.";

            _eTag = [propValues[[[YDFileListRequest eTagProp] fullname]] copy];
            if (_eTag == nil) errors[@"eTag"] = @"ETag field missing.";
        }

        if (errors.count>0) {
            errors[@"abstract"] = @"Bad WebDAV response.";
            NSError *error = [NSError errorWithDomain:kYDSessionBadResponseErrorDomain
                                                 code:0
                                             userInfo:errors];
            NSDictionary *userInfo = @{@"error": error};
            [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionResponseError
                                                                               object:self
                                                                             userInfo:userInfo];
            NSAssert(NO, @"Bad WebDAV response.");
        }
    }
    return self;
}

@end
