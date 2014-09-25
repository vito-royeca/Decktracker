//
//  MainViewController.h
//  DeckTracker
//
//  Created by Jovit Royeca on 8/5/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;

#import "IASKSettingsReader.h"
#import "InAppPurchase.h"

@interface MainViewController : UITabBarController<UITabBarControllerDelegate, InAppPurchaseDelegate>

-(void) addCollectionsProduct;
-(void) addNavigationController:(UINavigationController*) navController atIndex:(int) index;

@end
