//
// Created by shiweifu on 10/15/15.
// Copyright (c) 2015 shiweifu. All rights reserved.
//

#import "DFDownloadOperation.h"


@interface DFDownloadOperation ()

@property (nonatomic, copy) DFDownloadCompletionHandler operationCompletionBlock;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) NSString *savePath;
@property (nonatomic, strong) NSMutableURLRequest *operationRequest;

@property (nonatomic) int state;
@property (nonatomic, strong) NSFileHandle *operationFileHandle;
@property (nonatomic, strong) NSMutableData *operationData;
@property (nonatomic, strong) NSTimer *timeoutTimer;
@property (nonatomic) NSTimeInterval timeoutInterval;
@property (nonatomic) long long int expectedContentLength;
@property (nonatomic) int receivedContentLength;
@property (nonatomic, strong) NSHTTPURLResponse *operationURLResponse;
@property (nonatomic, strong) dispatch_group_t saveDataDispatchGroup;
@property (nonatomic, strong) dispatch_queue_t saveDataDispatchQueue;
@end

@implementation DFDownloadOperation
{
}
- (DFDownloadOperation *)initWithAddress:(NSString *)urlString
                              saveToPath:(NSString *)savePath
                              completion:(DFDownloadCompletionHandler)completionBlock
{
  self = [super init];
  self.savePath  = savePath;
  self.urlString = urlString;

  NSURL *url = [[NSURL alloc] initWithString:urlString];
  self.operationRequest = [[NSMutableURLRequest alloc] initWithURL:url];
  [self.operationRequest setHTTPMethod:@"GET"];
  self.state = DFDownloadOperationStateReady;

  self.saveDataDispatchGroup = dispatch_group_create();
  self.saveDataDispatchQueue = dispatch_queue_create("com.dafa.download_operation", DISPATCH_QUEUE_SERIAL);

  self.operationCompletionBlock = completionBlock;

  executing = NO;
  finished  = NO;

  return self;
}

- (BOOL)isConcurrent {
  return YES;
}

- (BOOL)isExecuting {
  return executing;
}

- (BOOL)isFinished {
  return finished;
}

- (void)start
{
  if(self.userAgent)
  {
    [self.operationRequest setValue:self.userAgent
                 forHTTPHeaderField:@"User-Agent"];
  }

  if(self.savePath)
  {
    [[NSFileManager defaultManager] createFileAtPath:self.savePath contents:nil attributes:nil];
    self.operationFileHandle = [NSFileHandle fileHandleForWritingAtPath:self.savePath];
  }
  else
  {
    self.operationData = [[NSMutableData alloc] init];
    self.timeoutTimer  = [NSTimer scheduledTimerWithTimeInterval:self.timeoutInterval
                                                          target:self
                                                        selector:@selector(requestTimeout)
                                                        userInfo:nil
                                                         repeats:NO];
    [self.operationRequest setTimeoutInterval:self.timeoutInterval];
  }

  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionDataTask *task = [session dataTaskWithRequest:self.operationRequest
                                          completionHandler:
                                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if(self.operationCompletionBlock)
                                                    {
                                                      dispatch_sync(dispatch_get_main_queue(), ^{
                                                        self.operationCompletionBlock(data, response, error);
                                                      });
                                                    }
                                                    [self finish];
                                                  }];
  [self willChangeValueForKey:@"isExecuting"];
  [task resume];
  executing = YES;
  self.state = DFDownloadOperationStateExecuting;
  [self didChangeValueForKey:@"isExecuting"];
}

- (NSTimeInterval)timeoutInterval {
  if(_timeoutInterval == 0)
    return 50;
  return _timeoutInterval;
}

- (void)requestTimeout {

  NSURL *failingURL = self.operationRequest.URL;

  NSDictionary *userInfo = @{NSLocalizedDescriptionKey          : @"The operation timed out.",
                             NSURLErrorFailingURLErrorKey       : failingURL,
                             NSURLErrorFailingURLStringErrorKey : failingURL.absoluteString};

  NSError *timeoutError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:userInfo];
  [self connection:nil didFailWithError:timeoutError];
}

#pragma mark - NSURLConnectionDelegate

- (void)finish {
  self.state = DFDownloadOperationStateFinished;

  [self willChangeValueForKey:@"isFinished"];
  finished = YES;
  [self didChangeValueForKey:@"isFinished"];
}

@end

