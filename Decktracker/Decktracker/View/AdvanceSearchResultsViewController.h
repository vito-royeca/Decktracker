//
//  AdvanceSearchResultsViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/19/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdvanceSearchResultsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property(strong,nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(strong,nonatomic) UITableView *tblResults;

@end
