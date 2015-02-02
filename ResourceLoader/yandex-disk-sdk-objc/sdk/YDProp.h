/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import <Foundation/Foundation.h>
#import "DDXML.h"


/**
 * This class contains info about the Prop (namespace, name)
 * and the method for extracting value for this Prop.
 *
 * Subclass it if your Prop has a different value type (for example, this class extract only string values)
 */

@interface YDProp : NSObject

@property (nonatomic, copy, readonly) DDXMLNode *namespace;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *fullname;

+ (instancetype)propWithName:(NSString *)name xmlns:(DDXMLNode *)namespace;

/**
 * method for extracting value for this Prop.
 */
- (id)valueForXMLElement:(DDXMLElement *)xmlElement;

@end
