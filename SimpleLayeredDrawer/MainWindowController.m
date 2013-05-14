//
//  MainWindowController.m
//  SimpleLayeredDrawer
//
//  Created by Wade Sweatt on 5/11/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "MainWindowController.h"
#import "NSColor+MyColorAdditions.h"

@implementation MainWindowController

- (void) awakeFromNib {
	[self.window setDelegate:self];
	[self.window setMovableByWindowBackground:NO];
	
	self.titleBarLabel.textColor = [NSColor rvLightestGrayColor];
	[self.titleBarLabel setBordered:NO];
	[self.titleBarLabel setBezeled:NO];
	[self.titleBarLabel setEditable:NO];
	[self.titleBarLabel setFocusRingType:NSFocusRingTypeNone];
	[self.titleBarLabel setAlignment:NSCenterTextAlignment];
	CGRect windowFrame = [self.window.contentView superview].frame;
	[self.titleBarLabel setFrame:NSMakeRect((windowFrame.size.width - 200) / 2 ,  windowFrame.size.height - 32, 200, 30)];
	[self.titleBarLabel setAutoresizingMask:(NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin)];
	[self.titleBarLabel setStringValue:@"SimpleLayeredDrawer"];
	[[self.window.contentView superview] addSubview:self.titleBarLabel];
	
	[self updateWindow];
}


#pragma mark - WINDOW

- (void) windowDidResize:(NSNotification *)aNotification {
	if ([aNotification object] == self.window) {
		[self updateWindow];
	}
}

- (void) windowDidBecomeKey:(NSNotification*)aNotification {
	if ([aNotification object] == self.window) {
		[self updateWindow];
	}
}

- (void)windowDidResignKey:(NSNotification *)aNotification {
	if ([aNotification object] == self.window) {
		[self updateWindow];
	}
}

- (void) updateWindow {
	NSImage *bg = [[NSImage alloc] initWithSize:self.window.frame.size];
    NSRect aRect = NSMakeRect(0, 0, bg.size.width, bg.size.height);
	
	[bg lockFocus];

	// top frame (title bar) is all that will show with this dark color
    [[NSColor rvDarkestGrayColor] setFill];
    NSRectFill(aRect);
    
	[bg unlockFocus];
    [self.window setBackgroundColor:[NSColor colorWithPatternImage:bg]];
}

@end
