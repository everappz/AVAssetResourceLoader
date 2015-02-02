/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDWebDAVCommon.h"


NSString *YDWebDAVDepthStringRepresentation(YDWebDAVDepth depth)
{
    NSString *result;

    switch (depth) {
        default:
        case YDWebDAVDepth0:
            result = @"0";
            break;

        case YDWebDAVDepth1:
            result = @"1";
            break;
    }

    return result;

}

DDXMLNode *YDWebDAVDefaultDAVXMLNamespace()
{
    return [DDXMLNode namespaceWithName:@"D" stringValue:@"DAV:"];
}

DDXMLNode *YDWebDAVDefaultYandexXMLNamespace()
{
    return [DDXMLNode namespaceWithName:@"Y" stringValue:@"urn:yandex:disk:meta"];
}
