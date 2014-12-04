//
//  GERHTTPCachedDownloadOperation.m
//  LExpress
//
//  Created by rcodarini on 23/06/14.
//  Copyright (c) 2014 Groupe Express-Roularta. All rights reserved.
//

#import "GERHTTPCachedDownloadOperation.h"

static NSOperationQueue *DefaultQueue;
static dispatch_queue_t MainQueue;


@interface GERHTTPCachedDownloadOperation()

// The actual NSURLConnection management
@property (nonatomic, strong)   NSURLConnection *connection;
@property (nonatomic, strong)   NSMutableData *data;
@property (nonatomic, strong)   NSError* error;

// NSURLRequest headerFields
@property (nonatomic, strong)   NSMutableDictionary *requestHeaderFields;
@property (nonatomic, strong)   NSDictionary *postParameters;
@property (nonatomic, strong)   NSData *postJsonData;

// NSURLRequest configuration
@property (nonatomic, assign)   NSTimeInterval timeout;
@property (nonatomic, assign)   NSURLRequestCachePolicy cachePolicy;
@property (nonatomic, assign)   NSInteger statusCode;
@property (nonatomic, assign)   NSInteger contentLength;


@property (nonatomic, assign)   long long dataLength;

// callback blocks
@property (nonatomic, copy) GERDownloadCompletionBlock_ completionHandler;
@property (nonatomic, copy) GERDownloadProgressionBlock progressionBlock;

@end

#pragma mark -
@implementation GERHTTPCachedDownloadOperation
#pragma mark -

+ (void)initialize
{
    ADLog(@"");
    DefaultQueue = [[NSOperationQueue alloc] init];
    [DefaultQueue setMaxConcurrentOperationCount:2];
    MainQueue = dispatch_get_main_queue();
}

#pragma mark -
#pragma mark Class methods
#pragma mark -

+ (void)getRequestForURL:(NSURL *)url completionBlock:(GERDownloadCompletionBlock_)block
{
    [self getRequestForURL:url queue:DefaultQueue completionBlock:block];
}
+ (void)postRequestForURL:(NSURL *)url parameters:(NSDictionary *)parameters completionBlock:(GERDownloadCompletionBlock_)block
{
    [self postRequestForURL:url parameters:parameters queue:DefaultQueue completionBlock:block];
}
+ (void)postRequestForURL:(NSURL *)url data:(NSData *)data completionBlock:(GERDownloadCompletionBlock_)block
{
    [self postRequestForURL:url data:data queue:DefaultQueue completionBlock:block];
}

+ (void)getRequestForURL:(NSURL *)url queue:(NSOperationQueue *)queue completionBlock:(GERDownloadCompletionBlock_)block
{
    GERHTTPCachedDownloadOperation *operation = [[GERHTTPCachedDownloadOperation alloc] initWithUrl:url completion:block];
    [queue addOperation:operation];
}
+ (void)getRequestForURL:(NSURL *)url queue:(NSOperationQueue *)queue cachePolicy:(NSURLRequestCachePolicy)cachePolicy completionBlock:(GERDownloadCompletionBlock_)block
{
    GERHTTPCachedDownloadOperation *operation = [[GERHTTPCachedDownloadOperation alloc] initWithUrl:url completion:block];
    [operation setCachePolicy:cachePolicy];
    [queue addOperation:operation];
}
+ (void)postRequestForURL:(NSURL *)url parameters:(NSDictionary *)parameters queue:(NSOperationQueue *)queue completionBlock:(GERDownloadCompletionBlock_)block
{
    GERHTTPCachedDownloadOperation *operation = [[GERHTTPCachedDownloadOperation alloc] initWithUrl:url postParameters:parameters completion:block];
    [queue addOperation:operation];
}
+ (void)postRequestForURL:(NSURL *)url data:(NSData *)data queue:(NSOperationQueue *)queue completionBlock:(GERDownloadCompletionBlock_)block
{
    GERHTTPCachedDownloadOperation *operation = [[GERHTTPCachedDownloadOperation alloc] initWithUrl:url data:data completion:block];
    operation.postJsonData = data;
    [queue addOperation:operation];
}

+ (void)cancelAllRequests
{
    ADLog(@"");
    [DefaultQueue cancelAllOperations];
}
+ (void)cancelRequestForURL:(NSURL *)url
{
    ADLog(@"%@", url);
    if (url && [DefaultQueue operationCount]) {
        for (GERHTTPCachedDownloadOperation *op in [DefaultQueue operations]) {
            if ([op.connectionURL isEqual:url]) {
                [op cancel];
            }
        }
    }
}


