/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDDateRFC822Prop.h"

@implementation YDDateRFC822Prop

- (NSDateFormatter *)rfc822DateFormatter
{
    static NSDateFormatter *rfc822DateFormatter = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rfc822DateFormatter = [[NSDateFormatter alloc] init];
        [rfc822DateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [rfc822DateFormatter setDateFormat:@"EEE',' dd MMM yyyy HH:mm:ss zzz"];
        [rfc822DateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    });

    return rfc822DateFormatter;
}

- (id)valueForXMLElement:(DDXMLElement *)xmlElement
{
    NSDate *result = nil;
    @synchronized([self class]) {
        result = [self.rfc822DateFormatter dateFromString:xmlElement.stringValue];
    }
    return result;
}

@end
