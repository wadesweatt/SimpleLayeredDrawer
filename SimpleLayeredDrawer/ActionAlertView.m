//
//  RVPVPMaskActionAlertView.m
//  ProVideoPlayer 2
//
//  Created by Wade Sweatt on 5/3/13.
//  Copyright (c) 2013 Renewed Vision. All rights reserved.
//

#import "ActionAlertView.h"
#import "NSColor+MyColorAdditions.h"

#define OVERSHOOT_SIZE 0.1

@interface ActionAlertView ()
@property (nonatomic, strong) NSMutableDictionary *fontAttributes;
@property (nonatomic, strong) NSGradient *backgroundGradient;
@end

@implementation ActionAlertView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _alertText = nil;
		_fontAttributes = [NSMutableDictionary dictionary];
		NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
		[paraStyle setAlignment:NSCenterTextAlignment];
		[_fontAttributes setValue:paraStyle forKey:NSParagraphStyleAttributeName];
		[_fontAttributes setValue:[NSFont fontWithName:@"Lucida Grande" size:13] forKey: NSFontAttributeName];
		[_fontAttributes setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];		
		_backgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor rvDarkestGrayColor] endingColor:[NSColor rvMediumDarkGrayColor]];
		[self setWantsLayer:YES]; // layer backing store
    }
    return self;
}

- (void) fadeOut:(NSTimer *)timer {
	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
		[context setDuration:0.2];
		[[self animator] setAlphaValue:0.0];
	} completionHandler:^{
		[self setHidden:YES];
		showing = NO;
		[timer invalidate];
	}];
}

- (void) presentWithText:(NSString *)text {
	self.alertText = text;
	CGRect originalFrame = [self frame];
	CGSize textSize = [_alertText sizeWithAttributes:_fontAttributes];
	// resize if the text is wider than the frame that was given to us
	if (textSize.width > self.bounds.size.width) {
		CGFloat difference = textSize.width - originalFrame.size.width + 25;
		originalFrame.size.width += difference;
		originalFrame.origin.x -= difference/2;
		[self setFrame:originalFrame];
	}
	[self setNeedsDisplay:YES];
	
	if (showing) return;
	showing = YES;

	CAAnimationGroup *groupAnim = [self popInAnimationWithSize:originalFrame.size beginningAlpha:0.7 endingAlpha:1.0];
	[CATransaction begin];
	[self.layer addAnimation:groupAnim forKey:@"popInAnimation"];
	[CATransaction commit];
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	if (flag) {
		NSTimer *fadeOutTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(fadeOut:) userInfo:nil repeats:NO];
		[[NSRunLoop currentRunLoop] addTimer:fadeOutTimer forMode:NSRunLoopCommonModes];
	}
}

- (void)drawRect:(NSRect)dirtyRect {
    CGRect bounds = [self bounds];
	
	bounds = CGRectInset(bounds, 2.0, 2.0);
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:bounds xRadius:10.0 yRadius:10.0];
	[_backgroundGradient drawInBezierPath:path angle:90.0];
	
	[super drawRect:dirtyRect];
	if (_alertText.length > 0) {
		[_alertText drawInRect:CGRectInset(bounds, 2, 2) withAttributes:_fontAttributes];
	}
}


#pragma mark - CORE ANIMATION

// the following is a single CAKeyframeAnimation animation, but I contained it within a CAAnimationGroup in case I ever wanted to add more to it.
- (CAAnimationGroup *) popInAnimationWithSize:(CGSize)size beginningAlpha:(CGFloat)alphaStart endingAlpha:(CGFloat)alphaEnd {
	
	CAKeyframeAnimation *boundsOvershootAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	
	CGFloat startingX = floor(0.3 * size.width) / 2;
	CGFloat overshotX = floor(-0.1 * size.width) / 2;

	CGFloat startingY = floor(0.3 * size.height) / 2;
	CGFloat overshotY = floor(-0.1 * size.height) / 2;
	
	CATransform3D startingScale = CATransform3DScale (CATransform3DMakeTranslation(startingX, startingY, 0), 0.7, 0.7, alphaStart);
	CATransform3D overshootScale = CATransform3DScale (CATransform3DMakeTranslation(overshotX, overshotY, 0), 1.1, 1.1, 1.0);
	CATransform3D undershootScale = CATransform3DScale (self.layer.transform, 1.0, 1.0, 1.0); // not currently undershooting, but left it here in case I ever wanted to.
	CATransform3D endingScale = CATransform3DScale (self.layer.transform, 1.0, 1.0, alphaEnd);
	
	NSArray *boundsValues = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:startingScale],
							 [NSValue valueWithCATransform3D:overshootScale],
							 [NSValue valueWithCATransform3D:undershootScale],
							 [NSValue valueWithCATransform3D:endingScale], nil];
	[boundsOvershootAnimation setValues:boundsValues];
	
	NSArray *times = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],
					  [NSNumber numberWithFloat:0.5f],
					  [NSNumber numberWithFloat:0.9f],
					  [NSNumber numberWithFloat:1.0f], nil];
	[boundsOvershootAnimation setKeyTimes:times];
	
	NSArray *timingFunctions = [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
								[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
								[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
								nil];
	[boundsOvershootAnimation setTimingFunctions:timingFunctions];
	boundsOvershootAnimation.fillMode = kCAFillModeForwards;
	boundsOvershootAnimation.removedOnCompletion = NO;

	CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
	groupAnimation.animations = [NSArray arrayWithObjects:boundsOvershootAnimation, nil];
	groupAnimation.delegate = self;
	groupAnimation.fillMode = kCAFillModeForwards;
	groupAnimation.removedOnCompletion = NO;
	
	return groupAnimation;
}

@end
