//
// Created by shiweifu on 15/10/16.
// Copyright (c) 2015 shiweifu. All rights reserved.
//

#import "TestOperation.h"


@interface TestOperation ()
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) NSURLConnection *connection;
@end

@implementation TestOperation
{
  BOOL executing;
  BOOL finished;
}

- (instancetype)init
{
  self = [super init];
  finished  = NO;
  executing = NO;

  return self;
}


- (void)start
{
  [super start];
  NSLog(@"%@", @"start operation");

  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionDataTask *task = [session dataTaskWithRequest:self.request
                                          completionHandler:
                                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    [self willChangeValueForKey:@"isFinished"];
                                                    finished = YES;
                                                    [self didChangeValueForKey:@"isFinished"];
                                                  }];
  [self willChangeValueForKey:@"isExecuting"];
  [task resume];
  executing = YES;
  [self didChangeValueForKey:@"isExecuting"];
}

-(NSMutableURLRequest *)request
{
  if(!_request)
  {
    NSURL *url = [[NSURL alloc] initWithString:@"http://segmentfault.com/a/1190000003852397"];
    _request = [[NSMutableURLRequest alloc] initWithURL:url];
    [_request setHTTPMethod:@"GET"];
  }
  return _request;
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{

}


- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{

}

- (BOOL)isExecuting
{
  return executing;
}

- (BOOL)isFinished
{
  return finished;
}

@end

