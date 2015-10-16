//
//  ViewController.m
//  DafaWebCache
//
//  Created by shiweifu on 10/14/15.
//  Copyright (c) 2015 shiweifu. All rights reserved.
//

#import "ViewController.h"
#import "DFDownloadOperation.h"
#import "TestOperation.h"

@interface ViewController ()

@property(nonatomic, strong) NSLock *lock;
@property(assign, atomic) NSUInteger num;

@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation ViewController

- (IBAction)onCacheURL:(id)sender {
  NSString *url = @"http://segmentfault.com/a/1190000003862596";
  DFDownloadOperation *operation = [[DFDownloadOperation alloc] initWithAddress:url
                                                                     saveToPath:nil
                                                                     completion:^(NSString *response, NSHTTPURLResponse *urlResponse, NSError *error)
          {
            NSLog(@"%@", response);
          }];
//  [self.queue addOperation:operation];

  TestOperation *to = [[TestOperation alloc] init];
  [to setCompletionBlock:^
  {
    NSLog(@"run operation finish");
  }];
  [self.queue addOperation:to];

}

- (NSOperationQueue *)queue
{
  if(!_queue)
  {
    _queue = [[NSOperationQueue alloc] init];
  }
  return _queue;
}

- (IBAction)loadFromCache:(id)sender {
}

@end
