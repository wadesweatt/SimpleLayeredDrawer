//
//  RVPVPMaskTableViewController.h
//  ProVideoPlayer 2
//
//  Created by Wade Sweatt on 1/24/13.
//  Copyright (c) 2013 Renewed Vision. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RVPathEditorController;

@interface RVPathTableViewController : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) RVPathEditorController *parentController;
@property (nonatomic, strong) NSTableView *pathsTableView;

- (void) delete:(id)sender;
- (void) reloadTablePreservingSelection;

@end
