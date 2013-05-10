//
//  NSColor+RVColor.h
//  ProPresenter
//
//  Created by Rich Salvatierra on 12/4/09.
//  Copyright 2009 Renewed Vision LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define RVNonKeyColorBlendFactor 0.1f
#define RVNonKeyColorBlendColor [NSColor grayColor]

@interface NSColor (MyColorAdditions)

+ (NSColor*) rvLightestGrayColor;
+ (NSColor*) rvLightGrayColor;
+ (NSColor*) rvMediumLightGrayColor;
+ (NSColor*) rvMediumGrayColor;
+ (NSColor*) rvMediumDarkGrayColor;
+ (NSColor*) rvDarkGrayColor;
+ (NSColor*) rvDarkestGrayColor;
+ (NSColor*) rvReallyDarkGrayColor;

+ (NSColor*) learnActiveColor;
+ (NSColor*) learnActiveColorBorder;
+ (NSColor*) learnColor;

- (NSColor *) nonKeyColor;
@end
