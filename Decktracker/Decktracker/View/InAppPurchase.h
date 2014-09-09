//
//  CollectionsPurchase.h
//  Decktracker
//
//  Created by Jovit Royeca on 9/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import Foundation;
@import StoreKit;

@protocol InAppPurchaseDialogDelegate <NSObject>

-(void) purchaseSucceded:(NSString*) message;
-(void) purchaseFailed:(NSString*) message;

@end

@interface InAppPurchaseDialog : NSObject<SKPaymentTransactionObserver, SKProductsRequestDelegate, UIAlertViewDelegate>

@property(strong,nonatomic) id<InAppPurchaseDialogDelegate> delegate;
@property(strong,nonatomic) NSString *productID;
@property(strong,nonatomic) SKProduct *product;

-(void) showPurchaseDialog;

@end
