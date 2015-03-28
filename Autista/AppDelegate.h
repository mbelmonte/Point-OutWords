//
//  AppDelegate.h
//  Autista
//  Autista is a tablet application to help autistic children with speech
//  difficulties develop manual motor and oral motor skills.
//
//  Copyright (C) 2014 The Groden Center, Inc.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>

typedef enum {
	AppRUnStateUndefined = 0, AppRunStateNormal, AppRunStateFirstRun, AppRunStateAppUpdated, AppRunStateAppHadCrashed
} AppRunState;

@class User;
@class GlobalPreferences;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, assign) AppRunState runState;
@property (nonatomic, retain) User *currentUser;
@property (nonatomic, assign) GlobalPreferences *prefs;
@property (readonly, nonatomic, retain) NSString *appVersion;

- (void)saveState;
- (void)saveContext;
- (id)newManagedObjectWithEntity:(NSString *)entity;

- (NSURL *)applicationDocumentsDirectory;

@end
