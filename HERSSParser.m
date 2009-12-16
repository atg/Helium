//
//  HERSSParser.m
//  Helium
//
//  Created by Alex Gordon on 15/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HERSSParser.h"
#import "HERSSDateParser.h"

@interface HERSSParser ()

- (NSManagedObject *)parseChannelElement:(NSXMLElement *)channelElement intoContext:(NSManagedObjectContext *)ctx;
- (NSManagedObject *)parseItemElement:(NSXMLElement *)itemElement context:(NSManagedObjectContext *)ctx;
- (NSManagedObject *)parseEnclosureElement:(NSXMLElement *)itemElement context:(NSManagedObjectContext *)ctx;

- (BOOL)addSubelementFrom:(NSXMLElement *)xmlElement name:(NSString *)subelementName into:(NSManagedObject *)mo key:(NSString *)key;

@end


@implementation HERSSParser

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
	NSLog(@"url2");
	NSXMLDocument *xml = [[NSXMLDocument alloc] initWithContentsOfURL:url options:NSXMLDocumentTidyXML error:&err];
	if (!xml || err)
	{
		NSLog(@"Error parsing XML document: %@", err);
		return;
	}
	
	//Parse <channel>s
	for (NSXMLElement *channel in [[xml rootElement] elementsForName:@"channel"])
	{
		NSManagedObject *channelObject = [self parseChannelElement:channel intoContext:ctx];
		[channelObject setValue:feedObject forKey:@"feed"];
	}
}
- (NSManagedObject *)parseChannelElement:(NSXMLElement *)channelElement intoContext:(NSManagedObjectContext *)ctx
{
	NSEntityDescription *feedsEntity = [NSEntityDescription entityForName:@"Channel" inManagedObjectContext:ctx];
	
	NSManagedObject *item = [[NSManagedObject alloc] initWithEntity:feedsEntity insertIntoManagedObjectContext:ctx];
	
	[self addSubelementFrom:channelElement name:@"title" into:item key:@"name"];
	[self addSubelementFrom:channelElement name:@"description" into:item key:@"summary"];
	[self addSubelementFrom:channelElement name:@"link" into:item key:@"URL"];
	
	if (![self addSubelementFrom:channelElement name:@"managingEditor" into:item key:@"emailAddress"])
		[self addSubelementFrom:channelElement name:@"webMaster" into:item key:@"emailAddress"];
	
	//Time to live
	NSArray *ttlElements = [channelElement elementsForName:@"ttl"];
	if ([ttlElements count])
	{
		NSString *string = [[ttlElements objectAtIndex:0] stringValue];
		if ([string length] && [string integerValue] > 0)
			[item setValue:[NSNumber numberWithUnsignedInteger:[string integerValue]] forKey:@"ttlMinutes"];
	}
	
	//Parse <item>s
	for (NSXMLElement *channel in [channelElement elementsForName:@"item"])
	{
		NSManagedObject *itemObject = [self parseItemElement:channel context:ctx];
		[itemObject setValue:item forKey:@"channel"];
	}
	
	return item;
}
- (NSManagedObject *)parseItemElement:(NSXMLElement *)itemElement context:(NSManagedObjectContext *)ctx
{
	NSEntityDescription *postsEntity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:ctx];
	
	NSManagedObject *item = [[NSManagedObject alloc] initWithEntity:postsEntity insertIntoManagedObjectContext:ctx];
	
	//RSS Required properties (although we don't require them)
	[self addSubelementFrom:itemElement name:@"title" into:item key:@"title"];
	[self addSubelementFrom:itemElement name:@"description" into:item key:@"contents"];
	[self addSubelementFrom:itemElement name:@"link" into:item key:@"URL"];
	
	//RSS Optional properties
	[self addSubelementFrom:itemElement name:@"author" into:item key:@"authorEmail"];
	[self addSubelementFrom:itemElement name:@"category" into:item key:@"category"];
	[self addSubelementFrom:itemElement name:@"comments" into:item key:@"commentsURL"];
	[self addSubelementFrom:itemElement name:@"source" into:item key:@"source"];
	[self addSubelementFrom:itemElement name:@"guid" into:item key:@"uuid"];
	
	//Publication Date
	NSArray *pubDateElements = [itemElement elementsForName:@"pubDate"];
	[item setValue:[NSDate date] forKey:@"pubDate"];
	if ([pubDateElements count])
	{
		NSString *string = [[pubDateElements objectAtIndex:0] stringValue];
		if ([string length])
		{
			NSDate *date = HEParseRSSDateString(string);
			if (date)
				[item setValue:date forKey:@"pubDate"];
		}
	}
	
	//Parse <enclosures>s
	for (NSXMLElement *channel in [itemElement elementsForName:@"enclosure"])
	{
		NSManagedObject *enclosureObject = [self parseEnclosureElement:channel context:ctx];
		[enclosureObject setValue:item forKey:@"post"];
	}
	
	return item;
}
- (NSManagedObject *)parseEnclosureElement:(NSXMLElement *)itemElement context:(NSManagedObjectContext *)ctx
{
	//FIXME: Implement enclosures
	return nil;
}

- (BOOL)addSubelementFrom:(NSXMLElement *)xmlElement name:(NSString *)subelementName into:(NSManagedObject *)mo key:(NSString *)key
{
	NSArray *elements = [xmlElement elementsForName:subelementName];
	if (![elements count])
		return NO;
	
	NSString *string = [[elements objectAtIndex:0] stringValue];
	if ([string length])
		[mo setValue:string forKey:key];
	
	//NSLog(@"Set key/value pair: %@, %@", key, string);
	
	return YES;
}

@end
