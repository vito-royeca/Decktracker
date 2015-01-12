//
//  InAppPurchaseViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 9/28/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InAppPurchase.h"

@protocol InAppPurchaseViewControllerDelegate

-(void) productPurchaseSucceeded:(NSString*) productID;

@end

@interface InAppPurchaseViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, InAppPurchaseDelegate>

@property(strong,nonatomic) id<InAppPurchaseViewControllerDelegate> delegate;

@property(strong,nonatomic) NSString *productID;
@property(strong,nonatomic) NSDictionary *productDetails;
@property(strong,nonatomic) UIBarButtonItem *btnCancel;
@property(strong,nonatomic) UIBarButtonItem *btnBuy;
@property(strong,nonatomic) UITableView *tblProducDetails;

@end
