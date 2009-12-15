//
//  HERSSDateParser.m
//  Helium
//

#import "HERSSDateParser.h"


NSDate *HEParseRSSDateString(NSString *dateString)
{
	int yearValue = 0;
	int monthValue = 1;
	int dayValue = 0;
	int hourValue = 0;
	int minuteValue = 0;
	int secondValue = 0;
	int tzOffset = 0;
	
	// Let CURL have a crack at parsing since it knows all about the
	// RSS/HTTP formats. Add a hack to substitute UT with GMT as it doesn't
	// seem to be able to parse the former.

	dateString = [dateString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	unsigned int dateLength = [dateString length];
	if ([dateString hasSuffix:@" UT"])
		dateString = [[dateString substringToIndex:dateLength - 3] stringByAppendingString:@" GMT"];
	// CURL seems to require seconds in the time, so add seconds if necessary.
	NSScanner * scanner = [NSScanner scannerWithString:dateString];
	if ([scanner scanUpToString:@":" intoString:NULL])
	{
		unsigned int location = [scanner scanLocation] + 3u;
		if ((location < dateLength) && [dateString characterAtIndex:location] != ':')
		{
			dateString = [NSString stringWithFormat:@"%@:00%@", [dateString substringToIndex:location], [dateString substringFromIndex:location]];
			scanner = [NSScanner scannerWithString:dateString];
		}
	}
	
#if 0
	NSCalendarDate * curlDate = [CurlGetDate getDateFromString:dateString];
	if (curlDate != nil)
		return curlDate;
#endif
	
	// Otherwise do it ourselves.
	[scanner setScanLocation:0u];
	if (![scanner scanInt:&yearValue])
		return nil;
	if (yearValue < 100)
		yearValue += 2000;
	if ([scanner scanString:@"-" intoString:nil])
	{
		if (![scanner scanInt:&monthValue])
			return nil;
		if (monthValue < 1 || monthValue > 12)
			return nil;
		if ([scanner scanString:@"-" intoString:nil])
		{
			if (![scanner scanInt:&dayValue])
				return nil;
			if (dayValue < 1 || dayValue > 31)
				return nil;
		}
	}
	
	// Parse the time portion.
	// (I discovered that GMail sometimes returns a timestamp with 24 as the hour
	// portion although this is clearly contrary to the RFC spec. So be
	// prepared for things like this.)
	if ([scanner scanString:@"T" intoString:nil])
	{
		if (![scanner scanInt:&hourValue])
			return nil;
		hourValue %= 24;
		if ([scanner scanString:@":" intoString:nil])
		{
			if (![scanner scanInt:&minuteValue])
				return nil;
			if (minuteValue < 0 || minuteValue > 59)
				return nil;
			if ([scanner scanString:@":" intoString:nil] || [scanner scanString:@"." intoString:nil])
			{
				if (![scanner scanInt:&secondValue])
					return nil;
				if (secondValue < 0 || secondValue > 59)
					return nil;
				// Drop any fractional seconds
				if ([scanner scanString:@"." intoString:nil])
				{
					if (![scanner scanInt:nil])
						return nil;
				}
			}
		}
	}
	else
	{
		// If no time is specified, set the time to 11:59pm,
		// so new articles within the last 24 hours are detected.
		hourValue = 23;
		minuteValue = 59;
	}
	
	// At this point we're at any potential timezone
	// tzOffset needs to be the number of seconds since GMT
	if ([scanner scanString:@"Z" intoString:nil])
		tzOffset = 0;
	else if (![scanner isAtEnd])
	{
		if (![scanner scanInt:&tzOffset])
			return nil;
		if (tzOffset > 12)
			return nil;
	}
	
	// Now combine the whole thing into a date we know about.
	NSTimeZone * tzValue = [NSTimeZone timeZoneForSecondsFromGMT:tzOffset * 60 * 60];
	
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	[dateComponents setYear:yearValue];
	[dateComponents setMonth:monthValue];
	[dateComponents setDay:dayValue];
	[dateComponents setHour:hourValue];
	[dateComponents setMinute:minuteValue];
	[dateComponents setSecond:secondValue];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[gregorian setTimeZone:tzValue];
	
	return [gregorian dateFromComponents:dateComponents];
}
