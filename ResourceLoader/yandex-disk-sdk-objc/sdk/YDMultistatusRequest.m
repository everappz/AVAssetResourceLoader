/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDMultistatusRequest.h"
#import "YDWebDAVCommon.h"
#import "DDXMLElementAdditions.h"


@implementation YDMultistatusRequest

- (YDMultiStatusResponse *)multistatusResponseForXMLElement:(DDXMLElement *)element
{
    if (element == nil) {
        return nil;
    }

    DDXMLNode *webDAVNamespace = YDWebDAVDefaultDAVXMLNamespace();
    NSString *webDAVNamespaceStr = webDAVNamespace.stringValue;

    YDMultiStatusResponse *multistatusResponse = [[YDMultiStatusResponse alloc] init];

    // Status code for this response
    DDXMLElement *statusElement = [element elementForName:@"status" xmlns:webDAVNamespaceStr];
    if (statusElement) {
        NSString *HTTPStatusStr = statusElement.stringValue;
        NSArray *HTTPStatusStrWords = [HTTPStatusStr componentsSeparatedByString:@" "];
        NSAssert(HTTPStatusStrWords.count > 0 && [HTTPStatusStrWords[0] isEqualToString:@"HTTP/1.1"],
                 @"Wrong format for response status code.");
        if (HTTPStatusStrWords.count >= 1) {
            multistatusResponse.statusCode = [HTTPStatusStrWords[1] integerValue];
        }
    }
    else {
        // Common response status code
        multistatusResponse.statusCode = 207;
    }

    // Response URL
    DDXMLElement *hrefElement = [element elementForName:@"href" xmlns:webDAVNamespaceStr];
    NSString *hrefStr = hrefElement.stringValue;
    // By specs webdav server should return full url in href element, but our server
    // returns only relative paths here.
    NSString *URLStr = [NSString stringWithFormat:@"%@://%@%@", self.URL.scheme, self.URL.host, hrefStr];
    multistatusResponse.URL = [NSURL URLWithString:URLStr];

    return multistatusResponse;
}

- (void)cancel{
    [super cancel];
    self.didReceiveMultistatusResponsesBlock = nil;
}

- (void)processReceivedData
{
    if (self.lastResponse.statusCode == 207) {
        if (self.receivedData.length == 0 || self.isCancelled) {
            return;
        }

        NSMutableArray *responses = [NSMutableArray arrayWithCapacity:0];

        DDXMLNode *webDAVNamespace = YDWebDAVDefaultDAVXMLNamespace();
        NSString *webDAVNamespaceStr = webDAVNamespace.stringValue;

        DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:self.receivedData options:0 error:nil];
        DDXMLElement *rootElement = xmlDoc.rootElement;

        NSArray *responseElements = [rootElement elementsForLocalName:@"response" URI:webDAVNamespaceStr];

        for (DDXMLElement *responseElement in responseElements) {
            YDMultiStatusResponse *multistatusResponse = [self multistatusResponseForXMLElement:responseElement];
            [responses addObject:multistatusResponse];
        }

        self.multistatusResponses = responses;

        // Call delegate callback
        if (self.didReceiveMultistatusResponsesBlock != nil) {
            dispatch_async(self.callbackQueue, ^{
                if(self.isCancelled==NO){
                    self.didReceiveMultistatusResponsesBlock(self.multistatusResponses);
                }
            });
        }
    }
}

@end
