//
//  RVPoint.h
//  SimpleMaskDrawer
//
//  Created by Wade Sweatt on 1/10/13.
//  Copyright (c) 2013 Renewed Vision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RVBezierPath.h"

@interface RVPoint : NSObject <NSCopying>

@property (nonatomic, assign) NSPoint point, frontControlPoint, behindControlPoint;
@property (nonatomic, assign) BOOL hasPoint, frontControlPointSelected, behindControlPointSelected, hasFrontControlPoint, hasBehindControlPoint;
@property (weak) RVBezierPath *parentPath;

- (id) initWithPoint:(NSPoint)point;

@end
