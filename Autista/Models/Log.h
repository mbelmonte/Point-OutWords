//
//  Log.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, User;

@interface Log : NSManagedObject

@property (nonatomic, retain) NSNumber * absoluteTime;
@property (nonatomic, retain) NSString * appState;
@property (nonatomic, retain) NSNumber * timeSinceLaunch;
@property (nonatomic, retain) NSString * eventInfo;
@property (nonatomic, retain) NSString * appSettings;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) User *user;

@end
