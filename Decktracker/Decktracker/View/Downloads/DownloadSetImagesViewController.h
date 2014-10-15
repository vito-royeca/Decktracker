//
//  DownloadSetImagesViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 10/6/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Set.h"

#import "JJJ/JJJ.h"

@interface DownloadSetImagesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property(strong,nonatomic) NSArray *arrSets;
@property(strong,nonatomic) UITableView *tblSets;

@end
