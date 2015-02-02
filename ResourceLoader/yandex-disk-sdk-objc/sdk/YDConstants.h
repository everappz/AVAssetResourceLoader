/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#ifdef __cplusplus
#   define YD_EXTERN  extern "C" __attribute__((visibility ("default")))
#else
#   define YD_EXTERN  extern __attribute__((visibility ("default")))
#endif

//#define YD_DEBUG YES

#ifdef YD_DEBUG
#define YDLog(...) NSLog(__VA_ARGS__)
#else
#define YDLog(...) {}
#endif


YD_EXTERN NSInteger const kYDSessionErrorUnknown;

YD_EXTERN NSString *const kYDSessionAuthenticationErrorDomain;
YD_EXTERN NSString *const kYDSessionBadArgumentErrorDomain;
YD_EXTERN NSString *const kYDSessionBadResponseErrorDomain;
YD_EXTERN NSString *const kYDSessionConnectionErrorDomain;
YD_EXTERN NSString *const kYDSessionRequestErrorDomain;

YD_EXTERN NSString *const kYDSessionConnectionDidFailAuthenticateWithError;
YD_EXTERN NSString *const kYDSessionResponseError;

YD_EXTERN NSString *const kYDSessionDidStartAuthRequestNotification;
YD_EXTERN NSString *const kYDSessionDidStopAuthRequestNotification;
YD_EXTERN NSString *const kYDSessionDidAuthNotification;
YD_EXTERN NSString *const kYDSessionDidFailWithAuthRequestNotification;
YD_EXTERN NSString *const kYDSessionDidFailWithFetchDirectoryRequestNotification;
YD_EXTERN NSString *const kYDSessionDidFailWithFetchStatusRequestNotification;
YD_EXTERN NSString *const kYDSessionDidFailWithFetchUserInfoRequestNotification;
YD_EXTERN NSString *const kYDSessionDidFailToCreateDirectoryNotification;
YD_EXTERN NSString *const kYDSessionDidCreateDirectoryNotification;
YD_EXTERN NSString *const kYDSessionDidSendCreateDirectoryRequestNotification;
YD_EXTERN NSString *const kYDSessionDidRemoveNotification;
YD_EXTERN NSString *const kYDSessionDidFailWithRemoveRequestNotification;
YD_EXTERN NSString *const kYDSessionDidSendRemoveRequestNotification;
YD_EXTERN NSString *const kYDSessionDidFailToMoveNotification;
YD_EXTERN NSString *const kYDSessionDidMoveNotification;
YD_EXTERN NSString *const kYDSessionDidSendMoveRequestNotification;
YD_EXTERN NSString *const kYDSessionDidStartUploadFileNotification;
YD_EXTERN NSString *const kYDSessionDidFinishUploadFileNotification;
YD_EXTERN NSString *const kYDSessionDidFailUploadFileNotification;
YD_EXTERN NSString *const kYDSessionDidDownloadFileNotification;
YD_EXTERN NSString *const kYDSessionDidFailToDownloadFileNotification;
YD_EXTERN NSString *const kYDSessionDidStartDownloadFileNotification;
YD_EXTERN NSString *const kYDSessionDidPublishFileNotification;
YD_EXTERN NSString *const kYDSessionDidFailWithPublishRequestNotification;
YD_EXTERN NSString *const kYDSessionDidUnpublishFileNotification;
YD_EXTERN NSString *const kYDSessionDidFailWithUnpublishRequestNotification;

#undef YD_EXTERN