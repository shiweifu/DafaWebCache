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

  [webCache cacheStringURL:@"http://post.smzdm.com/p/354324/"
                 recursion:YES
                     force:YES
                 imgPrefix:@"http://www.smzdm.com"
                 cssPrefix:@"http://www.smzdm.com"];

//  NSURL *url = [[NSURL alloc] initWithString:@"http://wap.fanfou.com/home"];
//  NSString *page = [NSString stringWithContentsOfURL:url
//                                            encoding:NSUTF8StringEncoding
//                                               error:nil];
//
//
//
//  [webCache cacheHTMLPage:page
//                uniqueURL:@"home_of_fanfou"
//                recursion:YES
//                    force:YES
//                imgPrefix:@"http://m.fanfou.com"
//                cssPrefix:@"http://m.fanfou.com"];

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
  DFWebCacheResult *result = [webCache getCachedURL:@"http://post.smzdm.com/p/354324/"];
  [self.webView loadHTMLString:result.contentHTML
                       baseURL:result.path];
}

@end
