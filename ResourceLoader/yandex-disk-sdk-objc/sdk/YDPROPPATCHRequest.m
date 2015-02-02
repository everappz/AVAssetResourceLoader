/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDPROPPATCHRequest.h"
#import "YDPROPPATCHProp.h"
#import "YDWebDAVCommon.h"
#import "YDPropstatResponse.h"
#import "DDXMLElementAdditions.h"


@implementation YDPROPPATCHRequest

#pragma mark - Private

- (void)prepareRequest:(NSMutableURLRequest *)request
{
    [super prepareRequest:request];

    [request setHTTPMethod:@"PROPPATCH"];
}

- (BOOL)acceptResponseCode:(NSUInteger)statusCode
{
    return (statusCode == 207);
}

- (YDMultiStatusResponse *)multistatusResponseForXMLElement:(DDXMLElement *)element
{
    // Add propstats to the multistatus response.

    YDMultiStatusResponse *multistatusResponse = [super multistatusResponseForXMLElement:element];
    if (multistatusResponse == nil) {
        return nil;
    }

    DDXMLNode *webDAVNamespace = YDWebDAVDefaultDAVXMLNamespace();
    NSString *webDAVNamespaceStr = webDAVNamespace.stringValue;

    // Parts of response with property values and their own status codes
    NSArray *propstatElements = [element elementsForLocalName:@"propstat" URI:webDAVNamespaceStr];
    NSMutableArray *propstatResponses = [NSMutableArray arrayWithCapacity:0];
    for (DDXMLElement *propstatElement in propstatElements) {
        YDPropstatResponse *propstatResponse = [[YDPropstatResponse alloc] init];

        // Status code for propstat element
        DDXMLElement *statusElement = [propstatElement elementForName:@"status" xmlns:webDAVNamespaceStr];
        NSString *HTTPStatusStr = statusElement.stringValue;
        NSArray *HTTPStatusStrWords = [HTTPStatusStr componentsSeparatedByString:@" "];
        NSAssert(HTTPStatusStrWords.count > 0 && [HTTPStatusStrWords[0] isEqualToString:@"HTTP/1.1"],
                 @"Wrong format for propstat status code in PROPPATCH response");
        if (HTTPStatusStrWords.count >= 1) {
            propstatResponse.statusCode = [HTTPStatusStrWords[1] integerValue];
        }

        [propstatResponses addObject:propstatResponse];
    }

    multistatusResponse.propstats = propstatResponses;

    return multistatusResponse;
}

- (NSData *)buildHTTPBody
{
    DDXMLNode *webDAVNamespace = YDWebDAVDefaultDAVXMLNamespace();
    DDXMLNode *yandexNamespace = YDWebDAVDefaultYandexXMLNamespace();

    NSString *webDAVNamespaceStr = webDAVNamespace.stringValue;
    NSString *yandexNamespaceStr = yandexNamespace.stringValue;

    DDXMLElement *proppatchElement = [DDXMLElement elementWithName:@"D:propertyupdate"];
    DDXMLElement *setElement = [DDXMLElement elementWithName:@"D:set"];
    DDXMLElement *propSetElement = [DDXMLElement elementWithName:@"D:prop"];
    DDXMLElement *removeElement = [DDXMLElement elementWithName:@"D:remove"];
    DDXMLElement *propRemoveElement = [DDXMLElement elementWithName:@"D:prop"];
    DDXMLElement *elt = nil;
    NSMutableSet *namespaces = [[NSMutableSet alloc] init];
    [namespaces addObject:webDAVNamespace];

    for (YDPROPPATCHProp *prop in self.props) {
        NSString *namespace = @"";

        if (prop.namespace != nil) {
            [namespaces addObject:prop.namespace];

            // We are using shortened namespaces here, so replace default long namespaces with short ones
            if ([prop.namespace.stringValue isEqualToString:webDAVNamespaceStr]) {
                namespace = @"D:";
            }
            else if ([prop.namespace.stringValue isEqualToString:yandexNamespaceStr]) {
                namespace = @"Y:";
            }
        }

        elt = [DDXMLElement elementWithName:[namespace stringByAppendingString:prop.name]];

        switch (prop.type) {
            case YDWebDAVPROPPATCHTypeSet:
                [propSetElement addChild:elt];
                [elt addChild:[prop XMLElementForValue]];
                break;

            case YDWebDAVPROPPATCHTypeRemove:
                [propRemoveElement addChild:elt];
                break;

            default:
                break;
        }
    }

    if (propSetElement.childCount) {
        [setElement addChild:propSetElement];
        [proppatchElement addChild:setElement];
    }

    if (propRemoveElement.childCount) {
        [removeElement addChild:propRemoveElement];
        [proppatchElement addChild:removeElement];
    }

    [proppatchElement setNamespaces:namespaces.allObjects];

    NSString *xmlStr = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>%@", proppatchElement.XMLString];
    
    return [xmlStr dataUsingEncoding:NSUTF8StringEncoding];
}

@end
