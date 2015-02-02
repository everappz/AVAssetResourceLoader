/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDMultistatusRequest.h"
#import "YDWebDAVCommon.h"
#import "YDResourceTypeProp.h"


@interface YDPROPFINDRequest : YDMultistatusRequest

#pragma mark Properties that should be configured before starting request

/* Fill this array with property names that will be requested for this resource. */
@property (nonatomic, copy) NSArray *props;

/*
 * See WebDav depth description near the definition of YOWebDAVDepth type
 * PROPFIND request supports following depth values:
 *  • YOWebDAVDepth0,
 *  • YOWebDAVDepth1,
 *  • YOWebDAVDepthInfinity (not supported by Yandex.WebDAV).
 * By default YOWebDAVDepthInfinity value used.
 */
@property (nonatomic, assign) YDWebDAVDepth depth;

+ (YDResourceTypeProp *)resourceTypeProp;

@end
