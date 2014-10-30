//
//  AppDelegate.m
//  DeckTracker
//
//  Created by Jovit Royeca on 8/2/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "AppDelegate.h"
#import "Database.h"
#import "FileManager.h"
#import "MainViewController.h"

#import "BoxSDK.h"
#import <Crashlytics/Crashlytics.h>
#import <Dropbox/Dropbox.h>
#import "GAI.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

    // Google Analytics
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelWarning];
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-53780226-1"];
    
    // Crashlytics
    [Crashlytics startWithAPIKey:@"114b3dd82452ec2f4024140ec862698d331b8f3f"];

    // FileSystem
    [[FileManager sharedInstance] moveFilesInDocumentsToCaches];
    for (NSInteger i=FileSystemLocal; i<=FileSystemOneDrive; i++)
    {
        [[FileManager sharedInstance] setupFilesystem:i];
        [[FileManager sharedInstance] initFilesystem:i];
    }
    [[FileManager sharedInstance] syncFiles];

    // MagicalRecord
    [[Database sharedInstance ] setupDb];

    // custom colors
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x691F01)];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
        NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UITabBar appearance] setBarTintColor:UIColorFromRGB(0x691F01)];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UISearchBar appearance] setTintColor:UIColorFromRGB(0x691F01)];
    [[UISegmentedControl appearance] setTintColor:[UIColor grayColor]];
    
    // remove the "< Back" title in back buttons
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    UIViewController *viewController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ||
        [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        viewController = [[MainViewController alloc] init];
    }
    
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[Database sharedInstance] closeDb];
}

// Dropbox handler after authenticating
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
  sourceApplication:(NSString *)source
         annotation:(id)annotation
{
    if ([[url scheme] hasPrefix:@"db-"])
    {
        DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
        
        if (account)
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"dropbox_preference"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[FileManager sharedInstance] initFilesystem:FileSystemDropbox];
            [[FileManager sharedInstance] syncFiles];
            return YES;
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:@"dropbox_preference"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[FileManager sharedInstance] disconnectFromFileSystem:FileSystemDropbox];
            return NO;
        }
    }
    
    return NO;
}

@end
