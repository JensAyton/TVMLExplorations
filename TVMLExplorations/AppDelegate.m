#import "AppDelegate.h"
#import "Logger.h"
@import TVMLKit;

static NSString * const BaseURL = @"http://jens.ayton.se/code/tvmlexplorations/";


@interface AppDelegate () <TVApplicationControllerDelegate>

@property (strong, nonatomic) TVApplicationController *applicationController;

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
	
	TVApplicationControllerContext *context = [TVApplicationControllerContext new];
	context.javaScriptApplicationURL = [self urlForResource:@"main.v2.js"];
	context.launchOptions = launchOptions;
	
	self.applicationController = [[TVApplicationController alloc] initWithContext:context
																		   window:self.window
																		 delegate:self];
	
	return YES;
}


- (NSURL *)urlForResource:(NSString *)resourceName
{
	static NSURL *baseURL;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		baseURL = [NSURL URLWithString:BaseURL];
	});
	NSURL *url = [NSURL URLWithString:resourceName relativeToURL:baseURL].absoluteURL;
	NSLog(@"%@", url.absoluteString);
	return url;
}


#pragma mark TVApplicationControllerDelegate

- (void)appController:(TVApplicationController *)appController evaluateAppJavaScriptInContext:(JSContext *)jsContext
{
	jsContext[@"logger"] = [[Logger alloc] initWithJSContext:jsContext];
}

@end
