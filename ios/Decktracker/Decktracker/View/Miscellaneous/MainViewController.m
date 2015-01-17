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

#import "Decktracker-Swift.h"

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
    UIViewController *vc1 = [[FeaturedViewController alloc] initWithNibName:nil bundle:nil];
    nc1.viewControllers = [NSArray arrayWithObjects:vc1, nil];
    nc1.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:1];
    
    UINavigationController *nc2 = [[UINavigationController alloc] init];
    UIViewController *vc2 = [[DecksViewController alloc] initWithNibName:nil bundle:nil];
    nc2.viewControllers = [NSArray arrayWithObjects:vc2, nil];
    nc2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Decks"
                                                   image:[UIImage imageNamed:@"layers.png"]
                                           selectedImage:nil];
    
    UINavigationController *nc4 = [[UINavigationController alloc] init];
    UIViewController *vc4 = [[SimpleSearchViewController alloc] initWithNibName:nil bundle:nil];
    nc4.viewControllers = [NSArray arrayWithObjects:vc4, nil];
    nc4.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Search"
                                                   image:[UIImage imageNamed:@"search.png"]
                                           selectedImage:nil];
    
    UINavigationController *nc5 = [[UINavigationController alloc] init];
    UIViewController *vc5 = [[MoreViewController alloc] initWithNibName:nil bundle:nil];
    nc5.viewControllers = [NSArray arrayWithObjects:vc5, nil];
    nc5.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:5];
    
    self.viewControllers = @[nc1, nc2, nc4, nc5];
    self.selectedViewController = nc1;
    
    [self addCollectionsProduct];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) addCollectionsProduct
{
    if (![InAppPurchase isProductPurchased:COLLECTIONS_IAP_PRODUCT_ID])
    {
        return;
    }
    
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
@end
