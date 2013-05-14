//
//  RVPVPMaskTableViewController.h
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

#import <Foundation/Foundation.h>

@class RVPathEditorController;

@interface RVPathTableViewController : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) RVPathEditorController *parentController;
@property (nonatomic, strong) NSTableView *pathsTableView;

- (void) delete:(id)sender;
- (void) reloadTablePreservingSelection;

@end
