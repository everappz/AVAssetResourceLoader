/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YDConstants.h"

NSInteger const kYDSessionErrorUnknown = -1;

NSString *const kYDSessionAuthenticationErrorDomain = @"kYDSessionAuthenticationErrorDomain";
NSString *const kYDSessionBadArgumentErrorDomain = @"kYDSessionBadArgumentErrorDomain";
NSString *const kYDSessionBadResponseErrorDomain = @"kYDSessionBadResponseErrorDomain";
NSString *const kYDSessionRequestErrorDomain = @"kYDSessionRequestErrorDomain";
NSString *const kYDSessionConnectionErrorDomain = @"kYDSessionConnectionErrorDomain";

NSString *const kYDSessionConnectionDidFailAuthenticateWithError = @"kYDSessionConnectionDidFailAuthenticateWithError";
NSString *const kYDSessionResponseError = @"kYDSessionResponseError";


NSString *const kYDSessionDidStartAuthRequestNotification = @"kYDSessionDidStartAuthRequestNotification";
NSString *const kYDSessionDidStopAuthRequestNotification = @"kYDSessionDidStopAuthRequestNotification";
NSString *const kYDSessionDidAuthNotification = @"kYDSessionDidAuthNotification";
NSString *const kYDSessionDidFailWithAuthRequestNotification = @"kYDSessionDidFailWithAuthRequestNotification";
NSString *const kYDSessionDidFailWithFetchDirectoryRequestNotification = @"kYDSessionDidFailWithFetchDirectoryRequestNotification";
NSString *const kYDSessionDidFailWithFetchStatusRequestNotification = @"kYDSessionDidFailWithFetchStatusRequestNotification";
NSString *const kYDSessionDidFailWithFetchUserInfoRequestNotification = @"kYDSessionDidFailWithFetchUserInfoRequestNotification";
NSString *const kYDSessionDidFailToCreateDirectoryNotification = @"kYDSessionDidFailToCreateDirectoryNotification";
NSString *const kYDSessionDidCreateDirectoryNotification = @"kYDSessionDidCreateDirectoryNotification";
NSString *const kYDSessionDidSendCreateDirectoryRequestNotification = @"kYDSessionDidSendCreateDirectoryRequestNotification";
NSString *const kYDSessionDidRemoveNotification = @"kYDSessionDidRemoveNotification";
NSString *const kYDSessionDidFailWithRemoveRequestNotification = @"kYDSessionDidFailWithRemoveRequestNotification";
NSString *const kYDSessionDidSendRemoveRequestNotification = @"kYDSessionDidSendRemoveRequestNotification";
NSString *const kYDSessionDidFailToMoveNotification = @"kYDSessionDidFailToMoveNotification";
NSString *const kYDSessionDidMoveNotification = @"kYDSessionDidMoveNotification";
NSString *const kYDSessionDidSendMoveRequestNotification = @"kYDSessionDidSendMoveRequestNotification";
NSString *const kYDSessionDidStartUploadFileNotification = @"kYDSessionDidStartUploadFileNotification";
NSString *const kYDSessionDidFinishUploadFileNotification = @"kYDSessionDidFinishUploadFileNotification";
NSString *const kYDSessionDidFailUploadFileNotification = @"kYDSessionDidFailUploadFileNotification";
NSString *const kYDSessionDidDownloadFileNotification = @"kYDSessionDidDownloadFileNotification";
NSString *const kYDSessionDidFailToDownloadFileNotification = @"kYDSessionDidFailToDownloadFileNotification";
NSString *const kYDSessionDidStartDownloadFileNotification = @"kYDSessionDidStartDownloadFileNotification";
NSString *const kYDSessionDidPublishFileNotification = @"kYDSessionDidPublishFileNotification";
NSString *const kYDSessionDidFailWithPublishRequestNotification = @"kYDSessionDidFailWithPublishRequestNotification";
NSString *const kYDSessionDidUnpublishFileNotification = @"kYDSessionDidUnpublishFileNotification";
NSString *const kYDSessionDidFailWithUnpublishRequestNotification = @"kYDSessionDidFailWithUnpublishRequestNotification";
