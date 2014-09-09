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
#import "Magic.h"
#import "SimpleSearchViewController.h"
#import "SettingsViewController.h"

@implementation MainViewController

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
    
    UINavigationController *nc3 = [[UINavigationController alloc] init];
    UIViewController *vc3 = [[CollectionsViewController alloc] initWithNibName:nil bundle:nil];
    nc3.viewControllers = [NSArray arrayWithObjects:vc3, nil];
    nc3.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Collections"
                                                   image:[UIImage imageNamed:@"cards.png"]
                                           selectedImage:nil];
    
    UINavigationController *nc4 = [[UINavigationController alloc] init];
    UIViewController *vc4 = [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
    nc4.viewControllers = [NSArray arrayWithObjects:vc4, nil];
    nc4.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings"
                                                   image:[UIImage imageNamed:@"settings.png"]
                                           selectedImage:nil];
    
    self.viewControllers = @[nc1, nc2, nc3, nc4];
    self.selectedViewController = nc1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITabBarControllerDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
//    if ([item.title isEqualToString:@"Collections"])
//    {
//        InAppPurchase *iap = [[InAppPurchase alloc] init];
//        
//        iap.delegate = self;
//        iap.productID = COLLECTIONS_PRODUCT_ID;
//        [iap initPurchase];
//    }
}

#pragma mark - InAppPurchase
-(void) purchaseSucceded:(NSString*) message
{
    self.selectedViewController = self.viewControllers[3];
}

-(void) purchaseFailed:(NSString*) message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"In-App Purchase Error"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    
    self.selectedViewController = [self.viewControllers firstObject];
}

@end
