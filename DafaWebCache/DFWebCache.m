//
// Created by shiweifu on 10/16/15.
// Copyright (c) 2015 shiweifu. All rights reserved.
//

#import <FMDB/FMDB.h>
#import "DFWebCache.h"
#import "DFUtils.h"
#import "DFDownloadOperation.h"

@interface DFWebCache ()

@property (nonatomic, strong) NSURL *cacheURL;
@property (nonatomic, strong) NSURL *cacheDBURL;
@property (nonatomic, strong) NSOperationQueue *dafaQueue;

@end

@implementation DFWebCache
{
}

- (instancetype)init
{
  self = [super init];
  [self createDatabase];
  [self createCacheDirectory];
  return self;
}

- (void)createDatabase
{
  FMDatabase *db   = [self openDB];
  [db executeUpdate:@"CREATE TABLE Dafa (url text, for_url, base_url text, path text, data blob);"];
  [db close];
}

- (BOOL)createCacheDirectory
{
  if ([[NSFileManager defaultManager] fileExistsAtPath:[self.cacheURL path]])
    return NO;

  NSError *error   = nil;
  BOOL     success = [[NSFileManager defaultManager] createDirectoryAtURL:self.cacheURL
                                              withIntermediateDirectories:YES
                                                               attributes:nil
                                                                    error:&error];
  return success;
}

- (NSURL *)cacheFileWithName:(NSString *)name
{
  NSURL *result = [[self cacheURL] URLByAppendingPathComponent:name];
  return result;
}

- (NSURL *)cacheURL
{
  if(!_cacheURL)
  {
    NSString *pathName = DFCachePrefix;
    _cacheURL = [NSURL fileURLWithPathComponents:@[[DFUtils documentPath], pathName ]];
  }
  return _cacheURL;
}

- (NSURL *)databaseURL
{
  if(!_cacheDBURL)
  {
    NSString *pathName = DFDatabaseName;
    _cacheDBURL = [NSURL fileURLWithPathComponents:@[[DFUtils documentPath], pathName ]];
  }

  return _cacheDBURL;
}

//当缓存url前会先创建对应的文件夹
- (BOOL)createDirectoryForURLString:(NSString *)urlString
{
  return NO;
}

