//
//  GGAPIEngine.m
//  GGBook
//
//  Created by Pierluigi Cifani on 20/11/13.
//  Copyright (c) 2013 Voalte Inc. All rights reserved.
//

#import "GGAPIEngine.h"
#import "AFHTTPSessionManager.h"

#define kProductionApiURL   @"http://assignment.golgek.mobi/"

#define kListPath           @"/api/v10/items"

@interface GGAPIEngine ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation GGAPIEngine

+ (instancetype) sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        //Start AFNetworking shit
        NSURL *baseURL = [NSURL URLWithString:kProductionApiURL];
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        
    }
    return self;
}

- (void) getBooks:(void (^)(id))block;
{
    [self.sessionManager GET:kListPath
                  parameters:[NSDictionary dictionary]
                     success:^(NSURLSessionDataTask *task, id responseObject){
                         block(responseObject);
                     }
                     failure:^(NSURLSessionDataTask *task, NSError *error){
                         NSLog(@"Error! %@", error);
                         block(nil);
                     }];
}

@end
