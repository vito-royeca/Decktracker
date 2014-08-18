//
//  SearchInputViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/15/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterInputViewControllerDelegate <NSObject>

-(void) addFilter:(NSDictionary*) filter;

@end

@interface FilterInputViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property(strong,nonatomic) id<FilterInputViewControllerDelegate> delegate;

@property(strong,nonatomic) NSString  *filterName;
@property(strong,nonatomic) NSArray  *filterOptions;
@property(strong,nonatomic) NSArray  *operatorOptions;
@property(strong,nonatomic) UITableView *tblFilter;
@property(strong,nonatomic) UITableView *tblOperator;

@end
