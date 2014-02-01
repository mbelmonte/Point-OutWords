//
//  AppDelegate.h
//  Autista
//
//  Created by Shashwat Parhi on 9/15/12.
//  Copyright (c) 2012 Shashwat Parhi
//
//  This file is part of Autista.
//  
//  Autista is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  Autista is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  To view the GNU General Public License, visit <http://www.gnu.org/licenses/>.
//

#import <UIKit/UIKit.h>
#import "TestFlight.h"

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
