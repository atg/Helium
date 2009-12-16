//
//  Helium_AppDelegate.h
//  Helium
//
//  Created by Alex Gordon on 15/12/2009.
//  Copyright __MyCompanyName__ 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HERefresher;

@interface Helium_AppDelegate : NSObject<NSApplicationDelegate>
{    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	NSManagedObjectContext *managedObjectContextForBackgroundRefresh;
	
	NSMutableArray *readerWindowControllers;
	
	HERefresher *refresher;
}

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@property (readonly) HERefresher *refresher;

- (IBAction)saveAction:sender;

- (NSManagedObjectContext *)managedObjectContextForBackgroundRefresh;

@end
