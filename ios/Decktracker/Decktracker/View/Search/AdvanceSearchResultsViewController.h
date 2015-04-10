//
//  AdvanceSearchResultsViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/19/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;

#import "Constants.h"

typedef NS_ENUM(NSInteger, AdvanceSearchResultsViewMode)
{
    AdvanceSearchResultsViewModeByList,
    AdvanceSearchResultsViewModeByGrid2x2,
    AdvanceSearchResultsViewModeByGrid3x3
};

@interface AdvanceSearchResultsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate>

@property(strong,nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(strong,nonatomic) UIBarButtonItem *btnView;
@property(strong,nonatomic) UIBarButtonItem *btnAction;
@property(strong,nonatomic) UITableView *tblResults;
@property(strong,nonatomic) UICollectionView *colResults;
@property(strong,nonatomic) NSDictionary *queryToSave;
@property(strong,nonatomic) NSDictionary *sorterToSave;
@property(nonatomic) EditMode mode;

@end