#pragma mark -
#pragma mark Instance methods
#pragma mark -

- (instancetype)initWithUrl:(NSURL *)url completion:(GERDownloadCompletionBlock_)block
{
    ADLog(@"%@",url);
    if( (self = [super init]) ) {
        _connectionURL = [url copy];
        _completionHandler = [block copy];
        _executing = NO;
        _finished = NO;
        _dataLength = 0;
        NSMutableDictionary *headerFields = [NSMutableDictionary dictionary];
        self.requestHeaderFields = headerFields;
        headerFields = nil;
    }
    return self;
}
- (instancetype)initWithUrl:(NSURL *)url postParameters:(NSDictionary *)parameters completion:(GERDownloadCompletionBlock_)block
{
    if(self = [self initWithUrl:url completion:block]) {
        self.postParameters = parameters;
    };
    return self;
}
- (instancetype)initWithUrl:(NSURL *)url data:(NSData *)data completion:(GERDownloadCompletionBlock_)block
{
    if(self = [self initWithUrl:url completion:block]) {
        self.postJsonData = data;
    };
    return self;
}

- (void)dealloc
{
    ADLog(@"");
    [_connection cancel];
    _connection = nil;
    
    
}

- (void)setTimeout:(NSTimeInterval)timeout
{
    _timeout = timeout;
}
- (void)setEtag:(NSString *)etag
{
    if (etag)
        [self.requestHeaderFields setValue:etag forKey:@"If-None-Match"];
}
- (void)setCachePolicy:(NSURLRequestCachePolicy)cachePolicy
{
    _cachePolicy = cachePolicy;
}


- (NSMutableDictionary *)requestHeaderFields
{
    return _requestHeaderFields;
}

- (void)setProgressionBlock:(GERDownloadProgressionBlock)progressionBlock
{
    _progressionBlock = [progressionBlock copy];
}


#pragma mark -
#pragma mark Operation Start & Utility methods
#pragma mark -

- (void)start
{
    ADLog(@"");
    // Ensure that this operation starts on the main thread
    dispatch_async(MainQueue, ^{
        
        // Ensure that the operation should exute
        if( !_finished && ![self isCancelled] && self.connectionURL != nil) {
            
            // From this point on, the operation is officially executing--remember, isExecuting
            // needs to be KVO compliant!
            [self willChangeValueForKey:@"isExecuting"];
            _executing = YES;
            [self didChangeValueForKey:@"isExecuting"];
            
            
            if (self.timeout < 1.0) {
                self.timeout = 30.0;
            }
            
            // Create the NSURLConnection--this could have been done in init, but we delayed
            // until no in case the operation was never enqueued or was cancelled before starting
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.connectionURL cachePolicy:self.cachePolicy?:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.timeout];
            
            // set custom user agent
            // ---------------------
            [self.requestHeaderFields setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"UserAgent"] forKey:@"User-Agent"];
            
            
            [request setAllHTTPHeaderFields:self.requestHeaderFields];
            [self refineRequestBeforeConnection:request];
            _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [self sendToDelegateProgress];
        }
        else {
            [self done];
        }
    });
}

// This method is just for convenience. It cancels the URL connection if it
// still exists and finishes up the operation.
- (void)done
{
    ADLog(@"");
    if(_connection != nil) {
        [_connection cancel];
        _connection = nil;
    }
    
    
    // send raw content
    dispatch_async(MainQueue, ^{
        self.completionHandler(self.statusCode, self.data, self.connectionURL, self.error, [self isCancelled]);
    });
    
    // Alert anyone that we are finished
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    _executing = NO;
    _finished  = YES;
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
}

-(void)cancel
{
    ADLog(@"");
    [super cancel];
    [self done];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return _executing;
}

- (BOOL)isFinished
{
    return _finished;
}

#pragma mark -
#pragma mark URL Connection
#pragma mark -

- (void)sendToDelegateProgress
{
    if (self.progressionBlock != NULL) {
        dispatch_async(MainQueue, ^{
            self.progressionBlock(self.connectionURL, [self progress]);
        });
	}
}

- (float)progress {
    if (self.contentLength != 0) {
        return ((1.0*_dataLength) / _contentLength);
    }
    return 0;
}

