//
//  CollectionsPurchase.m
//  Decktracker
//
//  Created by Jovit Royeca on 9/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "InAppPurchase.h"


@implementation InAppPurchase

@synthesize productID = _productID;

-(id) init
{
    if ((self = [super init]))
    {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    
    return self;
}

-(BOOL) isProductPurchased:(NSString*) productID
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:productID] boolValue];
}

-(void) purchaseProduct:(NSString*) productID
{
    self.productID = productID;
    
    if ([SKPaymentQueue canMakePayments])
    {
        NSSet *set = [NSSet setWithObject:self.productID];
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
        request.delegate = self;
        
        [request start];
    }
    else
    {
        [self.delegate purchaseFailed:@"Please enable In-App Purchase in Settings."];
    }
}

-(void) restorePurchase:(NSString*) productID
{
    self.productID = productID;
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark SKProductsRequestDelegate
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    
    if (products.count != 0)
    {
        SKProduct *product= [products firstObject];
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else
    {
        [self.delegate purchaseFailed:@"Product is not found."];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [self.delegate purchaseFailed:@"Product is not found."];
}

#pragma mark SKPaymentTransactionObserver
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStateRestored:
            {
                if ([transaction.originalTransaction.payment.productIdentifier isEqualToString:self.productID])
                {
                    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:self.productID];
                    [self.delegate purchaseRestored:@"In-App Purchase restored."];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStatePurchased:
            {
                if ([transaction.originalTransaction.payment.productIdentifier isEqualToString:self.productID])
                {
                    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:self.productID];
                    [self.delegate purchaseSucceded:@"In-App Purchase succeded."];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed:
            {
                NSString *message = @"In-App Purchase failed.";
                if (transaction.error.code == SKErrorPaymentCancelled)
                {
                    message = @"In-App Purchase Cancelled";
                }
                [self.delegate purchaseFailed:message];
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
