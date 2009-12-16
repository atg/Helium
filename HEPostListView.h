//
//  HEPostListView.h
//  Helium
//
//  Created by Alex Gordon on 15/12/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@class HEPostListItemLayer;
@class HEPostListView;

@protocol HEPostListViewDelegate<NSObject>

- (void)postListSelectionDidChange:(HEPostListView *)listView;

@end


@interface HEPostListView : NSView
{
	NSMutableArray *posts;
	
	HEPostListItemLayer *selectedLayer;
	
	IBOutlet id<HEPostListViewDelegate> delegate;
}

@property (assign) id delegate;
@property (assign, setter=setSelectedLayer:) id selectedLayer;

@end