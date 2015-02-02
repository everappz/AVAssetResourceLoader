/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDFileUploadRequest.h"


@interface YDFileUploadRequest ()

@property (nonatomic, assign) UInt64 fileSize;

@end


@implementation YDFileUploadRequest


- (void)prepareRequest:(NSMutableURLRequest *)request
{
    [super prepareRequest:request];
    
    self.fileSize = [[NSFileManager.defaultManager attributesOfItemAtPath:self.localURL.path error:nil] fileSize];
   
    NSInputStream *is = [[NSInputStream alloc] initWithFileAtPath:self.localURL.path];
    
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBodyStream:is];
    [request setValue:self.md5 forHTTPHeaderField: @"Etag"];
    [request setValue:self.sha256 forHTTPHeaderField: @"Sha256"];
    [request setValue:@"100-continue" forHTTPHeaderField: @"Expect"];

    [request setValue:[NSString stringWithFormat:@"%lld", self.fileSize]
       forHTTPHeaderField:@"Content-Length"];
}

- (BOOL)acceptResponseCode:(NSUInteger)statusCode
{
    return statusCode == 201 || statusCode == 409;
}

- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request
{
    NSInputStream *is = [[NSInputStream alloc] initWithFileAtPath:self.localURL.path];
    return is;
}

@end
