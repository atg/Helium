//
//  HEReaderWindowController.h
//  Helium
//
//  Created by Alex Gordon on 15/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class HEPostListView;

@interface HEReaderWindowController : NSWindowController {
	IBOutlet HEPostListView *postsView;
	IBOutlet NSObjectController *postController;
	
	IBOutlet WebView *postWebView;
	
	IBOutlet NSTextField *addFeedURLField;
	IBOutlet NSSegmentedControl *addFeedImportance;
}

- (BOOL)shouldCloseSheet:(id)sender;

@end
