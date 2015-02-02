/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "YOAuth2Protocol.h"


@interface YOAuth2WindowController : NSWindowController <YOAuth2Protocol, NSWindowDelegate>

@property (nonatomic, weak) WebView *webView;

@end
