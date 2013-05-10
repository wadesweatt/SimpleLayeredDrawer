//
//  RVPVPMaskEditorController.m
//  ProVideoPlayer 2
//
//  Created by Wade Sweatt on 1/22/13.
//  Copyright (c) 2013 Renewed Vision. All rights reserved.
//

#import "RVPathEditorController.h"
#import "Static.h"
#import "RVPathGroup.h"
#import "RVBezierPath.h"
#import "RVPathTableViewController.h"
#import "CanvasView.h"

@implementation RVPathEditorController

- (id)init
{
    self = [super init];
    if (self) {
        self.groups = [NSMutableArray array];
        self.pathsTableViewController = [[RVPathTableViewController alloc] init];
        [self.pathsTableViewController setParentController:self];
		self.scale = 1.0;
    }
    return self;
}

- (void) setShouldFill:(id)sender {
    if ([sender state] == NSOnState) {
        [self.canvas setShouldFill:YES];
    } else {
        [self.canvas setShouldFill:NO];
    }
    [self.canvas setNeedsDisplay:YES];
}

- (void) setShouldStroke:(id)sender {
    if ([sender state] == NSOnState) {
        [self.canvas setShouldStroke:YES];
    } else {
        [self.canvas setShouldStroke:NO];
    }
    [self.canvas setNeedsDisplay:YES];
}


#pragma mark - TABLE DELEGATE/DATASOURCE

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [self.groups count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView == self.groupsTableView) {
        RVPathGroup *group = [self.groups objectAtIndex:row];
        if (!group) return nil;
        return [group name];
    }
    NSLog(@"No object value set for the mask table");
    return nil;
}

- (void) tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    RVPathGroup *group = [self.groups objectAtIndex:row];
    if (!group) return;
    [group setName:(NSString *)object];
    [[NSNotificationCenter defaultCenter] postNotificationName:RVPVPAddRemoveMask object:nil];
}

#pragma mark - MASK TABLE ACTION

- (void) changeSelectedMask:(id)sender {
    NSInteger selectedRow = [self.groupsTableView selectedRow];
    if (selectedRow < [self.groups count] && selectedRow > -1) {
        [self setSelectedGroup:[self.groups objectAtIndex:selectedRow]];
        [self.canvas setSelectedPath:[self.selectedGroup.paths lastObject]];
    } else {
		[self setSelectedGroup:nil];
		[self.canvas setSelectedPath:nil];
	}
	[self.pathsTableViewController.pathsTableView reloadData];
	[self.canvas setNeedsDisplay:YES];
}

#pragma mark - ADD/DELETE

- (void) createNewGroup {
    RVPathGroup *newGroup = [RVPathGroup group];
    [self.groups addObject:newGroup];
    [self.groupsTableView reloadData];
	NSInteger rowCount = [self.groupsTableView numberOfRows];
	[self.groupsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:(rowCount - 1)] byExtendingSelection:NO];
    [self setSelectedGroup:newGroup];
    [self.canvas setSelectedPath:[self.selectedGroup.paths lastObject]];
    [self.pathsTableViewController.pathsTableView reloadData];
    [self.canvas setNeedsDisplay:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RVPVPAddRemoveMask object:nil];
}

- (void) delete:(id)sender {
    // masks table
    if ([sender tag] == 5) {
        [self deleteSelectedGroup];
    // layers/shapes table
    } else {
        [self.pathsTableViewController delete:nil];
    }
}

- (void) deleteSelectedGroup {
    NSInteger selectedRow = [self.groupsTableView selectedRow];
    if ([self.groups count] > selectedRow) {
        [self.groupsTableView beginUpdates];
        [self.groups removeObjectAtIndex:selectedRow];
        [self.groupsTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:selectedRow] withAnimation:NSTableViewAnimationSlideUp];
		NSInteger rowCount = [self.groupsTableView numberOfRows];
		if (rowCount > 0) [self.groupsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:(rowCount -1 )] byExtendingSelection:NO];
        [self.groupsTableView endUpdates];
        [self setSelectedGroup:[[self groups] lastObject]];
        [self.canvas setSelectedPath:[self.selectedGroup.paths lastObject]];
        [self.pathsTableViewController.pathsTableView reloadData];
        [self.canvas setNeedsDisplay:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:RVPVPAddRemoveMask object:nil];
    }
}


