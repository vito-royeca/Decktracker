//
//  UIImage+Scale.h
//  JJJ
//
//  Created by Jovit Royeca on 8/6/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//
//  Code from: http://stackoverflow.com/questions/2645768/uiimage-resize-scale-proportion
//

#import <UIKit/UIKit.h>

@interface UIImage (Scale)

- (UIImage *) scaleToSize: (CGSize)size;
- (UIImage *) scaleProportionalToSize: (CGSize)size;

@end
