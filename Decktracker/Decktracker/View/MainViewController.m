//
//  MainViewController.m
//  DeckTracker
//
//  Created by Jovit Royeca on 8/5/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "MainViewController.h"
#import "CollectionsViewController.h"
#import "DecksViewController.h"
#import "FileManager.h"
#import "IASKAppSettingsViewController.h"
#import "Magic.h"
#import "SimpleSearchViewController.h"
#import "SettingsViewController.h"

#import "BoxSDK.h"
#import <Dropbox/Dropbox.h>

@implementation MainViewController
{
    InAppPurchase *_inAppPurchase;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UINavigationController *nc1 = [[UINavigationController alloc] init];
    UIViewController *vc1 = [[SimpleSearchViewController alloc] initWithNibName:nil bundle:nil];
    nc1.viewControllers = [NSArray arrayWithObjects:vc1, nil];
    nc1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Search"
                                                   image:[UIImage imageNamed:@"search.png"]
                                           selectedImage:nil];
    
    UINavigationController *nc2 = [[UINavigationController alloc] init];
    UIViewController *vc2 = [[DecksViewController alloc] initWithNibName:nil bundle:nil];
    nc2.viewControllers = [NSArray arrayWithObjects:vc2, nil];
    nc2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Decks"
                                                   image:[UIImage imageNamed:@"layers.png"]
                                           selectedImage:nil];
    
    UINavigationController *nc4 = [[UINavigationController alloc] init];
    UIViewController *vc4 = [[IASKAppSettingsViewController alloc] initWithNibName:nil bundle:nil];
    nc4.viewControllers = [NSArray arrayWithObjects:vc4, nil];
    nc4.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings"
                                                   image:[UIImage imageNamed:@"settings.png"]
                                           selectedImage:nil];
    
    self.viewControllers = @[nc1, nc2, nc4];
    self.selectedViewController = nc1;
    
    _inAppPurchase = [[InAppPurchase alloc] init];
    _inAppPurchase.delegate = self;
    if (![_inAppPurchase isProductPurchased:COLLECTIONS_IAP_PRODUCT_ID])
    {
        [_inAppPurchase restorePurchase:COLLECTIONS_IAP_PRODUCT_ID];
    }
    else
    {
        [self addCollectionsProduct];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kIASKAppSettingChanged
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingsChanged:)
                                                 name:kIASKAppSettingChanged
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) addCollectionsProduct
{
    BOOL bAlreaddyAdded = NO;
    
    for (UINavigationController *view in self.viewControllers)
    {
        if ([view.tabBarItem.title isEqualToString:@"Collections"])
        {
            bAlreaddyAdded = YES;
            break;
        }
    }
    
    if (!bAlreaddyAdded)
    {
        UINavigationController *nc3 = [[UINavigationController alloc] init];
        UIViewController *vc3 = [[CollectionsViewController alloc] initWithNibName:nil bundle:nil];
        nc3.viewControllers = [NSArray arrayWithObjects:vc3, nil];
        nc3.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Collections"
                                                       image:[UIImage imageNamed:@"cards.png"]
                                               selectedImage:nil];
        
        [self addNavigationController:nc3 atIndex:2];
    }
}

-(void) addNavigationController:(UINavigationController*) navController atIndex:(int) index
{
    NSMutableArray *arrViewControllers = [[NSMutableArray alloc] initWithArray:self.viewControllers];
    
    [arrViewControllers insertObject:navController atIndex:index];
    [self setViewControllers:arrViewControllers animated:NO];
}

#pragma mark - IASKSettingsDelegate
-(void) settingsChanged:(id) sender
{
    NSDictionary *dict = [sender userInfo];
    
    for (NSString *key in dict)
    {
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
    }
}

#pragma mark - InAppPurchaseDelegate
-(void) purchaseRestored:(NSString*) message
{
    [self addCollectionsProduct];
}

-(void) purchaseSucceded:(NSString*) message
{
    NSLog(@"%@", message);
}
-(void) purchaseFailed:(NSString*) message
{
    NSLog(@"%@", message);
}
@end
