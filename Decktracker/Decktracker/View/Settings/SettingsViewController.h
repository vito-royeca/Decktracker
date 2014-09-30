//
//  SettingsViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 9/4/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;

#import "IASKAppSettingsViewController.h"
#import "InAppPurchase.h"
#import "Magic.h"

#import "IASKSettingsReader.h"

@interface SettingsViewController : UIViewController<InAppPurchaseDelegate, IASKSettingsDelegate>

@property(strong,nonatomic) IASKAppSettingsViewController *appSettingsViewController;

@end
