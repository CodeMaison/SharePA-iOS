//
//  GERJSONDownloader.m
//  LExpress
//
//  Created by rcodarini on 23/06/14.
//  Copyright (c) 2014 Groupe Express-Roularta. All rights reserved.
//

#import "GERJSONDownloader.h"
#import "GERHTTPCachedDownloadOperation.h"

static NSOperationQueue *DownloadQueue;
static dispatch_queue_t MainQueue;
static dispatch_queue_t ParsingQueue;


NSString *const GERJSONDownloaderErrorDomain = @"GERJSONDownloaderErrorDomain";
const int GERErrorCodeJSONDownloaderBadAccess = 101;
const int GERErrorCodeJSONDownloaderJSONParsingFailed = 103;

@interface GERJSONDownloader()

@property (nonatomic, copy) GERJSONDownloaderCompletionBlock callbackBlock;

@end

#pragma mark -

@implementation GERJSONDownloader

+(void)initialize
{
    DownloadQueue = [[NSOperationQueue alloc] init];
    [DownloadQueue setMaxConcurrentOperationCount:4];
    MainQueue = dispatch_get_main_queue();
    ParsingQueue = dispatch_queue_create("parsingQueue", DISPATCH_QUEUE_CONCURRENT);
}

+ (void)getJSONObjectFromURL:(NSURL *)url completionBlock:(GERJSONDownloaderCompletionBlock)block
{
    ADLog(@"%@", url);
    [GERHTTPCachedDownloadOperation getRequestForURL:url
                                               queue:DownloadQueue
                                         cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                     completionBlock:^(NSInteger code, NSData *data, NSURL *URLSource, NSError *error, BOOL isCancelled) {
                                        __block NSError *err = error;
                                         
                                         dispatch_async(ParsingQueue, ^{
                                             id JSONobject = nil;
                                             if (!isCancelled) {
                                                 if (!error) {
                                                     JSONobject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                     
                                                     if (!JSONobject) {
                                                         err = [NSError errorWithDomain:GERJSONDownloaderErrorDomain code:GERErrorCodeJSONDownloaderJSONParsingFailed userInfo:nil];
                                                     }
                                                 }
                                             }
                                             
                                             dispatch_async(MainQueue, ^{
                                                 block(JSONobject, URLSource, err, isCancelled);
                                             });
                                         });
                                     }];
}

@end
