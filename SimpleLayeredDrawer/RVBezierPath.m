//
//  RVBezierPath.m
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

#import "RVBezierPath.h"
#import "RVPoint.h"

@implementation RVBezierPath

+ (RVBezierPath *) path {
    RVBezierPath *newPath = [[self alloc] init];
    newPath.shouldClose = NO;
    newPath.points = [NSMutableArray array];
    newPath.isCircle = NO;
    newPath.isRectangle = NO;
	//newPath.draggingHandle = RVBezierPathBoundsHandleNone;
    return newPath;
}

- (void) setPoints:(NSMutableArray *)points {
    if (_points != points) {
        _points = points;
    }
}

- (BOOL) canContainArc {
    return (!self.isRectangle && !self.isCircle);
}

//- (RVBezierPathBoundsHandle) boundsHandleForPoint:(RVPoint *)point {
//	if (self.isRectangle || NSEqualPoints(point.point, NSZeroPoint)) return RVBezierPathBoundsHandleNone;
//	
//	NSPoint location = point.point;
//	CGFloat radius = 10.0;
//	CGRect bounds = self.bounds;
//	CGPoint bottomLeft = bounds.origin;
//	CGPoint bottomRight = CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y);
//	CGPoint topLeft = CGPointMake(bottomLeft.x, bottomLeft.y + bounds.size.height);
//	CGPoint topRight = CGPointMake(bottomRight.x, topLeft.y);
//	
//	if ((ABS(location.x - bottomLeft.x)) < radius && (ABS(location.y - bottomLeft.y)) < radius) {
//		return RVBezierPathBoundsHandleBottomLeft;
//	} else if ((ABS(location.x - bottomRight.x)) < radius && (ABS(location.y - bottomRight.y)) < radius) {
//		return RVBezierPathBoundsHandleBottomRight;
//	} else if ((ABS(location.x - topLeft.x)) < radius && (ABS(location.y - topLeft.y)) < radius) {
//		return RVBezierPathBoundsHandleTopLeft;
//	} else if ((ABS(location.x - topRight.x)) < radius && (ABS(location.y - topRight.y)) < radius) {
//		return RVBezierPathBoundsHandleTopRight;
//	}
//	return RVBezierPathBoundsHandleNone;
//}

//- (void) scaleAndTranslatePointsWithHandle:(RVBezierPathBoundsHandle)handle byTranslationPoint:(NSPoint)translation {
//	CGFloat xChange = translation.x;
//	CGFloat yChange = translation.y;
//	CGFloat midX = self.bounds.origin.x + self.bounds.size.width/2;
//	CGFloat midY = self.bounds.origin.y + self.bounds.size.width/2;
//	
//	switch (handle) {
//		case RVBezierPathBoundsHandleBottomLeft: {
//			for (RVPoint *eachPoint in self.points) {
//				
//			}
//			break;
//		}
//		case RVBezierPathBoundsHandleBottomRight: {
//			
//			break;
//		}
//		case RVBezierPathBoundsHandleTopLeft: {
//			
//			break;
//		}
//		case RVBezierPathBoundsHandleTopRight: {
//			
//			break;
//		}
//		case RVBezierPathBoundsHandleNone:
//			break;
//	}
//}


#pragma mark - BOILER PLATE

- (NSString *) description {
    return [NSString stringWithFormat:@"RVBezierPath: points:%ld shouldClose:%@", [self.points count], self.shouldClose?@"YES":@"NO"];
}

- (void) copyPropertiesFrom:(RVBezierPath *)other {
    self.shouldClose = other.isClosed;
    self.points = [[NSMutableArray alloc] initWithArray:other.points copyItems:YES];
    self.isRectangle = other.isRectangle;
    self.isCircle = other.isCircle;
}

- (id) copyWithZone:(NSZone *)zone {
	RVBezierPath *copy = [[self class] path];
	[copy copyPropertiesFrom:self];
	return copy;
}


