//
// Created by shiweifu on 10/16/15.
// Copyright (c) 2015 shiweifu. All rights reserved.
//

#import "DFWebCache.h"
#import "DFUtils.h"

@interface DFWebCache ()

@property (nonatomic, strong) NSURL *cacheURL;
@property (nonatomic, strong) NSOperationQueue *dafaQueue;

@end

@implementation DFWebCache
{
}

- (instancetype)init
{
  self = [super init];
  [self createCacheDirectory];
  return self;
}

- (BOOL)createCacheDirectory
{
  if ([[NSFileManager defaultManager] fileExistsAtPath:[self.cacheURL path]])
    return NO;

  NSError *error = nil;
  BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:_cacheURL
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:&error];
  return success;
}

- (NSURL *)cacheURL
{
  if(!_cacheURL)
  {
    NSString *pathComponent = DFCachePrefix;
    _cacheURL = [NSURL fileURLWithPathComponents:@[[DFUtils documentPath], pathComponent ]];
  }
  return _cacheURL;
}


//当缓存url前会先创建对应的文件夹
- (BOOL)createDirectoryForURLString:(NSString *)urlString
{
  return NO;
}

- (void)cacheStringURL:(NSString *)string
             recursion:(BOOL)isRescursion
             imgPrefix:(NSString *)imgPrefix
             cssPrefix:(NSString *)cssPrefix
              jsPrefix:(NSString *)jsPrefix;
{

}

-(NSOperationQueue *)dafaQueue
{
  if(!_dafaQueue)
  {
    _dafaQueue = [[NSOperationQueue alloc] init];
  }
  return _dafaQueue;
}

//得到所有缓存的url
- (NSArray *)cachedURLList;
{
  return @[];
}

- (DFWebCacheResult *)getCachedURL:(NSString *)url;
{
  return nil;
}

@end

@implementation DFWebCacheResult

@end
