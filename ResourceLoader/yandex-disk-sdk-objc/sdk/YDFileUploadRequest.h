/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDDiskRequest.h"


@interface YDFileUploadRequest : YDDiskRequest

@property (nonatomic, strong) NSURL *localURL;
@property (nonatomic, copy) NSString *md5;
@property (nonatomic, copy) NSString *sha256;


@end
