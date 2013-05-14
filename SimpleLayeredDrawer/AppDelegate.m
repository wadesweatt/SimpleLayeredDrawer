//
//  AppDelegate.m
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

#import "AppDelegate.h"
#import "RVPathEditorController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	_pathEditorController = [[RVPathEditorController alloc] init];
	[_pathEditorController setCanvas:self.drawingView];
	[_pathEditorController setGroupsTableView:self.groupTableView];
	[_pathEditorController setPathsTableView:self.pathTableView];
	[_scaleSlider bind:NSValueBinding toObject:_pathEditorController withKeyPath:@"scale" options:nil];
}

- (IBAction) addGroup:(id)sender {
    [self.pathEditorController createNewGroup];
}

- (IBAction) deleteGroup:(id)sender {
    [self.pathEditorController deleteSelectedGroup];
}

- (IBAction) setShouldFill:(id)sender {
    [self.pathEditorController setShouldFill:sender];
}

- (IBAction) setShouldStroke:(id)sender {
    [self.pathEditorController setShouldStroke:sender];
}

@end
