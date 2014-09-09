//
//  CollectionsPurchase.h
//  Decktracker
//
//  Created by Jovit Royeca on 9/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import Foundation;
@import StoreKit;

@protocol InAppPurchaseDelegate <NSObject>

-(void) purchaseSucceded:(NSString*) message;
-(void) purchaseFailed:(NSString*) message;

@end

@interface InAppPurchase : NSObject<SKPaymentTransactionObserver, SKProductsRequestDelegate, UIAlertViewDelegate>

@property(strong,nonatomic) id<InAppPurchaseDelegate> delegate;
@property(strong,nonatomic) NSString *productID;
@property(strong,nonatomic) SKProduct *product;

-(void) initPurchase;

@end
