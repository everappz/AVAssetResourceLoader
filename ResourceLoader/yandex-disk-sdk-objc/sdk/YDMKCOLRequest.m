/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDMKCOLRequest.h"

@implementation YDMKCOLRequest

- (void)prepareRequest:(NSMutableURLRequest *)request
{
    [super prepareRequest:request];

    [request setHTTPMethod:@"MKCOL"];
}

- (BOOL)acceptResponseCode:(NSUInteger)statusCode
{
    // Accept only 201 code
    return (statusCode == 201);
}

@end
