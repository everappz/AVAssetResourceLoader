/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDDiskRequest.h"
#import "NSNotificationCenter+Additions.h"
#import "YDConstants.h"


@interface YDRequest ()

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

@end


@implementation YDDiskRequest

- (void)prepareRequest:(NSMutableURLRequest *)request
{
    [super prepareRequest:request];

    [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
}

- (void)connection:(NSURLConnection *)con didReceiveResponse:(NSURLResponse *)response
{
    [super connection:con didReceiveResponse:response];

    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];

    if (statusCode != 401) {
        return;
    }

    NSInteger errorCode = kYDSessionErrorUnknown;

    NSString *errorLocalizedDescription = @"AuthAuthorizationUnknownErrorText";

    NSError *error = [NSError errorWithDomain:kYDSessionConnectionErrorDomain
                                         code:errorCode
                                     userInfo:@{NSLocalizedDescriptionKey: errorLocalizedDescription}];

    NSDictionary *userInfo = @{@"error": error};
    [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionConnectionDidFailAuthenticateWithError
                                                                       object:self
                                                                     userInfo:userInfo];

    YDLog(@"Error authenticating: %ld %@", (long)statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
}

@end
