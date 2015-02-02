/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDResourceTypeProp.h"
#import "YDWebDAVCommon.h"

@implementation YDResourceTypeProp

- (id)valueForXMLElement:(DDXMLElement *)xmlElement
{
    NSString *webDAVNamespaceStr = [YDWebDAVDefaultDAVXMLNamespace() stringValue];

    if ([xmlElement elementsForLocalName:@"collection" URI:webDAVNamespaceStr].count > 0) {
        return @(YDWebDAVResourceTypeCollection);
    }

    return @(YDWebDAVResourceTypeNone);
}

@end
