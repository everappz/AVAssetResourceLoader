# Yandex Disk SDK for OSX and iOS

## What this is

A pleasant wrapper around the Yandex Disk Cloud API.

The current implementation is based on OAuth 2 for authorization, and on WebDAV for accessing the cloud storage.


## Required reading

Please check out the [Yandex Disk API page][DISKAPI],
and [Yandex OAuth 2 API page][AUTHAPI].


## Installing

### Register for an Yandex API key.

You can register your app at the: [Yandex OAuth app registration page][REGISTER].


### Include the code

You have a few options:

- Copy the yandex-disk-sdk source code into your Xcode project.
- Add the yandex-disk-sdk xcodeproj to your project/workspace.
- Build the yandex-disk-sdk as a static library and include the .h's and .a. (Make sure to add the `-ObjC` flag to your "Other Linker flags" if you choose this option). 
More info [here](http://developer.apple.com/library/ios/#technotes/iOSStaticLibraries/Articles/configuration.html#/apple_ref/doc/uid/TP40012554-CH3-SW2). 


### Link with frameworks

The yandex-disk-sdk depends on some frameworks, so you'll need to add them to any target's "Link Binary With Libraries" Build Phase.
Add the following frameworks in the "Link Binary With Libraries" phase

- libxml2


## Samples

There are two samples included in the SDK:

- sdk-example-ios: a very simple Yandex Disk browser for iPhone.
- sdk-example-osx: an OSX test application for the Yandex Disk SDK. 


## Using the Yandex Disk SDK from your code

### Preparations

The Yandex Disk SDK is using delegates to get all necessary information for authenticating and accessing Yandex Disk web API.
Your Delegate should implement two protocols:
- `YOAuth2Delegate` protocol,
- `YDSessionDelegate` protocol.

```
@protocol YOAuth2Delegate <NSObject>

- (NSString *)clientID;
- (NSString *)redirectURL;
- (void)OAuthLoginSucceededWithToken:(NSString *)token;
- (void)OAuthLoginFailedWithError:(NSError *)error;

@end
```
```
@protocol YDSessionDelegate <NSObject>

- (NSString *)userAgent;

@end
```

- clientID: received during app registration.
- redirectURL: should match the redirection URL specified at app registration. It is preferable to use some HTTP URL with some non valid domain like for example "http://myapp.authentication". Using some custom URL scheme can also work, might however require more extensive testing, and adaptions.
- userAgent: a user agent string identifying your software in the HTTP headers. This can be almost anything.


### Authenticate

Authorization works by creating and displaying either of `YOAuth2ViewController` (iOS), or `YOAuth2WindowController` (on OSX).
Once authentication is done one of the delegate method will be called.
In case an error occurred, `OAuthLoginFailedWithError:` will be called and the NSError will be set, otherwise `OAuthLoginSucceededWithToken:` will be called and the NSString will contain the acquired token.

```
    if (session.authenticated == NO) {
        self.authVC = [[YOAuth2ViewController alloc] init];
        self.authVC.delegate = self;
        [myViewController presentViewController:self.authVC animated:animated completion:nil];
    }
```

In case you have a token already, you can skip the authorization and just assign the token to the session.

```
    YDSession *disk = [[YDSession alloc] init];
    disk.OAuthToken = someLoadedToken;
```


### List the root directory

```
    [disk fetchDirectoryContentsAtPath:@"/" completion:^(NSError *err, NSArray *items) {
        if (err) {
            // do some error handling
        } else {
            // do something with the received items
            for (YDItemStat * item in items) {
                // ...
            }
        }
   }];

```


### YDSession interface

As already demonstrated in the previous section, the interface to YDSession is almost self explaining.
The complete interface looks like this:

```
typedef void (^YDFetchDirectoryHandler)(NSError* err, NSArray* list);
typedef void (^YDFetchStatusHandler)(NSError* err, YDItemStat* item);
typedef void (^YDPublishHandler)(NSError* err, NSURL* url);
typedef void (^YDHandler)(NSError *err);

@interface YDSession : NSObject

@property(copy) NSString * OAuthToken;
@property(weak, nonatomic) id<YDSessionDelegate> delegate;
@property (nonatomic, readonly) BOOL authenticated;

- (instancetype)initWithDelegate:(id<YDSessionDelegate>)delegate;

- (void)fetchDirectoryContentsAtPath:(NSString *)path completion:(YDFetchDirectoryHandler)block;
- (void)fetchStatusForPath:(NSString *)path completion:(YDFetchStatusHandler)block;
- (void)createDirectoryAtPath:(NSString *)path completion:(YDHandler)block;
- (void)removeItemAtPath:(NSString *)path completion:(YDHandler)block;
- (void)trashItemAtPath:(NSString *)path completion:(YDHandler)block;
- (void)moveItemAtPath:(NSString *)path toPath:(NSString *)topath completion:(YDHandler)block;
- (void)uploadFile:(NSString *)file toPath:(NSString *)path completion:(YDHandler)block;
- (void)downloadFileFromPath:(NSString *)path toFile:(NSString *)file completion:(YDHandler)block;
- (void)publishItemAtPath:(NSString *)path completion:(YDPublishHandler)block;
- (void)unpublishItemAtPath:(NSString *)path completion:(YDHandler)block;

@end
```


## Where to continue from here

Great, you made it so far. Now feel free to dig into the SDK, fork, remove, patch, add whatever you think things should be done different. And if you feel that your changes are ready for a broader audience, send us your pull requests.


## FAQ

### Does the Yandex Disk SDK support ARC?

Yes. To use the SDK in a non-ARC project, please use the `-fobjc-arc` compiler flag on all the files in the Yandex Disk SDK.


### Which versions of OS/ which deployment targets are supported?

On iOS requires minimum version iOS 5. (the included example is requires iOS 6)
On OSX requires minimum version OSX 10.7.


### Is there any more documentation available?

The main header files (for `YDSession`, `YDItemStat`, `YOAuth2Delegate`, and `YDSessionDelegate` are documented using HeaderDocs.
Besides that there is documentation about the web API on the [Yandex Disk API page][DISKAPI] and [Yandex OAuth 2 API page][AUTHAPI].


### I checked out the sources and it does not compile

Make sure to also `git submodule init`, `git submodule update`, to get the KissXML library. Also to be able to compile the example, you will need to register an app, and add your client secret to the code. (Read the compile error.)


## License

Лицензионное соглашение на использование набора средств разработки «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement

License agreement on use of Toolkit «SDK Яндекс.Диска» available at: http://legal.yandex.ru/sdk_agreement


[LICENSE]: http://legal.yandex.ru/sdk_agreement
[DISKAPI]: http://api.yandex.ru/disk/ "Yandex Disk API page"
[AUTHAPI]: http://api.yandex.ru/oauth/ "Yandex OAuth 2 API page"
[REGISTER]: https://oauth.yandex.ru/client/new "Yandex OAuth app registration page"

