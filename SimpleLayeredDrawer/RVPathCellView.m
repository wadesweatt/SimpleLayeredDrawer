//
//  RVPathCellView.m
//  SimpleLayeredDrawer
//
//  Created by Wade Sweatt on 1/18/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//

#import "RVPathCellView.h"
#import "RVPoint.h"
#import "RVBezierPath.h"

@implementation RVPathCellView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    CGRect bounds = [self bounds];
    
    if (self.path.points.count > 1 && !CGSizeEqualToSize(self.canvasSize, CGSizeZero)) {
        RVBezierPath *thisPath = self.path;
        [thisPath createSelfFromPointArray];
		
		CGRect insetBounds = CGRectInset(bounds, 15.0, 0.0);
		
        CGFloat ratio = MIN(insetBounds.size.width/self.canvasSize.width, insetBounds.size.height/self.canvasSize.height);
        CGFloat scaledWidth = self.canvasSize.width * ratio;
        CGFloat scaledHeight = self.canvasSize.height * ratio;
        CGPoint imageOrigin = CGPointMake((bounds.size.width - scaledWidth)/2, (bounds.size.height - scaledHeight)/2);

        [[NSGraphicsContext currentContext] saveGraphicsState];

        NSAffineTransform *translateTransform = [NSAffineTransform transform];
        [translateTransform translateXBy:imageOrigin.x yBy:imageOrigin.y];
        [translateTransform concat];

        NSAffineTransform *scaleTransform = [NSAffineTransform transform];
        [scaleTransform scaleBy:ratio];
        [scaleTransform concat];

        // draw path
        [[NSColor orangeColor] setFill];
        [thisPath fill];

        [[NSGraphicsContext currentContext] restoreGraphicsState];

        NSBezierPath *borderPath = [NSBezierPath bezierPathWithRect:NSMakeRect(imageOrigin.x, imageOrigin.y, scaledWidth, scaledHeight)];
        [borderPath setLineWidth:1.0];
        [[NSColor colorWithDeviceRed:0.91 green:0.95 blue:0.95 alpha:1.0] setStroke]; // this matches the cell's text label color
        [borderPath stroke];
    }
}

- (void) setPath:(RVBezierPath *)path {
    if (_path != path) {
        _path = path;
        [self setNeedsDisplay:YES];
    }
}

@end
