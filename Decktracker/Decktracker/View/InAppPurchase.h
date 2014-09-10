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

@interface InAppPurchase : NSObject<SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property(strong,nonatomic) id<InAppPurchaseDelegate> delegate;

-(BOOL) isProductPurchased:(NSString*) productID;
-(void) purchaseProduct:(NSString*) productID;

@end
