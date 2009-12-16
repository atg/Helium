//
//  HEReaderWindowController.h
//  Helium
//
//  Created by Alex Gordon on 15/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface HEReaderWindowController : NSWindowController {
	IBOutlet NSTextField *addFeedURLField;
	IBOutlet NSSegmentedControl *addFeedImportance;
}

- (void)addFeedURLField:(id)sender;
- (BOOL)shouldCloseSheet:(id)sender;

@end
