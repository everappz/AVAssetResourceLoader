/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDDiskRequest.h"
#import "YDMultiStatusResponse.h"


@interface YDMultistatusRequest : YDDiskRequest

/** @name Things that you may configure at any time */

@property (copy) void (^didReceiveMultistatusResponsesBlock)(NSArray *responses);

/** @name Properties that are meaningful after finishing of request */

/* Contains multistatus response for each file. */
@property (nonatomic, copy) NSArray *multistatusResponses;

- (YDMultiStatusResponse *)multistatusResponseForXMLElement:(DDXMLElement *)element;

@end
