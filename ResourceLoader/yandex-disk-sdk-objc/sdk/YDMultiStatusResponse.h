/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDAbstractResponse.h"


@interface YDMultiStatusResponse : YDAbstractResponse

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, copy) NSArray *propstats;

/* Returns prop values which returned with status code 200 */
- (NSDictionary *)successPropValues;
/* Returns prop values which returned with status code ≠ 200 */
- (NSDictionary *)failPropValues;

@end
