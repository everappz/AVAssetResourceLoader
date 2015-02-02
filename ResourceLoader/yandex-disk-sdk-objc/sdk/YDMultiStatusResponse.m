/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDMultiStatusResponse.h"
#import "YDPropstatResponse.h"

@implementation YDMultiStatusResponse

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithCapacity:0];
    [description appendFormat:@"%@, URL:%@\nPropstats: (\n", super.description, self.URL];

    for (NSObject *propstatResponse in self.propstats) {
        [description appendFormat:@"%@\n", propstatResponse.description];
    }

    [description appendString:@"\n"];

    return description;
}

#pragma mark - Public

/* Returns prop values which returned with status code 200 */
- (NSDictionary *)successPropValues
{
    NSDictionary *propValues = nil;

    NSUInteger index = [self.propstats indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        *stop = ([obj statusCode] == 200);
        return *stop;
    }];
    if (index != NSNotFound) {
        propValues = [self.propstats[index] propValues];
    }

    return  propValues;
}

/* Returns prop values which returned with status code ≠ 200 */
- (NSDictionary *)failPropValues
{
    NSMutableDictionary *propValues = nil;

    NSIndexSet *indexes = [self.propstats indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        *stop = ([obj statusCode] == 200);
        return *stop;
    }];

    NSUInteger index = indexes.firstIndex;
    if (index != NSNotFound) {
        propValues = [NSMutableDictionary dictionaryWithCapacity:0];
    }

    while(index != NSNotFound) {
        [propValues addEntriesFromDictionary:[self.propstats[index] propValues]];
        index = [indexes indexGreaterThanIndex:index];
    }

    return  propValues;
}

@end
