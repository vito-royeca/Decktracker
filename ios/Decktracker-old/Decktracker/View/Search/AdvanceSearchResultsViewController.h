//
//  AdvanceSearchResultsViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/19/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;
@import CoreData;

#import "Constants.h"

@interface AdvanceSearchResultsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate>

@property(strong,nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(strong,nonatomic) UIBarButtonItem *btnView;
@property(strong,nonatomic) UIBarButtonItem *btnAction;
@property(strong,nonatomic) UITableView *tblResults;
@property(strong,nonatomic) UICollectionView *colResults;
@property(strong,nonatomic) NSDictionary *queryToSave;
@property(strong,nonatomic) NSDictionary *sorterToSave;
@property(nonatomic) EditMode mode;

@end
