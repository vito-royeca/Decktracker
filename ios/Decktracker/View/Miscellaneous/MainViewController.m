//
//  MainViewController.m
//  DeckTracker
//
//  Created by Jovit Royeca on 8/5/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "MainViewController.h"
#import "Constants.h"
#import "DecksViewController.h"

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
    UIViewController *vc1 = [[CardsViewController alloc] initWithNibName:nil bundle:nil];
    nc1.viewControllers = [NSArray arrayWithObjects:vc1, nil];
    nc1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Cards"
                                                   image:[UIImage imageNamed:@"cards.png"]
                                           selectedImage:nil];

    UINavigationController *nc2 = [[UINavigationController alloc] init];
    UIViewController *vc2 = [[DecksViewController alloc] initWithNibName:nil bundle:nil];
    nc2.viewControllers = [NSArray arrayWithObjects:vc2, nil];
    nc2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Decks"
                                                   image:[UIImage imageNamed:@"layers.png"]
                                           selectedImage:nil];

    UIViewController *vc4 = [[CardQuizHomeViewController alloc] initWithNibName:nil bundle:nil];
    vc4.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Card Quiz"
                                                   image:[UIImage imageNamed:@"questions.png"]
                                           selectedImage:nil];
    
    UINavigationController *nc5 = [[UINavigationController alloc] init];
    UIViewController *vc5 = [[MoreViewController alloc] initWithNibName:nil bundle:nil];
    nc5.viewControllers = [NSArray arrayWithObjects:vc5, nil];
    nc5.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:5];
    
    self.viewControllers = @[nc1, nc2, vc4, nc5];
    self.selectedViewController = nc1;

//    UIViewController *vc1 = [[CardsViewController alloc] initWithNibName:nil bundle:nil];
//    vc1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Cards"
//                                                   image:[UIImage imageNamed:@"cards.png"]
//                                           selectedImage:nil];
//
//    UIViewController *vc2 = [[DecksViewController alloc] initWithNibName:nil bundle:nil];
//    vc2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Decks"
//                                                   image:[UIImage imageNamed:@"layers.png"]
//                                           selectedImage:nil];
//    
//    
//    UIViewController *vc4 = [[CardQuizHomeViewController alloc] initWithNibName:nil bundle:nil];
//    vc4.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Card Quiz"
//                                                   image:[UIImage imageNamed:@"questions.png"]
//                                           selectedImage:nil];
//    
//    UIViewController *vc5 = [[MoreViewController alloc] initWithNibName:nil bundle:nil];
//    vc5.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:5];
//    
//    self.viewControllers = @[vc1, vc2, vc4, vc5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
