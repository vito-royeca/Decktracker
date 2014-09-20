//
//  BoxFolderPickerCell.m
//  BoxSDK
//
//  Created on 5/30/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <BoxSDK/UIImage+BoxAdditions.h>
#import <BoxSDK/NSString+BoxAdditions.h>

#import <BoxSDK/BoxFolderPickerCell.h>
#import <BoxSDK/BoxItem.h>
#import <BoxSDK/BoxFolder.h>
#import <BoxSDK/BoxFolderPickerHelper.h>
#import <BoxSDK/BoxSDK.h>

#import <QuartzCore/QuartzCore.h>

#define kCellHeight                   (58.0)

#define kImageViewOffsetX             (12.0)
#define kImageViewSide                (32.0)

#define kImageToLabelOffsetX          (12.0)
#define kNameStringOriginY            (11.0)
#define kNameStringHeight             (20.0)

#define kPaddingNameDescription       (20.0)
#define kDisclosureIndicatorOriginY   (23.0)

#define kDisabledAlpha                (0.3)

// @NOTE: This enum was renamed in iOS 6
#ifdef __IPHONE_6_0
#   define BOX_LINE_BREAK_MODE (NSLineBreakByTruncatingMiddle)
#else
#   define BOX_LINE_BREAK_MODE (UILineBreakModeMiddleTruncation)
#endif

@interface BoxFolderPickerCell ()

- (void)renderCell;
- (CGRect)imageViewRect;

@end

@implementation BoxFolderPickerCell

@synthesize helper = _helper;
@synthesize item = _item;
@synthesize cachePath = _cachePath;
@synthesize showThumbnails;
@synthesize enabled = _enabled;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        self.imageView.frame = [self imageViewRect];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }

    return self;
}

- (void)setItem:(BoxItem *)item
{
    if (item == nil || self.item == item) {
        return ;
    }
    
    _item = item;
    [self renderCell];
}

- (CGRect)imageViewRect
{
    CGRect r = CGRectMake(0, 0, kImageViewSide, kImageViewSide);
    r.origin.y = (kCellHeight / 2) - (kImageViewSide / 2) - 1;
    r.origin.x = kImageViewOffsetX;
    return r;
}

- (void)setEnabled:(BOOL)enabled
{
    if (enabled != _enabled)
    {
        _enabled = enabled;
        CGFloat alpha = _enabled ? 1.0 : kDisabledAlpha;
        self.textLabel.alpha = alpha;
        self.detailTextLabel.alpha = alpha;
        self.imageView.alpha = alpha;
    }
}

- (void)renderCell
{
    CGRect r;
    CGRect rect = self.bounds;

    NSString *cachedThumbnailPath = [self.cachePath stringByAppendingPathComponent:self.item.modelID];

    // Load thumbnail via the API if necessary
    [self.helper itemNeedsAPICall:self.item cachePath:cachedThumbnailPath completion:^(BOOL needsAPICall, UIImage *cachedImage) {
        self.imageView.image = [cachedImage imageWith2XScaleIfRetina];

        // Checking if we need to download the thumbnail for the current item
        if ([self.helper shouldDiplayThumbnailForItem:self.item] && needsAPICall && showThumbnails)
        {
            __block BoxFolderPickerCell *cell = self;
            __block BoxItem *currentItem = self.item;

            [self.helper thumbnailForItem:self.item cachePath:self.cachePath refreshed:^(UIImage *image) {
                if (image && cell.item == currentItem)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.imageView.image = [image imageWith2XScaleIfRetina];

                        CATransition *transition = [CATransition animation];
                        transition.duration = 0.3f;
                        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                        transition.type = kCATransitionFade;

                        [cell.imageView.layer addAnimation:transition forKey:nil];
                    });
                }
            }];
        }
    }];

    // Positioning the name label by offset from the image
    r.origin.x += kImageViewSide + kImageToLabelOffsetX;
    r.origin.y += 4.0;
    r.size.height = kNameStringHeight;
    r.size.width = rect.size.width - kImageToLabelOffsetX - kImageViewSide - kImageViewOffsetX - 24.0;

    self.textLabel.frame = r;
    self.textLabel.text = self.item.name;
    self.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
    self.textLabel.lineBreakMode = BOX_LINE_BREAK_MODE;
    self.textLabel.textColor = [UIColor colorWithRed:86.0f/255.0f
                                               green:86.0f/255.0f
                                                blue:86.0f/255.0f
                                               alpha:self.enabled ? 1.0 : kDisabledAlpha];

    r.origin.y += kPaddingNameDescription;

    NSString * desc = [NSString stringWithFormat:NSLocalizedString(@"%@ - Last update : %@", @"Title: File size and last modified timestamp (example: 5MB - Last Update : 2013-09-06 03:55)"), [NSString humanReadableStringForByteSize:self.item.size], [self.helper dateStringForItem:self.item]];
    self.detailTextLabel.frame = r;
    self.detailTextLabel.text = desc;
    self.detailTextLabel.font = [UIFont boldSystemFontOfSize:12.0];
    self.detailTextLabel.lineBreakMode = BOX_LINE_BREAK_MODE;
    self.detailTextLabel.textColor = [UIColor colorWithRed:174.0f/255.0f
                                                     green:174.0f/255.0f
                                                      blue:174.0f/255.0f
                                                     alpha:self.enabled ? 1.0 : kDisabledAlpha];

    // If the item is a folder, draw the disclosure indicator
    if ([self.item isKindOfClass:[BoxFolder class]]) {
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage  imageFromBoxSDKResourcesBundleWithName:@"icon-disclosure"]];

        CGRect disclosureRect = self.accessoryView.frame;
        disclosureRect.origin.x = rect.size.width - 15;
        disclosureRect.origin.y = kDisclosureIndicatorOriginY;
        self.accessoryView.frame = disclosureRect;
    }
    else
    {
        self.accessoryView = nil;
    }
    
    self.imageView.alpha = self.enabled ? 1.0 : kDisabledAlpha;
}

@end
