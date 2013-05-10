//
//  NonActivePanel.m
//  SimpleLayeredDrawer
//
//  Created by Wade Sweatt on 5/9/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//

#import "NonActivePanel.h"

@implementation NonActivePanel
- (BOOL) canBecomeKeyWindow {
	return NO;
}

- (BOOL) canBecomeMainWindow {
	return NO;
}
@end
