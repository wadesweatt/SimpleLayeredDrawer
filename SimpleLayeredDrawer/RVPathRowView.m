//
//  RVPathRowView.m
//  SimpleLayeredDrawer
//
//  Created by Wade Sweatt on 1/22/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "RVPathRowView.h"
#import "NSColor+MyColorAdditions.h"

@implementation RVPathRowView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        backgroundGradient = [[NSGradient alloc] initWithColorsAndLocations:
                                       [NSColor colorWithDeviceRed:0.27 green:0.29 blue:0.30 alpha:1.0],
                                       0.0f,
                                       [NSColor colorWithDeviceRed:0.21 green:0.22 blue:0.23 alpha:1.0],
                                       1.0f, nil,nil];
    }
    return self;
}

- (void) drawSelectionInRect:(NSRect)dirtyRect {
    dirtyRect = self.bounds;
    [backgroundGradient drawInRect:dirtyRect angle:90.0f];
    [[NSColor rvMediumDarkGrayColor] setStroke];
    [[NSColor rvMediumGrayColor] setFill];
    NSBezierPath *aPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(dirtyRect, 4, 4) xRadius:6 yRadius:6];
    [aPath fill];
    [aPath stroke];
}

- (void) drawBackgroundInRect:(NSRect)dirtyRect {
    dirtyRect = self.bounds;
    [backgroundGradient drawInRect:dirtyRect angle:90.0f];
}

@end
