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
@synthesize product = _product;

-(id) init
{
    if ((self = [super init]))
    {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    
    return self;
}

+(BOOL) isProductPurchased:(NSString*) productID
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:productID] boolValue];
}

-(void) inquireProduct:(NSString*) productID
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
        [self.delegate productPurchaseFailed:self withMessage:@"Please enable In-App Purchase in your device Settings."];
    }
}

-(void) purchaseProduct:(NSString*) productID
{
    if (self.product)
    {
        SKPayment *payment = [SKPayment paymentWithProduct:self.product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else
    {
        [self.delegate productPurchaseFailed:self withMessage:@"Product is not found."];
    }
}

-(void) restorePurchases
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark SKProductsRequestDelegate
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    
    if (products.count != 0)
    {
        self.product = [products firstObject];
        [self.delegate productInquirySucceeded:self withMessage:@"Product inquiry succeeded."];
    }
    else
    {
        [self.delegate productInquiryFailed:self withMessage:@"Product not found."];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [self.delegate productInquiryFailed:self withMessage:error.localizedDescription];
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
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES]
                                                         forKey:transaction.originalTransaction.payment.productIdentifier];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStatePurchased:
            {
                if ([transaction.originalTransaction.payment.productIdentifier isEqualToString:self.productID])
                {
                    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES]
                                                             forKey:self.productID];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self.delegate productPurchaseSucceeded:self withMessage:@"In-App Purchase succeeded."];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed:
            {
                [self.delegate productPurchaseFailed:self withMessage:transaction.error.localizedDescription];
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

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    [self.delegate purchaseRestoreSucceeded:self withMessage:@"In-App Purchase restore succeeded."];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    [self.delegate purchaseRestoreFailed:self withMessage:error.localizedDescription];
}

@end
