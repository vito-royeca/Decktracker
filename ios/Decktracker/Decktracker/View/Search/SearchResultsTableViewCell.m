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
    UIFont *_pre8thEditionFont;
    UIFont *_8thEditionFont;
    EDStarRating *_ratingControl;
    NSString *_currentCropPath;
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

    _pre8thEditionFont = [UIFont fontWithName:@"Magic:the Gathering" size:20];
    _8thEditionFont = [UIFont fontWithName:@"Matrix-Bold" size:18];
    
    _ratingControl = [[EDStarRating alloc] initWithFrame:self.viewRating.frame];
    _ratingControl.userInteractionEnabled = NO;
    _ratingControl.starImage = [UIImage imageNamed:@"star.png"];
    _ratingControl.starHighlightedImage = [UIImage imageNamed:@"starhighlighted.png"];
    _ratingControl.maxRating = 5;
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

-(void) displayCard:(NSString*) cardId
{
    self.cardId = cardId;

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kCardDownloadCompleted
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadCropImage:)
                                                 name:kCardDownloadCompleted
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
    
    DTCard *card = [DTCard objectForPrimaryKey:self.cardId];
    
    NSMutableString *type = [[NSMutableString alloc] initWithFormat:@"%@", card.type];
    
    if (card.power.length > 0 || card.toughness.length > 0)
    {
        [type appendFormat:@" (%@/%@)", card.power, card.toughness];
    }
    else
    {
        DTCardType *planeswalkerType = [[DTCardType objectsWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", @"Planeswalker"]] firstObject];
        
        for (DTCardType *cardType in card.types)
        {
            if (cardType == planeswalkerType)
            {
                [type appendFormat:@" (Loyalty: %d)", card.loyalty];
                break;
            }
        }
    }
    
    if (card.modern)
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
    _ratingControl.rating = (float)card.rating;
    [[Database sharedInstance] fetchCardRating:card.cardId];
    
    // crop image
    _currentCropPath = [[FileManager sharedInstance] cropPath:self.cardId];
    self.imgCrop.image = [[UIImage alloc] initWithContentsOfFile:_currentCropPath];
    
    [[FileManager sharedInstance] downloadCardImage:self.cardId immediately:NO];
    
    // type image
    NSString *path = [[FileManager sharedInstance] cardTypePath:self.cardId];
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
    NSDictionary *dict = [[Database sharedInstance] inAppSettingsForSet:card.set.setId];
    if (dict)
    {
        self.imgSet.image = [UIImage imageNamed:@"locked.png"];
    }
    else
    {
        path = [[FileManager sharedInstance] cardSetPath:self.cardId];
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
    
    NSArray *arrManaImages = [[FileManager sharedInstance] manaImagesForCard:self.cardId];
    
    // remove first
    for (UIView *view in [self.viewManaCost subviews])
    {
        [view removeFromSuperview];
    }
    [self.lblCardName removeFromSuperview];
    [self.viewManaCost removeFromSuperview];
    
    // recalculate frame
    CGFloat newWidth = 0;
    for (NSDictionary *dict in arrManaImages)
    {
        CGFloat dWidth = [dict[@"width"] floatValue];
        newWidth += dWidth;
    }
    
    self.lblCardName.frame = CGRectMake(self.lblCardName.frame.origin.x, self.lblCardName.frame.origin.y, self.lblCardName.frame.size.width+(self.viewManaCost.frame.size.width-newWidth), self.lblCardName.frame.size.height);
    
    self.viewManaCost.frame = CGRectMake(self.lblCardName.frame.origin.x+self.lblCardName.frame.size.width, self.viewManaCost.frame.origin.y, newWidth, self.viewManaCost.frame.size.height);
    
    // then re-add
    CGFloat dY = 0;
    CGFloat dX = 0;
    int index = 0;
    [self addSubview:self.lblCardName];
    [self addSubview:self.viewManaCost];
    for (NSDictionary *dict in arrManaImages)
    {
        CGFloat dWidth = [dict[@"width"] floatValue];
        CGFloat dHeight = [dict[@"height"] floatValue];
        dX = self.viewManaCost.frame.size.width - ((arrManaImages.count-index) * dWidth);
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:dict[@"path"]];

        UIImageView *imgMana = [[UIImageView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
        imgMana.contentMode = UIViewContentModeScaleAspectFit;
        imgMana.image = image;
        
        [self.viewManaCost addSubview:imgMana];
        index++;
    }
    
    [self showCardPricing];
    [[Database sharedInstance] fetchTcgPlayerPriceForCard:card.cardId];
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
    self.lblRank.layer.cornerRadius = self.lblRank.bounds.size.height / 2;
}

-(void) updateDisplay
{
    UIView *view = self;
    UIView *parent;
    do
    {
        parent = view.superview;
        view = parent;
        
        if ([parent isKindOfClass:[UITableView class]])
        {
            break;
        }
        
    } while (parent);
    
    if (parent)
    {
        UITableView *table = (UITableView *)parent;
        NSIndexPath *indexPath = [table indexPathForCell: self];
        [table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void) updatePricing:(id) sender
{
    NSString *cardId = [sender userInfo][@"cardId"];
    
    if ([self.cardId isEqualToString:cardId])
    {
        [self showCardPricing];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:kPriceUpdateDone
                                                      object:nil];
//        [self updateDisplay];
    }
}

-(void) showCardPricing
{
    NSNumberFormatter *formatter =  [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    [formatter setRoundingMode:NSNumberFormatterRoundCeiling];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    DTCard *card = [DTCard objectForPrimaryKey:self.cardId];
    
    NSString *price = card.tcgPlayerLowPrice != 0 ? [formatter stringFromNumber:[NSNumber numberWithDouble:card.tcgPlayerLowPrice]] : @"N/A";
    UIColor *color = card.tcgPlayerLowPrice != 0 ? [UIColor redColor] : [UIColor lightGrayColor];
    self.lblLowPrice.text = price;
    self.lblLowPrice.textColor = color;
    
    price = card.tcgPlayerMidPrice != 0 ? [formatter stringFromNumber:[NSNumber numberWithDouble:card.tcgPlayerMidPrice]] : @"N/A";
    color = card.tcgPlayerMidPrice != 0 ? [UIColor blueColor] : [UIColor lightGrayColor];
    self.lblMedianPrice.text = price;
    self.lblMedianPrice.textColor = color;
    
    price = card.tcgPlayerHighPrice != 0 ? [formatter stringFromNumber:[NSNumber numberWithDouble:card.tcgPlayerHighPrice]] : @"N/A";
    color = card.tcgPlayerHighPrice != 0 ? [self colorFromHexString:@"#008000"] : [UIColor lightGrayColor];
    self.lblHighPrice.text = price;
    self.lblHighPrice.textColor = color;
    
    price = card.tcgPlayerFoilPrice != 0 ? [formatter stringFromNumber:[NSNumber numberWithDouble:card.tcgPlayerFoilPrice]] : @"N/A";
    color = card.tcgPlayerFoilPrice != 0 ? [self colorFromHexString:@"#998100"] : [UIColor lightGrayColor];
    self.lblFoilPrice.text = price;
    self.lblFoilPrice.textColor = color;
}

-(void) loadCropImage:(id) sender
{
    NSString *cardId = [sender userInfo][@"cardId"];
    
    if ([self.cardId isEqualToString:cardId])
    {
        NSString *path = [[FileManager sharedInstance] cropPath:self.cardId];
        
        if (![path isEqualToString:_currentCropPath])
        {
            UIImage *hiResImage = [UIImage imageWithContentsOfFile: path];
            
            [UIView transitionWithView:self.imgCrop
                              duration:1
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                self.imgCrop.image = hiResImage;
                            } completion:nil];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:kCardDownloadCompleted
                                                      object:nil];
    }
}

-(void) parseSyncDone:(id) sender
{
    NSString *cardId = [sender userInfo][@"cardId"];
    
    if ([self.cardId isEqualToString:cardId])
    {
        DTCard *card = [DTCard objectForPrimaryKey:self.cardId];
        _ratingControl.rating = (float)card.rating;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:kParseSyncDone
                                                      object:nil];
//        [self updateDisplay];
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
