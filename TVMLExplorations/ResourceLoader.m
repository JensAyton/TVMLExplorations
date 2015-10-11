#import "ResourceLoader.h"

@interface ResourceLoader () <NSURLSessionDelegate>

@property (readonly, copy, nonatomic) NSString *localResourceScheme;
@property (readonly, strong, nonatomic) JSValue *setTimeoutFunction;
@property (readonly, strong, nonatomic) NSURLSession *urlSession;
@property (readonly, strong, nonatomic) NSHashTable *tasks;

@end

typedef void (^CompletionHandler)(NSInteger status, NSString *result);


@interface ResourceTask : NSObject <ResourceTaskExport>

- (instancetype)initWithURL:(NSURL *)url
				 urlSession:(NSURLSession *)session
		  completionHandler:(CompletionHandler)completionHandler;

@property (strong, nonatomic) CompletionHandler completionHandler;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;

@end

static NSInteger HTTPStyleErrorCode(NSError *error);


@implementation ResourceLoader

- (instancetype)initWithJSContext:(JSContext *)jsContext
			  localResourceScheme:(NSString *)localResourceScheme
{
	if ((self = [super init]))
	{
		_localResourceScheme = localResourceScheme.lowercaseString;
		_setTimeoutFunction = jsContext[@"setTimeout"];
		_urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
													delegate:self
											   delegateQueue:nil];
		_tasks = [NSHashTable weakObjectsHashTable];
	}
	return self;
}


- (void)dealloc
{
	[_tasks.allObjects makeObjectsPerformSelector:@selector(cancel)];
}


- (id<ResourceTaskExport>)loadResourceAtURL:(NSString *)urlString completionHandler:(JSValue *)jsHandler
{
	__weak typeof (self) weakSelf = self;
	CompletionHandler handler = ^(NSInteger status, NSString *result)
	{
		[weakSelf callJSCallback:jsHandler withArguments:@[ @(status), result ]];
	};
	
	NSURL *url = [self resolveURLInternal:urlString];
	ResourceTask *task = [[ResourceTask alloc] initWithURL:url
												urlSession:self.urlSession
										 completionHandler:handler];
	[self.tasks addObject:task];
	
	return task;
}


- (NSString *)resolveURL:(NSString *)urlString
{
	NSURL *url = [self resolveURLInternal:urlString];
	return url ? url.absoluteString : @"";
}


- (NSURL *)resolveURLInternal:(NSString *)urlString
{
	NSURL *url = [NSURL URLWithString:urlString];
	NSString *scheme = url.scheme.lowercaseString;
	
	if ([scheme isEqualToString:self.localResourceScheme])
	{
		url = [NSBundle.mainBundle URLForResource:url.resourceSpecifier withExtension:nil];
	}
	
	return url;
}


- (void)callJSCallback:(JSValue *)callback withArguments:(NSArray *)arguments
{
    NSMutableArray *argArray = [NSMutableArray arrayWithArray:arguments];
    [argArray insertObject:@0 atIndex:0];
    [argArray insertObject:callback atIndex:0];
    [self.setTimeoutFunction callWithArguments:argArray];
}

@end


@implementation ResourceTask

- (instancetype)initWithURL:(NSURL *)url
				 urlSession:(NSURLSession *)session
		  completionHandler:(CompletionHandler)completionHandler
{
	if ((self = [super init])) {
		_completionHandler = completionHandler;
		__weak typeof (self) weakSelf = self;
		_dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			[weakSelf completeWithData:data response:response error:error];
		}];
		[_dataTask resume];
	}
	return self;
}


- (void)dealloc
{
	[self.dataTask cancel];
}


- (void)cancel
{
	[self.dataTask cancel];
	self.dataTask = nil;
	self.completionHandler = nil;
}


- (void)completeWithData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error
{
	CompletionHandler handler = self.completionHandler;
	if (handler == nil) {
		return;
	}
	
	// It's important to clean up objects exposed to JavaScript because their lifetimes are controlled by the JS garbage
	// collector, and they may hang around for quite a while.
	self.dataTask = nil;
	self.completionHandler = nil;
	
	// Assuming that all resources are UTF-8 text is obviously not the Right Thing, but it's not obvious what is the
	// Right Thing given differences in string semantics between Objective-C and JavaScript. It would be nice if
	// JSExport handled NSData by turning it into a UInt8Array, but nope.
	NSString *string = nil;
	if (data != nil) {
		string = [[NSString alloc] initWithData:(NSData * __nonnull)data
									   encoding:NSUTF8StringEncoding];
	}
	if (string != nil)
	{
		handler(200, string);
	}
	else if (data != nil)
	{
		handler(415, @"Resource is not UTF-8");
	}
	else if ([response isKindOfClass:NSHTTPURLResponse.class] &&
			   [(NSHTTPURLResponse *)response statusCode] != 200)
	{
		NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
		handler(statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
	}
	else
	{
		handler(HTTPStyleErrorCode(error), error.localizedDescription ?: @"Connection failed");
	}
}

@end


static NSInteger HTTPStyleErrorCode(NSError *error)
{
	if ([error.domain isEqualToString:NSCocoaErrorDomain]) switch (error.code)
	{
		case NSFileReadNoSuchFileError:
		case NSFileReadInvalidFileNameError:
			return 404;	// Not Found
		case NSFileReadNoPermissionError:
			return 403;	// Forbidden
	}
	
	if ([error.domain isEqualToString:NSURLErrorDomain]) switch (error.code)
	{
		case NSURLErrorBadURL:
		case NSURLErrorUnsupportedURL:
		case NSURLErrorCannotConnectToHost:
		case NSURLErrorNetworkConnectionLost:
		case NSURLErrorNotConnectedToInternet:
		case NSURLErrorAppTransportSecurityRequiresSecureConnection:
			return 502;	// Bad Gateway
		case NSURLErrorTimedOut:
			return 504;	// Gateway Timeout
		case NSURLErrorResourceUnavailable:
		case NSURLErrorRedirectToNonExistentLocation:
			return 404;	// Not Found
	}
	
	return 500;	// Internal Server Error
}
