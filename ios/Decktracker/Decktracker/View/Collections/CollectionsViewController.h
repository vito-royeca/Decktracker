//
//  CollectionsViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/23/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;

@interface CollectionsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property(strong,nonatomic) UITableView *tblCollections;

@property(strong,nonatomic) NSMutableArray *arrCollections;

@end
