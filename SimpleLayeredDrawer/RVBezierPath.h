//
//  RVBezierPath.h
//  SimpleMaskDrawer
//
//  Created by Wade Sweatt on 1/16/13.
//  Copyright (c) 2013 Renewed Vision. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RVBezierPath : NSBezierPath <NSCopying>

@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, assign, getter = isClosed) BOOL shouldClose;
@property (nonatomic, assign) BOOL draggingBounds, isRectangle, isCircle;

+ (RVBezierPath *) path;

- (BOOL)canContainArc;
- (CGFloat) radius;
- (void) createSelfFromPointArray;

@end
