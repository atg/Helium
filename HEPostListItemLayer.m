//
//  HEPostListItemLayer.m
//  Helium
//
//  Created by Alex Gordon on 16/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HEPostListItemLayer.h"

@interface HEPostListItemLayer()

- (NSDictionary *)attributesForSelected:(BOOL)selected small:(BOOL)small;

@end


@implementation HEPostListItemLayer

@synthesize icon;
@synthesize title;
@synthesize source;
@synthesize managedObject;
@synthesize isSelected;

- (id)init
{
	if (self = [super init])
	{
		self.needsDisplayOnBoundsChange = YES;
		self.autoresizingMask |= kCALayerWidthSizable;
	}
	return self;
}

- (BOOL)contentsAreFlipped
{
	return YES;
}

- (NSDictionary *)attributesForSelected:(BOOL)selected small:(BOOL)small
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	
	float fontSize = (small ? 10.0 : 13.0);
	if (!small || selected)
		[dict setValue:[NSFont boldSystemFontOfSize:fontSize] forKey:NSFontAttributeName];
	else
		[dict setValue:[NSFont systemFontOfSize:fontSize] forKey:NSFontAttributeName];
	
	float alpha = (small ? 0.9 : 1.0);
	if (selected)
		[dict setValue:[NSColor colorWithCalibratedWhite:1.0 alpha:alpha] forKey:NSForegroundColorAttributeName];
	else
		[dict setValue:[NSColor colorWithCalibratedRed:0.243 green:0.288 blue:0.335 alpha:alpha] forKey:NSForegroundColorAttributeName];
	
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
	[shadow setShadowBlurRadius:0.0];
	
	if (selected)
		[shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:1.0]];
	else
		[shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.9 alpha:1.0]];
	
	[dict setValue:shadow forKey:NSShadowAttributeName];
	
	return dict;
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
	
	
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:YES]];
	
	//Draw Text
	const float leftTextMargin = 9.0;
	const float rightTextMargin = 8.0;
	const float topTextMargin = 5.0;
	const float betweenLineTextMargin = 4.0;
	const float bottomTextMargin = 7.0;
	
	NSRect bounds = [self bounds];
	
	NSDictionary *bigAttributes = [self attributesForSelected:isSelected small:NO];
	NSSize bigSize = [title sizeWithAttributes:bigAttributes];
	
	NSDictionary *smallAttributes = [self attributesForSelected:isSelected small:YES];
	NSSize smallSize = [source sizeWithAttributes:smallAttributes];
	
	NSRect titleRect = NSMakeRect(leftTextMargin, topTextMargin, bounds.size.width - leftTextMargin - rightTextMargin, bounds.size.height - topTextMargin - betweenLineTextMargin - smallSize.height - bottomTextMargin);
	[title drawInRect:titleRect withAttributes:bigAttributes];
	
	NSRect sourceRect = NSMakeRect(titleRect.origin.x, topTextMargin + NSHeight(titleRect) + betweenLineTextMargin, titleRect.size.width, smallSize.height);
	[source drawInRect:sourceRect withAttributes:smallAttributes];
	
	[NSGraphicsContext setCurrentContext:oldContext];
}

@end
