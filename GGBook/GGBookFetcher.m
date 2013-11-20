//
//  GGBookFetcher.m
//  GGBook
//
//  Created by Pierluigi Cifani on 20/11/13.
//  Copyright (c) 2013 Voalte Inc. All rights reserved.
//

#import "GGBookFetcher.h"
#import "GGAPIEngine.h"
#import "GGCoreDataStack.h"
#import "Book.h"

@import CoreData;

@interface GGBookFetcher ()
{
    dispatch_queue_t backgroundQueue;
}
@end

@implementation GGBookFetcher

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
        backgroundQueue = dispatch_queue_create("com.goldengekko.fetcher", NULL);
        [self getBooks];
    }
    return self;
}

- (NSFetchedResultsController *) booksFRC;
{
    return [[GGCoreDataStack sharedInstance] booksFRC];
}

- (void) getBooks
{
    [[GGAPIEngine sharedInstance] getBooks:^(id response){
        
        [self processBooksResponse:response];
    }];
}

- (void) fetchDetailsForBook:(Book *)book completion:(void (^)(BOOL))block;
{
    [[GGAPIEngine sharedInstance] getDetailsForBookInPath:book.detailsPath
                                               completion:^(id result) {
                                                   
                                                   if (result == nil)
                                                   {
                                                       block(NO);
                                                   }
                                                   
                                                   [self processDetails:result
                                                          forBookWithID:book.iID
                                                         userCompletion:block];
                                               }];

}

- (void) processBooksResponse:(NSArray *)response
{
    [[GGCoreDataStack sharedInstance] performBackgroundCoreDataOperation:^(NSManagedObjectContext *backgroundMOC){
        
        for (NSDictionary *book in response)
        {
            [self processBook:book inContext:backgroundMOC];
        }
    }];
}

- (void) processDetails:(NSDictionary *)details
          forBookWithID:(NSString *)bookID
         userCompletion:(void (^)(BOOL))block
{
    GGCoreDataStack *stack = [GGCoreDataStack sharedInstance];
    [stack performBackgroundCoreDataOperation:^(NSManagedObjectContext *backgroundMOC){
        
        NSArray *array = [[GGCoreDataStack sharedInstance] bookWithID:bookID context:backgroundMOC];
        if ([array count])
        {
            Book *book = [array firstObject];
            book.author = details[@"author"];
            book.price = details[@"price"];
            book.imagePath = details[@"image"];
        }
    }
                                   completion:^(NSError *error) {
                                       if (error)
                                       {
                                           block(NO);
                                       }
                                       else
                                       {
                                           block(YES);
                                       }
                                   }];
}

- (void) processBook:(NSDictionary *)book inContext:(NSManagedObjectContext *)context
{
    NSString *bookID = [book objectForKey:@"id"];
    
    NSArray *array = [[GGCoreDataStack sharedInstance] bookWithID:bookID context:context];
    if ([array count])
    {
        NSLog(@"This book already exists");
    }
    else
    {
        //Create new book!
        Book *newBook = [Book insertInManagedObjectContext:context];
        newBook.iID = book[@"id"];
        newBook.title = book[@"title"];
        newBook.detailsPath = book[@"link"];
    }
}

@end
