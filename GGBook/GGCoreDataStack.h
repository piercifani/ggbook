//
//  PCCoreDataStack.h
//  Bank
//
//  Created by Pierluigi Cifani on 27/9/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreData;

typedef void(^GGBackgroundCoreDataBlock)(NSManagedObjectContext *);

@interface GGCoreDataStack : NSObject

+ (instancetype) sharedInstance;

- (NSManagedObjectContext *) defaultContext;

- (NSFetchedResultsController *) booksFRC;
- (NSArray *) bookWithID:(NSString *)bookID context:(NSManagedObjectContext *)context;

- (void) performBackgroundCoreDataOperation:(GGBackgroundCoreDataBlock)operationBlock;
- (void) performBackgroundCoreDataOperation:(GGBackgroundCoreDataBlock)operationBlock
                                 completion:(void (^)(NSError *))block;

@end
