/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDPROPFINDRequest.h"
#import "YDProp.h"
#import "YDLongLongProp.h"
#import "YDDateRFC822Prop.h"


@interface YDFileListRequest : YDPROPFINDRequest

+ (YDProp *)displayNameProp;
+ (YDLongLongProp *)contentLengthProp;
+ (YDDateRFC822Prop *)lastModifiedProp;
+ (YDProp *)eTagProp;
+ (YDProp *)readonlyProp;
+ (YDProp *)sharedProp;
+ (YDProp *)contentTypeProp;
+ (YDProp *)publicUrlProp;

@end
