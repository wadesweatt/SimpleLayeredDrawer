//
//  RVPathCellView.h
//  SimpleMaskDrawer
//
//  Created by Wade Sweatt on 1/18/13.
//  Copyright (c) 2013 Renewed Vision. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RVBezierPath;

@interface RVPathCellView : NSTableCellView
@property (nonatomic, assign) CGSize canvasSize;
@property (nonatomic, strong) RVBezierPath *path;
@end