- (void)refineRequestBeforeConnection:(NSMutableURLRequest *)request{
    ADLog(@"%@",_postParameters);
    if (_postParameters || _postJsonData){
        request.HTTPMethod = @"POST";
        if (_postParameters.count){
            // create an encoded query string
            NSMutableString *queryString = [[NSMutableString alloc] init];
            [_postParameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSObject *value, BOOL *stop){
#define escape(s) (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes \
(NULL, (CFStringRef)s, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
                NSString* escKey = escape(key);
                NSString* escValue = escape(value.description);
                [queryString appendFormat:@"%@=%@&", escKey, escValue];
            }];
            [queryString deleteCharactersInRange:NSMakeRange(queryString.length-1, 1)]; // remove trailing '&'
            // set request body
            NSData *body = [queryString dataUsingEncoding:NSUTF8StringEncoding];
            NSString *length = [[NSString alloc] initWithFormat:@"%u", [body length]];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setValue:length forHTTPHeaderField:@"Content-Length"];
            [request setHTTPBody:body];
        }
        else if (_postJsonData) {
            // set request body
            NSString *length = [[NSString alloc] initWithFormat:@"%u", [_postJsonData length]];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:length forHTTPHeaderField:@"Content-Length"];
            [request setHTTPBody:_postJsonData];
        }
    }
}

#pragma mark -
#pragma mark NSURLConnectionDelegate Methods


// Initial response
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    ADLog(@"%@", [response description]);

    // Check if the operation has been cancelled
    if(![self isCancelled]) {
        
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        self.statusCode = [httpResponse statusCode];
        NSDictionary *headerFields = [httpResponse allHeaderFields];
        
        NSString *etag = headerFields[@"Etag"];
        if (etag != nil) {

        }
        self.contentLength = [headerFields[@"Content-Length"] integerValue];
        switch (self.statusCode) {
            case 200:
            case 202:
            {
                if ([self loadDataInMemory]) {
                    NSUInteger contentSize = [httpResponse expectedContentLength] > 0 ? (NSUInteger)[httpResponse expectedContentLength] : 0;
                    _data = [[NSMutableData alloc] initWithCapacity:contentSize];
                }
                _dataLength = 0;
                [self sendToDelegateProgress];
                break;
            }
            case 404:
            {
                NSString* statusError  = nil;
                statusError  = NSLocalizedString(@"NetworkPageNotFoundErrorMessage", nil);
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey: statusError};
                _error = [[NSError alloc] initWithDomain:@"DownloadUrlOperation"
                                                    code:self.statusCode
                                                userInfo:userInfo];
                [self connection:connection didFailWithError:_error];
                break;
            }
            case 301:
            case 302:
            case 500:
            {
                
                NSString* statusError  = nil;
                
                statusError  = NSLocalizedString(@"GeneralNetworkErrorMessage", nil);
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey: statusError};
                _error = [[NSError alloc] initWithDomain:@"DownloadUrlOperation"
                                                    code:self.statusCode
                                                userInfo:userInfo];
                [self connection:connection didFailWithError:_error];
                break;
            }
            default:
            {
                NSString* statusError  = nil;
                statusError  = NSLocalizedString(@"GeneralNetworkErrorMessage", nil);
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey: statusError};
                _error = [[NSError alloc] initWithDomain:@"DownloadUrlOperation"
                                                    code:self.statusCode
                                                userInfo:userInfo];
                [self connection:connection didFailWithError:_error];
                break;
            }
        }
    }
    ADLog(@" %d : \n size : %lld", [connection hash], [response expectedContentLength]);
}


// The connection failed
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    ADLog(@"error code %d  : %@   : %@",[error code], [error domain], [error localizedDescription]);

    // Check if the operation has been cancelled
    if(![self isCancelled]) {
		self.data = nil;
        _dataLength = 0;
//        [[GERNetworkConnectionHelper sharedNetworkConnectionHelper] invalidateEtagforURL:self.connectionURL];
		self.error = error;
		[self done];
	}
}

// The connection received more data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    ADLog(@"data length %d ",[data length]);

    // Check if the operation has been cancelled
    if(![self isCancelled]) {
        _dataLength += [data length];
        [self.data appendData:data];
        [self performSelectorOnMainThread:@selector(sendToDelegateProgress) withObject:nil waitUntilDone:NO];
    }
}

- (BOOL)loadDataInMemory {
    return YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    ADLog(@"connection hash: %d data size : %lld", [connection hash], _dataLength);
    // Check if the operation has been cancelled
    if(![self isCancelled]) {
		[self done];
	}
}


@end
