#import "AppDelegate.h"
#import "Logger.h"
#import "ResourceLoader.h"
@import TVMLKit;

@interface AppDelegate () <TVApplicationControllerDelegate>

@property (strong, nonatomic) TVApplicationController *applicationController;

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
	
	TVApplicationControllerContext *context = [TVApplicationControllerContext new];
	context.javaScriptApplicationURL = [self urlForResource:@"main.js"];
	context.launchOptions = launchOptions;
	
	self.applicationController = [[TVApplicationController alloc] initWithContext:context
																		   window:self.window
																		 delegate:self];
	
	return YES;
}


- (NSURL *)urlForResource:(NSString *)resourceName
{
	return [NSBundle.mainBundle URLForResource:resourceName withExtension:nil];
}


#pragma mark TVApplicationControllerDelegate

- (void)appController:(TVApplicationController *)appController evaluateAppJavaScriptInContext:(JSContext *)jsContext
{
	jsContext[@"logger"] = [[Logger alloc] initWithJSContext:jsContext];
	jsContext[@"resourceLoader"] = [[ResourceLoader alloc] initWithJSContext:jsContext
														 localResourceScheme:@"vnd.myapp.local"];
}

@end
