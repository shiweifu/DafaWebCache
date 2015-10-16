//
// Created by shiweifu on 10/15/15.
// Copyright (c) 2015 shiweifu. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
   DFDownloadOperationStateReady = 0,
   DFDownloadOperationStateExecuting,
   DFDownloadOperationStateFinished
};

typedef NSUInteger DafaDownloadOperationState;

typedef void (^DFDownloadCompletionHandler)(NSString *response, NSHTTPURLResponse *urlResponse, NSError *error);


@interface DFDownloadOperation : NSOperation <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
  BOOL executing;
  BOOL finished;
}

@property (nonatomic, strong) NSString *userAgent;

- (DFDownloadOperation *)initWithAddress:(NSString*)urlString
                              saveToPath:(NSString*)savePath
                              completion:(DFDownloadCompletionHandler)completionBlock;

@end
