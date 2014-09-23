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
{
    Card *_card;
}

@synthesize imgCrop = _imgCrop;
@synthesize lblCardName = _lblCardName;
@synthesize lblDetail = _lblDetail;
@synthesize viewManaCost = _viewManaCost;
@synthesize imgSet = _imgSet;
@synthesize lblBadge = _lblBadge;

- (void)awakeFromNib
{
    // Initialization code
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
    _card = card;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kCropDownloadCompleted
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadCropImage:)
                                                 name:kCropDownloadCompleted
                                               object:nil];
    
    NSMutableString *type = [[NSMutableString alloc] initWithFormat:@"%@", card.type];
    
    if (card.power || card.toughness)
    {
        [type appendFormat:@" (%@/%@)", card.power, card.toughness];
    }
    else if ([card.types containsObject:[CardType MR_findFirstByAttribute:@"name" withValue:@"Planeswalker"]])
    {
        [type appendFormat:@" (Loyalty: %@)", card.loyalty];
    }
    
    self.lblCardName.font = [UIFont fontWithName:@"Magic:the Gathering" size:22];
    self.lblCardName.text = [NSString stringWithFormat:@" %@", card.name];
    self.lblDetail.text = type;
    self.lblSet.text = [NSString stringWithFormat:@"%@ - %@", card.set.name, card.rarity.name];
    
    NSString *path = [[FileManager sharedInstance] cropPath:card];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        self.imgCrop.image = [UIImage imageNamed:@"blank.png"];
    }
    else
    {
        self.imgCrop.image = [[UIImage alloc] initWithContentsOfFile:path];
    }
    [[FileManager sharedInstance] downloadCropImage:card];
    [[FileManager sharedInstance] downloadCardImage:card];
    
    // set image
    path = [[FileManager sharedInstance] cardSetPath:card];
    UIImage *setImage = [[UIImage alloc] initWithContentsOfFile:path];
    self.imgSet.image = setImage;
    // resize the image
    CGSize itemSize = CGSizeMake(setImage.size.width/2, setImage.size.height/2);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [setImage drawInRect:imageRect];
    self.imgSet.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
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
        CGFloat width, height;
        int pngSize;
        
        if ([noCurlies isEqualToString:@"100"])
        {
            width = 24;
            height = 13;
            pngSize = 48;
        }
        else if ([noCurlies isEqualToString:@"1000000"])
        {
            width = 64;
            height = 13;
            pngSize = 96;
        }
        else
        {
            width = 16;
            height = 16;
            pngSize = 32;
        }
        
        for (NSString *mana in kManaSymbols)
        {
            if ([mana isEqualToString:noCurlies])
            {
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/images/mana/%@/%d.png", [[NSBundle mainBundle] bundlePath], noCurlies, pngSize]];

                [arrImages addObject:@{@"width"  : [NSNumber numberWithFloat:width],
                                       @"height" : [NSNumber numberWithFloat:height],
                                       @"image"  : image}];
                bFound = YES;
            }
            else if ([mana isEqualToString:noCurliesReverse])
            {
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/images/mana/%@/%D.png", [[NSBundle mainBundle] bundlePath], noCurliesReverse, pngSize]];
                
                [arrImages addObject:@{@"width"  : [NSNumber numberWithFloat:width],
                                       @"height" : [NSNumber numberWithFloat:height],
                                       @"image"  : image}];
                bFound = YES;
            }
        }
        
        if (!bFound)
        {
            for (NSString *mana in kOtherSymbols)
            {
                if ([mana isEqualToString:noCurlies])
                {
                    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/images/other/%@/%d.png", [[NSBundle mainBundle] bundlePath], noCurlies, pngSize]];
                    
                    [arrImages addObject:@{@"width"  : [NSNumber numberWithFloat:width],
                                           @"height" : [NSNumber numberWithFloat:height],
                                           @"image"  : image}];
                }
                else if ([mana isEqualToString:noCurlies])
                {
                    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/images/other/%@/%d.png", [[NSBundle mainBundle] bundlePath], noCurliesReverse, pngSize]];
                    
                    [arrImages addObject:@{@"width"  : [NSNumber numberWithFloat:width],
                                           @"height" : [NSNumber numberWithFloat:height],
                                           @"image"  : image}];
                }
            }
        }
    }

    // remove first
    for (UIView *view in [self.viewManaCost subviews])
    {
        [view removeFromSuperview];
    }
    [self.lblCardName removeFromSuperview];
    [self.viewManaCost removeFromSuperview];
    
    // recalculate frame
    CGFloat newWidth = 0;
    for (NSDictionary *dict in arrImages)
    {
        CGFloat dWidth = [dict[@"width"] floatValue];
        newWidth += dWidth;
    }
    
    self.lblCardName.frame = CGRectMake(self.lblCardName.frame.origin.x, self.lblCardName.frame.origin.y, self.lblCardName.frame.size.width+(self.viewManaCost.frame.size.width-newWidth), self.lblCardName.frame.size.height);
    
    self.viewManaCost.frame = CGRectMake(self.lblCardName.frame.origin.x+self.lblCardName.frame.size.width, self.viewManaCost.frame.origin.y, newWidth, self.viewManaCost.frame.size.height);
    
    // then re-add
    CGFloat dY = 0;
    CGFloat dX = 0;
    [self addSubview:self.lblCardName];
    [self addSubview:self.viewManaCost];
    for (NSDictionary *dict in arrImages)
    {
        CGFloat dWidth = [dict[@"width"] floatValue];
        CGFloat dHeight = [dict[@"height"] floatValue];
        dX = self.viewManaCost.frame.size.width - ((arrImages.count-[arrImages indexOfObject:dict]) * dWidth);
        UIImage *image = dict [@"image"];

        UIImageView *imgMana = [[UIImageView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
        imgMana.contentMode = UIViewContentModeScaleAspectFit;
        imgMana.image = image;
        
        [self.viewManaCost addSubview:imgMana];
    }
}

-(void) addBadge:(int) badgeValue
{
    self.lblBadge.text = [NSString stringWithFormat:@"%dx", badgeValue];
    self.lblBadge.layer.backgroundColor = [UIColor redColor].CGColor;
    self.lblBadge.layer.cornerRadius = self.lblBadge.bounds.size.height / 4;
}

-(void) loadCropImage:(id) sender
{
    Card *card = [sender userInfo][@"card"];
    
    if (_card == card)
    {
        UIImage *hiResImage = [UIImage imageWithContentsOfFile:[[FileManager sharedInstance] cropPath:card]];
        
        self.imgCrop.image = hiResImage;
    }
}

@end
