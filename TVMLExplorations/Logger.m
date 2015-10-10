#import "Logger.h"

@implementation Logger

- (instancetype)initWithJSContext:(JSContext *)jsContext
{
	return [super init];
}

- (void)log:(NSString *)message
{
	NSLog(@"[TVJS] %@", message);
}

@end
