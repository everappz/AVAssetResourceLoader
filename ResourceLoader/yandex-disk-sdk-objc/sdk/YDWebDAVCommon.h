/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "DDXML.h"


/*
 * The Depth request header is used with methods executed on resources
 * that could potentially have internal members to indicate whether the
 * method is to be applied only to the resource ("Depth: 0"), to the
 * resource and its internal members only ("Depth: 1"), or the resource
 * and all its members ("Depth: infinity").

 * The Depth header is only supported if a method's definition
 * explicitly provides for such support.

 * The following rules are the default behavior for any method that
 * supports the Depth header.  A method may override these defaults by
 * defining different behavior in its definition.

 * Methods that support the Depth header may choose not to support all
 * of the header's values and may define, on a case-by-case basis, the
 * behavior of the method if a Depth header is not present.  For
 * example, the MOVE method only supports "Depth: infinity", and if a
 * Depth header is not present, it will act as if a "Depth: infinity"
 * header had been applied.
 */
typedef enum {
    YDWebDAVDepthUnknown,
    YDWebDAVDepth0,
    YDWebDAVDepth1,
    YDWebDAVDepthInfinity
} YDWebDAVDepth;

// Returns simple string representation of enum value
NSString *YDWebDAVDepthStringRepresentation(YDWebDAVDepth depth);

// Returns default DAV xml namespace (xmlns:D="DAV:")
DDXMLNode *YDWebDAVDefaultDAVXMLNamespace(void);
// Returns default Yandex xml namespace (xmlns:Y="urn:yandex:disk:meta:")
DDXMLNode *YDWebDAVDefaultYandexXMLNamespace(void);
