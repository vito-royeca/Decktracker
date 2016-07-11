//
//  SearchViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/15/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;
@import CoreData;

#import "MBProgressHUD.h"

@interface AdvanceSearchViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate>

@property(strong,nonatomic) NSMutableArray *arrAdvanceSearches;
@property(strong,nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(strong,nonatomic) UITableView *tblView;

@end
