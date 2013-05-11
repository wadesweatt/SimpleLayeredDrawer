//
//  MainWindowController.h
//  SimpleLayeredDrawer
//
//  Created by Wade Sweatt on 5/11/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainWindowController : NSWindowController <NSWindowDelegate>
@property (weak) IBOutlet NSTextField *titleBarLabel;
@end
