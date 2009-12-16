//
//  HERefresher.m
//  Helium
//
//  Created by Alex Gordon on 16/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HERefresher.h"
#import "HERSSParser.h"
#import "Helium_AppDelegate.h"

@implementation HERefresher

+ (id)globalRefresher
{
	return [[NSApp delegate] refresher];
}

- (void)refresh
{
	//If we're already refreshing, bail
	if (refreshIsInProgress)
		return;
	
	//Get the managed object context for the background tasks
	NSManagedObjectContext *ctx = [(Helium_AppDelegate *)[NSApp delegate] managedObjectContextForBackgroundRefresh];
	
	//No context? Bail
	if (!ctx)
		return;
	
	//Hop into a background thread
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		
		//Get a list of all feeds. We refresh the important ones first
		NSFetchRequest *fetchFeedsRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *feedsEntity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:ctx];
		[fetchFeedsRequest setEntity:feedsEntity];
		
		[fetchFeedsRequest setSortDescriptors:
		 [NSArray arrayWithObject:
		  [NSSortDescriptor sortDescriptorWithKey:@"importance" ascending:NO]
		  ]
		 ];
		
		NSError *err = nil;
		NSArray *feeds = [ctx executeFetchRequest:fetchFeedsRequest error:&err];
		
		for (NSManagedObject *feed in feeds)
		{
			//Get the URL
			NSURL *url = [NSURL URLWithString:[feed valueForKey:@"URL"]];
			if (!url)
				continue;
			
			//Send to the parser
			HERSSParser *parser = [[HERSSParser alloc] initWithURL:url feedObject:feed];
			[parser parseIntoContext:ctx];
		}
		
		[ctx save:nil];
		[ctx reset];
		
		//Hop back onto the main thread to finish up
		dispatch_async(dispatch_get_main_queue(), ^{
			
			refreshIsInProgress = NO;
			
			//Notify the UI of the refresh
			[[NSNotificationCenter defaultCenter] postNotificationName:@"HERefresher_Refreshed" object:self];
		});
	});	
}

@end
