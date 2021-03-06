//
//  HEPostListView.m
//  Helium
//
//  Created by Alex Gordon on 15/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HEPostListView.h"
#import "HEPostListItemLayer.h"
#import "HEApplicationDelegate.h"

#import "NSManagedObject+Utilities.h"


@interface HEPostListView ()

- (void)refreshedModel:(NSNotification *)notif;
- (void)removeAllItems;

- (void)sizeToFit;
- (NSRect)sizeFrameToFit:(NSRect)frame;
- (void)scrollToVisible:(HEPostListItemLayer *)layer;

@end


@implementation HEPostListView

@synthesize delegate;
@synthesize selectedLayer;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		posts = [[NSMutableArray alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshedModel:) name:@"HERefresher_Refreshed" object:nil];
	}
	return self;
}
- (void)awakeFromNib
{
	[self layer].geometryFlipped = YES;
	
	//Test layers out
	
	/*
	HEPostListItemLayer *layer = [[HEPostListItemLayer alloc] init];
	layer.frame = CGRectMake(20, 20, [self bounds].size.width - 40, 66);
	layer.isSelected = YES;
	[posts addObject:layer];
	[[self layer] addSublayer:layer];
	
	self.selectedLayer = layer;
	
	
	HEPostListItemLayer *layer2 = [[HEPostListItemLayer alloc] init];
	layer2.frame = CGRectMake(20, layer.frame.origin.y + layer.frame.size.height + 20, [self bounds].size.width - 40, 66);
	layer2.isSelected = NO;
	[posts addObject:layer2];
	[[self layer] addSublayer:layer2];
	
	
	HEPostListItemLayer *layer3 = [[HEPostListItemLayer alloc] init];
	layer3.frame = CGRectMake(20, layer2.frame.origin.y + layer2.frame.size.height + 20, [self bounds].size.width - 40, 66);
	layer3.isSelected = NO;
	[posts addObject:layer3];
	[[self layer] addSublayer:layer3];
	 */
}
- (void)refreshedModel:(NSNotification *)notif
{
	[self refresh];
}
- (void)refresh
{
	[self removeAllItems];
	
	NSManagedObjectContext *ctx = [(HEApplicationDelegate *)[NSApp delegate] managedObjectContext];
	
	NSFetchRequest *fetchFeedsRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *postsEntity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:ctx];
	[fetchFeedsRequest setEntity:postsEntity];
	
	
	[fetchFeedsRequest setSortDescriptors:
	 [NSArray arrayWithObjects:
	  [NSSortDescriptor sortDescriptorWithKey:@"channel.feed.importance" ascending:NO],
	  [NSSortDescriptor sortDescriptorWithKey:@"pubDate" ascending:NO],
	  nil
	  ]
	 ];
	 
	
	NSError *err = nil;
	NSArray *postObjects = [ctx executeFetchRequest:fetchFeedsRequest error:&err];
	
	float previousMaxY = 20.0;
	int count = 0;
	for (NSManagedObject *postObject in postObjects)
	{
		if (count + 1 > 10)
			break;
		
		HEPostListItemLayer *layer = [[HEPostListItemLayer alloc] init];
		layer.frame = CGRectMake(20, previousMaxY, [self bounds].size.width - 40, 66);
		layer.title = [postObject valueForKey:@"title"];
		layer.source = [postObject valueForKeyPath:@"channel.name"];
		
		layer.values = [postObject he_dictionaryFromManagedObject];
		
		previousMaxY = layer.frame.origin.y + layer.frame.size.height + 11;
		
		[posts addObject:layer];
		[[self layer] addSublayer:layer];
		
		if (selectedLayer == nil)
		{
			self.selectedLayer = layer;
		}
				
		[layer setNeedsDisplay];
		count++;
	}
	
	[[self layer] setNeedsDisplay];
	[self sizeToFit];
	
	[self scrollToVisible:self.selectedLayer];
}
- (void)sizeToFit
{
	[CATransaction begin];
	//[CATransaction setAnimationDuration:0.0];
	
	NSRect frame = [self frame];
	frame = [self sizeFrameToFit:frame];
	[super setFrame:frame];
	
	[CATransaction commit];
}
- (NSRect)sizeFrameToFit:(NSRect)frame
{
	float maxY = [[self superview] frame].size.height - 20.0;
	for (HEPostListItemLayer *post in posts)
	{
		float y = post.frame.origin.y + post.frame.size.height;
		if (y > maxY)
			maxY = y;
	}
	maxY += 20.0;
	
	frame.size.height = maxY;
	
	return frame;
}
- (void)setFrame:(NSRect)newFrame
{
	newFrame = [self sizeFrameToFit:newFrame];
	[super setFrame:newFrame];
	
	if ([delegate respondsToSelector:@selector(postListDidResize:)])
	{
		[delegate postListDidResize:self];
	}
}


- (void)removeAllItems
{
	for (HEPostListItemLayer *post in posts)
	{
		[post removeFromSuperlayer];
	}
	[posts removeAllObjects];
	
	//self.selectedLayer = nil;
	
	[[self layer] setNeedsDisplay];
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSRect rect = [self bounds];
	[[NSColor colorWithCalibratedRed:0.840 green:0.863 blue:0.899 alpha:1.000] set];
	NSRectFillUsingOperation(rect, NSCompositeSourceOver);
}

- (void)mouseUp:(NSEvent *)event
{
	NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
	
	//Flip p
	p.y = [self bounds].size.height - p.y;
	
	for (HEPostListItemLayer *post in posts)
	{
		if ([post hitTest:NSPointFromCGPoint(p)])
		{
			self.selectedLayer = post;
			
			break;
		}
	}
}
- (void)scrollToVisible:(HEPostListItemLayer *)layer
{
	if (!layer)
		return;
	
	NSInteger layerIndex = [posts indexOfObjectIdenticalTo:layer];
	float margin = 12.0;
	if (layerIndex == 0)
		margin = 20.0;
	
	NSRect flippedLayerRect = [layer frame];
	flippedLayerRect.origin.y = [self frame].size.height - NSMaxY(flippedLayerRect);
	
	NSClipView *clipView = [[self enclosingScrollView] contentView];
	
	//Check if any portion of the layer is outside the clip
	if (!NSEqualRects(NSIntersectionRect([clipView documentVisibleRect], flippedLayerRect), flippedLayerRect))
	{
		//If so, scroll so it's fully visible
		[self scrollPoint:NSMakePoint(0, [self frame].size.height + margin - layer.frame.origin.y - [clipView frame].size.height)];
	}
}
- (void)setSelectedLayer:(HEPostListItemLayer *)layer
{
	if (selectedLayer != layer)
	{
		[self scrollToVisible:layer];
	}
	
	HEPostListItemLayer *oldSelectedLayer = selectedLayer;
	selectedLayer.isSelected = NO;
	
	layer.isSelected = YES;
	selectedLayer = layer;
	
	[oldSelectedLayer setNeedsDisplay];
	[layer setNeedsDisplay];
	
	if ([delegate respondsToSelector:@selector(postListSelectionDidChange:)])
	{
		[delegate postListSelectionDidChange:self];
	}
}

- (BOOL)isFlipped
{
	return NO;
}

@end
