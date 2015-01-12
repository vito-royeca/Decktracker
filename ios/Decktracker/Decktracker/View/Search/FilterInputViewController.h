//
//  SearchInputViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/15/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;

#import "JJJ/JJJ.h"

@protocol FilterInputViewControllerDelegate <NSObject>

-(void) addFilter:(NSDictionary*) filter;

@end

@interface FilterInputViewController : UIViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property(strong,nonatomic) id<FilterInputViewControllerDelegate> delegate;

@property(strong,nonatomic) NSString  *filterName;
@property(strong,nonatomic) NSArray  *filterOptions;
@property(strong,nonatomic) NSArray  *operatorOptions;
@property(strong,nonatomic) UISearchBar *searchBar;
@property(strong,nonatomic) UITableView *tblOperator;
@property(strong,nonatomic) UITableView *tblFilter;

@end
