//
//  Static.h
//  SimpleLayeredDrawer
//
//  Created by Wade Sweatt on 5/8/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Foundation/Foundation.h>

#define RVReloadMaskTable @"RVReloadMaskTable"
#define RVSelectRowInMaskTable @"RVSelectRowInMaskTable"
#define RVPVPAddRemoveMask @"RVPVPAddRemoveMask"

@interface NSEvent (ModifierKeys)
// note that the class methods grab the current state of the modifier keys, not necessarily the state of the modifier keys at the time of the event in question
+ (BOOL) isControlKeyDown;
+ (BOOL) isOptionKeyDown;
+ (BOOL) isCommandKeyDown;
+ (BOOL) isShiftKeyDown;
- (BOOL) wasControlKeyDown;
- (BOOL) wasOptionKeyDown;
- (BOOL) wasCommandKeyDown;
- (BOOL) wasShiftKeyDown;
@end

@implementation NSEvent (ModifierKeys)

+ (BOOL) isControlKeyDown {
    return ([NSEvent modifierFlags] & NSControlKeyMask) != 0;
}

+ (BOOL) isOptionKeyDown {
    return ([NSEvent modifierFlags] & NSAlternateKeyMask) != 0;
}

+ (BOOL) isCommandKeyDown {
    return ([NSEvent modifierFlags] & NSCommandKeyMask) != 0;
}

+ (BOOL) isShiftKeyDown {
    return ([NSEvent modifierFlags] & NSShiftKeyMask) != 0;
}

- (BOOL) wasControlKeyDown {
	return ([self modifierFlags] & NSControlKeyMask) != 0;
}

- (BOOL) wasOptionKeyDown {
	return ([self modifierFlags] & NSAlternateKeyMask) != 0;
}

- (BOOL) wasCommandKeyDown {
	return ([self modifierFlags] & NSCommandKeyMask) != 0;
}

- (BOOL) wasShiftKeyDown {
	return ([self modifierFlags] & NSShiftKeyMask) != 0;
}

@end