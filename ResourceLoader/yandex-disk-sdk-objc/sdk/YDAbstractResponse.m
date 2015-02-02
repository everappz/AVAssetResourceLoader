/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDAbstractResponse.h"

@implementation YDAbstractResponse

- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"%@, status code:%ld",
                             super.description, (unsigned long)self.statusCode];

    return description;
}

@end
