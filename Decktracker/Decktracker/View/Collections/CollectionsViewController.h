//
//  CollectionsViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/23/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property(strong,nonatomic) UITableView *tblResults;

@end
