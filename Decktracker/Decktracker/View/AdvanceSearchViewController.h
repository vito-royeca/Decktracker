//
//  SearchViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/15/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdvanceSearchViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property(strong,nonatomic) NSMutableArray *arrAdvanceSearches;
@property(strong,nonatomic) UITableView *tblView;

@end
