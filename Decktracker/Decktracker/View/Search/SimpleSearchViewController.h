//
//  SearchViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/5/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;

#import "MBProgressHUD.h"

@interface SimpleSearchViewController : UIViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, MBProgressHUDDelegate>

@property(strong,nonatomic) NSString *titleString;
@property(strong,nonatomic) UISearchBar *searchBar;
@property(strong,nonatomic) UITableView *tblResults;
@property(strong,nonatomic) NSPredicate *predicate;
@property(strong,nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void) doSearch;
@end
