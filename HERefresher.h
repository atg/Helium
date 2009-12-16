//
//  HERefresher.h
//  Helium
//
//  Created by Alex Gordon on 16/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <dispatch/dispatch.h>

@interface HERefresher : NSObject
{
	NSTimeInterval firstStart;
	
	//Only one refresh is allowed at any one time. This variable must only be set in the main thread
	BOOL refreshIsInProgress;
}

+ (id)globalRefresher;

//Scan each Feed for Channels and Posts that don't exist
//If Channels/Posts have been updated, update their representation in the model
- (void)refresh;

@end
