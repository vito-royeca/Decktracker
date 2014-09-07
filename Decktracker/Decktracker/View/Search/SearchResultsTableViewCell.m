//
//  SearchResultsTableViewCell.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/24/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "SearchResultsTableViewCell.h"
#import "FileManager.h"

#import "JSBadgeView.h"

@implementation SearchResultsTableViewCell
{
    Card *_card;
}

@synthesize imgCrop = _imgCrop;
@synthesize lblCardName = _lblCardName;
@synthesize lblDetail = _lblDetail;
@synthesize viewManaCost = _viewManaCost;
@synthesize imgSet = _imgSet;
@synthesize viewBadge = _viewBadge;

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
    
    self.lblCardName.font = [UIFont fontWithName:@"Magic:the Gathering" size:20];
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
    self.imgSet.image = [[UIImage alloc] initWithContentsOfFile:path];
    
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
    
    for (UIView *view in [self.viewManaCost subviews])
    {
        [view removeFromSuperview];
    }
    
    CGFloat dX = 0;//self.viewManaCost.frame.size.width - (arrImages.count*16);
    CGFloat dY = 0;
    for (NSDictionary *dict in arrImages)
    {
        CGFloat dWidth = [dict[@"width"] floatValue];
        CGFloat dHeight = [dict[@"height"] floatValue];
        UIImage *image = dict [@"image"];
        
        UIImageView *imgMana = [[UIImageView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
        imgMana.contentMode = UIViewContentModeScaleAspectFit;
        imgMana.image = image;
        
        [self.viewManaCost addSubview:imgMana];
        dX += dWidth;
    }
}

-(void) addBadge:(int) badgeValue
{
    JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:self.viewBadge
                                                           alignment:JSBadgeViewAlignmentCenter];
    badgeView.badgeText = [NSString stringWithFormat:@"%d", badgeValue];
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
