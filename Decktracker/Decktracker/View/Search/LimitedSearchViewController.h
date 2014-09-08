//
//  LimitedSearchViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 9/6/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface LimitedSearchViewController : UIViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, MBProgressHUDDelegate>

@property(strong,nonatomic) NSDictionary *dictDeck;
@property(strong,nonatomic) UISearchBar *searchBar;
@property(strong,nonatomic) UITableView *tblResults;
@property(strong,nonatomic) NSPredicate *predicate;
@property(strong,nonatomic) NSFetchedResultsController *fetchedResultsController;

@end