//
//  RVPoint.h
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

#import <Foundation/Foundation.h>
#import "RVBezierPath.h"

@interface RVPoint : NSObject <NSCopying, NSCoding>

@property (nonatomic, assign) NSPoint point, frontControlPoint, behindControlPoint;
@property (nonatomic, assign) BOOL hasPoint, frontControlPointSelected, behindControlPointSelected, hasFrontControlPoint, hasBehindControlPoint;
@property (weak) RVBezierPath *parentPath;

- (id) initWithPoint:(NSPoint)point;

@end
