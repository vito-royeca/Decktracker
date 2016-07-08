//
//  CollectionDetailsViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 9/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InAppPurchaseViewController.h"

@interface CollectionDetailsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, InAppPurchaseViewControllerDelegate>

@property(strong,nonatomic) NSDictionary *dictCollection;
@property(strong,nonatomic) UITableView *tblCards;
@property(strong, nonatomic) UIToolbar *bottomToolbar;

@end
