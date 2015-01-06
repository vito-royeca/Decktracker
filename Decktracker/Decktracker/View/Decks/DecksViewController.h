//
//  DecksViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/23/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;

#import "MBProgressHUD.h"

@interface DecksViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, MBProgressHUDDelegate>

@property(strong,nonatomic) UITableView *tblDecks;
@property(strong,nonatomic) NSMutableArray *arrDecks;

@end
