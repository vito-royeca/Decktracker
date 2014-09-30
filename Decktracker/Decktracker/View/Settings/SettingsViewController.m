//
//  SettingsViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 9/4/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "SettingsViewController.h"
#import "FileManager.h"
#import "InAppPurchaseViewController.h"
#import "MainViewController.h"

#import "BoxSDK.h"
#import <Dropbox/Dropbox.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@implementation SettingsViewController
{
    InAppPurchase *_inAppPurchase;
}

@synthesize appSettingsViewController = _appSettingsViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat dX = 0;
    CGFloat dY = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.view.frame.size.height - dY - self.tabBarController.tabBar.frame.size.height;
    
    self.appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
    self.appSettingsViewController.delegate = self;
    self.appSettingsViewController.view.frame = CGRectMake(dX, dY, dWidth, dHeight);
//    self.appSettingsViewController.hiddenKeys = [self hiddenKeys];
    
    [self.view addSubview:self.appSettingsViewController.view];
    self.navigationItem.title = @"Settings";
    
    _inAppPurchase = [[InAppPurchase alloc] init];
    _inAppPurchase.delegate = self;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kIASKAppSettingChanged
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingsChanged:)
                                                 name:kIASKAppSettingChanged
                                               object:nil];
    
    // send the screen to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:self.navigationItem.title];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void) viewDidAppear:(BOOL)animated
{
    self.appSettingsViewController.hiddenKeys = [self hiddenKeys];
    [self.appSettingsViewController.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSSet*) hiddenKeys
{
    NSMutableSet *setHiddenKeys = [[NSMutableSet alloc] init];

    if ([InAppPurchase isProductPurchased:COLLECTIONS_IAP_PRODUCT_ID])
    {
        [setHiddenKeys addObject:COLLECTIONS_IAP_PRODUCT_ID];
    }
    if ([InAppPurchase isProductPurchased:CLOUD_STORAGE_IAP_PRODUCT_ID])
    {
        [setHiddenKeys addObject:CLOUD_STORAGE_IAP_PRODUCT_ID];
    }
    
    return setHiddenKeys;
}

#pragma mark - IASKSettingsDelegate
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender
{
    
}

- (void)settingsViewController:(IASKAppSettingsViewController*)sender
      buttonTappedForSpecifier:(IASKSpecifier*)specifier
{
    if ([specifier.key isEqualToString:COLLECTIONS_IAP_PRODUCT_ID])
    {
        if (![InAppPurchase isProductPurchased:COLLECTIONS_IAP_PRODUCT_ID])
        {
            InAppPurchaseViewController *view = [[InAppPurchaseViewController alloc] init];
            
            view.productID = COLLECTIONS_IAP_PRODUCT_ID;
            [self.navigationController pushViewController:view animated:NO];
        }
    }
    
    else if ([specifier.key isEqualToString:CLOUD_STORAGE_IAP_PRODUCT_ID])
    {
        if (![InAppPurchase isProductPurchased:CLOUD_STORAGE_IAP_PRODUCT_ID])
        {
            InAppPurchaseViewController *view = [[InAppPurchaseViewController alloc] init];
            
            view.productID = CLOUD_STORAGE_IAP_PRODUCT_ID;
            [self.navigationController pushViewController:view animated:NO];
        }
    }
    
    else if ([specifier.key isEqualToString:@"restore_purchases"])
    {
        [_inAppPurchase restorePurchases];
    }
}

-(void) settingsChanged:(id) sender
{
    NSDictionary *dict = [sender userInfo];
    
    for (NSString *key in dict)
    {
        if ([key isEqualToString:@"box_preference"] ||
            [key isEqualToString:@"dropbox_preference"] ||
            [key isEqualToString:@"google_drive_preference"] ||
            [key isEqualToString:@"google_drive_preference"] ||
            [key isEqualToString:@"icloud_preference"] ||
            [key isEqualToString:@"onedrive_preference"])
        {
            if (![InAppPurchase isProductPurchased:CLOUD_STORAGE_IAP_PRODUCT_ID])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                                message:@"You may need to purchase Cloud Storage first."
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
                [alert show];
                
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:key];
                [self.appSettingsViewController.tableView reloadData];
            }
            
            continue;
        }
        
        id value = [dict valueForKey:key];
        
        if ([key isEqualToString:@"box_preference"])
        {
            if ([value boolValue])
            {
                UIViewController *authorizationController = [[BoxAuthorizationViewController alloc] initWithAuthorizationURL:[[BoxSDK sharedSDK].OAuth2Session authorizeURL] redirectURI:@"boxsdk-v3vx3t10k6genv8ao7r5f3rqunz23atm"];
                [self presentViewController:authorizationController animated:NO completion:nil];
            }
            else
            {
                
            }
        }
        
        else if ([key isEqualToString:@"dropbox_preference"])
        {
            if ([value boolValue])
            {
                if (![[DBAccountManager sharedManager] linkedAccount])
                {
                    [[DBAccountManager sharedManager] linkFromController:self];
                    if ([[DBAccountManager sharedManager] linkedAccount])
                    {
                        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:key];
                        [[FileManager sharedInstance] initFilesystem];
                    }
                    else
                    {
                        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:key];
                    }
                }
                
            }
            else
            {
                [[[DBAccountManager sharedManager] linkedAccount] unlink];
            }
        }
        
        else if ([key isEqualToString:@"google_drive_preference"])
        {
            
        }
        
        else if ([key isEqualToString:@"icloud_preference"])
        {
            
        }
        
        else if ([key isEqualToString:@"onedrive_preference"])
        {
            
        }
    }
}

#pragma mark - InAppPurchaseDelegate
-(void) productPurchaseFailed:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void) purchaseRestoreSucceeded:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message
{
    MainViewController *view = (MainViewController*)self.tabBarController;
    [view addCollectionsProduct];
    
    self.appSettingsViewController.hiddenKeys = [self hiddenKeys];
    [self.appSettingsViewController.tableView reloadData];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Settings"
                                                          action:@"Restore Purchases"
                                                           label:@"Succeeded"
                                                           value:nil] build]];
}

-(void) purchaseRestoreFailed:(InAppPurchase*) inAppPurchase withMessage:(NSString*) message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
