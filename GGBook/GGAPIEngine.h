//
//  GGAPIEngine.h
//  GGBook
//
//  Created by Pierluigi Cifani on 20/11/13.
//  Copyright (c) 2013 Voalte Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GGAPIEngine : NSObject

+ (instancetype) sharedInstance;

- (void) getBooks:(void (^)(id))block;

@end
