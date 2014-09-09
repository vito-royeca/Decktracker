//
//  CollectionsPurchase.m
//  Decktracker
//
//  Created by Jovit Royeca on 9/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "InAppPurchaseDialog.h"

@implementation InAppPurchaseDialog

@synthesize product = _product;

-(void) showPurchaseDialog
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please enable In App Purchase in Settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
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
        NSString *message = [NSString stringWithFormat:@"%@ requires In-App purchase. Product description: %@. Buy now?", self.product.localizedTitle, self.product.localizedDescription];
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"In-App Purchase"
                                                         message:message
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"Buy", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Product is not found."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
        [self.delegate purchaseFailed:@"Product is not found."];
    }
    
    products = response.invalidProductIdentifiers;
    
    for (SKProduct *product in products)
    {
        NSLog(@"Product not found: %@", product);
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        SKPayment *payment = [SKPayment paymentWithProduct:self.product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
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
                [self.delegate purchaseSucceded:@"Transaction Ok"];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
                
            case SKPaymentTransactionStateFailed:
            {
                [self.delegate purchaseSucceded:@"Transaction Failed"];
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
