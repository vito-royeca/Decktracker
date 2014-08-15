//
//  SearchInputViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/15/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterInputViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property(strong,nonatomic) NSArray  *filterOptions;
@property(strong,nonatomic) NSArray  *operatorOptions;
@property(strong,nonatomic) UITableView *tblFilter;
@property(strong,nonatomic) UITableView *tblOperator;

@end
