//
//  Book.m
//  GGBook
//
//  Created by Pierluigi Cifani on 20/11/13.
//  Copyright (c) 2013 Voalte Inc. All rights reserved.
//

#import "Book.h"
#import "GGCoreDataStack.h"

@implementation Book

@dynamic iID;
@dynamic title;
@dynamic detailsPath;
@dynamic price;
@dynamic imagePath;
@dynamic author;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_
{
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:moc_];
}

+ (id)insertInDefaultContext
{
    NSManagedObjectContext *moc = [[GGCoreDataStack sharedInstance] defaultContext];
    return [self insertInManagedObjectContext:moc];
}

@end
