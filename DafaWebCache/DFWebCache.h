//
// Created by shiweifu on 10/16/15.
// Copyright (c) 2015 shiweifu. All rights reserved.
//

#import <Foundation/Foundation.h>


static NSString * const DFCachePrefix = @"com.dollop.dafawebcache";

@interface DFWebCacheResult : NSObject

@property (nonatomic, strong) NSURL    *path;
@property (nonatomic, strong) NSString *contentHTML;

@end

@interface DFWebCache : NSObject

// 缓存URL.如果不需要递归,则只下载当前url.否则下载页面中所有的css/js/img
- (void)cacheStringURL:(NSString *)string
             recursion:(BOOL)isRescursion
             imgPrefix:(NSString *)prefix
             cssPrefix:(NSString *)prefix1
              jsPrefix:(NSString *)prefix2;

// 所有已经缓存的URL列表
- (NSArray *)cachedURLList;

// 返回已经缓存的url
- (DFWebCacheResult *)getCachedURL:(NSString *)url;

@end