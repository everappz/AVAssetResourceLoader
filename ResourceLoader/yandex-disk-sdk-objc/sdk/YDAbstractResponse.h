/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import <Foundation/Foundation.h>


@interface YDAbstractResponse : NSObject

@property (nonatomic, assign) NSUInteger statusCode;
@property (nonatomic, copy) NSString *responseDescription;

@end
