/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDDiskPOSTRequest.h"


@implementation YDDiskPOSTRequest

// because parent class build cached requests
- (NSURLRequest *)buildRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];

    [self prepareRequest:request];

    return request;
}

- (void)prepareRequest:(NSMutableURLRequest *)request
{
    [super prepareRequest:request];

    [request setHTTPMethod:@"POST"];
}

@end
