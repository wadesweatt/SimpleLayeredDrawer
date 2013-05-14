//
//  CanvasView.h
//  SimpleLayeredDrawer
//
//  Created by Wade Sweatt on 5/8/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Cocoa/Cocoa.h>
#import "Protocols.h"

@class RVPVPRenderLayoutScaleView;
@class RVPoint;
@class RVBezierPath;

typedef enum _RVDrawingMode {
	RVDrawingModeSelectTool,
    RVDrawingModePenTool,
    RVDrawingModeRectangleTool,
    RVDrawingModeCircleTool
} RVDrawingMode;

@interface CanvasView : NSView {
    NSPoint mouseStartPoint;
    NSPoint mouseLocation;
    NSInteger selectedIndex;
    // dragging
    BOOL dragged, draggedPathBounds, createdRectOrCircle, pointWasSelected, pathWasSelected, closePathOnClick, mouseInView;
    NSPoint lastDragPoint, rectangleCenter; // for dragging shapes
	
    
	NSMutableArray *pointsArchive; // for undo
    RVPoint *arcPoint1, *arcPoint2; // temp for arc creation

    // mode - selection, pen, rectangle, or circle
    IBOutlet NSSegmentedControl *maskModeControl;
    RVDrawingMode drawingMode;
	
	CGFloat scale;
}

@property (nonatomic, strong) id <RVMaskEditorDataSource> pathEditorDelegate;
@property (nonatomic, strong) RVBezierPath *selectedPath;
@property (nonatomic, strong) RVBezierPath *lastSelectedPath;
@property (nonatomic, assign) NSInteger lineWidth;
@property (nonatomic, strong) NSColor *strokeColor, *fillColor, *selectedColor;
@property (nonatomic, assign) BOOL shouldFill, shouldStroke, shouldShowSelection;
@property (weak) IBOutlet NSTextField *coordinatesTextField;

- (IBAction)changeTool:(id)sender;
- (void) showActionNotificationWithText:(NSString *)actionMessage;
- (void) setSelectedIndex:(NSInteger)index;
- (void) setScale:(CGFloat)scaleAmount;

@end
