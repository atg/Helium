//
//  HEAtomParser.m
//  Helium
//
//  Created by Alex Gordon on 16/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HEAtomParser.h"
#import "HERSSDateParser.h"


@implementation HEAtomParser

// http://www.intertwingly.net/wiki/pie/Rss20AndAtom10Compared#table

- (void)parseXML:(NSXMLDocument *)xml intoContext:(NSManagedObjectContext *)ctx
{
	//Parse <feed>s
	[self parseChannelElement:[xml rootElement] feed:nil context:ctx];
}
- (NSManagedObject *)parseChannelElement:(NSXMLElement *)channelElement feed:(NSManagedObject *)feed context:(NSManagedObjectContext *)ctx
{
	NSEntityDescription *channelsEntity = [NSEntityDescription entityForName:@"Channel" inManagedObjectContext:ctx];
	
	//Check if the channel exists already
	NSString *title = [self subElementStringFrom:channelElement name:@"title"];
	if (!title)
		return nil;
	
	NSManagedObject *item = [self getOrCreateWithEntity:channelsEntity parent:feed parentKey:@"feed" key:@"name" value:title context:ctx];
	
	[self addSubelementFrom:channelElement name:@"title" into:item key:@"name"];
	[self addSubelementFrom:channelElement name:@"subtitle" into:item key:@"summary"];
	[self addSubelementFrom:channelElement name:@"link" into:item key:@"URL"];
	
	if (![self addSubelementFrom:channelElement name:@"author" into:item key:@"emailAddress"])
		[self addSubelementFrom:channelElement name:@"contributor" into:item key:@"emailAddress"];
	
	//Parse <entry>s
	for (NSXMLElement *channel in [channelElement elementsForName:@"entry"])
	{
		NSManagedObject *itemObject = [self parseItemElement:channel channel:item context:ctx];
		[itemObject setValue:item forKey:@"channel"];
	}
	
	return item;
}
- (NSManagedObject *)parseItemElement:(NSXMLElement *)itemElement channel:(NSManagedObject *)channel context:(NSManagedObjectContext *)ctx
{
	NSEntityDescription *postsEntity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:ctx];
	
	NSString *title = [self subElementStringFrom:itemElement name:@"title"];
	if (!title)
		return nil;
	
	NSManagedObject *item = [self getOrCreateWithEntity:postsEntity parent:channel parentKey:@"channel" key:@"title" value:title context:ctx];
	
	[self addSubelementFrom:itemElement name:@"title" into:item key:@"title"];
	if (![self addSubelementFrom:itemElement name:@"content" into:item key:@"contents"])
		[self addSubelementFrom:itemElement name:@"summary" into:item key:@"contents"];
	
	//RSS Optional properties
	if (![self addSubelementFrom:itemElement name:@"author" into:item key:@"authorEmail"])
		[self addSubelementFrom:itemElement name:@"contributor" into:item key:@"authorEmail"];
	[self addSubelementFrom:itemElement name:@"category" into:item key:@"category"];
	[self addSubelementFrom:itemElement name:@"id" into:item key:@"uuid"];
	
	//Publication Date
	NSArray *pubDateElements = [itemElement elementsForName:@"published"];
	[item setValue:[NSDate date] forKey:@"published"];
	if ([pubDateElements count])
	{
		NSString *string = [[pubDateElements objectAtIndex:0] stringValue];
		if ([string length])
		{
			NSDate *date = HEParseRSSDateString(string);
			if (date)
				[item setValue:date forKey:@"published"];
		}
	}
	
	//Parse <link>s which may be rel="enclosure"s
	for (NSXMLElement *link in [itemElement elementsForName:@"link"])
	{
		if (![[link stringValue] length])
			continue;
		
		NSString *rel = [[link attributeForName:@"rel"] stringValue];
		if (![rel length])
			[item setValue:[link stringValue] forKey:@"URL"];
		else if ([rel isEqual:@"via"])
			[item setValue:[link stringValue] forKey:@"source"];
		else if ([rel isEqual:@"comments"])
			[item setValue:[link stringValue] forKey:@"commentsURL"];
		else if ([rel isEqual:@"enclosure"])
		{
			NSManagedObject *enclosureObject = [self parseEnclosureElement:link post:item context:ctx];
			[enclosureObject setValue:item forKey:@"post"];
		}
	}
	
	return item;
}
- (NSManagedObject *)parseEnclosureElement:(NSXMLElement *)itemElement post:(NSManagedObject *)post context:(NSManagedObjectContext *)ctx
{
	//FIXME: Implement enclosures
	return nil;
}

@end