#pragma mark - CONSTRUCT
// Used for rendering and in the editor table view cells
// simply creates (but not draws) from the points in the points array
// does not draw points, control points, selection, etc. - just the path
- (void) createSelfFromPointArray {
    [self removeAllPoints]; // removes internal NSBezierPath points, NOT RVBezierPath's array of points
    if ([self.points count] > 0) {
        // Draw each path

        if (self.isCircle) {
            [self circlePathForPath:self];
            return;
        }

        // first point (path origin)
        RVPoint *firstPointObject = [self.points objectAtIndex:0];
        NSPoint firstPoint = firstPointObject.point;

        
        RVPoint *lastPointObject = [self.points lastObject];
        if ((firstPointObject.hasBehindControlPoint || lastPointObject.hasFrontControlPoint) && [self isClosed]) {
            NSPoint lastPoint = [lastPointObject point];

            // only first point has a control point
            if (firstPointObject.hasBehindControlPoint && !lastPointObject.hasFrontControlPoint) {
                NSPoint behindControlPoint = firstPointObject.behindControlPoint;

                [self moveToPoint:lastPoint];
                [self curveToPoint:firstPoint controlPoint1:behindControlPoint controlPoint2:behindControlPoint];

            // only previous point has a control point
            } else if (!firstPointObject.hasBehindControlPoint && lastPointObject.hasFrontControlPoint) {
                NSPoint frontControlPoint = lastPointObject.frontControlPoint;

                [self moveToPoint:lastPoint];
                [self curveToPoint:firstPoint controlPoint1:frontControlPoint controlPoint2:frontControlPoint];

            // both points have control points between them
            } else if (firstPointObject.hasBehindControlPoint && lastPointObject.hasFrontControlPoint) {
                NSPoint frontControlPoint = lastPointObject.frontControlPoint;

                NSPoint behindControlPoint = firstPointObject.behindControlPoint;

                [self moveToPoint:lastPoint];
                [self curveToPoint:firstPoint controlPoint1:frontControlPoint controlPoint2:behindControlPoint];
            }
        // neither point has a control point between them or the path is not closed - just move here
        } else {
            [self moveToPoint:firstPoint];
        }

        // Rest of the points in this path
        // notice starting index of 1
        for (int i = 1; i<[self.points count]; i++) {
            RVPoint *destinationPointObject = [self.points objectAtIndex:i];
            NSPoint destinationPoint = destinationPointObject.point;
            RVPoint *behindPointObject = [self.points objectAtIndex:(i-1)];

            NSPoint destinationPointBehindControlPoint = NSZeroPoint;
            NSPoint behindPointFrontControlPoint = NSZeroPoint;

            // if only the destination point has a behind control point
            if ([destinationPointObject hasBehindControlPoint] && ![behindPointObject hasFrontControlPoint]) {
                destinationPointBehindControlPoint = [destinationPointObject behindControlPoint];

                [self curveToPoint:destinationPoint controlPoint1:destinationPointBehindControlPoint controlPoint2:destinationPointBehindControlPoint];

            // if only the last point has a front control point
            } else if (![destinationPointObject hasBehindControlPoint] && [behindPointObject hasFrontControlPoint]) {
                behindPointFrontControlPoint = [behindPointObject frontControlPoint];

                [self curveToPoint:destinationPoint controlPoint1:behindPointFrontControlPoint controlPoint2:behindPointFrontControlPoint];

            // if both the current point and the destination point have a control points between themselves
            } else if ([destinationPointObject hasBehindControlPoint] && [behindPointObject hasFrontControlPoint]) {
                destinationPointBehindControlPoint = [destinationPointObject behindControlPoint];
                behindPointFrontControlPoint = [behindPointObject frontControlPoint];

                [self curveToPoint:destinationPoint controlPoint1:behindPointFrontControlPoint controlPoint2:destinationPointBehindControlPoint];

            } else {
                [self lineToPoint:destinationPoint];
            }
        }

        if ([self isClosed]) [self closePath];
    }
}


#pragma mark - CIRCLE

- (CGFloat)radius {
    if (self.isCircle && [self.points count] == 2) {
        NSPoint center = [(RVPoint *)[self.points objectAtIndex:0] point];
        NSPoint controlPoint = [(RVPoint *)[self.points lastObject] point];
        CGFloat distance = sqrtf( powf((controlPoint.x - center.x), 2) +  powf((controlPoint.y - center.y), 2) );
        return distance;
    }
    return 0.0;
}

- (void) circlePathForPath:(RVBezierPath *)path {
    if (path.isCircle && [path.points count] == 2) {
        NSPoint center = [[path.points objectAtIndex:0] point];
        CGFloat radius = [path radius];
		if (radius <= 0) radius = 1;

        if (radius > 0) {
            CGFloat xMin = center.x - radius;
            CGFloat xMax = center.x + radius;
            NSPoint firstPoint = NSMakePoint(xMin, center.y);
            [path moveToPoint:firstPoint];
            // upper half
            for (CGFloat upperX = xMin; upperX<xMax; upperX += 1.0) {
                CGFloat radiusSquared = powf(radius, 2);
                CGFloat differenceSquared = powf((upperX - center.x), 2);
                CGFloat thisY = center.y + sqrtf(radiusSquared - differenceSquared);
                if (isnan(thisY))  {
                    continue;
                }
                [path lineToPoint:NSMakePoint(upperX, thisY)];
            }
            // lower half
            for (CGFloat lowerX = xMax; lowerX>xMin; lowerX--) {
                CGFloat thisY = center.y - sqrtf(powf(radius, 2) - powf((lowerX - center.x), 2));
                [path lineToPoint:NSMakePoint(lowerX, thisY)];
            }

            [path lineToPoint:firstPoint]; // close it out
        }
    } else {
        NSLog(@"%s self is invalid circle", __PRETTY_FUNCTION__);
    }
}

@end
