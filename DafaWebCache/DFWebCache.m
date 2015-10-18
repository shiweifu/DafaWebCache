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
@property (nonatomic, strong) NSOperationQueue *dafaQueue;

@end

@implementation DFWebCache
{
}

- (instancetype)init
{
  self = [super init];
  [self createDatabase];
  return self;
}

- (void)createDatabase
{
  NSString   *path = self.databaseURL.path;
  FMDatabase *db   = [FMDatabase databaseWithPath:path];
  [db open];
  [db executeUpdate:@"CREATE TABLE Dafa (url text, base_url text, path text, data blob);"];
  [db close];
}

- (BOOL)createCacheDirectory
{
  if ([[NSFileManager defaultManager] fileExistsAtPath:[self.cacheURL path]])
    return NO;

  NSError *error = nil;
  BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:self.cacheURL
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:&error];
  return success;
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
  if(!_cacheURL)
  {
    NSString *pathName = DFDatabaseName;
    _cacheURL = [NSURL fileURLWithPathComponents:@[[DFUtils documentPath], pathName ]];
  }
  return _cacheURL;
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

  DFDownloadOperation *operation = [[DFDownloadOperation alloc] initWithAddress:url
                                                                     saveToPath:nil
                                                                     completion:^(NSData *response, NSHTTPURLResponse *urlResponse, NSError *error)
                                                                     {
                                                                       [weakSelf insertData:response
                                                                                        url:urlResponse.URL];
                                                                       if(!response || error)
                                                                       {
                                                                         [[NSNotificationCenter defaultCenter] postNotificationName:kURLCacheFailureNotification
                                                                                                                             object:urlResponse.URL];
                                                                         return;
                                                                       }
                                                                       [[NSNotificationCenter defaultCenter] postNotificationName:kURLCacheSuccessNotification
                                                                                                                           object:urlResponse.URL];
                                                                     }];
  [self.dafaQueue addOperation:operation];
  return YES;
}

- (void)deleteRowWithURL:(NSString *)url
{
  FMDatabase *db   = [FMDatabase databaseWithPath:self.databaseURL.absoluteString];
  [db open];
  [db executeUpdate:@"DELETE FROM Dafa WHERE url=?;", url];
  [db commit];
  [db close];
}

-(BOOL)isCached:(NSString *)url
{
  FMDatabase *db   = [FMDatabase databaseWithPath:self.databaseURL.absoluteString];
  [db open];
  FMResultSet *rs = [db executeQuery:@"SELECT * FROM Dafa WHERE url=?", url];
  BOOL b = NO;
  if(rs.next)
  {
    b = YES;
  }
  [db close];
  return b;
}

- (void)insertData:(NSData *)data
               url:(NSURL *)url
{
  NSString *sql = @"INSERT INTO Dafa(url, base_url, path, data) VALUES(?, ?, ?, ?);";
  NSURLComponents *components = [NSURLComponents componentsWithString:url.absoluteString];

  FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.databaseURL.path];
  [dbQueue inDatabase:^(FMDatabase *db)
  {
    [db executeUpdate:sql, url.absoluteString, components.host, components.host, data];
  }];
  [dbQueue close];
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

@end

@implementation DFWebCacheResult

@end
