//
//  QuantityTableViewCell.h
//  Decktracker
//
//  Created by Jovit Royeca on 9/3/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;

#define QUANTITY_TABLE_CELL_HEIGHT            60

@class QuantityTableViewCell;

@protocol QuantityTableViewCellDelegate <NSObject>

-(void) stepperChanged:(QuantityTableViewCell*) cell withValue:(int) newValue;

@end

@interface QuantityTableViewCell : UITableViewCell

@property(strong,nonatomic) id<QuantityTableViewCellDelegate> delegate;
@property(strong,nonatomic) IBOutlet UIStepper *stepper;
@property(strong,nonatomic) IBOutlet UITextField *txtQuantity;

@end
