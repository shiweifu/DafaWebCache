//
// Created by shiweifu on 10/16/15.
// Copyright (c) 2015 shiweifu. All rights reserved.
//

#import "DFUtils.h"


@implementation DFUtils
{

}

+ (NSString *)documentPath
{
  NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  return documentPath;
}

+ (NSString *)savePathWithURLString:(NSString *)urlString
{
  NSString *documentPath      = [DFUtils documentPath];
  NSURLComponents *components = [[NSURLComponents alloc] initWithString:urlString];
  NSString *urlPath = components.path;
  urlPath = [urlPath stringByReplacingOccurrencesOfString:@"/"
                                               withString:@"_"];

  NSString *path = [NSString stringWithFormat:@"dafa_webcache/%@", urlPath];

  return [documentPath stringByAppendingPathComponent:path];
}

@end
