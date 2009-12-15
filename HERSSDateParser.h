//
//  HERSSDateParser.h
//  Helium
//

/* This function is taken from Vienna and is licenced under the Apache 2.0 licence.
   It has been slightly modified to use non-deprecated APIs.
 
 http://www.vienna-rss.org/
 
 http://www.apache.org/licenses/LICENSE-2.0.txt
 
 */

#import <Cocoa/Cocoa.h>

NSDate *HEParseRSSDateString(NSString *dateString);
