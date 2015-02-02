/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YOAuth2WindowController.h"
#import "YDConstants.h"


@interface YOAuth2WindowController ()

@property (nonatomic, assign) BOOL done;
@property (nonatomic, copy, readwrite) NSString *token;

@end


@implementation YOAuth2WindowController

@synthesize token = _token;
@synthesize delegate = _delegate;

- (instancetype)init
{
    return [self initWithWindowNibName:@"YOAuth2WindowController"];
}

-(void)showWindow:(id)sender
{
    NSURL *url = [NSURL URLWithString:self.authURI];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    self.window.delegate = self;
    self.webView.resourceLoadDelegate = self;
    [self.webView.mainFrame loadRequest:request];
    [super showWindow:sender];
    [self.window makeKeyAndOrderFront:NSApp];
}

- (NSString *)authURI
{
    return [NSString stringWithFormat:@"https://oauth.yandex.ru/authorize?response_type=token&client_id=%@&display=popup", self.delegate.clientID];
}


#pragma mark - NSWindowDelegate methods

- (void)windowWillClose:(NSNotification *)notification
{
    if (!self.done) {
        NSError *error = [NSError errorWithDomain:kYDSessionAuthenticationErrorDomain
                                             code:kYDSessionErrorUnknown
                                         userInfo:nil];
        [self.delegate OAuthLoginFailedWithError:error];
    }
}


#pragma mark - WebViewResourceLoadDelegate methods

- (NSURLRequest *)webView:(WebView *)sender
                 resource:(id)identifier
          willSendRequest:(NSURLRequest *)request
         redirectResponse:(NSURLResponse *)redirectResponse
           fromDataSource:(WebDataSource *)dataSource
{
    NSString *uri = request.URL.absoluteString;
    
    if ([uri hasPrefix:self.delegate.redirectURL]) {  // did we get redirected to the redirect url?
        NSArray *split = [uri componentsSeparatedByString:@"#"];
        NSString *param = split[1];
        split = [param componentsSeparatedByString:@"&"];
        NSMutableDictionary *paraDict = [NSMutableDictionary dictionary];

        for (NSString *s in split) {
            NSArray *kv = [s componentsSeparatedByString:@"="];
            if (kv) {
                paraDict[kv[0]] = kv[1];
            }
        }

        if (paraDict[@"access_token"]) {
            self.token = paraDict[@"access_token"];
            self.done = YES;
            [self.delegate OAuthLoginSucceededWithToken:self.token];
            [sender.window close];
        }
        else if (paraDict[@"error"]) {
            NSError *error = [NSError errorWithDomain:kYDSessionAuthenticationErrorDomain
                                                 code:kYDSessionErrorUnknown
                                             userInfo:paraDict];
            [self.delegate OAuthLoginFailedWithError:error];
            self.done = YES;
            [sender.window close];
        }
        return nil;
    }
    return request;
}

@end
