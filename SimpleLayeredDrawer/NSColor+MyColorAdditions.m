//
//  NSColor+MyColorAdditions.m
//  SimpleLayeredDrawer
//
//  Created by J. Wade Sweatt on 10/4/12.
//  Copyright 2012 J. Wade Sweatt. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "NSColor+MyColorAdditions.h"
#define RVLightestColorValue 0.8f
#define RVLightColorValue 0.55f
#define RVMidColorValue 0.5f
#define RVMediumColorValue 0.3f
#define RVMediumDarkColorValue 0.25f
#define RVMidDarkColorValue 0.2f
#define RVMaxDarkColorValue 0.15f
#define RVReallyDarkColorValue 0.1f


@implementation NSColor (MyColorAdditions)

+ (NSColor*) rvLightestGrayColor
{
	static NSColor *lightestGrayColor;
	if(! lightestGrayColor){
		lightestGrayColor = [NSColor colorWithCalibratedWhite:RVLightestColorValue alpha:1.0f];
	}
	return lightestGrayColor;
}

+ (NSColor*) rvLightGrayColor
{
	static NSColor *mediumLightGrayColor;
	if(! mediumLightGrayColor){
		mediumLightGrayColor = [NSColor colorWithCalibratedWhite:RVLightColorValue alpha:1.0f];
	}
	return mediumLightGrayColor;
}

+ (NSColor*) rvMediumLightGrayColor
{
	static NSColor *mediumLightGrayColor;
	if(! mediumLightGrayColor){
		mediumLightGrayColor = [NSColor colorWithCalibratedWhite:RVMidColorValue alpha:1.0f];
	}
	return mediumLightGrayColor;
}


+ (NSColor*) rvMediumGrayColor
{
	static NSColor *mediumGrayColor;
	if(! mediumGrayColor){
		mediumGrayColor = [NSColor colorWithCalibratedWhite:RVMediumColorValue alpha:1.0f];
	}
	return mediumGrayColor;
}

+ (NSColor*) rvMediumDarkGrayColor
{
	static NSColor *mediumDarkGrayColor;
	if(! mediumDarkGrayColor){
		mediumDarkGrayColor = [NSColor colorWithCalibratedWhite:RVMediumDarkColorValue alpha:1.0f];
	}
	return mediumDarkGrayColor;
}

+ (NSColor*) rvDarkGrayColor
{
	static NSColor *darkGrayColor;
	if(! darkGrayColor){
		darkGrayColor = [NSColor colorWithCalibratedWhite:RVMidDarkColorValue alpha:1.0f];
	}
	return darkGrayColor;
}


+ (NSColor*) rvDarkestGrayColor
{
	static NSColor *darkestGrayColor;
	if(! darkestGrayColor){
		darkestGrayColor = [NSColor colorWithCalibratedWhite:RVMaxDarkColorValue alpha:1.0f];
	}
	return darkestGrayColor;
}

+ (NSColor*) rvReallyDarkGrayColor
{
	static NSColor *darkestGrayColor;
	if(! darkestGrayColor){
		darkestGrayColor = [NSColor colorWithCalibratedWhite:RVReallyDarkColorValue alpha:1.0f];
	}
	return darkestGrayColor;
}

+ (NSColor*) learnActiveColor
{
    static NSColor *learnActiveColor;
    if(! learnActiveColor){
        learnActiveColor = [NSColor magentaColor];
    }
    return learnActiveColor;
}
+ (NSColor*) learnActiveColorBorder
{
    static NSColor *learnActiveColorBorder;
    if(! learnActiveColorBorder){
        learnActiveColorBorder = [NSColor colorWithCalibratedRed:.5 green:.0 blue:.5 alpha:1.0];
    }
    return learnActiveColorBorder;
}
+ (NSColor*) learnColor
{
    static NSColor *learnColor;
    if(! learnColor){
        learnColor = [NSColor colorWithCalibratedRed:.5 green:.0 blue:.5 alpha:.8];
    }
    return learnColor;
}

- (NSColor *) nonKeyColor {
	return [self blendedColorWithFraction:RVNonKeyColorBlendFactor ofColor:RVNonKeyColorBlendColor];
}

@end
