//
//  GGDetailViewController.h
//  GGBook
//
//  Created by Pierluigi Cifani on 20/11/13.
//  Copyright (c) 2013 Voalte Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Book;

@interface GGDetailViewController : UIViewController

@property (strong, nonatomic) Book *detailBook;

@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UIImageView *coverImage;

@end
