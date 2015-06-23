//
//  MainViewController.h
//  DeckTracker
//
//  Created by Jovit Royeca on 8/5/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;

@interface MainViewController : UITabBarController<UITabBarControllerDelegate>

-(void) addNavigationController:(UINavigationController*) navController atIndex:(int) index;

@end
