/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDFileListRequest.h"

@implementation YDFileListRequest


#pragma mark - Object lifecycle

- (void)dealloc
{
    self.didReceiveMultistatusResponsesBlock = nil;
}


#pragma mark - Default Props

+ (YDProp *)displayNameProp
{
    return [YDProp propWithName:@"displayname" xmlns:YDWebDAVDefaultDAVXMLNamespace()];
}

+ (YDLongLongProp *)contentLengthProp
{
    return [YDLongLongProp propWithName:@"getcontentlength" xmlns:YDWebDAVDefaultDAVXMLNamespace()];
}

+ (YDDateRFC822Prop *)lastModifiedProp
{
    return [YDDateRFC822Prop propWithName:@"getlastmodified" xmlns:YDWebDAVDefaultDAVXMLNamespace()];
}

+ (YDProp *)eTagProp
{
    return [YDProp propWithName:@"getetag" xmlns:YDWebDAVDefaultDAVXMLNamespace()];
}

+ (YDProp *)readonlyProp
{
    return [YDProp propWithName:@"readonly" xmlns:YDWebDAVDefaultYandexXMLNamespace()];
}

+ (YDProp *)sharedProp
{
    return [YDProp propWithName:@"shared" xmlns:YDWebDAVDefaultYandexXMLNamespace()];
}

+ (YDProp *)contentTypeProp
{
    return [YDProp propWithName:@"getcontenttype" xmlns:YDWebDAVDefaultDAVXMLNamespace()];
}

+ (YDProp *)publicUrlProp
{
    return [YDProp propWithName:@"public_url" xmlns:YDWebDAVDefaultYandexXMLNamespace()];
}

@end
