//
//  RVPathCellView.h
//  SimpleLayeredDrawer
//
//  Created by Wade Sweatt on 1/18/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Cocoa/Cocoa.h>

@class RVBezierPath;

@interface RVPathCellView : NSTableCellView
@property (nonatomic, assign) CGSize canvasSize;
@property (nonatomic, strong) RVBezierPath *path;
@end