- (BOOL)cacheStringURL:(NSString *)url
             recursion:(BOOL)isRescursion
                 force:(BOOL)isForce
             imgPrefix:(NSString *)imgPrefix
             cssPrefix:(NSString *)cssPrefix
              jsPrefix:(NSString *)jsPrefix;
{
  __block DFWebCache   *weakSelf  = self;
  if(isForce)
  {
    [self deleteRowWithURL:url];
  }
  else if([self isCached:url])
  {
    return NO;
  }

  DFDownloadCompletionHandler noRescursionBlock = ^(NSData *response, NSHTTPURLResponse *urlResponse, NSError *error)
                                                                     {
                                                                       [weakSelf insertData:response
                                                                                     forUrl:urlResponse.URL.absoluteString
                                                                               orignalPath:nil
                                                                                        url:urlResponse.URL];
                                                                       if(!response || error)
                                                                       {
                                                                         [[NSNotificationCenter defaultCenter] postNotificationName:kURLCacheFailureNotification
                                                                                                                             object:urlResponse.URL];
                                                                         return;
                                                                       }
                                                                       [[NSNotificationCenter defaultCenter] postNotificationName:kURLCacheSuccessNotification
                                                                                                                           object:urlResponse.URL];
                                                                     };


  DFDownloadCompletionHandler rescursionBlock = ^(NSData *response, NSHTTPURLResponse *urlResponse, NSError *error)
  {
    [weakSelf insertData:response
                  forUrl:urlResponse.URL.absoluteString
             orignalPath:nil
                     url:urlResponse.URL];
    if(!response || error)
    {
      [[NSNotificationCenter defaultCenter] postNotificationName:kURLCacheFailureNotification
                                                          object:urlResponse.URL];
      return;
    }

    NSString *htmlString = [[NSString alloc] initWithData:response
                                                 encoding:NSUTF8StringEncoding];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<img[^<^{^(]+src=['\"]{0,1}([^>^\\s^\"]*)['\"]{0,1}[^>]*>"
                                                                           options:nil
                                                                             error:nil];
    NSArray *imageURLs = [regex matchesInString:htmlString
                                        options:0
                                          range:NSMakeRange(0, htmlString.length)];


    NSBlockOperation *notiOp = [NSBlockOperation blockOperationWithBlock:^
    {
      [[NSNotificationCenter defaultCenter] postNotificationName:kURLCacheSuccessNotification
                                                          object:urlResponse.URL];
    }];

    for(NSTextCheckingResult *t in imageURLs)
    {
      NSRange r = [t rangeAtIndex:1];
      NSString *imagePath = [htmlString substringWithRange:r];
      NSString *imgURL = @"";

      //拼接字符串成为一个完整的URL
      if([imagePath hasPrefix:@"//"])
      {
        imgURL = [NSString stringWithFormat:@"http:%@", imagePath];
      }
      else if ([imagePath hasPrefix:@"/"])
      {
        imgURL = [NSString stringWithFormat:@"%@%@", imgPrefix, imagePath];
      }

      NSLog(@"%@", imgURL);

      if([imgURL isEqualToString:@""])
      {
        continue;
      }

      __block NSString *blockImagePath = imagePath;

      // 建立一个队列，发出请求
      DFDownloadOperation *imgOP = [[DFDownloadOperation alloc] initWithAddress:imgURL
                                                                     saveToPath:nil
                                                                     completion:^(NSData *imgData, NSHTTPURLResponse *imgResponse, NSError *imgErr)
                                                                     {
                                                                       if(imgData || !imgErr )
                                                                       {
                                                                         [weakSelf insertData:imgData
                                                                                       forUrl:urlResponse.URL.absoluteString
                                                                                  orignalPath:blockImagePath
                                                                                          url:imgResponse.URL];
                                                                       }
                                                                     }];
      [notiOp addDependency:imgOP];
      [weakSelf.dafaQueue addOperation:imgOP];
    }
    [weakSelf.dafaQueue addOperation:notiOp];
  };

  DFDownloadOperation *operation = nil;

  if(isRescursion)
  {
    operation = [[DFDownloadOperation alloc] initWithAddress:url
                                                  saveToPath:nil
                                                  completion:rescursionBlock];
  }
  else
  {
    operation = [[DFDownloadOperation alloc] initWithAddress:url
                                                  saveToPath:nil
                                                  completion:noRescursionBlock];
  }

  [self.dafaQueue addOperation:operation];
  return YES;
}

- (void)deleteRowWithURL:(NSString *)url
{
  FMDatabase *db = [self openDB];
  [db executeUpdate:@"DELETE FROM Dafa WHERE for_url=?;", url];
  [db commit];
  [db close];
}

-(BOOL)isCached:(NSString *)url
{
  FMDatabase *db = [self openDB];
  FMResultSet *rs = [db executeQuery:@"SELECT * FROM Dafa WHERE url=?;", url];
  BOOL b = NO;
  if(rs.next)
  {
    b = YES;
  }
  [rs close];
  [db close];
  return b;
}

- (void)insertData:(NSData *)data
            forUrl:(NSString *)forUrl
        orignalPath:path
               url:(NSURL *)url
{
  NSString *sql = @"INSERT INTO Dafa(url, for_url, base_url, path, data) VALUES(?, ?, ?, ?, ?);";
  NSURLComponents *components = [NSURLComponents componentsWithString:url.absoluteString];
  if(!path)
  {
    path = @"";
  }

  FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.databaseURL.path];
  [dbQueue inDatabase:^(FMDatabase *db)
  {
    [db executeUpdate:sql, url.absoluteString, forUrl, components.host, path, data];
  }];
  [dbQueue close];
}

+ (DFWebCache *)instance
{
  static DFWebCache *_instance = nil;

  @synchronized (self)
  {
    if (_instance == nil)
    {
      _instance = [[self alloc] init];
    }
  }

  return _instance;
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
- (NSArray *)cachedList;
{
  NSMutableArray *result = [@[] mutableCopy];
  FMDatabase *db         = [self openDB];
  FMResultSet *rs        = [db executeQuery:@"SELECT url FROM Dafa;"];
  while([rs next])
  {
    NSString *url = [rs stringForColumnIndex:0];
    [result addObject:url];
  }

  [rs close];
  [db close];
  return result;
}

- (DFWebCacheResult *)getCachedURL:(NSString *)url
{
  FMDatabase *db         = [self openDB];
  FMResultSet *rs        = [db executeQuery:@"SELECT data FROM Dafa WHERE url = ?;", url];
  NSString *contentHTML  = @"";

  // 得到 content html
  if(![rs next])
  {
    return nil;
  }
  else
  {
    contentHTML = [rs stringForColumnIndex:0];
  }

  [rs close];

  // 得到这个页面其他缓存的内容

  rs = [db executeQuery:@"SELECT url, path, data FROM Dafa WHERE for_url = ?;", url];
  while([rs next])
  {
    NSData   *data    = [rs   dataForColumn:@"data"];
    NSString *path    = [rs stringForColumn:@"path"];
    NSString *fullUrl = [rs stringForColumn:@"url"];

    if([path isEqualToString:@""])
    {
      continue;
    }

    NSURLComponents *components = [[NSURLComponents alloc] initWithString:fullUrl];
    NSString        *name = [components.path stringByReplacingOccurrencesOfString:@"/"
                                                                       withString:@"_"];


    // 将相关内容的路径替换为新的路径

    contentHTML = [contentHTML stringByReplacingOccurrencesOfString:path
                                                         withString:name];

    [data writeToURL:[self cacheFileWithName:name]
          atomically:YES];
  }

  [rs close];

  // 生成CacheResult对象
  DFWebCacheResult *result = [[DFWebCacheResult alloc] init];
  result.contentHTML       = contentHTML;
  result.path              = [self cacheURL];

  [db close];

  return result;
}

-(FMDatabase *)openDB
{
  FMDatabase *db   = [FMDatabase databaseWithPath:self.databaseURL.absoluteString];
  NSLog(@"open dataBase: %@", self.databaseURL);
  [db open];
  return db;
}

@end

@implementation DFWebCacheResult

@end
