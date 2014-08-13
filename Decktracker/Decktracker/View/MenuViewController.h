//
//  MenuViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/13/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tblMenu;

@end
