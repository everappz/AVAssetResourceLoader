/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDMultistatusRequest.h"


@interface YDPROPPATCHRequest : YDMultistatusRequest

/**
 Fill this array with YDPPProp.

 This should be configured before starting request.
 */
@property (nonatomic, copy) NSArray *props;

@end
