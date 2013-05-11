//
//  CanvasView.m
//  SimpleLayeredDrawer
//
//  Created by Wade Sweatt on 5/8/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//

#import "CanvasView.h"
#import "NSColor+MyColorAdditions.h"
#import "KeyCodes.h"
#import "Static.h"
#import "RVPoint.h"
#import "RVBezierPath.h"
#import "RVPathGroup.h"
#import "ActionAlertView.h"

#define RVSELECTION_RADIUS 10 // for point selection in mask editor and corner pinning
#define RVPATHPREVIEW_LINE_WIDTH 3.0
#define RVCONTROL_POINT_LINE_WIDTH 2.0
#define RVPATHBOUNDS_LINE_WIDTH 1.0
#define RVPATHBOUNDS_SELECTED_LINE_WIDTH 3.0

@implementation CanvasView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		mouseInView = NO;
		self.lineWidth = 2.0;
		self.shouldFill = NO;
		self.shouldStroke = YES;
		self.shouldShowSelection = YES;
		scale = 1.0;
		selectedIndex = -1;
		drawingMode = RVDrawingModeSelectTool;
		[maskModeControl setSelectedSegment:0]; // selector tool
		[NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
		NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self visibleRect]
																	options:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingInVisibleRect | NSTrackingActiveAlways
																	  owner:self
																   userInfo:nil];
		[self addTrackingArea:trackingArea];
    }
    return self;
}

- (void) awakeFromNib {
	[self.coordinatesTextField setStringValue:@""];
	self.strokeColor = [NSColor orangeColor];
	self.fillColor = [NSColor blackColor];
	self.selectedColor = [NSColor orangeColor];
}


#pragma mark - SETTERS

- (void) setScale:(CGFloat)scaleAmount {
	if (scale != scaleAmount) {
		scale = scaleAmount;
		[self setNeedsDisplay:YES];
	}
}

- (void) setSelectedIndex:(NSInteger)index {
	if (selectedIndex != index)
		selectedIndex = index;
}

- (void) setSelectedPath:(RVBezierPath *)selectedPath {
    if (_selectedPath != selectedPath) {
        _selectedPath = selectedPath;
        selectedIndex = 0;
		pointsArchive = [[NSMutableArray alloc] initWithArray:_selectedPath.points copyItems:YES];
        [self setNeedsDisplay:YES];
    }
}

- (void) setLineWidth:(NSInteger)lineWidth {
    if (_lineWidth != lineWidth) {
        _lineWidth = lineWidth;
        [self setNeedsDisplay:YES];
    }
}

- (void) setStrokeColor:(NSColor *)strokeColor {
    if (_strokeColor != strokeColor) {
        _strokeColor = strokeColor;
        [self setNeedsDisplay:YES];
    }
}

- (void) setFillColor:(NSColor *)fillColor {
	if (_fillColor != fillColor) {
		_fillColor = fillColor;
		[self setNeedsDisplay:YES];
	}
}

- (void) setSelectedColor:(NSColor *)selectedColor {
    if (_selectedColor != selectedColor) {
        _selectedColor = selectedColor;
        [self setNeedsDisplay:YES];
    }
}


#pragma mark - DRAW

#pragma mark helpers
- (NSPoint) scaledPointForPoint:(NSPoint)originalPoint {
    NSPoint newPoint = NSMakePoint(originalPoint.x*scale, originalPoint.y*scale);
    return newPoint;
}

- (void) outlineSelectionForPath:(RVBezierPath *)path {
    NSBezierPath *boundsOutline = [NSBezierPath bezierPathWithRect:[path bounds]];
    if ([path draggingBounds]) {
        [[NSColor greenColor] setStroke];
        [boundsOutline setLineWidth:2.0];
    } else {
        [[NSColor lightGrayColor] setStroke];
        [boundsOutline setLineWidth:1.0];
    }
    [boundsOutline stroke];
}

- (void) drawCircleAtPoint:(NSPoint)point color:(NSColor *)fillColor select:(BOOL)shouldSelect {
	CGFloat scaleAmount = scale;
	if (scaleAmount > 1.25) scaleAmount = 1.25;
    NSRect rect = NSMakeRect(point.x - 3.0*scaleAmount, point.y - 3.0*scaleAmount, 6.0*scaleAmount, 6.0*scaleAmount);
    [fillColor setFill];
	
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth:self.lineWidth];
    [path moveToPoint:NSMakePoint(NSMinX(rect),NSMidY(rect))];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(NSMinX(rect),NSMaxY(rect)) toPoint:NSMakePoint(NSMidX(rect),NSMaxY(rect)) radius:3*scaleAmount];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(NSMaxX(rect),NSMaxY(rect)) toPoint:NSMakePoint(NSMaxX(rect),NSMidY(rect)) radius:3*scaleAmount];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(NSMaxX(rect),NSMinY(rect)) toPoint:NSMakePoint(NSMidX(rect),NSMinY(rect)) radius:3*scaleAmount];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(NSMinX(rect),NSMinY(rect)) toPoint:NSMakePoint(NSMinX(rect),NSMidY(rect)) radius:3*scaleAmount];
    [path closePath];
	
    if (shouldSelect) {
        [self.selectedColor set];
		[path fill];
    }
	[fillColor set];
    [path stroke];
}

- (void) circlePathForPath:(RVBezierPath *)path {
    if (path.isCircle && [path.points count] == 2) {
        NSPoint center = [self scaledPointForPoint:[[path.points objectAtIndex:0] point]];
        NSPoint control = [self scaledPointForPoint:[[path.points lastObject] point]];
        CGFloat radius = [path radius]*scale;
        if (radius > 0) {
            CGFloat xMin = center.x - radius;
            CGFloat xMax = center.x + radius;
            NSPoint firstPoint = NSMakePoint(xMin, center.y);
            [path moveToPoint:firstPoint];
            // upper half
            for (CGFloat upperX = xMin; upperX<xMax; upperX += 1.0) {
                CGFloat radius2 = powf(radius, 2);
                CGFloat difference2 = powf((upperX - center.x), 2);
                CGFloat thisY = center.y + sqrtf(radius2 - difference2);
                if (isnan(thisY))  {
                    continue;
                }
                [path lineToPoint:NSMakePoint(upperX, thisY)];
            }
            // lower half
            for (CGFloat lowerX = xMax; lowerX>xMin; lowerX--) {
                CGFloat thisY = center.y - sqrtf(powf(radius, 2) - powf((lowerX - center.x), 2));
                [path lineToPoint:NSMakePoint(lowerX, thisY)];
            }
			
            [path lineToPoint:firstPoint]; // close it out
			
			if (self.shouldFill) {
				[self.fillColor setFill];
				[path fill];
			}
			
			if (self.shouldStroke) {
				[self.strokeColor setStroke];
				[path setLineWidth:self.lineWidth];
				[path stroke];
			}
            
			if (path == self.selectedPath) {
				[self outlineSelectionForPath:path];
                [self drawCircleAtPoint:center color:[NSColor lightGrayColor] select:NO];
                [self drawCircleAtPoint:control color:self.strokeColor select:YES];
            }
        }
        return;
    }
    NSLog(@"%s Received invalid circle", __PRETTY_FUNCTION__);
}

