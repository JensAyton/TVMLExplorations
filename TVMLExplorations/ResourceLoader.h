@import JavaScriptCore;

@protocol ResourceTaskExport <JSExport>

- (void)cancel;

@end

@protocol ResourceLoaderExport <JSExport>

JSExportAs(load,
- (id<ResourceTaskExport>)loadResourceAtURL:(NSString *)urlString completionHandler:(JSValue *)jsHandler
);

- (NSString *)resolveURL:(NSString *)url;

@end

@interface ResourceLoader : NSObject <ResourceLoaderExport>

- (instancetype)initWithJSContext:(JSContext *)jsContext
			  localResourceScheme:(NSString *)localResourceScheme;

@end
