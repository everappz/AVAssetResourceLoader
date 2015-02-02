/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "YOAuth2ViewController.h"
#import "NSNotificationCenter+Additions.h"
#import "YDConstants.h"


@interface YOAuth2ViewController ()

@property (nonatomic, assign) BOOL appeared;
@property (nonatomic, assign) BOOL done;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, copy, readwrite) NSString *token;

@end


@implementation YOAuth2ViewController

@synthesize token = _token;
@synthesize delegate = _delegate;

- (instancetype)initWithDelegate:(id<YOAuth2Delegate>)authDelegate
{
    self = [super init];
    if (self) {
        _delegate = authDelegate;
    }
    return self;
}

- (void)loadView
{
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    self.view = self.webView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setTitle:@"Sign-In"];
    NSURL *url = [NSURL URLWithString:self.authURI];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [self.webView loadRequest:request];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.appeared = YES;
    [self handleResult];
}

#pragma mark - UIWebViewDelegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidStartAuthRequestNotification
                                                                       object:self
                                                                     userInfo:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidStopAuthRequestNotification
                                                                       object:self
                                                                     userInfo:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *uri = request.URL.absoluteString;
    if ([uri hasPrefix:self.delegate.redirectURL]) { // did we get redirected to the redirect url?
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
        }
        else if (paraDict[@"error"]) {
            self.error = [NSError errorWithDomain:kYDSessionAuthenticationErrorDomain
                                             code:kYDSessionErrorUnknown
                                         userInfo:paraDict];
            self.done = YES;
        }
        [self handleResult];
    }
    return !self.done;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (!self.done) {
        YDLog(@"%@", error.localizedDescription);
        [self handleError:error];
    }
}

- (NSString *)authURI
{
    return [NSString stringWithFormat:@"https://oauth.yandex.ru/authorize?response_type=token&client_id=%@&display=popup", self.delegate.clientID];
}

- (void)handleResult
{
    if (self.done && self.appeared) {
        if (self.token) {
            [self.delegate OAuthLoginSucceededWithToken:self.token];
            [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidAuthNotification
                                                                               object:self
                                                                             userInfo:@{@"token": self.token}];
        } else if (self.error) {
            [self handleError:self.error];
        }
    }
}

- (void)handleError:(NSError *)error
{
    [self.delegate OAuthLoginFailedWithError:error];
    [[NSNotificationCenter defaultCenter] postNotificationInMainQueueWithName:kYDSessionDidFailWithAuthRequestNotification
                                                                       object:self
                                                                     userInfo:@{@"error": error}];
}

@end
