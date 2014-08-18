//
//  NewAdvanceSearchViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/18/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterInputViewController.h"
#import "HMSegmentedControl.h"

@interface NewAdvanceSearchViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, FilterInputViewControllerDelegate>

@property(strong,nonatomic) HMSegmentedControl *segmentedControl;
@property(strong,nonatomic) UITableView *tblView;
@property(strong,nonatomic) NSMutableArray *arrCurrentQuery;

@end
