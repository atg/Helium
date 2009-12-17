//
//  HEApplicationDelegate.h
//  Helium
//
//  Created by Alex Gordon on 15/12/2009.
//  Copyright __MyCompanyName__ 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HERefresher;
@class HEPreferencesWindowController;
@class HEReaderWindowController;

@interface HEApplicationDelegate : NSObject<NSApplicationDelegate>
{    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	NSManagedObjectContext *managedObjectContextForBackgroundRefresh;
	
	NSMutableArray *readerWindowControllers;
	
	HEPreferencesWindowController *preferencesController;
	
	HERefresher *refresher;
}

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@property (readonly) HERefresher *refresher;

- (IBAction)saveAction:sender;

- (IBAction)showPreferences:(id)sender;

- (IBAction)newReaderWindow:(id)sender;
- (void)readerWillClose:(HEReaderWindowController *)reader;

- (NSManagedObjectContext *)managedObjectContextForBackgroundRefresh;

@end
