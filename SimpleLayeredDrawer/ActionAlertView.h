//
//  RVPVPMaskActionAlertView.h
//  SimpleLayeredDrawer
//
//  Created by Wade Sweatt on 5/3/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface ActionAlertView : NSView {
	BOOL showing;
}
@property (nonatomic, strong) NSString *alertText;
@property (copy) void (^completionBlock)(void);
- (void) presentWithText:(NSString *)text completionHandler:(void(^)(void))callback;
@end
