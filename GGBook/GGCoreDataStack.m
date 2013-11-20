//
//  PCCoreDataStack.m
//  Bank
//
//  Created by Pierluigi Cifani on 27/9/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import "GGCoreDataStack.h"

@interface GGCoreDataStack ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, strong) NSOperationQueue *backgroundOperationQueue;

@end

@implementation GGCoreDataStack

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
    if (self) {
        [self managedObjectContext]; // This will kick out stuff
        
        _backgroundOperationQueue = [[NSOperationQueue alloc] init];
        _backgroundOperationQueue.maxConcurrentOperationCount = 2;
        
        [NSTimer scheduledTimerWithTimeInterval:10.0
                                         target:self
                                       selector:@selector(save:)
                                       userInfo:nil
                                        repeats:NO];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(save:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
    }
    return self;
}

- (void) save:(id)value
{
    NSError *error;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"Can't save, something's really wrong");
    }
}

- (NSManagedObjectContext *) defaultContext;
{
    return self.managedObjectContext;
}

- (NSManagedObjectContext *) backgroundContext;
{
    NSAssert(![NSThread isMainThread], @"call this from another thread");
    NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] init];
    backgroundContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    return backgroundContext;
}

- (void)mergeChanges:(NSNotification *)notification {
    
    if (notification.object != self.managedObjectContext) {
        [self performSelectorOnMainThread:@selector(updateMainContext:) withObject:notification waitUntilDone:NO];
    }
}

- (void)updateMainContext:(NSNotification *)notification {
    
    assert([NSThread isMainThread]);
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}

#pragma mark - API

- (NSString *) bookEntity
{
    return @"Book";
}

- (NSFetchedResultsController *) fetchBooks;
{
    NSManagedObjectContext *moc = [self defaultContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:[self bookEntity]
                                              inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"iID" ascending:NO];
    
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSFetchedResultsController *fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:@"root"];
    
    NSError *error;
    [fetchController performFetch:&error];
    if (error)
    {
        NSLog(@"Some error happened");
        return nil;
    }
    
    return fetchController;
}

- (NSArray *) bookWithID:(NSString *)bookID context:(NSManagedObjectContext *)context;
{
    if (context == nil) context = self.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:[self bookEntity]
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"iID = %@", bookID];
    
    [request setPredicate:searchFilter];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (error)
    {
        NSLog(@"Error Fetching %@", error);
        return nil;
    }
    
    return results;

}

- (void) performBackgroundCoreDataOperation:(GGBackgroundCoreDataBlock)operationBlock;
{
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        //Create Background MOC
        NSManagedObjectContext *backgroundMOC = [self backgroundContext];
        
        //Execute Background operation
        operationBlock(backgroundMOC);

        //Save
        NSError *error;
        [backgroundMOC save:&error];
        
        if (error) {
            NSLog(@"Some error happened saving"); //Maybe we should handle this in a better way
        }
    }];
    
    [self.backgroundOperationQueue addOperation:blockOperation];
}

#pragma mark - Core Data stack

// Returns the path to the application's documents directory.
- (NSString *)applicationDocumentsDirectory {
    
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
//
- (NSManagedObjectContext *)managedObjectContext {
	
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [NSManagedObjectContext new];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    // observe the ParseOperation's save operation with its managed object context
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChanges:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
//
- (NSManagedObjectModel *)managedObjectModel {
	
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GGBook" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it
//
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // find the earthquake data in our Documents folder
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"GGBooks.sqlite"];
    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
    
    NSDictionary *options = @{
                              NSInferMappingModelAutomaticallyOption : @YES,
                              NSMigratePersistentStoresAutomaticallyOption: @YES
                              };

    NSError *error;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
    
    return _persistentStoreCoordinator;
}

@end
