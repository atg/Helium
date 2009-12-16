//
//  HEPostListView.m
//  Helium
//
//  Created by Alex Gordon on 15/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HEPostListView.h"
#import "HEPostListItemLayer.h"
#import "Helium_AppDelegate.h"

@interface HEPostListView ()

- (void)refresh;
- (void)refreshedModel:(NSNotification *)notif;
- (void)removeAllItems;

@end


@implementation HEPostListView

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
	
	HEPostListItemLayer *layer = [[HEPostListItemLayer alloc] init];
	layer.frame = CGRectMake(20, 20, [self bounds].size.width - 40, 66);
	layer.isSelected = YES;
	[posts addObject:layer];
	[[self layer] addSublayer:layer];
	
	selectedLayer = layer;
	
	
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
}
- (void)refreshedModel:(NSNotification *)notif
{
	[self refresh];
}
- (void)refresh
{
	[self removeAllItems];
	
	NSManagedObjectContext *ctx = [(Helium_AppDelegate *)[NSApp delegate] managedObjectContext];
	
	NSFetchRequest *fetchFeedsRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *postsEntity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:ctx];
	[fetchFeedsRequest setEntity:postsEntity];
	
	[fetchFeedsRequest setSortDescriptors:
	 [NSArray arrayWithObject:
	  [NSSortDescriptor sortDescriptorWithKey:@"importance" ascending:NO]
	  ]
	 ];
	
	NSError *err = nil;
	NSArray *postObjects = [ctx executeFetchRequest:fetchFeedsRequest error:&err];
	
	float previousMaxY = 20.0;
	for (NSManagedObject *postObject in postObjects)
	{
		HEPostListItemLayer *layer = [[HEPostListItemLayer alloc] init];
		layer.frame = CGRectMake(20, previousMaxY, [self bounds].size.width - 40, 66);
		
		previousMaxY = layer.frame.origin.y + layer.frame.size.height;
		
		[posts addObject:layer];
		[[self layer] addSublayer:layer];
		
		if (selectedLayer == nil)
		{
			layer.isSelected = YES;			
			selectedLayer = layer;
		}
	}
	
	[[self layer] setNeedsDisplay];
}
- (void)removeAllItems
{
	for (HEPostListItemLayer *post in posts)
	{
		[post removeFromSuperlayer];
	}
	[posts removeAllObjects];
	
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
		if (NSPointInRect(p, NSRectFromCGRect(post.frame)))
		{
			HEPostListItemLayer *oldSelectedLayer = selectedLayer;
			selectedLayer.isSelected = NO;
			
			post.isSelected = YES;
			selectedLayer = post;
			
			[oldSelectedLayer setNeedsDisplay];
			[post setNeedsDisplay];
			break;
		}
	}
}

- (BOOL)isFlipped
{
	return NO;
}

@end
