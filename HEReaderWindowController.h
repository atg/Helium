//
//  HEReaderWindowController.h
//  Helium
//
//  Created by Alex Gordon on 15/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import <BWToolkitFramework/BWToolkitFramework.h>

#import "HEPostListView.h"

@interface HEReaderWindowController : NSWindowController<HEPostListViewDelegate> {
	IBOutlet HEPostListView *postsView;
	IBOutlet NSObjectController *postController;
	
	IBOutlet WebView *postWebView;

	IBOutlet NSView *bottomBarButtonsContainer;
	
	IBOutlet BWSheetController *addFeedSheetController;
	IBOutlet NSTextField *addFeedURLField;
	IBOutlet NSSegmentedControl *addFeedImportance;
}

- (IBAction)showComments:(id)sender;
- (IBAction)openInBrowser:(id)sender;
- (IBAction)backForwardButtons:(id)sender;
- (IBAction)addFeed:(id)sender;

- (BOOL)shouldCloseSheet:(id)sender;

- (void)refresh;

@end
