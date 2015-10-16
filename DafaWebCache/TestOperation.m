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

}

- (void)main
{
  NSLog(@"%@", @"start operation");

  self.connection = [[NSURLConnection alloc] initWithRequest:self.request
                                                    delegate:self];
  [self.connection start];
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

@end

