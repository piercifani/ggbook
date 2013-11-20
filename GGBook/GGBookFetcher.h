//
//  GGBookFetcher.h
//  GGBook
//
//  Created by Pierluigi Cifani on 20/11/13.
//  Copyright (c) 2013 Voalte Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GGBookFetcher : NSObject

+ (instancetype) sharedInstance;
- (NSFetchedResultsController *) fetchBooks;

@end
