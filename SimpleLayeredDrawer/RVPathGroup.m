//
//  RVPVPMask.m
//  ProVideoPlayer 2
//
//  Created by Wade Sweatt on 1/23/13.
//  Copyright (c) 2013 Renewed Vision. All rights reserved.
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
