//
//  HEPreferencesWindowController.m
//  Helium
//
//  Created by Alex Gordon on 16/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HEPreferencesWindowController.h"


@implementation HEPreferencesWindowController

- (id)init
{
	if (self = [super initWithWindowNibName:@"HEPreferences"])
	{
		
	}
	return self;
}

- (void)windowDidLoad
{
	[[self window] center];
}

@end
