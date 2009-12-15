//
//  HEBannerView.m
//  Helium
//
//  Created by Alex Gordon on 15/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HEBannerView.h"

@implementation HEBannerView

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		// Initialization code here.
	}
	return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSRect rect = [self bounds];
	
	
	//Background gradient fill
	NSGradient *backgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.290 green:0.469 blue:0.883 alpha:1.000]
																   endingColor:[NSColor colorWithCalibratedRed:0.108 green:0.360 blue:0.910 alpha:1.000]];
	[backgroundGradient drawInRect:NSInsetRect(rect, 0.0, 1.0) angle:270];
	
	
	//Top highlight line
	[[NSColor colorWithCalibratedRed:0.335 green:0.526 blue:0.976 alpha:1.000] set];
	NSRect topHighlightRect = rect;
	topHighlightRect.origin.y = rect.size.height - 1.0;
	topHighlightRect.size.height = 1.0;
	NSRectFillUsingOperation(topHighlightRect, NSCompositeSourceOver);
	
	
	//Bottom shadow line
	[[NSColor colorWithCalibratedRed:0.000 green:0.229 blue:0.624 alpha:1.000] set];
	NSRect bottomShadowRect = rect;
	bottomShadowRect.size.height = 1.0;
	NSRectFillUsingOperation(bottomShadowRect, NSCompositeSourceOver);
}

@end
