//
//  HEPostListItemLayer.m
//  Helium
//
//  Created by Alex Gordon on 16/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HEPostListItemLayer.h"


@implementation HEPostListItemLayer

@synthesize icon;
@synthesize managedObject;
@synthesize isSelected;

- (id)init
{
	if (self = [super init])
	{
		self.needsDisplayOnBoundsChange = YES;
		self.autoresizingMask |= kCALayerWidthSizable;
		/*[self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintWidth
														 relativeTo:@"superlayer"
														  attribute:kCAConstraintWidth]];*/
				
		/*[self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxY
														 relativeTo:@"superlayer"
														  attribute:kCAConstraintMaxY]];*/
		
	}
	return self;
}

- (BOOL)contentsAreFlipped
{
	return YES;
}

- (void)drawInContext:(CGContextRef)ctx
{	
	NSGraphicsContext *oldContext = [NSGraphicsContext currentContext];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO]];
	
	NSRect rect = NSRectFromCGRect(self.bounds);
	const float radius = 8.0;
	
	//Draw the bottom highlight ("shadow")
	if (isSelected == NO)
	{
		NSRect bottomHighlightRect = rect;
		bottomHighlightRect.size.height -= 1.0;
		bottomHighlightRect.origin.y += 1.0;
		
		NSBezierPath *bottomHighlightPath = [NSBezierPath bezierPathWithRoundedRect:bottomHighlightRect xRadius:radius yRadius:radius];
		[[NSColor colorWithCalibratedWhite:1.0 alpha:0.2] set];
		[bottomHighlightPath fill];
	}
	
	//Leave some space for a the bottom highlight
	rect.size.height -= 1.0;
		
	//Draw the gradient stroke
	NSBezierPath *strokePath = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:radius yRadius:radius];
	NSGradient *strokeFill = nil;
	if (isSelected)
	{
		strokeFill = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.112 green:0.364 blue:0.910 alpha:1.000]
												   endingColor:[NSColor colorWithCalibratedRed:0.000 green:0.232 blue:0.628 alpha:1.000]];
	}
	else
	{
		strokeFill = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.714 green:0.758 blue:0.834 alpha:1.000]
												   endingColor:[NSColor colorWithCalibratedRed:0.668 green:0.716 blue:0.806 alpha:1.000]];
	}
	
	[strokeFill drawInBezierPath:strokePath angle:90];
	
	//Draw the highlight
	NSRect innerRect = NSInsetRect(rect, 1.0, 1.0);
	
	NSRect highlightRect = innerRect;
	highlightRect.size.height -= 10.0;
	NSBezierPath *highlightPath = [NSBezierPath bezierPathWithRoundedRect:highlightRect xRadius:radius - 1.0 yRadius:radius - 1.0];
	if (isSelected)
	{
		[[NSColor colorWithCalibratedWhite:1.0 alpha:0.35] set];
	}
	else
	{
		[[NSColor colorWithCalibratedWhite:1.0 alpha:0.55] set];
	}
	[highlightPath fill];
	
	//Draw the inner fill
	innerRect.size.height -= 1.0;
	innerRect.origin.y += 1.0;
	NSBezierPath *innerPath = [NSBezierPath bezierPathWithRoundedRect:innerRect xRadius:radius yRadius:radius];
	NSGradient *innerFill = nil;
	if (isSelected)
	{
		innerFill = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.287 green:0.469 blue:0.883 alpha:1.000]
												  endingColor:[NSColor colorWithCalibratedRed:0.111 green:0.360 blue:0.910 alpha:1.000]];
	}
	else
	{
		innerFill = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.826 green:0.853 blue:0.889 alpha:1.000]
												  endingColor:[NSColor colorWithCalibratedRed:0.760 green:0.806 blue:0.856 alpha:1.000]];
	}
	
	[innerFill drawInBezierPath:innerPath angle:90];
	
	[NSGraphicsContext setCurrentContext:oldContext];
}

@end
