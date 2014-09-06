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
#import "MHFacebookImageViewer.h"

@interface CardDetailsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate, MBProgressHUDDelegate, MHFacebookImageViewerDatasource>

@property(strong, nonatomic) Card *card;
@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(strong, nonatomic) UITableView *tblView;
@property(strong, nonatomic) UISegmentedControl *segmentedControl;
@property(strong, nonatomic) UIImageView *cardImage;
@property(strong, nonatomic) UIWebView *webView;
@property(strong, nonatomic) UITableView *tblDetails;
@property(strong, nonatomic) UIToolbar *bottomToolbar;
@property(strong, nonatomic) UIBarButtonItem *btnPrevious;
@property(strong, nonatomic) UIBarButtonItem *btnNext;
@property(strong, nonatomic) UIBarButtonItem *btnAction;
@property(strong, nonatomic) UIBarButtonItem *btnAddToDeck;
@property(strong, nonatomic) UIBarButtonItem *btnAddToCollection;

@property(nonatomic) BOOL addToDeckButtonVisible;
@property(nonatomic) BOOL addToCollectionButtonVisible;

@end
