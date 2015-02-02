/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import <Foundation/Foundation.h>


@interface NSNotificationCenter (Additions)

- (void)postNotificationInMainQueueWithName:(NSString *)aName
                                     object:(id)anObject
                                   userInfo:(NSDictionary *)aUserInfo;

@end
