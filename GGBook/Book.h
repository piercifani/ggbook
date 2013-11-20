//
//  Book.h
//  GGBook
//
//  Created by Pierluigi Cifani on 20/11/13.
//  Copyright (c) 2013 Voalte Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Book : NSManagedObject

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;

@property (nonatomic, retain) NSString * iID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * detailsPath;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSString * author;

@end
