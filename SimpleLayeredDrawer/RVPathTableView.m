//
//  RVPathTableView.m
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

#import "RVPathTableView.h"
#import "KeyCodes.h"

@implementation RVPathTableView

- (void) keyDown:(NSEvent *)theEvent {
    int key = [theEvent keyCode];
    if (key == KEY_CODE_BACKWARD_DELETE || key == KEY_CODE_FORWARD_DELETE) {
        if (_dataSource) {
            [_dataSource delete:self];
        } else {
            [_delegate delete:self];
        }
        return;
    }
    [super keyDown:theEvent];
}

@end
