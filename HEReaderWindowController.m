//
//  HEReaderWindowController.m
//  Helium
//
//  Created by Alex Gordon on 15/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HEReaderWindowController.h"

@interface HEReaderWindowController ()

- (BOOL)validateAddFeedURL;

@end

@implementation HEReaderWindowController

- (id)init
{
	if (self = [super initWithWindowNibName:@"HEReader"])
	{
		
	}
	return self;
}

- (void)windowDidLoad
{
	[[self window] center];
}

#pragma mark Adding Feeds

- (BOOL)validateAddFeedURL
{
	//FIXME: Do some fancier validation of feed URLs (for instance, checking the scheme)
	
	if (![[addFeedURLField stringValue] length])
	{
		[addFeedURLField setBackgroundColor:[NSColor colorWithCalibratedRed:0.984 green:0.937 blue:0.929 alpha:1.0]];		
		return NO;
	}
	
	[addFeedURLField setBackgroundColor:[NSColor whiteColor]];
	return YES;
}
- (BOOL)shouldCloseSheet:(id)sender
{
	//Check the URL is valid
	if ([self validateAddFeedURL] == NO)
	{
		NSBeep();
		return NO;
	}
	
	NSManagedObjectContext *ctx = [[NSApp delegate] managedObjectContext];
	NSEntityDescription *feedsEntity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:ctx];
	NSManagedObject *item = [[NSManagedObject alloc] initWithEntity:feedsEntity insertIntoManagedObjectContext:ctx];
	
	[item setValue:[addFeedURLField stringValue] forKey:@"rssURL"];
	
	return YES;
}

@end
