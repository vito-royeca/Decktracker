//
//  NewAdvanceSearchViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/18/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;

#import "FilterInputViewController.h"
#import "Magic.h"
#import "MBProgressHUD.h"

@interface NewAdvanceSearchViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, FilterInputViewControllerDelegate, MBProgressHUDDelegate>

@property(strong,nonatomic) UISegmentedControl *segmentedControl;
@property(strong,nonatomic) UITableView *tblView;
@property(strong,nonatomic) NSMutableDictionary *dictCurrentQuery;
@property(strong,nonatomic) NSMutableDictionary *dictCurrentSorter;
@property(strong,nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic) EditMode mode;

-(void) showSegment:(int) index;

@end