#pragma mark - DRAWING ATTRIBUTES

- (IBAction)doSetStrokeColor:(id)sender {
    NSColor *newColor = [(NSColorWell *)sender color];
    [self.canvas setStrokeColor:newColor];
}

- (IBAction)doSetFillColor:(id)sender {
    NSColor *newColor = [(NSColorWell *)sender color];
    [self.canvas setFillColor:newColor];
}

- (IBAction)doSetSelectedColor:(id)sender {
    NSColor *newColor = [(NSColorWell *)sender color];
    [self.canvas setSelectedColor:newColor];
}


#pragma mark - SETTERS

- (void) setScale:(CGFloat)scale {
	if (_scale != scale) {
		_scale = scale;
		[self.canvas setScale:_scale];
	}
}

- (void) setCanvas:(CanvasView *)canvas {
	if (_canvas != canvas) {
		_canvas = canvas;
		[_canvas setPathEditorDelegate:self];
	}
}

- (void) setPathsTableView:(NSTableView *)pathsTableView {
    if (_pathsTableView != pathsTableView ) {
        _pathsTableView = pathsTableView;
        [self.pathsTableViewController setPathsTableView:_pathsTableView];
        [self.pathsTableView setDelegate:self.pathsTableViewController];
        [self.pathsTableView setDataSource:self.pathsTableViewController];
    }
}

- (void) setGroupsTableView:(NSTableView *)groupsTableView {
    if (_groupsTableView != groupsTableView) {
        _groupsTableView = groupsTableView;
        [_groupsTableView setDelegate:self];
        [_groupsTableView setDataSource:self];
        [_groupsTableView setTarget:self];
        [_groupsTableView setAction:@selector(changeSelectedMask:)];
    }
}

- (void) setSelectedGroup:(RVPathGroup *)selectedGroup {
    if (_selectedGroup != selectedGroup) {
        _selectedGroup = selectedGroup;
        [self.pathsTableView reloadData];
    }
}


#pragma mark - UNDO

- (void) undoPathChanges:(NSDictionary *)undoDict {
	NSString *message = [undoDict valueForKey:@"message"];
	NSMutableArray *points = [undoDict valueForKey:@"objects"];
	RVBezierPath *affectedPath = [undoDict valueForKey:@"path"];
	BOOL created = [[undoDict valueForKey:@"created"] boolValue]; // this action was the initial creation of a rect or circle
	NSInteger newSelectedIndex = -1;
	if (created && ![affectedPath canContainArc]) {
		[self.selectedGroup.paths removeObject:affectedPath];
		newSelectedIndex = -1;
	} else {
		[affectedPath setPoints:points];
		newSelectedIndex = affectedPath.points.count - 1;
	}

	[self.canvas setSelectedIndex:newSelectedIndex];
	[self.canvas setNeedsDisplay:YES];
	[self.canvas showActionNotificationWithText:[NSString stringWithFormat:@"Undo %@", message]];
	[self.pathsTableViewController reloadTablePreservingSelection];
}

- (void) undoMaskChanges:(NSDictionary *)undoDict {
	NSString *message = [undoDict valueForKey:@"message"];
	NSMutableArray *paths = [undoDict valueForKey:@"objects"];
	RVPathGroup *affectedMask = [undoDict valueForKey:@"mask"];
	[affectedMask setPaths:paths];
	[self.canvas setNeedsDisplay:YES];
	[self.canvas showActionNotificationWithText:[NSString stringWithFormat:@"Undo %@", message]];
	[self.pathsTableViewController reloadTablePreservingSelection];
}

- (void) registerPathUndoActionWithManager:(NSUndoManager *)manager userInfo:(NSDictionary *)undoDict {
	[manager setActionName:[undoDict valueForKey:@"message"]];
	[manager registerUndoWithTarget:self
						   selector:@selector(undoPathChanges:)
							 object:undoDict];
}

- (void) registerMaskUndoActionWithManager:(NSUndoManager *)manager userInfo:(NSDictionary *)undoDict {
	[manager setActionName:[undoDict valueForKey:@"message"]];
	[manager registerUndoWithTarget:self
						   selector:@selector(undoMaskChanges:)
							 object:undoDict];
}


@end
