/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDPROPFINDRequest.h"
#import "YDPropstatResponse.h"
#import "DDXMLElementAdditions.h"

@interface YDPROPFINDRequest ()

@property (nonatomic, copy) NSArray *responses;

@end


@implementation YDPROPFINDRequest

#pragma mark - Object lifecycle

// Designated initializer
- (instancetype)initWithURL:(NSURL *)theURL
{
    self = [super initWithURL:theURL];
    if (self != nil) {
        _depth = YDWebDAVDepthInfinity;
    }

    return self;
}


+ (YDResourceTypeProp *)resourceTypeProp
{
    return [YDResourceTypeProp propWithName:@"resourcetype" xmlns:YDWebDAVDefaultDAVXMLNamespace()];
}

#pragma mark - Private

- (void)prepareRequest:(NSMutableURLRequest *)request
{
    [super prepareRequest:request];

    [request setHTTPMethod:@"PROPFIND"];

    NSString *depthStr = YDWebDAVDepthStringRepresentation(self.depth);
    [request setValue:depthStr forHTTPHeaderField:@"depth"];
}

- (BOOL)acceptResponseCode:(NSUInteger)statusCode
{
    // This request can be successful with 207 status code only.
    // It does not mean that there are no errors for any element in response,
    // it is just about the whole request processing.
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
                 @"Wrong format for propstat status code in PROPFIND response");
        if (HTTPStatusStrWords.count >= 1) {
            propstatResponse.statusCode = [HTTPStatusStrWords[1] integerValue];
        }

        DDXMLElement *propElement = [propstatElement elementForName:@"prop" xmlns:webDAVNamespaceStr];

        NSMutableDictionary *propValues = [NSMutableDictionary dictionaryWithCapacity:0];

        for (YDProp *prop in self.props) {
            DDXMLElement *propValueElement = [propElement elementForName:prop.name xmlns:prop.namespace.stringValue];

            if (propValueElement != nil) {
                NSObject *value = [prop valueForXMLElement:propValueElement];
                if (value == nil) {
                    value = [NSNull null];
                }

                propValues[prop.fullname] = value;
            }
        }

        propstatResponse.propValues = propValues;
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

    DDXMLElement *propElement = [DDXMLElement elementWithName:@"D:prop"];
    [propElement addNamespace:yandexNamespace];

    for (YDProp *prop in self.props) {
        NSString *namespace = @"";

        if (prop.namespace != nil) {
            // We are using shortened namespaces here, so replace default long namespaces with short ones
            if ([prop.namespace.stringValue isEqualToString:webDAVNamespaceStr]) {
                namespace = @"D:";
            }
            else if ([prop.namespace.stringValue isEqualToString:yandexNamespaceStr]) {
                namespace = @"Y:";
            }
        }

        NSString *propName = [namespace stringByAppendingString:prop.name];
        [propElement addChild:[DDXMLElement elementWithName:propName]];
    }

    DDXMLElement *propfindElement = [DDXMLElement elementWithName:@"D:propfind"];
    [propfindElement addChild:propElement];
    [propfindElement addNamespace:webDAVNamespace];

    NSString *xmlStr = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>%@", propfindElement.XMLString];

    return [xmlStr dataUsingEncoding:NSUTF8StringEncoding];
}

@end
