/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDPropstatResponse.h"


@implementation YDPropstatResponse

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, Propvalues:\n%@", super.description, self.propValues];
}

@end
