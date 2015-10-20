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
@property (weak, nonatomic) IBOutlet UIWebView *webView;

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

  DFWebCache *webCache = [DFWebCache instance];
//  [webCache setEncodingName:@"GBK"];
  [webCache cacheStringURL:@"http://www.v2ex.com/"
                 recursion:YES
                     force:YES
                 imgPrefix:@"http://www.v2ex.com"
                 cssPrefix:@"http://www.v2ex.com"];


  return;
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
  DFWebCache *webCache     = [DFWebCache instance];
  DFWebCacheResult *result = [webCache getCachedURL:@"http://www.v2ex.com/"];
  [self.webView loadHTMLString:result.contentHTML
                       baseURL:result.path];
}

@end
