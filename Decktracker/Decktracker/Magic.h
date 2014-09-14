//
//  Magic.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/2/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#ifndef Decktracker_Magic_h
#define Decktracker_Magic_h

#define LayoutNormal                     @"Normal"
#define LayoutSplit                      @"Split"
#define LayoutFlip                       @"Flip"
#define LayoutDoubleFaced                @"Double-Faced"
#define LayoutToken                      @"Token"
#define LayoutPlane                      @"Plane"
#define LayoutScheme                     @"Scheme"
#define LayoutPhenomenon                 @"Phenomenon"
#define LayoutLeveler                    @"Leveler"
#define LayoutVanguard                   @"Vanguard"
typedef NSString* Layout;

#define kManaSymbols                   @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", \
                                         @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", \
                                         @"18", @"19", @"20", @"100", @"1000000", @"W", @"U", @"B", \
                                         @"R", @"G", @"S", @"X", @"Y", @"Z", @"WU", @"WB", @"UB", \
                                         @"UR", @"BR", @"BG", @"RG", @"RW", @"GW", @"GU", @"2W", \
                                         @"2U", @"2B", @"2R", @"2G", @"P", @"PW", @"PU", @"PB", \
                                         @"PR", @"PG", @"Infinity", @"H", @"HW", @"HU", @"HB", \
                                         @"HR", @"HG"]


#define kOtherSymbols                   @[@"T", @"Q", @"C", @"artifact", @"creature", \
                                         @"enchantment", @"instant", @"land", @"multiple", \
                                         @"planeswalker", @"sorcery", @"power", @"toughness", \
                                         @"chaosdice", @"planeswalk", @"forwardslash"]

#define kImageSizes                     @[@"32", @"48", @"64", @"96"]

#define CARD_TYPES                      @[@"Artifact", @"Conspiracy", @"Creature", \
                                          @"Enchantment", @"Instant", @"Land", \
                                          @"Legendary", @"Ongoing", @"Phenomenon", @"Plane", \
                                          @"Planeswalker", @"Scheme", @"Snow", @"Sorcery", \
                                          @"Tribal", @"Vanguard", @"World"]


#define TCGPLAYER_PARTNER_KEY           @"DECKTRACKER"
#define COLLECTIONS_IAP_PRODUCT_ID      @"Collections_ID"

typedef NS_ENUM(NSInteger, EditMode)
{
    EditModeNew,
    EditModeEdit
};

#endif
