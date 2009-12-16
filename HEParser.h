//
//  HEParser.h
//  Helium
//
//  Created by Alex Gordon on 16/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface HEParser : NSObject
{
	NSURL *url;
	NSManagedObject *feedObject;
}

- (id)initWithURL:(NSURL *)docURL feedObject:(NSManagedObject *)feedObject;

- (void)parseIntoContext:(NSManagedObjectContext *)ctx;

@end



#pragma mark -
#pragma mark Protected Methods
//Protected methods for subclasses to override

@interface HEParser (Protected)

- (NSManagedObject *)parseChannelElement:(NSXMLElement *)channelElement feed:(NSManagedObject *)feed context:(NSManagedObjectContext *)ctx;
- (NSManagedObject *)parseItemElement:(NSXMLElement *)itemElement channel:(NSManagedObject *)channel context:(NSManagedObjectContext *)ctx;
- (NSManagedObject *)parseEnclosureElement:(NSXMLElement *)itemElement post:(NSManagedObject *)post context:(NSManagedObjectContext *)ctx;

- (NSManagedObject *)getOrCreateWithEntity:(NSEntityDescription *)entity parent:(NSManagedObject *)parent parentKey:(NSString *)parentKey key:(NSString *)key value:(id)value context:(NSManagedObjectContext *)ctx;
- (NSString *)subElementStringFrom:(NSXMLElement *)xmlElement name:(NSString *)subelementName;
- (BOOL)addSubelementFrom:(NSXMLElement *)xmlElement name:(NSString *)subelementName into:(NSManagedObject *)mo key:(NSString *)key;

@end