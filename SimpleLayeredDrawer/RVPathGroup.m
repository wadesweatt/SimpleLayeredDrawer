//
//  RVPVPMask.m
//  SimpleLayeredDrawer
//
//  Created by Wade Sweatt on 1/23/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "RVPathGroup.h"

@implementation RVPathGroup

+ (RVPathGroup *) group {
    RVPathGroup *newGroup = [[self alloc] init];
    newGroup.name = @"New Group";
    newGroup.paths = [NSMutableArray array];
    return newGroup;
}

- (void) setPaths:(NSMutableArray *)paths {
    if (_paths != paths) {
        _paths = paths;
    }
}

- (void) copyPropertiesFrom:(RVPathGroup *)other {
    self.paths = [[NSMutableArray alloc] initWithArray:other.paths copyItems:YES];
    self.name = other.name;
}

- (id) copyWithZone:(NSZone *)zone {
	RVPathGroup *copy = [[[self class] allocWithZone:zone] init];
	[copy copyPropertiesFrom:self];
	return copy;
}

@end
