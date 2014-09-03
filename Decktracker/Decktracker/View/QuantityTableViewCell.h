//
//  QuantityTableViewCell.h
//  Decktracker
//
//  Created by Jovit Royeca on 9/3/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QuantityTableViewCell;

@protocol QualityTableViewCellDelegate <NSObject>

-(void) stepperChanged:(QuantityTableViewCell*) cell withValue:(int) newValue;

@end

@interface QuantityTableViewCell : UITableViewCell

@property(strong,nonatomic) id<QualityTableViewCellDelegate> delegate;
@property(strong,nonatomic) IBOutlet UIStepper *stepper;
@property(strong,nonatomic) IBOutlet UITextField *txtQuantity;

@end
