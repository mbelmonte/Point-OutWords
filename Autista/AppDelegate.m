
//  AppDelegate.m
//  Autista
//
//  Created by Shashwat Parhi on 9/15/12.
//  Copyright (c) 2014 The Groden Center, Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  To view the GNU General Public License, visit <http://www.gnu.org/licenses/>.
//

#import "AppDelegate.h"
#import "GlobalPreferences.h"
#import "User.h"
#import "Scene.h"
#import "PuzzleObject.h"
#import "Piece.h"
#import "Event.h"
#import "EventLogger.h"
#import "AutistaIAPHelper.h"
#import <AdSupport/AdSupport.h>
#import <Instabug/Instabug.h>

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup TestFlight
    [TestFlight setDeviceIdentifier:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    [TestFlight takeOff:@"720f99b3-598b-4635-af66-c4416aae61ad"];
    // Use this option to notifiy beta users of any updates
    //[TestFlight setOptions:@{ TFOptionDisableInAppUpdates : @YES }];
   
    [Instabug KickOffWithToken:@"d0e8d2627d6e13ca2d1371fc175c479a" CaptureSource:InstabugCaptureSourceUIKit FeedbackEvent:InstabugFeedbackEventNone IsTrackingLocation:NO];
    
    [AutistaIAPHelper sharedInstance];
    
	_appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	_prefs = [GlobalPreferences sharedGlobalPreferences];
	
	[_prefs restoreFromSavedState];
	
	if (_prefs.prefsVersion == nil) {
		_runState = AppRunStateFirstRun;
		[self primeCoreDataStoreWithData];
		[self saveState];														// in case bad things happen after this point, we are at least covered
	}
	else if (![_appVersion isEqualToString:_prefs.prefsVersion]) {				// app has been updated...
		_runState = AppRunStateAppUpdated;
	}
	else {																		// at this point we know that Core Data has been primed and there is info in there
		_runState = AppRunStateNormal;
		[_prefs restoreFromSavedState];
		[self fetchCurrentUser];
	}
	
	[[EventLogger sharedLogger] logEvent:LogEventCodeAppLaunched eventInfo:nil];
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	
	[[EventLogger sharedLogger] logEvent:LogEventCodeAppExited eventInfo:nil];
	
	[self saveState];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	
	// here we copy over changes that may have been made in the Settings app while we were in the background
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	if ([userDefaults objectForKey:@"name_preference"] != nil)
		_currentUser.fullname = [[userDefaults objectForKey:@"name_preference"] capitalizedString];
	
	if ([userDefaults objectForKey:@"gender_preference"] != nil) {
		NSInteger genderValue = [[userDefaults objectForKey:@"gender_preference"] intValue];
		if (genderValue == 1)
			_currentUser.gender = @"Male";
		else if (genderValue == 2)
			_currentUser.gender = @"Female";
	}
	
	if ([userDefaults objectForKey:@"dob_preference"] != nil) {
		NSString *dob = [userDefaults objectForKey:@"dob_preference"];
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd"];
		_currentUser.dob = [formatter dateFromString:dob];
	}
	
	if ([userDefaults objectForKey:@"reset_userdata"] != nil) {
		if ([[userDefaults objectForKey:@"reset_userdata"] boolValue] == YES) {
			[self.managedObjectContext deleteObject:_currentUser];
			[self createUser];
		}
	}
	
	[[EventLogger sharedLogger] logEvent:LogEventCodeAppLaunched eventInfo:nil];
	
	[self saveContext];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Saves changes in the application's managed object context before the application terminates.
	[self saveContext];
}

- (void)fetchCurrentUser
{
	NSManagedObjectContext *context = self.managedObjectContext;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
	
	NSArray *users = [context executeFetchRequest:fetchRequest error:nil];
	_currentUser = [users objectAtIndex:0];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            TFLog(@"Unresolved error %@, %@", error, [error userInfo]);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Behavior" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //[alert addButtonWithTitle:@"Ok"];
            [alert show];
            //abort();
        } 
    }
}

- (void)saveState
{
	[_prefs saveState];
	[self saveContext];
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Autista" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Autista.sqlite"];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
	NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        TFLog(@"Unresolved error %@, %@", error, [error userInfo]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Behavior" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert addButtonWithTitle:@"Ok"];
        [alert show];
        //abort();
    }    
    
    return _persistentStoreCoordinator;
}

