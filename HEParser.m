//
//  HEParser.m
//  Helium
//
//  Created by Alex Gordon on 16/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HEParser.h"
#import "RegexKitLite.h"

#import "HERSSParser.h"
#import "HEAtomParser.h"

@interface HEParser ()

+ (id)autodetectAndParseURL:(NSString *)urlString feedObject:(NSManagedObject *)feed allowHTMLIndirection:(BOOL)allowHTMLIndirection;

@end


@implementation HEParser

@synthesize stringContents;


//This code is from http://stackoverflow.com/questions/1105169/html-character-decoding-in-objective-c-cocoa/1105297#1105297
+ (NSString *)decodingXMLEntitiesInString:(NSString *)entStr
{
    NSUInteger myLength = [entStr length];
    NSUInteger ampIndex = [entStr rangeOfString:@"&" options:NSLiteralSearch].location;
	
    // Short-circuit if there are no ampersands.
    if (ampIndex == NSNotFound) {
        return entStr;
    }
    // Make result string with some extra capacity.
    NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25)];
	
    // First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
    NSScanner *scanner = [NSScanner scannerWithString:entStr];
	
    [scanner setCharactersToBeSkipped:nil];
	
    NSCharacterSet *boundaryCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r;"];
	
    do {
        // Scan up to the next entity or the end of the string.
        NSString *nonEntityString;
        if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
            [result appendString:nonEntityString];
        }
        if ([scanner isAtEnd]) {
            goto finish;
        }
        // Scan either a HTML or numeric character entity reference.
        if ([scanner scanString:@"&amp;" intoString:NULL])
            [result appendString:@"&"];
        else if ([scanner scanString:@"&apos;" intoString:NULL])
            [result appendString:@"'"];
        else if ([scanner scanString:@"&quot;" intoString:NULL])
            [result appendString:@"\""];
        else if ([scanner scanString:@"&lt;" intoString:NULL])
            [result appendString:@"<"];
        else if ([scanner scanString:@"&gt;" intoString:NULL])
            [result appendString:@">"];
        else if ([scanner scanString:@"&#" intoString:NULL]) {
            BOOL gotNumber;
            unsigned charCode;
            NSString *xForHex = @"";
			
            // Is it hex or decimal?
            if ([scanner scanString:@"x" intoString:&xForHex]) {
                gotNumber = [scanner scanHexInt:&charCode];
            }
            else {
                gotNumber = [scanner scanInt:(int*)&charCode];
            }
			
            if (gotNumber) {
                [result appendFormat:@"%C", charCode];
				
				[scanner scanString:@";" intoString:NULL];
            }
            else {
                NSString *unknownEntity = @"";
				
				[scanner scanUpToCharactersFromSet:boundaryCharacterSet intoString:&unknownEntity];
				
				[result appendFormat:@"&#%@%@", xForHex, unknownEntity];
            }
			
        }
        else
		{
			NSString *amp = nil;
			[scanner scanString:@"&" intoString:&amp];      //an isolated & symbol
			[result appendString:amp];
        }
		
    }
    while (![scanner isAtEnd]);
	
finish:
    return result;
}

+ (id)autodetectAndParseURL:(NSString *)urlString feedObject:(NSManagedObject *)feed
{
	return [self autodetectAndParseURL:urlString feedObject:feed allowHTMLIndirection:YES];
}
+ (id)autodetectAndParseURL:(NSString *)urlString feedObject:(NSManagedObject *)feed allowHTMLIndirection:(BOOL)allowHTMLIndirection
{
	if (![urlString length])
		return nil;
	
	NSLog(@"Autodetect and parse URL = %@", urlString);
	
	//Sanatize the URL
	if (![urlString isMatchedByRegex:@"^[A-Za-z_\\-]+://"])
	{
		urlString = [@"http://" stringByAppendingString:urlString];
	}
	NSLog(@"\t urlString = '%@'", urlString);
	
	//FIXME: Use NSURLConnection throughout to handle redirects
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSLog(@"\t url = '%@'", url);
	
	NSStringEncoding stringEncoding = NSUTF8StringEncoding;
	NSError *err = nil;
	NSString *string = [NSString stringWithContentsOfURL:url usedEncoding:&stringEncoding error:&err];
	NSLog(@"\t [string length] = '%d'", [string length]);
	NSLog(@"\t err = '%@'", err);
	if (err || ![string length])
	{
		return nil;
	}
	
	//This is either: a) an atom feed, b) an rss feed or c) an html document pointing to a feed
	
	//RSS
	if ([string isMatchedByRegex:@"<rss\\b"])
	{
		NSLog(@"Matched rss");
		HERSSParser *parser = [[HERSSParser alloc] init];
		parser.stringContents = string;
		return parser;
	}
	
	//Atom
	else if ([string isMatchedByRegex:@"<feed\\b"])
	{
		NSLog(@"Matched feed");
		HEAtomParser *parser = [[HEAtomParser alloc] init];
		parser.stringContents = string;
		return parser;
	}
	
	//HTML
	else if (allowHTMLIndirection)
	{
		//<\s*link.+?type\s*=\s*("|')application/rss(\+xml)?("|')[^>]*>
		
		//application/(rss/atom)\+xml
		
		//href=("|')([^"']+)("|')
		
		//Extract a link tag
		NSString *linkTag = [string stringByMatching:@"<\\s*link[^>]+type\\s*=\\s*(\"|')application/(atom|rss)(\\+xml)?(\"|')[^>]*>"];
		NSLog(@"\t linkTag = %@", linkTag);
		
		//Extract the href
		NSArray *components = [linkTag captureComponentsMatchedByRegex:@"href=(\"|')([^\"']+)(\"|')"];
		NSLog(@"\t components = %@", components);
		if ([components count] == 4)
		{
			NSMutableString *href = [self decodingXMLEntitiesInString:[components objectAtIndex:2]];
			
			//Parse the linked file, but don't allow another HTML file (otherwise we could end up with an infinite loop)
			return [self autodetectAndParseURL:[[NSURL URLWithString:href relativeToURL:url] absoluteString] feedObject:feed allowHTMLIndirection:NO];
		}
	}
	
	NSLog(@"Nothing?");
	
	//NSLog(@"Nothing? %@", string);

	
	return nil;
}
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
	NSXMLDocument *xml = nil;
	if ([stringContents length])
	{
		xml = [[NSXMLDocument alloc] initWithXMLString:stringContents options:NSXMLDocumentTidyXML error:&err];
	}
	else
	{
		xml = [[NSXMLDocument alloc] initWithContentsOfURL:url options:NSXMLDocumentTidyXML error:&err];
	}
	
	//NSLog(@"Parsing = %@", xml);
	
	if (err || !xml)
	{
		NSLog(@"Error parsing XML document: %@", err);
		return;
	}
	
	[self parseXML:xml intoContext:ctx];
}

- (void)parseXML:(NSXMLDocument *)xml intoContext:(NSManagedObjectContext *)ctx
{
	@throw [NSException exceptionWithName:NSGenericException reason:@"Abstract method -[HEParser parseXML:intoContext:] called. Subclasses should override this." userInfo:[NSDictionary dictionary]];
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
