//
//  AppDelegate.h
//  SimpleLayeredDrawer
//
//  Created by Wade Sweatt on 5/8/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CanvasView.h"

@class RVPathEditorController;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, weak) IBOutlet CanvasView *drawingView;
@property (nonatomic, weak) IBOutlet NSTableView *groupTableView, *pathTableView;
@property (nonatomic, weak)	IBOutlet NSSlider *scaleSlider;
@property (nonatomic, strong) RVPathEditorController *pathEditorController;

@end
