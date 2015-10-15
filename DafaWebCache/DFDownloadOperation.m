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
@property (nonatomic, strong) NSURLConnection *operationConnection;
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

  return self;
}

- (void)main
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

  self.operationConnection = [[NSURLConnection alloc] initWithRequest:self.operationRequest
                                                             delegate:self
                                                     startImmediately:NO];

  NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
  BOOL inBackgroundAndInOperationQueue = (currentQueue != nil && currentQueue != [NSOperationQueue mainQueue]);
  NSRunLoop *targetRunLoop = (inBackgroundAndInOperationQueue) ? [NSRunLoop currentRunLoop] : [NSRunLoop mainRunLoop];

  if(self.savePath) // schedule on main run loop so scrolling doesn't prevent UI updates of the progress block
    [self.operationConnection scheduleInRunLoop:targetRunLoop forMode:NSRunLoopCommonModes];
  else
    [self.operationConnection scheduleInRunLoop:targetRunLoop forMode:NSDefaultRunLoopMode];

  [self.operationConnection start];

  self.state = DFDownloadOperationStateExecuting;
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

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
  [self callCompletionBlockWithResponse:nil error:error];
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
  self.expectedContentLength = response.expectedContentLength;
  self.receivedContentLength = 0;
  self.operationURLResponse = (NSHTTPURLResponse*)response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  dispatch_group_async(self.saveDataDispatchGroup, self.saveDataDispatchQueue, ^{
    if(self.savePath) {
      @try { //writeData: can throw exception when there's no disk space. Give an error, don't crash
        [self.operationFileHandle writeData:data];
      }
      @catch (NSException *exception) {
        [self.operationConnection cancel];
        NSError *writeError = [NSError errorWithDomain:@"DFDownloadOperation error"
                                                  code:0
                                              userInfo:exception.userInfo];
        [self callCompletionBlockWithResponse:nil error:writeError];
      }
    }
    else
      [self.operationData appendData:data];
  });
}

- (void)callCompletionBlockWithResponse:(id)response
                                  error:(NSError *)error
{
  if(self.operationCompletionBlock && !self.isCancelled)
  {
    NSData *responseData = response;
    NSString *responseString = [[NSString alloc] initWithData:responseData
                                                     encoding:NSUTF8StringEncoding];
    self.operationCompletionBlock(responseString, self.operationURLResponse, error);
  }

  [self finish];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  dispatch_group_notify(self.saveDataDispatchGroup, self.saveDataDispatchQueue, ^{
    id response = [NSData dataWithData:self.operationData];
    NSError *error = nil;
    [self callCompletionBlockWithResponse:response error:error];
  });
}

- (void)finish {
  [self.operationConnection cancel];
  self.operationConnection = nil;

  self.state = DFDownloadOperationStateFinished;
}

@end

