//
//  InAppPurchaseViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 9/28/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "InAppPurchaseViewController.h"
#import "FileManager.h"
#import "Magic.h"
#import "MainViewController.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@implementation InAppPurchaseViewController
{
    InAppPurchase *_inAppPurchase;
    NSArray *_arrSections;
}

@synthesize productID;
@synthesize btnCancel;
@synthesize btnBuy;
@synthesize tblProducDetails;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _arrSections = @[@"Name", @"Price", @"Description"];
    
    CGFloat dX = 0;
    CGFloat dY = 0;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.view.frame.size.height - dY;// - self.tabBarController.tabBar.frame.size.height;
    
    self.tblProducDetails = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight) style:UITableViewStyleGrouped];
    self.tblProducDetails.delegate = self;
    self.tblProducDetails.dataSource = self;
    
    [self.view addSubview:self.tblProducDetails];
    
    self.btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                   target:self
                                                                   action:@selector(cancelPurchase:)];
    
    self.btnBuy = [[UIBarButtonItem alloc] initWithTitle:@"Buy"
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(purchaseProduct:)];
    self.btnBuy.enabled = NO;
    
    self.navigationItem.leftBarButtonItem = btnCancel;
    self.navigationItem.rightBarButtonItem = btnBuy;
    self.navigationItem.title = @"Product Details";
    
    // send the screen to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:[NSString stringWithFormat:@"Product Details - %@", self.productID]];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];

    _inAppPurchase = [[InAppPurchase alloc] init];
    _inAppPurchase.delegate = self;
    [_inAppPurchase inquireProduct:self.productID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) cancelPurchase:(id) sender
{
    // send to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"Product Details - %@", self.productID]
                                                          action:@"Cancel"
                                                           label:@"Cancel"
                                                           value:nil] build]];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void) purchaseProduct:(id) sender
{
    self.btnBuy.enabled = NO;
    [_inAppPurchase purchaseProduct:self.productID];
}

#pragma mark - UITable
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _arrSections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _arrSections[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        return 132;
    }
    else
    {
        return UITableViewAutomaticDimension;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    switch (indexPath.section)
    {
        case 0:
        {
            cell.textLabel.text = _inAppPurchase.product.localizedTitle;
            break;
        }
        case 1:
        {
            if (_inAppPurchase.product.priceLocale &&
                _inAppPurchase.product.price)
            {
                NSString *currencyCode = [_inAppPurchase.product.priceLocale objectForKey:NSLocaleCurrencyCode];
            
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", currencyCode, [_inAppPurchase.product.price stringValue]];
            }
            break;
        }
        case 2:
        {
            cell.textLabel.text = _inAppPurchase.product.localizedDescription;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            break;
        }
    }
    
    return cell;
}

#pragma mark - InAppPurchaseDelegate
-(void) productInquirySucceeded:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message
{
    [self.tblProducDetails reloadData];
    self.btnBuy.enabled = YES;
}

-(void) productInquiryFailed:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void) productPurchaseSucceeded:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message
{
    if ([inAppPurchase.productID isEqualToString:COLLECTIONS_IAP_PRODUCT_ID])
    {
        MainViewController *view = (MainViewController*)self.tabBarController;
        [view addCollectionsProduct];
    }
    
    else if ([inAppPurchase.productID isEqualToString:CLOUD_STORAGE_IAP_PRODUCT_ID])
    {
        [[FileManager sharedInstance] syncFiles];
    }
        
    [self.navigationController popViewControllerAnimated:NO];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"Product Details - %@", self.productID]
                                                          action:@"Purchase"
                                                           label:@"Succeeded"
                                                           value:nil] build]];
}

-(void) productPurchaseFailed:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void) purchaseRestoreSucceeded:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message
{
    
}

-(void) purchaseRestoreFailed:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    [self.navigationController popViewControllerAnimated:NO];
}

@end
