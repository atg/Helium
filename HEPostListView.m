//
//  HEPostListView.m
//  Helium
//
//  Created by Alex Gordon on 15/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HEPostListView.h"
#import "HEPostListItemLayer.h"

@implementation HEPostListView

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		posts = [[NSMutableArray alloc] init];
	}
	return self;
}
- (void)awakeFromNib
{
	[self layer].geometryFlipped = YES;

	HEPostListItemLayer *layer = [[HEPostListItemLayer alloc] init];
	layer.frame = CGRectMake(20, 20, [self bounds].size.width - 40, 65);
	layer.isSelected = YES;
	[[self layer] addSublayer:layer];

	HEPostListItemLayer *layer2 = [[HEPostListItemLayer alloc] init];
	layer2.frame = CGRectMake(20, layer.frame.origin.y + layer.frame.size.height + 20, [self bounds].size.width - 40, 65);
	layer2.isSelected = NO;
	[[self layer] addSublayer:layer2];	
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSRect rect = [self bounds];
	[[NSColor colorWithCalibratedRed:0.840 green:0.863 blue:0.899 alpha:1.000] set];
	NSRectFillUsingOperation(rect, NSCompositeSourceOver);
}

- (BOOL)isFlipped
{
	return NO;
}

@end
