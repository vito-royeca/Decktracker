//
//  CardDetailsViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/6/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;
@import CoreData;

#import "DTCard.h"
#import "MBProgressHUD.h"
#import "MHFacebookImageViewer.h"

#import <JJJUtils/JJJ.h>

@interface CardDetailsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate, MBProgressHUDDelegate, MHFacebookImageViewerDatasource, UIAlertViewDelegate>

@property(strong, nonatomic) NSString *cardId;
@property(strong, nonatomic) NSArray *cardIds;

@property(strong, nonatomic) UISegmentedControl *segmentedControl;
//@property(strong, nonatomic) UIPageViewController *pageView;
@property(strong, nonatomic) UIImageView *cardImage;
@property(strong, nonatomic) UIWebView *webView;
@property(strong, nonatomic) UITableView *tblDetails;
@property(strong, nonatomic) UIToolbar *bottomToolbar;
@property(strong, nonatomic) UIBarButtonItem *btnAction;
@property(strong, nonatomic) UIBarButtonItem *btnRate;
@property(strong, nonatomic) UIBarButtonItem *btnBuy;
@property(strong, nonatomic) UIBarButtonItem *btnAdd;

@property(nonatomic) BOOL addButtonVisible;

@end
