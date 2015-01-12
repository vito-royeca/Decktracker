//
//  AdvanceSearchResultsViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/19/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;

#import "Magic.h"

@interface AdvanceSearchResultsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate>

@property(strong,nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(strong,nonatomic) UITableView *tblResults;
@property(strong,nonatomic) NSDictionary *queryToSave;
@property(strong,nonatomic) NSDictionary *sorterToSave;
@property(nonatomic) EditMode mode;

@end
