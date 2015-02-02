/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import <Foundation/Foundation.h>


@protocol YOAuth2Delegate <NSObject>

/**
 @abstract The OAuth client ID of the delegate.

 @discussion
 The delegate returns the client ID, during registration of the application at:
 [Yandex OAuth app registration page]( https://oauth.yandex.ru/client/new )

 @return
 This applications OAuth client ID.
 */
- (NSString *)clientID;

/**
 @abstract The redirect URL of the delegate which should be used during OAuth authorization.

 @discussion
 The delegate returns the redirect URL which was provided during registration of the application at:
 [Yandex OAuth app registration page]( https://oauth.yandex.ru/client/new )

 @return
 This applications OAuth redirect URL.
 */
- (NSString *)redirectURL;

/**
 @abstract Callback for successful authentication

 @discussion
 This method is called on the delegate in the event of successful authentication.
 
 @param token
    The OAuth token recieved during authentication.
 */
- (void)OAuthLoginSucceededWithToken:(NSString *)token;

/**
 @abstract Callback for failed authentication

 @discussion
 This method is called on the delegate in the event of failed authentication.

 @param error
    Error information.
 */
- (void)OAuthLoginFailedWithError:(NSError *)error;

@end
