//
//  MainViewController.m
//  DeckTracker
//
//  Created by Jovit Royeca on 8/5/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "MainViewController.h"
#import "SimpleSearchViewController.h"

@interface MainViewController ()

@end

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
                                                   image:[UIImage imageNamed:@"search-25.png"]
                                           selectedImage:nil];
    
    UINavigationController *nc2 = [[UINavigationController alloc] init];
    UIViewController *vc2 = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    vc2.view.backgroundColor = [UIColor blueColor];
    nc2.viewControllers = [NSArray arrayWithObjects:vc2, nil];
    nc2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Decks"
                                                   image:[UIImage imageNamed:@"layers-25.png"]
                                           selectedImage:nil];
    
    UINavigationController *nc3 = [[UINavigationController alloc] init];
    UIViewController *vc3 = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    vc3.view.backgroundColor = [UIColor greenColor];
    nc3.viewControllers = [NSArray arrayWithObjects:vc3, nil];
    nc3.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Collections"
                                                   image:[UIImage imageNamed:@"cards-25.png"]
                                           selectedImage:nil];
    
    UINavigationController *nc4 = [[UINavigationController alloc] init];
    UIViewController *vc4 = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    vc4.view.backgroundColor = [UIColor greenColor];
    nc4.viewControllers = [NSArray arrayWithObjects:vc3, nil];
    nc4.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings"
                                                   image:[UIImage imageNamed:@"settings-25.png"]
                                           selectedImage:nil];
    
    self.viewControllers = [NSArray arrayWithObjects:nc1, nc2, nc3, nc4, nil];
    self.selectedViewController = nc1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[hud removeFromSuperview];
}

#pragma mark - UITabBarControllerDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
