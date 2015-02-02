/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import <Foundation/Foundation.h>

@protocol YDSessionDelegate <NSObject>

/**
 @abstract The user agent name of the delegate.

 @discussion
 This user agent will be used as UserAgent in HTTP headers when communicating with the cloud.

 @return
    This applications user agent string.
 */
- (NSString *)userAgent;

@end
