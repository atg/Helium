//
//  HEParser.m
//  Helium
//
//  Created by Alex Gordon on 16/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HEParser.h"

@implementation HEParser

- (id)initWithURL:(NSURL *)docURL feedObject:(NSManagedObject *)feed
{
	if (self = [super init])
	{
		url = docURL;
		feedObject = feed;
	}
	return self;
}

- (void)parseIntoContext:(NSManagedObjectContext *)ctx
{
	//Download the XML
	NSError *err = nil;
	NSXMLDocument *xml = [[NSXMLDocument alloc] initWithContentsOfURL:url options:NSXMLDocumentTidyXML error:&err];
	if (!xml || err)
	{
		NSLog(@"Error parsing XML document: %@", err);
		return;
	}
	
	//Parse <channel>s
	for (NSXMLElement *channel in [[xml rootElement] elementsForName:@"channel"])
	{
		NSManagedObject *channelObject = [self parseChannelElement:channel feed:feedObject context:ctx];
		[channelObject setValue:feedObject forKey:@"feed"];
	}
}

- (NSManagedObject *)parseChannelElement:(NSXMLElement *)channelElement feed:(NSManagedObject *)feed context:(NSManagedObjectContext *)ctx
{
	@throw [NSException exceptionWithName:NSGenericException reason:@"Abstract method -[HEParser parseChannelElement:feed:context:] called. Subclasses should override this." userInfo:[NSDictionary dictionary]];
}
- (NSManagedObject *)parseItemElement:(NSXMLElement *)itemElement channel:(NSManagedObject *)channel context:(NSManagedObjectContext *)ctx
{
	@throw [NSException exceptionWithName:NSGenericException reason:@"Abstract method -[HEParser parseItemElement:channel:context:] called. Subclasses should override this." userInfo:[NSDictionary dictionary]];
}
- (NSManagedObject *)parseEnclosureElement:(NSXMLElement *)itemElement post:(NSManagedObject *)post context:(NSManagedObjectContext *)ctx
{
	@throw [NSException exceptionWithName:NSGenericException reason:@"Abstract method -[HEParser parseEnclosureElement:post:context:] called. Subclasses should override this." userInfo:[NSDictionary dictionary]];
}

#pragma mark Utility methods

- (NSManagedObject *)getOrCreateWithEntity:(NSEntityDescription *)entity parent:(NSManagedObject *)parent parentKey:(NSString *)parentKey key:(NSString *)key value:(id)value context:(NSManagedObjectContext *)ctx
{	
	NSFetchRequest *getExistingChannelRequest = [[NSFetchRequest alloc] init];
	[getExistingChannelRequest setPredicate:[NSPredicate predicateWithFormat:@"%K=%@ && %K=%@", key, value, parentKey, parent]];
	[getExistingChannelRequest setEntity:entity];
	
	NSError *err = nil;
	NSArray *feeds = [ctx executeFetchRequest:getExistingChannelRequest error:&err];
	NSManagedObject *item = [feeds lastObject];
	
	if (!item || err)
		item = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:ctx];
	
	return item;
}
- (NSString *)subElementStringFrom:(NSXMLElement *)xmlElement name:(NSString *)subelementName
{
	NSArray *elements = [xmlElement elementsForName:subelementName];
	if (![elements count])
		return nil;
	
	NSString *string = [[elements objectAtIndex:0] stringValue];
	if (![string length])
		return nil;
	
	return string;
}
- (BOOL)addSubelementFrom:(NSXMLElement *)xmlElement name:(NSString *)subelementName into:(NSManagedObject *)mo key:(NSString *)key
{
	NSString *string = [self subElementStringFrom:xmlElement name:subelementName];
	if (string)
		[mo setValue:string forKey:key];
	
	//NSLog(@"Set key/value pair: %@, %@", key, string);
	
	return YES;
}

@end
