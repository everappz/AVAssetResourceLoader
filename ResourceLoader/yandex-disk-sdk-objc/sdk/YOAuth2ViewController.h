/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import <UIKit/UIKit.h>
#import "YOAuth2Protocol.h"


@interface YOAuth2ViewController : UIViewController <YOAuth2Protocol, UIWebViewDelegate>

- (instancetype)initWithDelegate:(id<YOAuth2Delegate>)delegate;

@end
