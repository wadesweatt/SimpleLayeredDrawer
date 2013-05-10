//
//  AppDelegate.m
//  SimpleLayeredDrawer
//
//  Created by Wade Sweatt on 5/8/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//

#import "AppDelegate.h"
#import "RVPathEditorController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	_pathEditorController = [[RVPathEditorController alloc] init];
	[_pathEditorController setCanvas:self.drawingView];
	[_pathEditorController setGroupsTableView:self.groupTableView];
	[_pathEditorController setPathsTableView:self.pathTableView];
	//[_scaleSlider bind:NSValueBinding toObject:_pathEditorController withKeyPath:@"scale" options:nil];
}

- (IBAction) addMask:(id)sender {
    [self.pathEditorController createNewGroup];
}

- (IBAction) deleteMask:(id)sender {
    [self.pathEditorController deleteSelectedGroup];
}

- (IBAction) setShouldFill:(id)sender {
    [self.pathEditorController setShouldFill:sender];
}

- (IBAction) setShouldStroke:(id)sender {
    [self.pathEditorController setShouldStroke:sender];
}

@end
