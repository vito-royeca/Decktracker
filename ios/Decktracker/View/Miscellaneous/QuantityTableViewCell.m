//
//  QuantityTableViewCell.m
//  Decktracker
//
//  Created by Jovit Royeca on 9/3/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "QuantityTableViewCell.h"

@implementation QuantityTableViewCell

@synthesize delegate;
@synthesize stepper;
@synthesize txtQuantity;

- (void)awakeFromNib
{
    // Initialization code

    [self.stepper addTarget:self
                     action:@selector(stepperChanged:)
           forControlEvents:UIControlEventValueChanged];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) stepperChanged:(id) sender
{
    int value = (int)self.stepper.value;
    
    if (self.delegate)
    {
        [self.delegate stepperChanged:self withValue:value];
    }
}

@end
