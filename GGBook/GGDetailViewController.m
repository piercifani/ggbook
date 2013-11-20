//
//  GGDetailViewController.m
//  GGBook
//
//  Created by Pierluigi Cifani on 20/11/13.
//  Copyright (c) 2013 Voalte Inc. All rights reserved.
//

#import "GGDetailViewController.h"

#import "GGBookFetcher.h"
#import "Book.h"

@interface GGDetailViewController ()

@end

@implementation GGDetailViewController

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self configureView];
    
    __weak __typeof(self) weakSelf = self;
    
    [[GGBookFetcher sharedInstance] fetchDetailsForBook:_detailBook
                                             completion:^(BOOL success) {
                                                 [weakSelf configureView];
                                             }];
}

- (void) configureView
{
    self.title = _detailBook.title;
    self.authorLabel.text = [NSString stringWithFormat:@"Author: %@", _detailBook.author];
    self.priceLabel.text = [NSString stringWithFormat:@"Price: %@", [_detailBook.price stringValue]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
