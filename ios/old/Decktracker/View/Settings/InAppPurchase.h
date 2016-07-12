//
//  CollectionsPurchase.h
//  Decktracker
//
//  Created by Jovit Royeca on 9/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import Foundation;
@import StoreKit;

@class InAppPurchase;

@protocol InAppPurchaseDelegate <NSObject>

@optional
-(void) productInquirySucceeded:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message;
-(void) productInquiryFailed:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message;

-(void) productPurchaseSucceeded:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message;
-(void) productPurchaseFailed:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message;

-(void) purchaseRestoreSucceeded:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message;
-(void) purchaseRestoreFailed:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message;

@end

@interface InAppPurchase : NSObject<SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property(strong,nonatomic) id<InAppPurchaseDelegate> delegate;
@property(strong,nonatomic) NSString *productID;
@property(strong,nonatomic) SKProduct *product;

+(BOOL) isProductPurchased:(NSString*) productID;

-(void) inquireProduct:(NSString*) productID;
-(void) purchaseProduct:(NSString*) productID;
-(void) restorePurchases;

@end
