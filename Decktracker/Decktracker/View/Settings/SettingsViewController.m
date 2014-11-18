//
//  SettingsViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 9/4/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "SettingsViewController.h"
#import "AcknowledgementTableViewCell.h"
#import "DownloadSetImagesViewController.h"
#import "FileManager.h"
#import "MainViewController.h"

#ifndef DEBUG
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#endif

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
    self.appSettingsViewController.showCreditsFooter = NO;
    self.appSettingsViewController.showDoneButton = NO;
    
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
    
#ifndef DEBUG
    // send the screen to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Settings"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
#endif
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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
    
    return setHiddenKeys;
}

#pragma mark - IASKSettingsDelegate
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender
{
    [sender.tableView reloadData];
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
            view.productDetails = @{@"name" : @"Collections",
                                    @"description": @"Lets you manage your card collections."};
            view.delegate = self;
            [self.navigationController pushViewController:view animated:YES];
        }
    }
    
    else if ([specifier.key isEqualToString:@"restore_purchases"])
    {
        [_inAppPurchase restorePurchases];
    }
    
//    else if ([specifier.key isEqualToString:@"download_set_images"])
//    {
//        DownloadSetImagesViewController *view = [[DownloadSetImagesViewController alloc] init];
//        
//        [self.navigationController pushViewController:view animated:NO];
//    }
    
    else if ([specifier.key isEqualToString:@"acknowledgements"])
    {
        IASKAppSettingsViewController *view = [[IASKAppSettingsViewController alloc] init];

        view.showDoneButton = NO;
        view.showCreditsFooter = NO;
        view.file = @"Acknowledgements";
        view.delegate = self;
        view.navigationItem.title = @"Acknowledgements";
        [self.navigationController pushViewController:view animated:YES];
    }
}

-(void) settingsChanged:(id) sender
{
    NSDictionary *dict = [sender userInfo];
    
    for (NSString *key in dict)
    {
        if ([key isEqualToString:@"dropbox_preference"])
        {
            id value = [dict valueForKey:key];
            FileSystem fileSystem = -1;
            UIViewController *viewController = self;
            
            if ([key isEqualToString:@"dropbox_preference"])
            {
                fileSystem = FileSystemDropbox;
            }
            
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:[value boolValue]] forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if ([value boolValue])
            {
                [[FileManager sharedInstance] setupFilesystem:fileSystem];
                [[FileManager sharedInstance] connectToFileSystem:fileSystem
                                               withViewController:viewController];
            }
            else
            {
                [[FileManager sharedInstance] disconnectFromFileSystem:fileSystem];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForSpecifier:(IASKSpecifier*)specifier
{
//    if ([specifier.key isEqualToString:@"customCell"])
//    {
//        return 44*3;
//    }
//    return 0;
    return 44*6;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForSpecifier:(IASKSpecifier*)specifier
{
    AcknowledgementTableViewCell *cell = (AcknowledgementTableViewCell*)[tableView dequeueReusableCellWithIdentifier:specifier.key];
    
    if (!cell)
    {
        cell = (AcknowledgementTableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"AcknowledgementTableViewCell"
                                                                             owner:self
                                                                           options:nil] firstObject];
    }
    cell.textView.text = specifier.title;
    [cell setNeedsLayout];
    return cell;
}

#pragma mark - InAppPurchaseViewControllerDelegate
-(void) productPurchaseSucceeded:(NSString*) productID
{
    if ([productID isEqualToString:COLLECTIONS_IAP_PRODUCT_ID])
    {
        MainViewController *view = (MainViewController*)self.tabBarController;
        [view addCollectionsProduct];
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
    // Collections
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
    
#ifndef DEBUG
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Settings"
                                                          action:@"Restore Purchases"
                                                           label:@"Succeeded"
                                                           value:nil] build]];
#endif
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
