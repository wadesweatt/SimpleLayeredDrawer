//
//  NSColor+MyColorAdditions.h
//  SimpleLayeredDrawer
//
//  Created by J. Wade Sweatt on 10/4/12.
//  Copyright 2012 J. Wade Sweatt. All rights reserved.
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
