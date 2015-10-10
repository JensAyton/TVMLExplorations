@import JavaScriptCore;

@protocol LoggerExport <JSExport>

- (void)log:(NSString *)message;

@end


@interface Logger : NSObject <LoggerExport>

- (instancetype)initWithJSContext:(JSContext *)jsContext;

@end
