//
//  InAppPurchaseViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 9/28/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "InAppPurchaseViewController.h"
#import "Constants.h"
#import "FileManager.h"
#import "MainViewController.h"

#ifndef DEBUG
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#endif

@implementation InAppPurchaseViewController
{
    InAppPurchase *_inAppPurchase;
    NSArray *_arrSections;
    MBProgressHUD *_hud;
}

@synthesize productID;
@synthesize productDetails;
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
    
    if (self.navigationController)
    {
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
    }

    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    _hud.delegate = self;
    [self.view addSubview:_hud];
    [_hud show:YES];
    _inAppPurchase = [[InAppPurchase alloc] init];
    _inAppPurchase.delegate = self;
    [_inAppPurchase inquireProduct:self.productID];

#ifndef DEBUG
    // send the screen to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:[NSString stringWithFormat:@"Product Details - %@", self.productID]];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) cancelPurchase:(id) sender
{
    [self.delegate productPurchaseCancelled];
    
    if (self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:NO];
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
#ifndef DEBUG
    // send to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"Product Details - %@", self.productID]
                                                          action:@"Cancel"
                                                           label:@"Cancel"
                                                           value:nil] build]];
#endif
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
            cell.textLabel.text = _inAppPurchase.product.localizedTitle ? _inAppPurchase.product.localizedTitle :
                self.productDetails[@"name"];
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
            UITextView *tvDescription = [[UITextView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width, 132)];
            tvDescription.text = _inAppPurchase.product.localizedDescription ? _inAppPurchase.product.localizedDescription : self.productDetails[@"description"];
            [cell.contentView addSubview:tvDescription];
            
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
    [_hud hide:YES];
}

-(void) productInquiryFailed:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message
{
    [_hud hide:YES];
    [JJJUtil alertWithTitle:@"Message" andMessage:message];
}

-(void) productPurchaseSucceeded:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message
{
    [self.delegate productPurchaseSucceeded:inAppPurchase.productID];
    
    if (self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:NO];
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
#ifndef DEBUG
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"Product Details - %@", self.productID]
                                                          action:@"Purchase"
                                                           label:@"Succeeded"
                                                           value:nil] build]];
#endif
}

-(void) productPurchaseFailed:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message
{
    [JJJUtil alertWithTitle:@"Message" andMessage:message];
    
    if (self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:NO];
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

-(void) purchaseRestoreSucceeded:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message
{
    
}

-(void) purchaseRestoreFailed:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message
{
    [JJJUtil alertWithTitle:@"Message" andMessage:message];
    
    if (self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:NO];
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark -MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
}

@end
