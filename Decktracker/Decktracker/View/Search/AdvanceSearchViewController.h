//
//  SearchViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/15/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface AdvanceSearchViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, MBProgressHUDDelegate>

@property(strong,nonatomic) NSMutableArray *arrAdvanceSearches;
@property(strong,nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(strong,nonatomic) UITableView *tblView;

@end
