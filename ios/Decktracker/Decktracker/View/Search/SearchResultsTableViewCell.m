//
//  SearchResultsTableViewCell.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/24/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "SearchResultsTableViewCell.h"
#import "DTSet.h"
#import "FileManager.h"

#import "EDStarRating.h"

@implementation SearchResultsTableViewCell
{
    DTCard *_card;
    DTCardType *_planeswalkerType;
    UIFont *_pre8thEditionFont;
    UIFont *_8thEditionFont;
    EDStarRating *_ratingControl;
}

@synthesize lblRank = _lblRank;
@synthesize imgCrop = _imgCrop;
@synthesize lblCardName = _lblCardName;
@synthesize lblDetail = _lblDetail;
@synthesize viewManaCost = _viewManaCost;
@synthesize imgSet = _imgSet;
@synthesize lblBadge = _lblBadge;
@synthesize viewRating = _viewRating;
@synthesize lblLowPrice = _lblLowPrice;
@synthesize lblMedianPrice = _lblMedianPrice;
@synthesize lblHighPrice = _lblHighPrice;
@synthesize lblFoilPrice = _lblFoilPrice;
@synthesize imgType = _imgType;

- (void)awakeFromNib
{
    // Initialization code
    self.imgCrop.layer.cornerRadius = 10.0;
    self.imgCrop.layer.masksToBounds = YES;

    _planeswalkerType = [DTCardType MR_findFirstByAttribute:@"name" withValue:@"Planeswalker"];
    _pre8thEditionFont = [UIFont fontWithName:@"Magic:the Gathering" size:20];
    _8thEditionFont = [UIFont fontWithName:@"Matrix-Bold" size:18];
    
    _ratingControl = [[EDStarRating alloc] initWithFrame:self.viewRating.frame];
    _ratingControl.userInteractionEnabled = NO;
    _ratingControl.starImage = [UIImage imageNamed:@"star.png"];
    _ratingControl.starHighlightedImage = [UIImage imageNamed:@"starhighlighted.png"];
    _ratingControl.maxRating = 5.0;
    _ratingControl.backgroundColor = [UIColor clearColor];
    _ratingControl.displayMode=EDStarRatingDisplayHalf;
    
    
    self.lblCardName.adjustsFontSizeToFitWidth = YES;
    self.lblDetail.adjustsFontSizeToFitWidth = YES;
    self.lblSet.adjustsFontSizeToFitWidth = YES;
    self.lblLowPrice.adjustsFontSizeToFitWidth = YES;
    self.lblMedianPrice.adjustsFontSizeToFitWidth = YES;
    self.lblHighPrice.adjustsFontSizeToFitWidth = YES;
    self.lblFoilPrice.adjustsFontSizeToFitWidth = YES;
    
    [self.viewRating removeFromSuperview];
    [self addSubview:_ratingControl];
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

-(void) displayCard:(DTCard*) card
{
    _card = card;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kCropDownloadCompleted
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadCropImage:)
                                                 name:kCropDownloadCompleted
                                               object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kParseSyncDone
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(parseSyncDone:)
                                                 name:kParseSyncDone
                                               object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kPriceUpdateDone
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePricing:)
                                                 name:kPriceUpdateDone
                                               object:nil];
    
    NSMutableString *type = [[NSMutableString alloc] initWithFormat:@"%@", card.type];
    
    if (card.power || card.toughness)
    {
        [type appendFormat:@" (%@/%@)", card.power, card.toughness];
    }
    else if ([card.types containsObject:_planeswalkerType])
    {
        [type appendFormat:@" (Loyalty: %@)", card.loyalty];
    }
    
    if ([[Database sharedInstance] isCardModern:card])
    {
        self.lblCardName.font = _8thEditionFont;
    }
    else
    {
        self.lblCardName.font = _pre8thEditionFont;
    }
    
    self.lblCardName.text = [NSString stringWithFormat:@" %@", card.name];
    self.lblDetail.text = type;
    self.lblSet.text = [NSString stringWithFormat:@"%@ (%@)", card.set.name, card.rarity.name];
    _ratingControl.rating = [_card.rating doubleValue];
    
    // crop image
    NSString *path = [[FileManager sharedInstance] cropPath:card];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        self.imgCrop.image = [UIImage imageNamed:@"blank.png"];
    }
    else
    {
        self.imgCrop.image = [[UIImage alloc] initWithContentsOfFile:path];
    }
    [[FileManager sharedInstance] downloadCropImage:card immediately:NO];
    [[FileManager sharedInstance] downloadCardImage:card immediately:NO];
    [[Database sharedInstance] fetchTcgPlayerPriceForCard:card];
    
    // type image
    path = [[FileManager sharedInstance] cardTypePath:card];
    if (path)
    {
        UIImage *typeImage = [[UIImage alloc] initWithContentsOfFile:path];
        self.imgType.image = typeImage;
        // resize the image
        CGSize itemSize = CGSizeMake(typeImage.size.width/2, typeImage.size.height/2);
        UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [typeImage drawInRect:imageRect];
        self.imgType.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else
    {
        self.imgType.image = nil;
    }
    
    // set image
    NSDictionary *dict = [[Database sharedInstance] inAppSettingsForSet:card.set];
    if (dict)
    {
        self.imgSet.image = [UIImage imageNamed:@"locked.png"];
    }
    else
    {
        path = [[FileManager sharedInstance] cardSetPath:card];
        if (path)
        {
            UIImage *setImage = [[UIImage alloc] initWithContentsOfFile:path];
            self.imgSet.image = setImage;
            // resize the image
            CGSize itemSize = CGSizeMake(setImage.size.width/2, setImage.size.height/2);
            UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            [setImage drawInRect:imageRect];
            self.imgSet.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        else
        {
            self.imgSet.image = nil;
        }
    }
    
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
    
    [self showCardPricing];
}

-(void) addBadge:(int) badgeValue
{
    self.lblBadge.text = [NSString stringWithFormat:@"%dx", badgeValue];
    self.lblBadge.layer.backgroundColor = [UIColor redColor].CGColor;
    self.lblBadge.layer.cornerRadius = self.lblBadge.bounds.size.height / 4;
}

-(void) addRank:(int) rankValue
{
    self.lblRank.text = [NSString stringWithFormat:@"%d", rankValue];
    self.lblRank.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.lblRank.layer.cornerRadius = self.lblBadge.bounds.size.height / 2;
}

-(void) updatePricing:(id) sender
{
    DTCard *card = [sender userInfo][@"card"];
    
    if (_card == card)
    {
        [self showCardPricing];
    }
}

-(void) showCardPricing
{
    NSNumberFormatter *formatter =  [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    [formatter setRoundingMode:NSNumberFormatterRoundCeiling];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSString *price = [_card.tcgPlayerLowPrice doubleValue] != 0 ? [formatter stringFromNumber:_card.tcgPlayerLowPrice] : @"N/A";
    UIColor *color = [_card.tcgPlayerLowPrice doubleValue] != 0 ? [UIColor redColor] : [UIColor lightGrayColor];
    self.lblLowPrice.text = price;
    self.lblLowPrice.textColor = color;
    
    price = [_card.tcgPlayerMidPrice doubleValue] != 0 ? [formatter stringFromNumber:_card.tcgPlayerMidPrice] : @"N/A";
    color = [_card.tcgPlayerMidPrice doubleValue] != 0 ? [UIColor blueColor] : [UIColor lightGrayColor];
    self.lblMedianPrice.text = price;
    self.lblMedianPrice.textColor = color;
    
    price = [_card.tcgPlayerHighPrice doubleValue] != 0 ? [formatter stringFromNumber:_card.tcgPlayerHighPrice] : @"N/A";
    color = [_card.tcgPlayerHighPrice doubleValue] != 0 ? [self colorFromHexString:@"#008000"] : [UIColor lightGrayColor];
    self.lblHighPrice.text = price;
    self.lblHighPrice.textColor = color;
    
    price = [_card.tcgPlayerFoilPrice doubleValue] != 0 ? [formatter stringFromNumber:_card.tcgPlayerFoilPrice] : @"N/A";
    color = [_card.tcgPlayerFoilPrice doubleValue] != 0 ? [self colorFromHexString:@"#998100"] : [UIColor lightGrayColor];
    self.lblFoilPrice.text = price;
    self.lblFoilPrice.textColor = color;
}

-(void) loadCropImage:(id) sender
{
    DTCard *card = [sender userInfo][@"card"];
    
    if (_card == card)
    {
        UIImage *hiResImage = [UIImage imageWithContentsOfFile:[[FileManager sharedInstance] cropPath:card]];
        
        self.imgCrop.image = hiResImage;
    }
}

-(void) parseSyncDone:(id) sender
{
    DTCard *card = [sender userInfo][@"card"];
    
    if (_card == card)
    {
        _ratingControl.rating = [card.rating doubleValue];
    }
}

// Assumes input like "#00FF00" (#RRGGBB).
- (UIColor*)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0xFF00) >> 8)/255.0
                            blue:(rgbValue & 0xFF)/255.0
                           alpha:1.0];
}
@end
