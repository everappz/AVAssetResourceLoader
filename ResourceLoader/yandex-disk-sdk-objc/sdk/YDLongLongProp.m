/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDLongLongProp.h"

@implementation YDLongLongProp

- (id)valueForXMLElement:(DDXMLElement *)xmlElement
{
    return @(xmlElement.stringValue.longLongValue);
}

@end
