/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDPROPPATCHProp.h"

@interface YDPROPPATCHProp ()

@property (nonatomic, assign, readwrite) YDWebDAVPROPPATCHType type;

@end


@implementation YDPROPPATCHProp

+ (instancetype)propWithName:(NSString *)_name xmlns:(DDXMLNode *)_namespace type:(YDWebDAVPROPPATCHType)_type
{
    YDPROPPATCHProp *prop = [super propWithName:_name xmlns:_namespace];

    prop.type = _type;
    return prop;
}

- (DDXMLElement *)XMLElementForValue
{
    return nil;
}

@end