- (void)drawRect:(NSRect)dirtyRect {
	[[NSColor whiteColor] setFill];
	NSRectFill(self.bounds);
	
    for (RVBezierPath *path in self.pathEditorDelegate.selectedGroup.paths) {
        [path removeAllPoints]; // removes internal NSBezierPath points, NOT RVBezierPath's array of points
        if ([path.points count] > 0) {
			// Draw each path
			
            if (path.isCircle) {
                [self circlePathForPath:path];
                continue;
            }
			
			// first point (path origin)
            RVPoint *firstPointObject = [path.points objectAtIndex:0];
            NSPoint firstPoint = [self scaledPointForPoint:firstPointObject.point];
            BOOL firstPointSelected = (selectedIndex == 0 && path == self.selectedPath);
            
            // draw line to first control point if selected
            if (firstPointSelected) {
                NSBezierPath *firstControlPointPath = [NSBezierPath bezierPath];
                [firstControlPointPath setLineWidth:RVCONTROL_POINT_LINE_WIDTH];
				
                // this point's front control point
                if ([firstPointObject hasFrontControlPoint]) {
                    NSPoint firstPointFrontControlPoint = [self scaledPointForPoint:firstPointObject.frontControlPoint];
                    [self drawCircleAtPoint:firstPointFrontControlPoint color:[NSColor lightGrayColor] select:NO];
                    [firstControlPointPath moveToPoint:firstPointFrontControlPoint];
                    [firstControlPointPath lineToPoint:firstPoint];
                }
				
                // the next point's behind control point
                if ([path.points count] > 1) {
                    RVPoint *nextPointObject = [path.points objectAtIndex:1];
                    NSPoint nextPoint = [self scaledPointForPoint:[nextPointObject point]];
                    NSPoint behindCP = [self scaledPointForPoint:[nextPointObject behindControlPoint]];
                    if ([nextPointObject hasBehindControlPoint]) {
                        [self drawCircleAtPoint:behindCP color:[NSColor lightGrayColor] select:NO];
                        [firstControlPointPath moveToPoint:behindCP];
                        [firstControlPointPath lineToPoint:nextPoint];
                    }
                }
				
                [[NSColor lightGrayColor] setStroke];
                [firstControlPointPath stroke];
            }
			
            RVPoint *lastPointObject = [path.points lastObject];
            if ((firstPointObject.hasBehindControlPoint || lastPointObject.hasFrontControlPoint) && [path isClosed]) {
                NSPoint lastPoint = [self scaledPointForPoint:[lastPointObject point]];
				
                // only first point has a control point
                if (firstPointObject.hasBehindControlPoint && !lastPointObject.hasFrontControlPoint) {
                    NSPoint behindControlPoint = [self scaledPointForPoint:firstPointObject.behindControlPoint];
                    //NSLog(@"Only first point had a control point");
                    if (firstPointSelected) {
                        [self drawCircleAtPoint:behindControlPoint color:[NSColor lightGrayColor] select:NO];
                        NSBezierPath *controlPointPath = [NSBezierPath bezierPath];
                        [controlPointPath setLineWidth:RVCONTROL_POINT_LINE_WIDTH];
                        [controlPointPath moveToPoint:behindControlPoint];
                        [controlPointPath lineToPoint:firstPoint];
                        [[NSColor lightGrayColor] setStroke];
                        [controlPointPath stroke];
                    }
					
                    [path moveToPoint:lastPoint];
                    [path curveToPoint:firstPoint controlPoint1:behindControlPoint controlPoint2:behindControlPoint];
					
					// only previous point has a control point
                } else if (!firstPointObject.hasBehindControlPoint && lastPointObject.hasFrontControlPoint) {
                    NSPoint frontControlPoint = [self scaledPointForPoint:lastPointObject.frontControlPoint];
                    //NSLog(@"Only lastObject point had a control point");
                    if (firstPointSelected) {
                        [self drawCircleAtPoint:frontControlPoint color:[NSColor lightGrayColor] select:NO];
                        NSBezierPath *controlPointPath = [NSBezierPath bezierPath];
                        [controlPointPath setLineWidth:RVCONTROL_POINT_LINE_WIDTH];
                        [controlPointPath moveToPoint:frontControlPoint];
                        [controlPointPath lineToPoint:lastPoint];
                        [[NSColor lightGrayColor] setStroke];
                        [controlPointPath stroke];
                    }
					
                    [path moveToPoint:lastPoint];
                    [path curveToPoint:firstPoint controlPoint1:frontControlPoint controlPoint2:frontControlPoint];
					
					// both points have control points between them
                } else if (firstPointObject.hasBehindControlPoint && lastPointObject.hasFrontControlPoint) {
                    NSPoint frontControlPoint = [self scaledPointForPoint:lastPointObject.frontControlPoint];
					
                    NSPoint behindControlPoint = [self scaledPointForPoint:firstPointObject.behindControlPoint];
                    //NSLog(@"Both first first and lastObject's point had control points between them");
                    if (firstPointSelected) {
                        NSBezierPath *controlPointPath = [NSBezierPath bezierPath];
                        [controlPointPath setLineWidth:RVCONTROL_POINT_LINE_WIDTH];
                        [self drawCircleAtPoint:frontControlPoint color:[NSColor lightGrayColor] select:NO];
                        [controlPointPath moveToPoint:frontControlPoint];
                        [controlPointPath lineToPoint:lastPoint];
						
                        [self drawCircleAtPoint:behindControlPoint color:[NSColor lightGrayColor] select:NO];
                        [controlPointPath moveToPoint:behindControlPoint];
                        [controlPointPath lineToPoint:firstPoint];
                        [[NSColor lightGrayColor] setStroke];
                        [controlPointPath stroke];
                    }
					
                    [path moveToPoint:lastPoint];
                    [path curveToPoint:firstPoint controlPoint1:frontControlPoint controlPoint2:behindControlPoint];
                }
				// neither point has a control point between them or the path is not closed - just move here
            } else {
                [path moveToPoint:firstPoint];
            }
			
			// Rest of the points in this path
            // notice starting index of 1
            for (int i = 1; i<[path.points count]; i++) {
                RVPoint *destinationPointObject = [path.points objectAtIndex:i];
                NSPoint destinationPoint = [self scaledPointForPoint:destinationPointObject.point];
				
                BOOL selected = (selectedIndex == i && path == self.selectedPath);
				
                if (selected) {
                    NSBezierPath *controlPointPath = [NSBezierPath bezierPath];
                    [controlPointPath setLineWidth:RVCONTROL_POINT_LINE_WIDTH];
					
                    // this point's forward control point
                    if ([destinationPointObject hasFrontControlPoint]) {
                        NSPoint destinationPointFrontCP = [self scaledPointForPoint:destinationPointObject.frontControlPoint];
                        [self drawCircleAtPoint:destinationPointFrontCP color:[NSColor lightGrayColor] select:NO];
                        [controlPointPath moveToPoint:destinationPointFrontCP];
                        [controlPointPath lineToPoint:destinationPoint];
                    }
					
                    // the next point's behind control point
                    if ([path.points count] > (i + 1)) {
                        RVPoint *nextPointObject = [path.points objectAtIndex:(i + 1)];
                        NSPoint nextPoint = [self scaledPointForPoint:[nextPointObject point]];
                        NSPoint behindCP = [self scaledPointForPoint:[nextPointObject behindControlPoint]];
                        if ([nextPointObject hasBehindControlPoint]) {
                            [self drawCircleAtPoint:behindCP color:[NSColor lightGrayColor] select:NO];
                            [controlPointPath moveToPoint:behindCP];
                            [controlPointPath lineToPoint:nextPoint];
                        }
                    } else if ((i + 1) == [path.points count]) { // if this is the last point
                        RVPoint *nextPointObject = [path.points objectAtIndex:0]; // next point is actually the first point
                        NSPoint nextPoint = [self scaledPointForPoint:[nextPointObject point]];
                        NSPoint behindCP = [self scaledPointForPoint:[nextPointObject behindControlPoint]];
                        if ([nextPointObject hasBehindControlPoint]) {
                            [self drawCircleAtPoint:behindCP color:[NSColor lightGrayColor] select:NO];
                            [controlPointPath moveToPoint:behindCP];
                            [controlPointPath lineToPoint:nextPoint];
                        }
                    }
					
                    [[NSColor lightGrayColor] setStroke];
                    [controlPointPath stroke];
                }
				
                RVPoint *behindPointObject = [path.points objectAtIndex:(i-1)];
                NSPoint behindPoint = [self scaledPointForPoint:behindPointObject.point];
                NSBezierPath *pathToControlPoints = [NSBezierPath bezierPath];
                [pathToControlPoints setLineWidth:RVCONTROL_POINT_LINE_WIDTH];
				
                NSPoint destinationPointBehindControlPoint = NSZeroPoint;
                NSPoint behindPointFrontControlPoint = NSZeroPoint;
				
                // if only the destination point has a behind control point
                if ([destinationPointObject hasBehindControlPoint] && ![behindPointObject hasFrontControlPoint]) {
                    //NSLog(@"Only destination point had a control point");
                    destinationPointBehindControlPoint = [self scaledPointForPoint:[destinationPointObject behindControlPoint]];
                    if (selected) {
                        [self drawCircleAtPoint:destinationPointBehindControlPoint color:[NSColor lightGrayColor] select:NO];
                        [pathToControlPoints moveToPoint:destinationPointBehindControlPoint];
                        [pathToControlPoints lineToPoint:destinationPoint];
                        [[NSColor lightGrayColor] setStroke];
                        [pathToControlPoints stroke];
                    }
					
                    [path curveToPoint:destinationPoint controlPoint1:destinationPointBehindControlPoint controlPoint2:destinationPointBehindControlPoint];
					
					// if only the last point has a front control point
                } else if (![destinationPointObject hasBehindControlPoint] && [behindPointObject hasFrontControlPoint]) {
                    //NSLog(@"Only previous point had a control point");
                    behindPointFrontControlPoint = [self scaledPointForPoint:[behindPointObject frontControlPoint]];
					
                    if (selected) {
                        [self drawCircleAtPoint:behindPointFrontControlPoint color:[NSColor lightGrayColor] select:NO];
                        [pathToControlPoints moveToPoint:behindPointFrontControlPoint];
                        [pathToControlPoints lineToPoint:behindPoint];
                        [[NSColor lightGrayColor] setStroke];
                        [pathToControlPoints stroke];
                    }
					
                    [path curveToPoint:destinationPoint controlPoint1:behindPointFrontControlPoint controlPoint2:behindPointFrontControlPoint];
					
					// if both the current point and the destination point have a control points between themselves
                } else if ([destinationPointObject hasBehindControlPoint] && [behindPointObject hasFrontControlPoint]) {
                    //NSLog(@"Both points had a control point between them");
                    destinationPointBehindControlPoint = [self scaledPointForPoint:[destinationPointObject behindControlPoint]];
                    behindPointFrontControlPoint = [self scaledPointForPoint:[behindPointObject frontControlPoint]];
					
                    if (selected) {
                        [self drawCircleAtPoint:destinationPointBehindControlPoint color:[NSColor lightGrayColor] select:NO];
                        [pathToControlPoints moveToPoint:destinationPointBehindControlPoint];
                        [pathToControlPoints lineToPoint:destinationPoint];
						
                        [self drawCircleAtPoint:behindPointFrontControlPoint color:[NSColor lightGrayColor] select:NO];
                        [pathToControlPoints moveToPoint:behindPointFrontControlPoint];
                        [pathToControlPoints lineToPoint:behindPoint];
                        [[NSColor lightGrayColor] setStroke];
                        [pathToControlPoints stroke];
                    }
					
                    [path curveToPoint:destinationPoint controlPoint1:behindPointFrontControlPoint controlPoint2:destinationPointBehindControlPoint];
					
					// no control points, draw a straight line
                } else {
                    //NSLog(@"Neither last nor destination point had a control point");
                    [path lineToPoint:destinationPoint];
                }
            }
			
            if ([path isClosed]) [path closePath];
            [path setLineWidth:self.lineWidth];
			
            // fill
            if (self.shouldFill) {
                [self.fillColor setFill];
                [path fill];
            }
			
            // stroke
            if (self.shouldStroke) {
                [self.strokeColor setStroke];
                [path stroke];
            }
			
            // outline
            if ([path isClosed] && path == self.selectedPath) {
                [self outlineSelectionForPath:path];
            }
			
            // draw the actual, circular points last, so they show up on top of the lines
            for (int i = 0; i<[path.points count]; i++) {
                BOOL selected = (selectedIndex == i && path == self.selectedPath);
                NSPoint destinationPoint =  [self scaledPointForPoint:[[path.points objectAtIndex:i] point]];
                [self drawCircleAtPoint:destinationPoint color:self.strokeColor select:selected];
            }
			
////////////// Selected path preview
			if (mouseInView) {
				if (path == self.selectedPath && [path canContainArc] && !dragged) {
					// show preview of next line
					if (!(NSControlKeyMask & [NSEvent modifierFlags]) && [path.points count] > 0 && drawingMode == RVDrawingModePenTool) {
						NSBezierPath *previewPath = [NSBezierPath bezierPath];
						[self.strokeColor setStroke];
						[previewPath setLineWidth:RVPATHPREVIEW_LINE_WIDTH];
						
						NSPoint lastPoint = NSZeroPoint;
						NSPoint nextPoint = NSZeroPoint;
						if (selectedIndex > -1 && selectedIndex < [path.points count]) {
							RVPoint *lastPointObject = [path.points objectAtIndex:selectedIndex];
							lastPoint = [self scaledPointForPoint:[lastPointObject point]];
							[previewPath moveToPoint:lastPoint];
							
							if (lastPointObject.hasFrontControlPoint ) {
								NSPoint lastPointFrontControlPoint = [self scaledPointForPoint:lastPointObject.frontControlPoint];
								[previewPath curveToPoint:mouseLocation controlPoint1:lastPointFrontControlPoint controlPoint2:lastPointFrontControlPoint];
							} else {
								[previewPath lineToPoint:mouseLocation];
							}
						}
						
						if ([path isClosed]) {
							// we have the first point selected
							if (selectedIndex == 0) {
								nextPoint = [self scaledPointForPoint:[[path.points lastObject] point]];
								[previewPath moveToPoint:nextPoint];
								[previewPath lineToPoint:mouseLocation];
								
							// any point except the first one is selected
							} else if (selectedIndex > -1) {
								nextPoint = [self scaledPointForPoint:[[path.points objectAtIndex:(selectedIndex - 1)] point]];
								[previewPath moveToPoint:nextPoint];
								[previewPath lineToPoint:mouseLocation];
							}
						}
						
						[previewPath stroke];
						
					// ctrl - show preview of arc around a point - SELECT TOOL ONLY
					} else if (NSControlKeyMask & [NSEvent modifierFlags] && drawingMode == RVDrawingModeSelectTool) {
						if ([path.points count] > 1) {
							NSPoint selectedPoint = NSZeroPoint;
							NSPoint behindPoint = NSZeroPoint;
							if (selectedIndex > -1 && selectedIndex < [path.points count]) {
								// if selection, get selected point and the points before and after it
								arcPoint1 = [path.points objectAtIndex:selectedIndex];
								selectedPoint = arcPoint1.point;
								
								NSInteger secondIndex = NSNotFound;
								if (selectedIndex == 0) secondIndex = [path.points count] - 1;
								else secondIndex = selectedIndex - 1;
								arcPoint2 = [path.points objectAtIndex:secondIndex];
								behindPoint = arcPoint2.point;
								
								selectedPoint = [self scaledPointForPoint:selectedPoint];
								behindPoint = [self scaledPointForPoint:behindPoint];
								
								
								// AB - from point to mouse location
								NSPoint vectorABEndpoint = mouseLocation;
								NSPoint distanceVector = NSMakePoint(vectorABEndpoint.x - selectedPoint.x, vectorABEndpoint.y - selectedPoint.y);
								// AC - negative of AB
								NSPoint vectorACEndpoint = NSMakePoint(selectedPoint.x - distanceVector.x, selectedPoint.y - distanceVector.y);
								
								// curve preview - behind
								NSBezierPath *previewPath = [NSBezierPath bezierPath];
								[self.strokeColor setStroke];
								[previewPath setLineWidth:RVPATHPREVIEW_LINE_WIDTH];
								[previewPath moveToPoint:behindPoint];
								if ([arcPoint2 hasFrontControlPoint]) {
									NSPoint arcPoint2FrontControlPoint = [self scaledPointForPoint:arcPoint2.frontControlPoint];
									[previewPath curveToPoint:selectedPoint controlPoint1:arcPoint2FrontControlPoint controlPoint2:vectorACEndpoint];
								} else {
									[previewPath curveToPoint:selectedPoint controlPoint1:vectorACEndpoint controlPoint2:vectorACEndpoint];
								}
								[previewPath stroke];
								
								// curve preview - in front - only if there is a point ahead of the selected point
								if ([path isClosed] && (selectedIndex + 1) < [path.points count]) {
									NSInteger thirdIndex = selectedIndex + 1;
									RVPoint *inFrontPointObject = [path.points objectAtIndex:thirdIndex];
									NSPoint inFrontPoint = [self scaledPointForPoint:inFrontPointObject.point];
									
									[previewPath moveToPoint:selectedPoint];
									
									if ([inFrontPointObject hasFrontControlPoint]) {
										NSPoint inFrontPointBehindControlPoint = [self scaledPointForPoint:inFrontPointObject.behindControlPoint];
										[previewPath curveToPoint:inFrontPoint controlPoint1:vectorABEndpoint controlPoint2:inFrontPointBehindControlPoint];
									} else {
										[previewPath curveToPoint:inFrontPoint controlPoint1:vectorABEndpoint controlPoint2:vectorABEndpoint];
									}
									[previewPath stroke];
									// or if last point is selected and the path is closed
								} else if ([path isClosed] && selectedIndex == ([path.points count] - 1)) {
									RVPoint *inFrontPointObject = [path.points objectAtIndex:0];
									NSPoint inFrontPoint = [self scaledPointForPoint:inFrontPointObject.point];
									[previewPath moveToPoint:selectedPoint];
									
									if ([inFrontPointObject hasFrontControlPoint]) {
										NSPoint inFrontPointBehindControlPoint = [self scaledPointForPoint:inFrontPointObject.behindControlPoint];
										[previewPath curveToPoint:inFrontPoint controlPoint1:vectorABEndpoint controlPoint2:inFrontPointBehindControlPoint];
									} else {
										[previewPath curveToPoint:inFrontPoint controlPoint1:vectorABEndpoint controlPoint2:vectorABEndpoint];
									}
									[previewPath stroke];
								}
								
								[[NSColor lightGrayColor] setStroke];
								NSBezierPath *pathToPoint = [NSBezierPath bezierPath];
								[pathToPoint setLineWidth:RVCONTROL_POINT_LINE_WIDTH];
								
								// front control point
								[self drawCircleAtPoint:vectorABEndpoint color:[NSColor lightGrayColor] select:NO];
								[pathToPoint moveToPoint:vectorABEndpoint];
								[pathToPoint lineToPoint:selectedPoint];
								
								// behind control point
								[self drawCircleAtPoint:vectorACEndpoint color:[NSColor lightGrayColor] select:NO];
								[pathToPoint moveToPoint:vectorACEndpoint];
								[pathToPoint lineToPoint:selectedPoint];
								[pathToPoint stroke];
							}
						}
					}
				} // end if (path == self.selectedPath && [path canContainArc] && !dragged)
			} // end if (mouseInView)
		} // end ([path.points count] > 0)
    } // end iteration through paths
}


