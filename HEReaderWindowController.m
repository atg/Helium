//
//  HEReaderWindowController.m
//  Helium
//
//  Created by Alex Gordon on 15/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HEReaderWindowController.h"

#import "HERefresher.h"
#import "HEPostListView.h"
#import "HEPostListItemLayer.h"

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

- (void)postListSelectionDidChange:(HEPostListView *)listView
{
	NSLog(@"Post list selected did change %@", [listView.selectedLayer managedObject]);
	NSManagedObject *postObject = [listView.selectedLayer managedObject];
	[postController setContent:postObject];
	
	if ([postObject valueForKey:@"URL"])
		[self loadWebViewURL:[NSURL URLWithString:[postObject valueForKey:@"URL"]]];
}
- (void)loadWebViewURL:(NSURL *)url
{
	NSLog(@"postWebView = %@", postWebView);
	NSLog(@"URL = %@", url);
	[[postWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
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
	
	[item setValue:[addFeedURLField stringValue] forKey:@"URL"];
	[item setValue:[NSNumber numberWithInt:[addFeedImportance tag]] forKey:@"importance"];
	
	/*
http://en.wikipedia.org/w/index.php?title=Special:RecentChanges&feed=rss
	 */
	[ctx save:nil];
	[ctx reset];
	
	[[HERefresher globalRefresher] refresh];
	
	return YES;
}

@end
