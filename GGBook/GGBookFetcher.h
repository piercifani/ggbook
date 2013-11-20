//
//  GGBookFetcher.h
//  GGBook
//
//  Created by Pierluigi Cifani on 20/11/13.
//  Copyright (c) 2013 Voalte Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Book;

@interface GGBookFetcher : NSObject

+ (instancetype) sharedInstance;

- (NSFetchedResultsController *) booksFRC;
- (void) fetchDetailsForBook:(Book *)book completion:(void (^)(BOOL))block;

@end