#pragma mark - MOUSE

- (void) mouseDown:(NSEvent *)theEvent {
	NSPoint mouseDownPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	// double click closes the current shape
	if ([theEvent clickCount] == 2) {
		if (drawingMode != RVDrawingModeSelectTool) {
			[self.selectedPath setShouldClose:YES];
			self.selectedPath = nil;
			selectedIndex = -1;
			closePathOnClick = NO;
			[self setNeedsDisplay:YES];
			[[NSCursor crosshairCursor] set];
			[self showActionNotificationWithText:@"Close Path"];
		}
		return;
	}
	
    // adjust for workspace origin offset
    mouseStartPoint = NSMakePoint(mouseDownPoint.x, mouseDownPoint.y);
    pointsArchive = nil;
    if (self.selectedPath) pointsArchive = [[NSMutableArray alloc] initWithArray:[self.selectedPath points] copyItems:YES]; // for undo
    dragged = NO; // reset
    pointWasSelected = NO; // reset
    pathWasSelected = NO; // reset
    createdRectOrCircle = NO;
    lastDragPoint = NSMakePoint(mouseStartPoint.x / scale, mouseStartPoint.y / scale); // set to current location on mouse down
	
#pragma mark Pen Tool
    if (drawingMode == RVDrawingModePenTool) {
        if (![self.pathEditorDelegate selectedGroup]) {
            [self.pathEditorDelegate createNewGroup];
        }
		
        // create a new path if the old one was closed or the click is outside the bounds of the old one
        if (!self.selectedPath) {
            RVBezierPath *newPath = [RVBezierPath path];
            [self.pathEditorDelegate.selectedGroup.paths addObject:newPath];
            self.selectedPath = newPath;
            pointsArchive = nil;
        }
		
		if (!self.selectedPath.canContainArc) {
			// can't insert, create arcs, etc on a circle or rectangle
			NSBeep();
			return;
		}
		
		// Arc creation
        // ctrl
        // create an arc from the last two points
        if (NSControlKeyMask & [NSEvent modifierFlags] && selectedIndex > -1 && selectedIndex < self.selectedPath.points.count) {
			[self registerUndoForPathChangesWithName:@"Create Arc"];
			[self showActionNotificationWithText:@"Create Arc"];
			
			RVPoint *selectedPoint = self.selectedPath.points[selectedIndex];
			selectedPoint.frontControlPoint = NSMakePoint(mouseStartPoint.x / scale, mouseStartPoint.y  / scale);
			
			NSPoint distanceVector = NSMakePoint(mouseStartPoint.x  / scale - selectedPoint.point.x, mouseStartPoint.y  / scale - selectedPoint.point.y);
			// AC - negative of AB
			NSPoint vectorACEndpoint = NSMakePoint(selectedPoint.point.x - distanceVector.x, selectedPoint.point.y - distanceVector.y);
			selectedPoint.behindControlPoint = vectorACEndpoint;
        } else {
			// New point creation
            if (!closePathOnClick) {
                RVPoint *newPoint = [[RVPoint alloc] initWithPoint:NSMakePoint(mouseStartPoint.x  / scale, mouseStartPoint.y  / scale)];
                newPoint.parentPath = self.selectedPath;
				
                // if we have a selection already, insert the point at that index rather than at the end
                if (selectedIndex > -1 && [self.selectedPath isClosed]) {
					[self registerUndoForPathChangesWithName:@"Insert Point"];
                    [self.selectedPath.points insertObject:newPoint atIndex:selectedIndex];
                } else {
					[self registerUndoForPathChangesWithName:@"Add Point"];
                    [self.selectedPath.points addObject:newPoint];
                    selectedIndex = [self.selectedPath.points count] - 1; // select the point
                }
				
            } else {
                [self.selectedPath setShouldClose:YES];
                closePathOnClick = NO;
                self.lastSelectedPath = self.selectedPath;
                self.selectedPath = nil;
				[self showActionNotificationWithText:@"Close Path"];
            }
        }
    }
	
#pragma mark Rectangle Tool
    else if (drawingMode == RVDrawingModeRectangleTool) {
        if (![self.pathEditorDelegate selectedGroup]) {
            [self.pathEditorDelegate createNewGroup];
        }
		
        // new path each click
        RVBezierPath *newPath = [RVBezierPath path];
        newPath.isRectangle = YES;
        newPath.shouldClose = YES;
        [self.pathEditorDelegate.selectedGroup.paths addObject:newPath];
        self.selectedPath = newPath;
        pointsArchive = nil;
        createdRectOrCircle = YES;
		
        RVPoint *bottomRight = [[RVPoint alloc] initWithPoint:NSMakePoint((mouseStartPoint.x  / scale) + 1, (mouseStartPoint.y  / scale) - 1)];
        RVPoint *bottomLeft = [[RVPoint alloc] initWithPoint:NSMakePoint(mouseStartPoint.x  / scale, (mouseStartPoint.y  / scale) - 1)];
        RVPoint *topRight = [[RVPoint alloc] initWithPoint:NSMakePoint((mouseStartPoint.x  / scale) + 1, mouseStartPoint.y  / scale)];
        RVPoint *topLeft = [[RVPoint alloc] initWithPoint:NSMakePoint(mouseStartPoint.x  / scale, mouseStartPoint.y  / scale)];
		
        bottomRight.parentPath = self.selectedPath;
        bottomLeft.parentPath = self.selectedPath;
        topRight.parentPath = self.selectedPath;
        topLeft.parentPath = self.selectedPath;
		
		//[self registerUndoForPathChangesWithName:@"Create Rectangle"];
        [self.selectedPath.points addObject:bottomRight];
        [self.selectedPath.points addObject:topRight];
        [self.selectedPath.points addObject:topLeft];
        [self.selectedPath.points addObject:bottomLeft];
        [self.selectedPath setShouldClose:YES];
        selectedIndex = [self.selectedPath.points count] - 2; // select the dragged point
    }
	
#pragma mark Circle Tool
    else if (drawingMode == RVDrawingModeCircleTool) {
        if (![self.pathEditorDelegate selectedGroup]) {
            [self.pathEditorDelegate createNewGroup];
        }
		
        // new path each click
        RVBezierPath *newPath = [RVBezierPath path];
        newPath.isCircle = YES;
        newPath.shouldClose = YES;
        [self.pathEditorDelegate.selectedGroup.paths addObject:newPath];
        self.selectedPath = newPath;
        pointsArchive = nil;
        createdRectOrCircle = YES;
		
        RVPoint *center = [[RVPoint alloc] initWithPoint:NSMakePoint(mouseStartPoint.x  / scale, mouseStartPoint.y  / scale)];
        RVPoint *control = [[RVPoint alloc] initWithPoint:NSMakePoint(mouseStartPoint.x  / scale, mouseStartPoint.y  / scale)];
		
        center.parentPath = self.selectedPath;
        control.parentPath = self.selectedPath;
		
		//[self registerUndoForPathChangesWithName:@"Create Circle"];
        [self.selectedPath.points addObject:center];
        [self.selectedPath.points addObject:control];
        selectedIndex = [self.selectedPath.points count] - 1; // select the control point
    }
	
    
#pragma mark Selection Tool
    else {
		// Arc creation in selection mode
        // ctrl
        // create an arc from the last two points
        if (NSControlKeyMask & [NSEvent modifierFlags] && selectedIndex > -1 && selectedIndex < self.selectedPath.points.count) {
			[self registerUndoForPathChangesWithName:@"Create Arc"];
			[self showActionNotificationWithText:@"Create Arc"];
			
			RVPoint *selectedPoint = self.selectedPath.points[selectedIndex];
			selectedPoint.frontControlPoint = NSMakePoint(mouseStartPoint.x  / scale, mouseStartPoint.y  / scale);
			
			NSPoint distanceVector = NSMakePoint(mouseStartPoint.x  / scale - selectedPoint.point.x, mouseStartPoint.y  / scale - selectedPoint.point.y);
			// AC - negative of AB
			NSPoint vectorACEndpoint = NSMakePoint(selectedPoint.point.x - distanceVector.x, selectedPoint.point.y - distanceVector.y);
			selectedPoint.behindControlPoint = vectorACEndpoint;
			
        } else {
			// Point selection
            // if the mouse click is near any given point, select the point and return
            for (int i = 0; i<[self.selectedPath.points count]; i++) {
                RVPoint *thisPointObject = [self.selectedPath.points objectAtIndex:i];
                NSPoint thisPoint = [self scaledPointForPoint:thisPointObject.point];
                // first, check near the actual point first
                if ((ABS(mouseLocation.x - thisPoint.x)) < RVSELECTION_RADIUS && (ABS(mouseLocation.y - thisPoint.y)) < RVSELECTION_RADIUS) {
                    selectedIndex = i;
                    thisPointObject.frontControlPointSelected = NO; // reset these
                    thisPointObject.behindControlPointSelected = NO;
                    [self setNeedsDisplay:YES];
                    //NSLog(@"selected point at index: %d", i);
                    pointWasSelected = YES;
                    return;
                }
                // if none, check near any control points
                // front
                if ([thisPointObject hasFrontControlPoint]) {
                    NSPoint thisControlPoint = [self scaledPointForPoint:thisPointObject.frontControlPoint];
                    if ((ABS(mouseLocation.x - thisControlPoint.x)) < RVSELECTION_RADIUS && (ABS(mouseLocation.y - thisControlPoint.y)) < RVSELECTION_RADIUS) {
                        selectedIndex = i;
                        thisPointObject.frontControlPointSelected = YES;
                        thisPointObject.behindControlPointSelected = NO;
                        pointWasSelected = YES;
                    } else {
                        thisPointObject.frontControlPointSelected = NO;
                    }
                }
				
                // behind
                if ([thisPointObject hasBehindControlPoint]) {
                    NSPoint thisControlPoint = thisPointObject.behindControlPoint;
                    thisControlPoint = [self scaledPointForPoint:thisControlPoint];
                    if ((ABS(mouseLocation.x - thisControlPoint.x)) < RVSELECTION_RADIUS && (ABS(mouseLocation.y - thisControlPoint.y)) < RVSELECTION_RADIUS) {
                        selectedIndex = i;
                        thisPointObject.frontControlPointSelected = NO;
                        thisPointObject.behindControlPointSelected = YES;
                        pointWasSelected = YES;
                    } else {
                        thisPointObject.behindControlPointSelected = NO;
                    }
                }
            }
        }
        if (!pointWasSelected) {
            for (NSInteger i = 0; i<[self.pathEditorDelegate.selectedGroup.paths count]; i++) {
                RVBezierPath *eachPath = [self.pathEditorDelegate.selectedGroup.paths objectAtIndex:i];
				if (eachPath.points.count < 1) continue;
                NSRect pathBounds = [eachPath bounds];
                if (NSPointInRect(mouseLocation, pathBounds)) {
                    [self setSelectedPath:eachPath];
					selectedIndex = -1;
                    pathWasSelected = YES; // flag for dragging
					[[NSNotificationCenter defaultCenter] postNotificationName:RVSelectRowInMaskTable object:[NSNumber numberWithInteger:i]];
                    break;
                }
                self.selectedPath = nil;
            }
			if (!pathWasSelected) [[NSNotificationCenter defaultCenter] postNotificationName:RVSelectRowInMaskTable object:[NSNumber numberWithInteger:-1]];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:RVReloadMaskTable object:nil];
    [self setNeedsDisplay:YES];
}

- (void) mouseDragged:(NSEvent *)theEvent {
	NSPoint dragPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    dragPoint = NSMakePoint((dragPoint.x) / scale, (dragPoint.y) / scale);
    dragged = YES;
	
    switch (drawingMode) {
#pragma mark Select Tool Drag
        case RVDrawingModeSelectTool: {
            if (selectedIndex > -1 && [self.selectedPath.points count] > selectedIndex && pointWasSelected) {
                RVPoint *pointDragged = [self.selectedPath.points objectAtIndex:selectedIndex];
                // rectangle
                if (self.selectedPath.isRectangle) {
                    if ([self.selectedPath.points count] != 4) break;
                    NSPoint distanceVectorEndpoint = NSMakePoint(dragPoint.x - lastDragPoint.x, dragPoint.y - lastDragPoint.y);
                    RVPoint *bottomRightObject = [self.selectedPath.points objectAtIndex:0];
                    RVPoint *topRightObject = [self.selectedPath.points objectAtIndex:1];
                    RVPoint *topLeftObject = [self.selectedPath.points objectAtIndex:2];
                    RVPoint *bottomLeftObject = [self.selectedPath.points objectAtIndex:3];
                    NSPoint bottomRight = bottomRightObject.point;
                    NSPoint topRight = topRightObject.point;
                    NSPoint topLeft = topLeftObject.point;
                    NSPoint bottomLeft = bottomLeftObject.point;
                    // which corner was dragged?
                    NSUInteger index = [self.selectedPath.points indexOfObject:pointDragged];
                    switch (index) {
                        case 0: // bottom right
                            bottomRight.x += distanceVectorEndpoint.x;
                            bottomRight.y += distanceVectorEndpoint.y;
                            bottomRightObject.point = bottomRight;
							
                            topRight.x = bottomRight.x;
                            topRight.y = topLeft.y; // won't change
                            topRightObject.point = topRight;
							
                            bottomLeft.x = topLeft.x; // won't change
                            bottomLeft.y = bottomRight.y;
                            bottomLeftObject.point = bottomLeft;
                            break;
							
                        case 1: // top right
                            topRight.x += distanceVectorEndpoint.x;
                            topRight.y += distanceVectorEndpoint.y;
                            topRightObject.point = topRight;
							
                            bottomRight.x = topRight.x;
                            bottomRight.y = bottomLeft.y; // won't change
                            bottomRightObject.point = bottomRight;
							
                            topLeft.x = bottomLeft.x; // won't change
                            topLeft.y = topRight.y;
                            topLeftObject.point = topLeft;
                            break;
							
                        case 2: // top left
                            topLeft.x += distanceVectorEndpoint.x;
                            topLeft.y += distanceVectorEndpoint.y;
                            topLeftObject.point = topLeft;
							
                            bottomLeft.x = topLeft.x;
                            bottomLeft.y = bottomRight.y; //won't change
                            bottomLeftObject.point = bottomLeft;
							
                            topRight.x = bottomRight.x; //won't change
                            topRight.y = topLeft.y;
                            topRightObject.point = topRight;
                            break;
							
                        case 3: // bottom left
                            bottomLeft.x += distanceVectorEndpoint.x;
                            bottomLeft.y += distanceVectorEndpoint.y;
                            bottomLeftObject.point = bottomLeft;
							
                            topLeft.x = bottomLeft.x;
                            topLeft.y = topRight.y; // won't change
                            topLeftObject.point = topLeft;
							
                            bottomRight.x = topRight.x; // won't change
                            bottomRight.y = bottomLeft.y;
                            bottomRightObject.point = bottomRight;
                            break;
                    }
                    break;
					
				// circle
                } else if (self.selectedPath.isCircle) {
                    if ([self.selectedPath.points count] != 2) break;
                    NSPoint distanceVectorEndpoint = NSMakePoint(dragPoint.x - lastDragPoint.x, dragPoint.y - lastDragPoint.y);
                    RVPoint *control = [self.selectedPath.points lastObject];
                    NSUInteger index = [self.selectedPath.points indexOfObject:pointDragged];
                    if (index == 1) { // can only drag control point for sizing
                        NSPoint controlPoint = control.point;
                        controlPoint.x += distanceVectorEndpoint.x;
                        controlPoint.y += distanceVectorEndpoint.y;
                        control.point = controlPoint;
                    }
					
                    break;
					
				// plain path
                } else {
                    if (pointDragged.frontControlPointSelected) pointDragged.frontControlPoint = dragPoint;
                    else if (pointDragged.behindControlPointSelected) pointDragged.behindControlPoint = dragPoint;
                    // if we dragged the main point, move any control points with it
                    else {
                        NSPoint distanceVectorEndpoint = NSMakePoint(dragPoint.x - pointDragged.point.x, dragPoint.y - pointDragged.point.y);
                        if ([pointDragged hasBehindControlPoint]) {
                            NSPoint behindPoint = [pointDragged behindControlPoint];
                            behindPoint = NSMakePoint(behindPoint.x + distanceVectorEndpoint.x, behindPoint.y + distanceVectorEndpoint.y);
                            pointDragged.behindControlPoint = behindPoint;
                        }
                        if ([pointDragged hasFrontControlPoint]) {
                            NSPoint frontPoint = [pointDragged frontControlPoint];
                            frontPoint = NSMakePoint(frontPoint.x + distanceVectorEndpoint.x, frontPoint.y + distanceVectorEndpoint.y);
                            pointDragged.frontControlPoint = frontPoint;
                        }
                        pointDragged.point = dragPoint;
                    }
                    break;
                }
                
			// dragging an entire path
            } else if (pathWasSelected) {
                NSPoint distanceVectorEndpoint = NSMakePoint(dragPoint.x - lastDragPoint.x, dragPoint.y - lastDragPoint.y);
                for (RVPoint *eachPointObject in self.selectedPath.points) {
                    NSPoint eachPoint = [eachPointObject point];
                    if ([eachPointObject hasBehindControlPoint]) {
                        NSPoint behindPoint = [eachPointObject behindControlPoint];
                        behindPoint = NSMakePoint(behindPoint.x + distanceVectorEndpoint.x, behindPoint.y + distanceVectorEndpoint.y);
                        eachPointObject.behindControlPoint = behindPoint;
                    }
                    if ([eachPointObject hasFrontControlPoint]) {
                        NSPoint frontPoint = [eachPointObject frontControlPoint];
                        frontPoint = NSMakePoint(frontPoint.x + distanceVectorEndpoint.x, frontPoint.y + distanceVectorEndpoint.y);
                        eachPointObject.frontControlPoint = frontPoint;
                    }
                    eachPoint.x += distanceVectorEndpoint.x;
                    eachPoint.y += distanceVectorEndpoint.y;
                    eachPointObject.point = eachPoint;
                }
                [self.selectedPath setDraggingBounds:YES];
            }
            break;
        }
			
#pragma mark Pen Tool Drag
        case RVDrawingModePenTool: {
            if ([self.selectedPath.points count] < 2) break;
            NSPoint distanceVectorEndpoint = NSMakePoint(dragPoint.x - lastDragPoint.x, dragPoint.y - lastDragPoint.y);
            RVPoint *pointDraggedObject = [self.selectedPath.points objectAtIndex:selectedIndex];
            if (!pointDraggedObject.hasFrontControlPoint) pointDraggedObject.frontControlPoint = pointDraggedObject.point;
			
            // we are dragging the front control point to make a curve
            NSPoint pointDraggedFrontControlPoint = pointDraggedObject.frontControlPoint;
            pointDraggedFrontControlPoint.x += distanceVectorEndpoint.x;
            pointDraggedFrontControlPoint.y += distanceVectorEndpoint.y;
            pointDraggedObject.frontControlPoint = pointDraggedFrontControlPoint;
			
            // set the behind control point to be the negative vector of the new front
            NSPoint distanceVector = NSMakePoint(pointDraggedObject.frontControlPoint.x - pointDraggedObject.point.x, pointDraggedObject.frontControlPoint.y - pointDraggedObject.point.y);
            pointDraggedObject.behindControlPoint = NSMakePoint(pointDraggedObject.point.x - distanceVector.x, pointDraggedObject.point.y - distanceVector.y);
            
            break;
        }
			
#pragma mark Rectangle Tool Drag
        case RVDrawingModeRectangleTool: {
            if ([self.selectedPath.points count] != 4) break;
			
            NSPoint distanceVectorEndpoint = NSMakePoint(dragPoint.x - lastDragPoint.x, dragPoint.y - lastDragPoint.y);
			RVPoint *topLeftObject = [self.selectedPath.points objectAtIndex:2];
            RVPoint *topRightObject = [self.selectedPath.points objectAtIndex:1];
            RVPoint *bottomLeftObject = [self.selectedPath.points objectAtIndex:3];
			RVPoint *bottomRightObject = [self.selectedPath.points objectAtIndex:0];
			NSPoint topLeft = topLeftObject.point;
			NSPoint topRight = topRightObject.point;
            NSPoint bottomLeft = bottomLeftObject.point;
			NSPoint bottomRight = bottomRightObject.point;
			
			// this is the point we are actually dragging
			topLeft.x += distanceVectorEndpoint.x;
			topLeft.y += distanceVectorEndpoint.y;
			
			// ctrl - preserve center point
			if (NSControlKeyMask & [NSEvent modifierFlags]) {
				bottomLeft.x = topLeft.x;
				bottomLeft.y = mouseStartPoint.y - (topLeft.y - mouseStartPoint.y);
				
				topRight.x = mouseStartPoint.x - (topLeft.x - mouseStartPoint.x);
				topRight.y = topLeft.y;
				
				bottomRight.x = topRight.x;
				bottomRight.y = bottomLeft.y;
				
			// no modifier - expand in direction of mouse
			} else {
				bottomLeft.x = topLeft.x;
				bottomLeft.y = bottomRight.y; //won't change
				
				topRight.x = bottomRight.x; //won't change
				topRight.y = topLeft.y;
			}
			
            topLeftObject.point = topLeft;
			topRightObject.point = topRight;
			bottomLeftObject.point = bottomLeft;
            bottomRightObject.point = bottomRight;
			
            break;
        }
			
#pragma mark Circle Tool Drag
        case RVDrawingModeCircleTool: {
            if ([self.selectedPath.points count] != 2) break;
            NSPoint distanceVectorEndpoint = NSMakePoint(dragPoint.x - lastDragPoint.x, dragPoint.y - lastDragPoint.y);
            RVPoint *control = [self.selectedPath.points lastObject];
            NSPoint controlPoint = control.point;
            controlPoint.x += distanceVectorEndpoint.x;
            controlPoint.y += distanceVectorEndpoint.y;
            control.point = controlPoint;
			
            break;
        }
    }
    
    lastDragPoint = dragPoint;
    [self setNeedsDisplay:YES];
}

- (void) mouseUp:(NSEvent *)theEvent {
	if (dragged) {
		NSString *message = nil;
		if (!pathWasSelected && !createdRectOrCircle) { // drag to resize or alter shape
			RVPoint *draggedPoint = [self.selectedPath.points objectAtIndex:selectedIndex];
			message = (draggedPoint.frontControlPointSelected || draggedPoint.behindControlPointSelected) ? @"Drag Control Point" : @"Drag Point";
		} else if (!pathWasSelected && createdRectOrCircle) { // drag when creating circle or rectangle
			if ([self.selectedPath isCircle])
				message = @"Create Circle";
			else
				message = @"Create Rectangle";
		} else {
			message = @"Drag Shape";
		}
		[self registerUndoForPathChangesWithName:message];
        dragged = NO;
        pathWasSelected = NO;
        [self.selectedPath setDraggingBounds:NO];
        lastDragPoint = NSZeroPoint;
        [[NSNotificationCenter defaultCenter] postNotificationName:RVReloadMaskTable object:nil];
        [self setNeedsDisplay:YES];
    }
	
    // clear out path after creating a circle or rectangle
    if ((self.selectedPath.isCircle || self.selectedPath.isRectangle) && createdRectOrCircle) {
        self.selectedPath = nil;
    }
}

- (void) mouseMoved:(NSEvent *)theEvent {
	mouseLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    if ([self.selectedPath.points count] > 0) {
        for (int i = 0; i<[self.selectedPath.points count]; i++) {
            RVPoint *pointObject = [self.selectedPath.points objectAtIndex:i];
            NSPoint thisPoint = [self scaledPointForPoint:pointObject.point];
            if ((ABS(mouseLocation.x - thisPoint.x)) < RVSELECTION_RADIUS && (ABS(mouseLocation.y - thisPoint.y)) < RVSELECTION_RADIUS) {
                [[NSCursor pointingHandCursor] set];
                if (drawingMode == RVDrawingModePenTool) {
                    closePathOnClick = YES;
                }
                break;
            } else {
				[[NSCursor arrowCursor] set];
			}
            closePathOnClick = NO;
            if (drawingMode != RVDrawingModeSelectTool) {
                [[NSCursor crosshairCursor] set];
            } else {
				[[NSCursor arrowCursor] set];
			}
        }
        [self setNeedsDisplay:YES];
    }
	[self updateCoordinatesTextFieldWithMouseLocation:mouseLocation];
}

- (void) mouseEntered:(NSEvent *)theEvent {
	[super mouseEntered:theEvent];
	mouseInView = YES;
    if (drawingMode != RVDrawingModeSelectTool) {
        [[NSCursor crosshairCursor] set];
    } else {
        [[NSCursor arrowCursor] set];
    }
	[self.coordinatesTextField setHidden:NO];
}

- (void) mouseExited:(NSEvent *)theEvent {
	[super mouseExited:theEvent];
	mouseInView = NO;
    [[NSCursor arrowCursor] set];
	[self setNeedsDisplay:YES];
	[self.coordinatesTextField setHidden:YES];
}

- (void) rightMouseDown:(NSEvent *)theEvent {
	// if drawing, this deselects the path
    if (drawingMode != RVDrawingModeSelectTool) {
        self.lastSelectedPath = self.selectedPath;
		[self.selectedPath setShouldClose:YES];
        self.selectedPath = nil;
		[self setNeedsDisplay:YES];
		[self showActionNotificationWithText:@"Close Path"];
    } else {
		[super rightMouseDown:theEvent];
    }
}


#pragma mark - KEY

// for moving points with arrow keys
- (void) movePoint:(RVPoint *)point byOffset:(CGFloat)offset vertical:(BOOL)isVerticalMove {
    if (point.frontControlPointSelected) {
        NSPoint frontControlPoint = point.frontControlPoint;
        if (isVerticalMove) {
            frontControlPoint.y += offset;
        } else {
            frontControlPoint.x += offset;
        }
        point.frontControlPoint = frontControlPoint;
    } else if (point.behindControlPointSelected) {
        NSPoint behindControlPoint = point.behindControlPoint;
        if (isVerticalMove) {
            behindControlPoint.y += offset;
        } else {
            behindControlPoint.x += offset;
        }
        point.behindControlPoint = behindControlPoint;
    } else {
        NSPoint thisPoint = point.point;
        if (isVerticalMove) {
            thisPoint.y += offset;
        } else {
            thisPoint.x += offset;
        }
        point.point = thisPoint;
    }
    [self setNeedsDisplay:YES];
}

- (void) keyDown:(NSEvent *)theEvent {
	int key = [theEvent keyCode];
	
    CGFloat offset = 1.0;
    if ([theEvent wasShiftKeyDown]) offset = 10.0;
	
    // delete a point
    if (key == KEY_CODE_BACKWARD_DELETE || key == KEY_CODE_FORWARD_DELETE) {
        if (!self.selectedPath.canContainArc) { // circle or rectangle
			[self registerUndoForMaskChangesWithName:self.selectedPath.isCircle? @"Delete Circle" : @"Delete Rectangle"];
			
            [self.pathEditorDelegate.selectedGroup.paths removeObject:self.selectedPath];
            [[NSNotificationCenter defaultCenter] postNotificationName:RVReloadMaskTable object:nil];
            [self setNeedsDisplay:YES];
            return;
        }
        if ([self.selectedPath.points count] > selectedIndex && selectedIndex > -1) {
            RVPoint *deletedPoint = [self.selectedPath.points objectAtIndex:selectedIndex];
			
			NSString *message = (deletedPoint.frontControlPointSelected || deletedPoint.behindControlPointSelected) ? @"Delete Control Point" : @"Delete Point";
            [self registerUndoForPathChangesWithName:message];
			
            if (deletedPoint.frontControlPointSelected || deletedPoint.behindControlPointSelected) {
                deletedPoint.frontControlPoint = NSZeroPoint;
                deletedPoint.behindControlPoint = NSZeroPoint;
                deletedPoint.frontControlPointSelected = NO;
                deletedPoint.behindControlPointSelected = NO;
            } else {
                [self.selectedPath.points removeObjectAtIndex:selectedIndex];
                self.selectedPath.shouldClose = NO;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:RVReloadMaskTable object:nil];
            [self setNeedsDisplay:YES];
        }
        return;
		// move selected point by one pixel
    } else if (key == KEY_CODE_LEFT_ARROW && selectedIndex > -1) {
        if ([self.selectedPath.points count] > selectedIndex) {
            RVPoint *movedPoint = [self.selectedPath.points objectAtIndex:selectedIndex];
            [self movePoint:movedPoint byOffset:(-offset) vertical:NO];
            [self setNeedsDisplay:YES];
        }
        return;
    } else if (key == KEY_CODE_RIGHT_ARROW && selectedIndex > -1) {
        if ([self.selectedPath.points count] > selectedIndex) {
            RVPoint *movedPoint = [self.selectedPath.points objectAtIndex:selectedIndex];
            [self movePoint:movedPoint byOffset:offset vertical:NO];
            [self setNeedsDisplay:YES];
        }
        return;
    } else if (key == KEY_CODE_UP_ARROW && selectedIndex > -1) {
        if ([self.selectedPath.points count] > selectedIndex) {
            RVPoint *movedPoint = [self.selectedPath.points objectAtIndex:selectedIndex];
            [self movePoint:movedPoint byOffset:offset vertical:YES];
            [self setNeedsDisplay:YES];
        }
        return;
    } else if (key == KEY_CODE_DOWN_ARROW && selectedIndex > -1) {
        if ([self.selectedPath.points count] > selectedIndex) {
            RVPoint *movedPoint = [self.selectedPath.points objectAtIndex:selectedIndex];
            [self movePoint:movedPoint byOffset:(-offset) vertical:YES];
            [self setNeedsDisplay:YES];
        }
        return;
		// moving an entire shape
	} else if((key == KEY_CODE_LEFT_ARROW || key == KEY_CODE_RIGHT_ARROW || key == KEY_CODE_UP_ARROW || key == KEY_CODE_DOWN_ARROW) && selectedIndex == -1) {
		BOOL vertical = NO;
		switch (key) {
			case KEY_CODE_LEFT_ARROW:
				offset = -offset;
				break;
			case KEY_CODE_RIGHT_ARROW:
				break;
			case KEY_CODE_UP_ARROW:
				vertical = YES;
				break;
			case KEY_CODE_DOWN_ARROW:
				offset = -offset;
				vertical = YES;
				break;
		}
		for (RVPoint *eachPoint in self.selectedPath.points) {
			[self movePoint:eachPoint byOffset:offset vertical:vertical];
		}
		[self setNeedsDisplay:YES];
		return;
		
		// deselect the current shape and close it
    } else if (key == KEY_CODE_ESCAPE) {
		[self.selectedPath setShouldClose:YES];
		closePathOnClick = NO;
		self.selectedPath = nil;
		[self setNeedsDisplay:YES];
		return;
	}
}


#pragma mark - MENU

- (void) removeControlPointsAtSelection {
	
	NSString *message = @"Flatten";
	[self registerUndoForPathChangesWithName:message];
	[self showActionNotificationWithText:message];
	
    RVPoint *point = [self.selectedPath.points objectAtIndex:selectedIndex];
    [point setBehindControlPoint:NSZeroPoint];
    [point setFrontControlPoint:NSZeroPoint];
    [self setNeedsDisplay:YES];
}

- (NSMenu *) menuForEvent:(NSEvent *)event {
	if (drawingMode == RVDrawingModeSelectTool && !(NSControlKeyMask & [NSEvent modifierFlags])) {
        selectedIndex = -1;
        RVPoint *selectedPoint = nil;
        for (int i = 0; i<[self.selectedPath.points count]; i++) {
            RVPoint *pointObject = [self.selectedPath.points objectAtIndex:i];
            NSPoint thisPoint = [self scaledPointForPoint:pointObject.point];
            if ((ABS(mouseLocation.x - thisPoint.x)) < RVSELECTION_RADIUS && (ABS(mouseLocation.y - thisPoint.y)) < RVSELECTION_RADIUS) {
                selectedIndex = i;
                selectedPoint = pointObject;
                break;
            }
        }
        if (selectedIndex > -1 && selectedIndex < [self.selectedPath.points count] && ([selectedPoint hasBehindControlPoint] || [selectedPoint hasFrontControlPoint])) {
            NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Flatten Menu"];
            [menu addItemWithTitle:@"Flatten" action:@selector(removeControlPointsAtSelection) keyEquivalent:@""];
			return menu;
        }
	}
	return nil;
}


#pragma mark - ACTION

- (IBAction)changeTool:(id)sender  {
    NSInteger selection = [(NSSegmentedControl *)sender selectedSegment];
	
    switch (selection) {
        case 0:
            drawingMode = RVDrawingModeSelectTool;
            [self.selectedPath setShouldClose:YES];
            closePathOnClick = NO;
            self.selectedPath = self.lastSelectedPath?:nil;
            [[NSCursor arrowCursor] set];
            break;
        case 1:
            drawingMode = RVDrawingModePenTool;
            self.selectedPath = nil;
			selectedIndex = -1;
            [[NSCursor crosshairCursor] set];
            break;
        case 2:
            drawingMode = RVDrawingModeRectangleTool;
            self.selectedPath = nil;
            selectedIndex = -1;
            [[NSCursor crosshairCursor] set];
            break;
        case 3:
            drawingMode = RVDrawingModeCircleTool;
            self.selectedPath = nil;
            selectedIndex = -1;
            [[NSCursor crosshairCursor] set];
            break;
    }
    
    [self setNeedsDisplay:YES];
}

- (void) showActionNotificationWithText:(NSString *)actionMessage {
	CGSize boundsSize = [self bounds].size;
	ActionAlertView *alertView = [[ActionAlertView alloc] initWithFrame:NSMakeRect((boundsSize.width - 90) / 2, 10, 90, 30)];
	[self addSubview:alertView];
	[alertView presentWithText:actionMessage];
}

- (void) updateCoordinatesTextFieldWithMouseLocation:(NSPoint)location {
	NSString *coordinatesString = [NSString stringWithFormat:@"x: %.2f y: %.2f", location.x, location.y];
	[self.coordinatesTextField setStringValue:coordinatesString];
}

#pragma mark - UNDO

- (void) registerUndoForPathChangesWithName:(NSString *)undoName {
	NSMutableArray *pointsCopy = [[NSMutableArray alloc] initWithArray:pointsArchive copyItems:YES];
	BOOL created = createdRectOrCircle;
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:undoName, @"message", pointsCopy, @"objects", self.selectedPath, @"path", [NSNumber numberWithBool:created], @"created", nil];
	[self.pathEditorDelegate registerPathUndoActionWithManager:[self undoManager] userInfo:dictionary];
}

- (void) registerUndoForMaskChangesWithName:(NSString *)undoName {
	NSString *message = self.selectedPath.isCircle? @"Delete Circle" : @"Delete Rectangle";
	NSMutableArray *pathsCopy = [[NSMutableArray alloc] initWithArray:self.pathEditorDelegate.selectedGroup.paths copyItems:YES];
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:message, @"message", pathsCopy, @"objects", self.pathEditorDelegate.selectedGroup, @"mask", nil];
	[self.pathEditorDelegate registerMaskUndoActionWithManager:[self undoManager] userInfo:dictionary];
}


@end
