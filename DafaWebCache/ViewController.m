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
#import "DFUtils.h"
#import "DFWebCache.h"

@interface ViewController ()

@property(nonatomic, strong) NSLock *lock;
@property(assign, atomic) NSUInteger num;

@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(cacheSuccess:)
                                               name:kURLCacheSuccessNotification
                                             object:nil];
}

- (void)cacheSuccess:(NSNotification *)noti
{
  NSLog(@"%@", noti);
}

-(void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:kURLCacheSuccessNotification
                                                object:nil];
}

- (IBAction)onCacheURL:(id)sender {

  DFWebCache *webCache = [[DFWebCache alloc] init];
  [webCache cacheStringURL:@"http://segmentfault.com/a/1190000003862596"
                 recursion:NO
                     force:NO
                 imgPrefix:@"http://segmentfault.com"
                 cssPrefix:@"http://segmentfault.com"
                  jsPrefix:@"http://segmentfault.com"];

  return;

  NSString *url = @"http://segmentfault.com/a/1190000003862596";
  DFDownloadOperation *operation = [[DFDownloadOperation alloc] initWithAddress:url
                                                                     saveToPath:nil
                                                                     completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error)
          {
            NSLog(@"%@", response);
          }];
  [operation setCompletionBlock:^
  {
    NSLog(@"run operation finish");
  }];

  NSString *documentPath = [DFUtils documentPath];


  [self.queue addOperation:operation];

//  TestOperation *to = [[TestOperation alloc] init];
//  __block TestOperation *bto = to;
//  [to setCompletionBlock:^
//  {
//    NSLog(@"%d", bto.isFinished);
//    NSLog(@"run operation finish");
//  }];
//  [self.queue addOperation:to];
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
