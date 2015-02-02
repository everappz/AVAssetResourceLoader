/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDProp.h"

@interface YDProp ()

@property (nonatomic, copy, readwrite) DDXMLNode *namespace;
@property (nonatomic, copy, readwrite) NSString *name;

@end


@implementation YDProp

- (instancetype)initWithName:(NSString *)name xmlns:(DDXMLNode *)namespace
{
    self = [super init];
    if (self) {
        _name = [name copy];
        _namespace = [namespace copy];
    }
    return self;
}

+ (instancetype)propWithName:(NSString *)name xmlns:(DDXMLNode *)namespace
{
    return [[self.class alloc] initWithName:name xmlns:namespace];
}

- (NSString *)fullname
{
    NSString *namespaceStr = self.namespace.stringValue;

    if ([namespaceStr hasSuffix:@":"]) {
        namespaceStr = [namespaceStr substringToIndex:namespaceStr.length - 1];
    }

    return [namespaceStr stringByAppendingFormat:@":%@", self.name];
}

- (id)valueForXMLElement:(DDXMLElement *)xmlElement
{
    return xmlElement.stringValue;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, Prop < %@ >", super.description, self.fullname];
}

@end
