//
//  CollectionsPurchase.m
//  Decktracker
//
//  Created by Jovit Royeca on 9/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "InAppPurchase.h"

@implementation InAppPurchase

@synthesize product = _product;

-(void) initPurchase
{
    if ([SKPaymentQueue canMakePayments])
    {
        NSSet *set = [NSSet setWithObject:self.productID];
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
        request.delegate = self;
        
        [request start];
    }
    else
    {
        [self.delegate purchaseFailed:@"Please enable In App Purchase in Settings."];
    }
}

#pragma mark SKProductsRequestDelegate
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    
    NSArray *products = response.products;
    
    if (products.count != 0)
    {
        self.product = [products firstObject];
//        NSString *message = [NSString stringWithFormat:@"%@ requires In-App purchase. Product description: %@. Buy now?", self.product.localizedTitle, self.product.localizedDescription];
//        
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"In-App Purchase"
//                                                         message:message
//                                                        delegate:self
//                                               cancelButtonTitle:@"Cancel"
//                                               otherButtonTitles:@"Buy", nil];
//        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//        [alert show];
        SKPayment *payment = [SKPayment paymentWithProduct:self.product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else
    {
        [self.delegate purchaseFailed:@"Product is not found."];
    }
    
    products = response.invalidProductIdentifiers;
    
    for (SKProduct *product in products)
    {
        NSLog(@"Product not found: %@", product);
    }
}

#pragma mark SKPaymentTransactionObserver
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
            {
                [self.delegate purchaseSucceded:@"In-App Purchase Ok"];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
                
            case SKPaymentTransactionStateFailed:
            {
                [self.delegate purchaseSucceded:@"In-App Purchase Failed"];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
                
            default:
            {
                break;
            }
        }
    }
}

@end
