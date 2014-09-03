//
//  AddToViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 9/3/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddToDeckViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property(strong,nonatomic) NSArray *arrSelection;
@property(strong,nonatomic) UITableView *tblAddTo;
@property(strong,nonatomic) UIBarButtonItem *btnNew;
@property(strong,nonatomic) UIToolbar *bottomToolbar;

@end
