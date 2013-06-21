//
//  RVBezierPath.h
//  SimpleLayeredDrawer
//
//  Created by Wade Sweatt on 1/16/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Cocoa/Cocoa.h>

typedef enum _RVBezierPathBoundsHandle {
	RVBezierPathBoundsHandleTopLeft,
    RVBezierPathBoundsHandleTopRight,
    RVBezierPathBoundsHandleBottomLeft,
    RVBezierPathBoundsHandleBottomRight,
	RVBezierPathBoundsHandleNone
} RVBezierPathBoundsHandle;

@interface RVBezierPath : NSBezierPath <NSCopying>

@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, assign, getter = isClosed) BOOL shouldClose;
@property (nonatomic, assign) BOOL draggingBounds, isRectangle, isCircle;
@property (nonatomic, assign) CGFloat feather;
//@property (nonatomic, assign) RVBezierPathBoundsHandle boundsHandle;

+ (RVBezierPath *) path;

- (BOOL) canContainArc;
- (CGFloat) radius;
- (void) createSelfFromPointArray;

@end
