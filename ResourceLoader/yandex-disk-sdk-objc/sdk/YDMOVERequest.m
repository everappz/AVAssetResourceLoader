/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDMOVERequest.h"

@implementation YDMOVERequest

- (void)prepareRequest:(NSMutableURLRequest *)request
{
    [super prepareRequest:request];

    [request setHTTPMethod:@"MOVE"];

    if (self.destination.length > 0) {
        [request setValue:self.destination forHTTPHeaderField:@"Destination"];
    }
}

- (BOOL)acceptResponseCode:(NSUInteger)statusCode
{
    // Accept only 201 code
    return (statusCode == 201);
}

@end
