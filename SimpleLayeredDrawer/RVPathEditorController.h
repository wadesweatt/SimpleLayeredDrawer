//
//  RVPVPMaskEditorController.h
//  SimpleLayeredDrawer
//
//  Created by Wade Sweatt on 1/22/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Foundation/Foundation.h>
#import "Protocols.h"

@class RVPathGroup, CanvasView, RVPathTableViewController;

@interface RVPathEditorController : NSObject <RVMaskEditorDataSource, NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) CanvasView *canvas;
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) RVPathGroup *selectedGroup;
@property (nonatomic, strong) NSTableView *groupsTableView, *pathsTableView;
@property (nonatomic, strong) RVPathTableViewController *pathsTableViewController;
@property (nonatomic, assign) CGFloat scale;

- (void) createNewGroup;
- (void) deleteSelectedGroup;
- (void) delete:(id)sender;

- (void) setShouldFill:(id)sender;
- (void) setShouldStroke:(id)sender;

- (void) registerPathUndoActionWithManager:(NSUndoManager *)manager userInfo:(NSDictionary *)undoDict;
- (void) registerMaskUndoActionWithManager:(NSUndoManager *)manager userInfo:(NSDictionary *)undoDict;

@end