- (void)primeCoreDataStoreWithData
{
	NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"PuzzleDataWithPhonetics" ofType:@"plist"];
	NSArray *scenes = [NSArray arrayWithContentsOfFile:plistPath];
	
	[self createUser];
	
	for (NSDictionary *sceneDict in scenes) {
		Scene *scene = [self newManagedObjectWithEntity:@"Scene"];
		
		scene.title = [sceneDict valueForKey:@"title"];
		scene.sceneSelectorImage = UIImagePNGRepresentation([UIImage imageNamed:[sceneDict valueForKey:@"sceneSelectorImage"]]);
		scene.sceneBackgroundImage = UIImagePNGRepresentation([UIImage imageNamed:[sceneDict valueForKey:@"sceneBackgroundImage"]]);
		scene.puzzleBackgroundImage = UIImagePNGRepresentation([UIImage imageNamed:[sceneDict valueForKey:@"puzzleBackgroundImage"]]);
		scene.sceneMusicFilename = [sceneDict valueForKey:@"sceneMusicFilename"];
		
		NSArray *objects = [sceneDict valueForKey:@"objects"];
		
		for (NSDictionary *objectDict in objects) {
			PuzzleObject *object = [self newManagedObjectWithEntity:@"PuzzleObject"];
			
			object.title = [objectDict valueForKey:@"title"];
			object.syllables = [objectDict valueForKey:@"syllables"];
            object.phonetics = [objectDict valueForKey:@"phonetics"];
			object.completedImage = UIImagePNGRepresentation([UIImage imageNamed:[objectDict valueForKey:@"completedImage"]]);
			object.placeholderImage = UIImagePNGRepresentation([UIImage imageNamed:[objectDict valueForKey:@"placeholderImage"]]);
			object.difficultyDrag = [NSNumber numberWithFloat:[[objectDict valueForKey:@"difficultyDrag"] floatValue]];
			object.difficultyType = [NSNumber numberWithFloat:[[objectDict valueForKey:@"difficultyType"] floatValue]];
			object.difficultySpeak = [NSNumber numberWithFloat:[[objectDict valueForKey:@"difficultySpeak"] floatValue]];
			
			object.offsetX = [NSNumber numberWithFloat:[[objectDict valueForKey:@"offsetX"] floatValue]];
			object.offsetY = [NSNumber numberWithFloat:[[objectDict valueForKey:@"offsetY"] floatValue]];
			object.width = [NSNumber numberWithFloat:[[objectDict valueForKey:@"width"] floatValue]];
			object.height = [NSNumber numberWithFloat:[[objectDict valueForKey:@"height"] floatValue]];
			
			object.scene = scene;
			
			NSArray *pieces = [objectDict valueForKey:@"pieces"];
			
			for (NSDictionary *pieceDict in pieces) {
				Piece *piece = [self newManagedObjectWithEntity:@"Piece"];
				
				piece.label = [pieceDict valueForKey:@"label"];
				piece.imageName = [pieceDict valueForKey:@"imageName"];
				piece.pieceImage = UIImagePNGRepresentation([UIImage imageNamed:[pieceDict valueForKey:@"imageName"]]);
				
				piece.finalPositionX = [NSNumber numberWithFloat:[[pieceDict valueForKey:@"offsetX"] floatValue]];
				piece.finalPositionY = [NSNumber numberWithFloat:[[pieceDict valueForKey:@"offsetY"] floatValue]];
				
				piece.puzzleObject = object;
			}
		}
	}
	
	plistPath = [[NSBundle mainBundle] pathForResource:@"EventList" ofType:@"plist"];
	NSArray *events = [NSArray arrayWithContentsOfFile:plistPath];
	
	for (NSDictionary *eventDict in events) {
		Event *event = [self newManagedObjectWithEntity:@"Event"];
		event.eventCode = [eventDict valueForKey:@"eventCode"];
		event.title = [eventDict valueForKey:@"description"];
	}

	[self saveContext];
}

- (id)newManagedObjectWithEntity:(NSString *)entity
{
	return [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:self.managedObjectContext];
}

- (void)createUser
{
	_currentUser = [self newManagedObjectWithEntity:@"User"];
	
	_currentUser.snapBackEnabled = [NSNumber numberWithBool:NO];				// in drag mode, whether pieces snap back to original position if uncsuccessfully placed
    
    _currentUser.praisePromptEnabled = [NSNumber numberWithBool:NO];
    
	_currentUser.snappingDistance = [NSNumber numberWithFloat:210];				// snapping distance to destination
	_currentUser.dragEnterEnabled = [NSNumber numberWithBool:NO];				// whether a touch outside and drag into a piece should be considered valid or not
	_currentUser.keyHitRadius = [NSNumber numberWithFloat:27];					// in type mode, how big to make the hit area for a key press to be registered
	
	_currentUser.rankDrag = [NSNumber numberWithFloat:0];						// start off rankings at 0 and move up as user progresses
	_currentUser.rankType = [NSNumber numberWithFloat:0];
	_currentUser.rankSpeak = [NSNumber numberWithFloat:0];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
