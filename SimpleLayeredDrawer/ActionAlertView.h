//
//  RVPVPMaskActionAlertView.h
//  ProVideoPlayer 2
//
//  Created by Wade Sweatt on 5/3/13.
//  Copyright (c) 2013 Renewed Vision. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface ActionAlertView : NSView {
	BOOL showing;
}
@property (nonatomic, strong) NSString *alertText;
- (void) presentWithText:(NSString *)text;
@end