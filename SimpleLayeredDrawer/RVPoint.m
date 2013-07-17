//
//  RVPoint.m
//  SimpleLayeredDrawer
//
//  Created by Wade Sweatt on 1/10/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "RVPoint.h"

#define kPoint @"point"
#define kBehindPoint @"behindPoint"
#define kFrontPoint @"frontPoint"


@implementation RVPoint

- (id)init
{
    self = [super init];
    if (self) {
        self.point = NSZeroPoint;
        self.frontControlPoint = NSZeroPoint;
        self.behindControlPoint = NSZeroPoint;
        self.frontControlPointSelected = NO;
        self.behindControlPointSelected = NO;
    }
    return self;
}

- (id) initWithPoint:(NSPoint)point {
    self = [self init];
    if (self) {
        self.point = point;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.point = [coder decodePointForKey:kPoint];
		self.behindControlPoint = [coder decodePointForKey:kBehindPoint];
		self.frontControlPoint = [coder decodePointForKey:kFrontPoint];
		self.frontControlPointSelected = NO;
        self.behindControlPointSelected = NO;
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodePoint:self.point forKey:kPoint];
	[aCoder encodePoint:self.behindControlPoint forKey:kBehindPoint];
	[aCoder encodePoint:self.frontControlPoint forKey:kFrontPoint];
}

- (BOOL) hasPoint {
    if (NSEqualPoints(self.point, NSZeroPoint)) {
        return NO;
    }
    return YES;
}

- (BOOL) hasFrontControlPoint {
    if (NSEqualPoints(self.frontControlPoint, NSZeroPoint)) {
        return NO;
    }
    return YES;
}

- (BOOL) hasBehindControlPoint {
    if (NSEqualPoints(self.behindControlPoint, NSZeroPoint)) {
        return NO;
    }
    return YES;
}

- (void) copyPropertiesFrom:(RVPoint *)other {
	self.point = other.point;
    self.frontControlPoint = other.frontControlPoint;
    self.behindControlPoint = other.behindControlPoint;
    self.frontControlPointSelected = other.frontControlPointSelected;
    self.behindControlPointSelected = other.behindControlPointSelected;
    self.parentPath = self.parentPath;
}

- (id) copyWithZone:(NSZone *)zone {
	RVPoint *copy = [[[self class] allocWithZone:zone] init];
	[copy copyPropertiesFrom:self];
	return copy;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"\n%p %@ fcp? %@ bcp? %@", self, NSStringFromPoint(self.point), self.hasFrontControlPoint?@"YES":@"NO", self.hasBehindControlPoint?@"YES":@"NO"];
}

@end
