//
//  RVPVPMaskTableViewController.m
//  SimpleLayeredDrawer
//
//  Created by Wade Sweatt on 1/24/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "RVPathTableViewController.h"
#import "RVPathEditorController.h"
#import "RVPathRowView.h"
#import "RVPathCellView.h"
#import "RVBezierPath.h"
#import "RVPathGroup.h"
#import "CanvasView.h"
#import "Static.h"

@implementation RVPathTableViewController

- (void) setPathsTableView:(NSTableView *)pathsTableView {
    _pathsTableView = pathsTableView;
    [_pathsTableView setTarget:self];
    [_pathsTableView setAction:@selector(changeSelectedPath:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(maskTableShouldReload:) name:RVReloadMaskTable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(maskTableShouldSelectRow:) name:RVSelectRowInMaskTable object:nil];
}


#pragma mark - TABLE DELEGATE/DATASOURCE

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [self.parentController.selectedGroup.paths count];
}

- (NSTableRowView *) tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    RVPathRowView *rowView = [[RVPathRowView alloc] init];
    return rowView;
}

- (NSView *)tableView:(NSTableView *)aTableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (aTableView == self.pathsTableView) {
        RVPathCellView *result = [aTableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        result.textField.stringValue = [NSString stringWithFormat:@"%ld.", (row + 1)];
        result.canvasSize = self.workspaceSize;
        result.path = [[self.parentController.selectedGroup.paths objectAtIndex:row] copy];
        return result;
    }
    return nil;
}


#pragma mark - PATH TABLE ACTION

- (void)changeSelectedPath:(id)sender {
    NSInteger selectedRow = [self.pathsTableView selectedRow];
    if (selectedRow < [self.parentController.selectedGroup.paths count] && selectedRow > -1) {
        self.parentController.canvas.selectedPath = [self.parentController.selectedGroup.paths objectAtIndex:selectedRow];
    } else {
		self.parentController.canvas.selectedPath = nil;
	}
}

// reloads preserving selection
- (void) maskTableShouldReload:(NSNotification *)notification {
	NSInteger selectedRow = [self.pathsTableView selectedRow];
	[self.pathsTableView reloadData];
	if ([self.pathsTableView numberOfRows] > selectedRow && selectedRow > -1) {
		[self.pathsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
	}
}

- (void) reloadTablePreservingSelection {
	[self maskTableShouldReload:nil];
}

- (void) maskTableShouldSelectRow:(NSNotification *)notification {
    NSInteger selection = [[notification object] integerValue];
    if ([[[self.parentController selectedGroup] paths] count] > selection && selection > -1) {
        [self.pathsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selection] byExtendingSelection:NO];
		[self.pathsTableView scrollRowToVisible:selection];
    } else {
		[self.pathsTableView deselectAll:nil];
	}
}

- (void) delete:(id)sender {
    NSInteger selectedRow = [self.pathsTableView selectedRow];
    if ([self.parentController.selectedGroup.paths count] > selectedRow) {
		NSString *message = self.parentController.canvas.selectedPath.isCircle? @"Delete Circle" : @"Delete Rectangle";
		NSMutableArray *pathsCopy = [[NSMutableArray alloc] initWithArray:self.parentController.selectedGroup.paths copyItems:YES];
		NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:message, @"message", pathsCopy, @"objects", self.parentController.selectedGroup, @"mask", nil];
		[self.parentController registerMaskUndoActionWithManager:[self.parentController.canvas undoManager] userInfo:dictionary];
		
        [self.parentController.selectedGroup.paths removeObjectAtIndex:selectedRow];
        [self.pathsTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:selectedRow] withAnimation:NSTableViewAnimationSlideUp];
		
		[self.parentController.canvas setNeedsDisplay:YES]; // canvas view
    }
}

- (NSSize) workspaceSize {
    return NSMakeSize([self.parentController.canvas frame].size.width, [self.parentController.canvas frame].size.height);
}

@end
