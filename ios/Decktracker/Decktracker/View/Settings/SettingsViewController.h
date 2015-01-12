//
//  SettingsViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 9/4/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;

#import "InAppPurchase.h"
#import "InAppPurchaseViewController.h"
#import "Magic.h"

#import "IASKSettingsReader.h"
#import "IASKAppSettingsViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/PFLoginViewController.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>


@interface SettingsViewController : UIViewController<InAppPurchaseDelegate, InAppPurchaseViewControllerDelegate, IASKSettingsDelegate, PFLogInViewControllerDelegate>

@property(strong,nonatomic) IASKAppSettingsViewController *appSettingsViewController;

@end
