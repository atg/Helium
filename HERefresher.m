//
//  HERefresher.m
//  Helium
//
//  Created by Alex Gordon on 16/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HERefresher.h"
#import "HERSSParser.h"
#import "HEApplicationDelegate.h"

@interface HERefresher ()

- (void)scheduleTimer;
- (void)refreshTimerFired;

@end


@implementation HERefresher

+ (id)globalRefresher
{
	return [[NSApp delegate] refresher];
}

- (id)init
{
	if (self = [super init])
	{
		firstStart = [NSDate timeIntervalSinceReferenceDate];
		
		[self scheduleTimer];
	}
	return self;
}
- (void)scheduleTimer
{
	NSInteger refreshIntervalInt = [[NSUserDefaults standardUserDefaults] integerForKey:@"HERefreshInterval"];
	NSLog(@"refreshIntervalInt = %d", refreshIntervalInt);
	NSTimeInterval refreshInterval = 0.0;
	if (refreshIntervalInt >= 30) //30 seconds is the minimum
		refreshInterval = (NSTimeInterval)refreshIntervalInt;
	else
		refreshInterval = 600.0; //600 seconds is the default		
	
	[self performSelector:@selector(refreshTimerFired) withObject:nil afterDelay:refreshInterval];	
}
- (void)refreshTimerFired
{
	NSLog(@"Timer fired at %lf", [NSDate timeIntervalSinceReferenceDate] - firstStart);
	@try {
		[self refresh];
	}
	@catch (NSException * e) {
		
	}
	
	[self scheduleTimer];
}


- (void)refresh
{
	//If we're already refreshing, bail
	if (refreshIsInProgress)
		return;
	
	//Get the managed object context for the background tasks
	NSManagedObjectContext *ctx = [(HEApplicationDelegate *)[NSApp delegate] managedObjectContextForBackgroundRefresh];
	
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
			NSString *urlString = [feed valueForKey:@"URL"];
			
			//Send to the parser
			HEParser *parser = [HEParser autodetectAndParseURL:urlString feedObject:feed];
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
