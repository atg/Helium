//
//  HERSSParser.h
//  Helium
//
//  Created by Alex Gordon on 15/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface HERSSParser : NSObject
{
	NSURL *url;
	NSManagedObject *feedObject;
}

- (id)initWithURL:(NSURL *)docURL feedObject:(NSManagedObject *)feedObject;

- (void)parseIntoContext:(NSManagedObjectContext *)ctx;

@end
