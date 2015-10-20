//
// Created by shiweifu on 10/16/15.
// Copyright (c) 2015 shiweifu. All rights reserved.
//

#import <Foundation/Foundation.h>


static NSString * const DFCachePrefix  = @"com.dollop.dafawebcache";
static NSString * const DFDatabaseName = @"dafawebcache.db";

static NSString * const kURLCacheSuccessNotification = @"DFCacheUrlCacheSuccessNotification";
static NSString * const kURLCacheFailureNotification = @"DFCacheUrlCacheFailureNotification";

@interface DFWebCacheResult : NSObject

@property (nonatomic, strong) NSURL    *path;
@property (nonatomic, strong) NSString *contentHTML;

@end

@interface DFWebCache : NSObject

@property (nonatomic, copy) NSString *encodingName;

//单例模式
+ (DFWebCache *)instance;

// 缓存URL。如果不需要递归，则只下载当前url。否则下载页面中所有的css/js/img并缓存。
// 如果该URL已经被缓存，则返回NO，如果下载队列被添加，则返回YES
- (BOOL)cacheStringURL:(NSString *)string
             recursion:(BOOL)isRescursion
                 force:(BOOL)isForce
             imgPrefix:(NSString *)imgPrefix
             cssPrefix:(NSString *)cssPrefix;

// 所有已经缓存的URL列表
- (NSArray *)cachedList;

// 返回已经缓存的url
- (DFWebCacheResult *)getCachedURL:(NSString *)url;

@end