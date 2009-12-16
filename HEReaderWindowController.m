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
- (void)loadWebViewURLString:(NSString *)urlString;

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

- (void)postListDidResize:(HEPostListView *)listView
{
	float listViewWidth = NSMaxX([[listView enclosingScrollView] frame]);
	
	NSRect bottomBarButtonsContainerFrame = [bottomBarButtonsContainer frame];
	bottomBarButtonsContainerFrame.origin.x = listViewWidth;
	[bottomBarButtonsContainer setFrame:bottomBarButtonsContainerFrame];
}
- (void)postListSelectionDidChange:(HEPostListView *)listView
{
	NSManagedObject *postObject = [listView.selectedLayer managedObject];
	[postController setContent:postObject];
	
	[self loadWebViewURLString:[postObject valueForKey:@"URL"]];
}
- (void)loadWebViewURLString:(NSString *)urlString
{
	if (![urlString length])
		return;
	
	NSURL *url = [NSURL URLWithString:urlString];
	
	[[postWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
}

- (IBAction)showComments:(id)sender
{
	[self loadWebViewURLString:[[postsView.selectedLayer managedObject] valueForKey:@"commentsURL"]];
}
- (IBAction)openInBrowser:(id)sender
{
	NSURL *url = [[[[postWebView mainFrame] provisionalDataSource] request] URL];
	if (url)
	{
		[[NSWorkspace sharedWorkspace] openURL:url];
	}
	else
	{
		url = [NSURL URLWithString:[[postsView.selectedLayer managedObject] valueForKey:@"URL"]];
		if (url)
			[[NSWorkspace sharedWorkspace] openURL:url];
	}
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
