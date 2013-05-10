//
//  RVPathTableView.m
//  ProVideoPlayer 2
//
//  Created by Wade Sweatt on 1/22/13.
//  Copyright (c) 2013 Renewed Vision. All rights reserved.
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
