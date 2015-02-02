/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDProp.h"
#import "DDXML.h"


typedef enum {
    YDWebDAVPROPPATCHTypeSet,
    YDWebDAVPROPPATCHTypeRemove
} YDWebDAVPROPPATCHType;


@interface YDPROPPATCHProp : YDProp

+ (instancetype)propWithName:(NSString *)_name xmlns:(DDXMLNode *)_namespace type:(YDWebDAVPROPPATCHType)_type;

@property (nonatomic, assign, readonly) YDWebDAVPROPPATCHType type;

/**
 * method for extracting xml for value of this Prop.
 */
- (DDXMLElement *)XMLElementForValue;

@end
