//
//  GERJSONDownloader.h
//  LExpress
//
//  Created by rcodarini on 23/06/14.
//  Copyright (c) 2014 Groupe Express-Roularta. All rights reserved.
//

typedef void(^GERJSONDownloaderCompletionBlock)(id data, NSURL *URLSource, NSError* error, BOOL isCancelled);      // data class can be NSArray or NSDictionary

extern NSString *const GERJSONDownloaderErrorDomain;
extern const int GERErrorCodeJSONDownloaderBadAccess;
extern const int GERErrorCodeJSONDownloaderJSONParsingFailed;

@interface GERJSONDownloader : NSObject

+ (void)getJSONObjectFromURL:(NSURL *)url completionBlock:(GERJSONDownloaderCompletionBlock)block;

@end
