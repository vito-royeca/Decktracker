//
//  CardDetailsViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/6/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Card.h"
#import "MBProgressHUD.h"

@interface CardDetailsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate>

@property(strong, nonatomic) Card *card;
@property(strong, nonatomic) UISegmentedControl *segmentedControl;
@property(strong, nonatomic) UIImageView *imageView;
@property(strong, nonatomic) UIWebView *webView;
@property(strong, nonatomic) UITableView *tableView;

@end
