@import JavaScriptCore;

@protocol ResourceTaskExport <JSExport>

- (void)cancel;

@end

@protocol ResourceLoaderExport <JSExport>

JSExportAs(load,
- (id<ResourceTaskExport>)loadResourceAtURL:(NSString *)urlString completionHandler:(JSValue *)jsHandler
);

@end

@interface ResourceLoader : NSObject <ResourceLoaderExport>

- (instancetype)initWithJSContext:(JSContext *)jsContext
			  localResourceScheme:(NSString *)localResourceScheme;

@end
