//
//  DeckDetailsViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 9/4/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface DeckDetailsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate>

@property(strong,nonatomic) NSDictionary *dictDeck;
@property(strong,nonatomic) UITableView *tblCards;
@property(strong, nonatomic) UIToolbar *bottomToolbar;

@end
