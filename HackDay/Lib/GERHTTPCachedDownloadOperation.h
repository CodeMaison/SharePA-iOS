//
//  GERHTTPCachedDownloadOperation.h
//  LExpress
//
//  Created by rcodarini on 23/06/14.
//  Copyright (c) 2014 Groupe Express-Roularta. All rights reserved.
//


typedef void (^GERDownloadCompletionBlock_) (NSInteger code, NSData *data,  NSURL *URLSource, NSError *error, BOOL isCancelled);
typedef void (^GERDownloadProgressionBlock) (NSURL *URLSource, CGFloat progression);

@interface GERHTTPCachedDownloadOperation : NSOperation
{
    // In concurrent operations, we have to manage the operation's state
    BOOL _executing;
    BOOL _finished;
}
@property (nonatomic, strong)   NSURL *connectionURL;

+ (void)getRequestForURL:(NSURL *)url completionBlock:(GERDownloadCompletionBlock_)block;
+ (void)getRequestForURL:(NSURL *)url queue:(NSOperationQueue *)queue completionBlock:(GERDownloadCompletionBlock_)block;
+ (void)getRequestForURL:(NSURL *)url queue:(NSOperationQueue *)queue cachePolicy:(NSURLRequestCachePolicy)cachePolicy completionBlock:(GERDownloadCompletionBlock_)block;


+ (void)postRequestForURL:(NSURL *)url parameters:(NSDictionary *)parameters completionBlock:(GERDownloadCompletionBlock_)block;
+ (void)postRequestForURL:(NSURL *)url parameters:(NSDictionary *)parameters queue:(NSOperationQueue *)queue completionBlock:(GERDownloadCompletionBlock_)block;
+ (void)postRequestForURL:(NSURL *)url data:(NSData *)data queue:(NSOperationQueue *)queue completionBlock:(GERDownloadCompletionBlock_)block;
+ (void)postRequestForURL:(NSURL *)url data:(NSData *)data completionBlock:(GERDownloadCompletionBlock_)block;

+ (void)cancelAllRequests;
+ (void)cancelRequestForURL:(NSURL *)url;

- (instancetype)initWithUrl:(NSURL *)url completion:(GERDownloadCompletionBlock_)block;
- (instancetype)initWithUrl:(NSURL *)url postParameters:(NSDictionary *)parameters completion:(GERDownloadCompletionBlock_)block;
- (instancetype)initWithUrl:(NSURL *)url data:(NSData *)data completion:(GERDownloadCompletionBlock_)block;

// TODO: progression management
- (void)setProgressionBlock:(GERDownloadProgressionBlock)progressionBlock;

- (void)setTimeout:(NSTimeInterval)timeout;
- (void)setEtag:(NSString *)etag;
- (void)setCachePolicy:(NSURLRequestCachePolicy)cachePolicy;
- (void)addHeaderApiKey;
- (NSMutableDictionary *)requestHeaderFields;


@end
