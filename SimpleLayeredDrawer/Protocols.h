//
//  Protocols.h
//  SimpleLayeredDrawer
//
//  Created by Wade Sweatt on 5/8/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RVPathGroup;

@protocol RVMaskEditorDataSource <NSObject>
@required
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) RVPathGroup *selectedGroup;
@property (nonatomic, assign) CGFloat scale;
- (void) createNewGroup;
- (void) registerPathUndoActionWithManager:(NSUndoManager *)manager userInfo:(NSDictionary *)undoDict;
- (void) registerMaskUndoActionWithManager:(NSUndoManager *)manager userInfo:(NSDictionary *)undoDict;
@end
