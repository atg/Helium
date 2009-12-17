//
//  NSManagedObject+Utilities.m
//  Helium
//
//  Created by Alex Gordon on 17/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSManagedObject+Utilities.h"


@implementation NSManagedObject (Utilities)

- (NSDictionary *)he_dictionaryFromManagedObject
{
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	
	for (id key in [[self entity] attributesByName])
	{
		[dictionary setValue:[self valueForKey:key] forKey:key];
	}
	
	return dictionary;
}

@end
