//
//  SearchViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/5/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface SimpleSearchViewController : UIViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, MBProgressHUDDelegate>

@property(nonatomic) NSInteger selectedIndex;
@property(strong,nonatomic) UISearchBar *searchBar;
@property(strong,nonatomic) UITableView *tblResults;
@property(strong,nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
