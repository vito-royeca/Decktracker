//
//  SearchResultsTableViewCell.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/24/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "SearchResultsTableViewCell.h"
#import "FileManager.h"

@implementation SearchResultsTableViewCell

@synthesize imgCrop;
@synthesize lblCardName;
@synthesize lblDetail;
@synthesize viewManaCost;
@synthesize imgSet;

- (void)awakeFromNib
{
    // Initialization code
    self.lblCardName.font = [UIFont fontWithName:@"Goudy Medieval Medieval" size:17];
    self.imgCrop.layer.cornerRadius = 10.0;
    self.imgCrop.layer.masksToBounds = YES;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) displayCard:(Card*) card
{
    NSMutableString *type = [[NSMutableString alloc] initWithFormat:@"%@", card.type];
    
    if (card.power || card.toughness)
    {
        [type appendFormat:@" (%@/%@)", card.power, card.toughness];
    }
    else if ([card.types containsObject:[CardType MR_findFirstByAttribute:@"name" withValue:@"Planeswalker"]])
    {
        [type appendFormat:@" (Loyalty: %@)", card.loyalty];
    }
    
    self.lblCardName.text = card.name;
    self.lblDetail.text = type;
    self.lblSet.text = [NSString stringWithFormat:@"%@ - %@", card.set.name, card.rarity.name];
    
    NSString *path = [[FileManager sharedInstance] cropPath:card];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        self.imgCrop.image = [UIImage imageNamed:@"blank-24.png"];
    }
    else
    {
        self.imgCrop.image = [[UIImage alloc] initWithContentsOfFile:path];
    }
    
    path = [[FileManager sharedInstance] cardSetPath:card];
    self.imgSet.image = [[UIImage alloc] initWithContentsOfFile:path];
    
    // download cardImage
    [[FileManager sharedInstance] downloadCardImage:card withCompletion:nil];

    // draw the mana cost
    NSMutableArray *arrImages = [[NSMutableArray alloc] init];
    NSMutableArray *arrSymbols = [[NSMutableArray alloc] init];
    int curlyOpen = -1;
    int curlyClose = -1;
    
    for (int i=0; i<card.manaCost.length; i++)
    {
        if ([card.manaCost characterAtIndex:i] == '{')
        {
            curlyOpen = i;
        }
        if ([card.manaCost characterAtIndex:i] == '}')
        {
            curlyClose = i;
        }
        if (curlyOpen != -1 && curlyClose != -1)
        {
            NSString *symbol = [card.manaCost substringWithRange:NSMakeRange(curlyOpen, (curlyClose-curlyOpen)+1)];
            
            [arrSymbols addObject:symbol];
            
            curlyOpen = -1;
            curlyClose = -1;
        }
    }
    
    for (NSString *symbol in arrSymbols)
    {
        BOOL bFound = NO;
        NSString *noCurlies = [[symbol substringWithRange:NSMakeRange(1, symbol.length-2)] stringByReplacingOccurrencesOfString:@"/" withString:@""];
        NSString *noCurliesReverse = [JJJUtil reverseString:noCurlies];
        NSString *pngFile;
        
        if ([noCurlies isEqualToString:@"100"])
        {
            pngFile = @"24.png";
        }
        else if ([noCurlies isEqualToString:@"1000000"])
        {
            pngFile = @"48.png";
        }
        else
        {
            pngFile = @"16.png";
        }
        
        for (NSString *mana in kManaSymbols)
        {
            if ([mana isEqualToString:noCurlies])
            {
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/images/mana/%@/%@", [[NSBundle mainBundle] bundlePath], noCurlies, pngFile]];

                [arrImages addObject:image];
                bFound = YES;
            }
            else if ([mana isEqualToString:noCurliesReverse])
            {
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/images/mana/%@/%@", [[NSBundle mainBundle] bundlePath], noCurliesReverse, pngFile]];
                
                [arrImages addObject:image];
                bFound = YES;
            }
        }
        
        if (!bFound)
        {
            for (NSString *mana in kOtherSymbols)
            {
                if ([mana isEqualToString:noCurlies])
                {
                    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/images/other/%@/%@", [[NSBundle mainBundle] bundlePath], noCurlies, pngFile]];
                    
                    [arrImages addObject:image];
                }
                else if ([mana isEqualToString:noCurlies])
                {
                    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/images/other/%@/%@", [[NSBundle mainBundle] bundlePath], noCurliesReverse, pngFile]];
                    
                    [arrImages addObject:image];
                }
            }
        }
    }
    
    for (UIView *view in [self.viewManaCost subviews])
    {
        [view removeFromSuperview];
    }
    
    CGFloat dX = self.viewManaCost.frame.size.width - (arrImages.count*16);
    CGFloat dY = 0;
    CGFloat dWidth = 16;
    CGFloat dHeight = 16;
    for (UIImage *image in arrImages)
    {
        UIImageView *imgMana = [[UIImageView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
        imgMana.image = image;
        
        [self.viewManaCost addSubview:imgMana];
        dX += dWidth;
    }
}

@end
