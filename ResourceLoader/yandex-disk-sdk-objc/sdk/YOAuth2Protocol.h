/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import <Foundation/Foundation.h>
#import "YOAuth2Delegate.h"

/**
 @abstract Common interface for Authentication View on iOS and OSX.

 @discussion
 This protocol represents the common interface of YOAuth2ViewController and YOAuth2WondowController.
 */
@protocol YOAuth2Protocol <NSObject>

/**
 @abstract Delegate for the authentication process.
 */
@property (nonatomic, weak) id<YOAuth2Delegate> delegate;

/**
 @abstract After suffessful authentication, this property contains the OAuth2 token that can be used with the registered Yandex web services.
 */
@property (nonatomic, copy, readonly) NSString *token;

@end
