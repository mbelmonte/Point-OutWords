//
//  User.h
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

@class Attempt, Log;

@interface User : NSManagedObject

@property (nonatomic, retain) NSDate * dob;
@property (nonatomic, retain) NSString * fullname;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSData * mugshot;
@property (nonatomic, retain) NSNumber * rankDrag;
@property (nonatomic, retain) NSNumber * rankSpeak;
@property (nonatomic, retain) NSNumber * rankType;
@property (nonatomic, retain) NSNumber * snapBackEnabled;
@property (nonatomic, retain) NSNumber * praisePromptEnabled;
@property (nonatomic, retain) NSNumber * snappingDistance;
@property (nonatomic, retain) NSNumber * keyHitRadius;
@property (nonatomic, retain) NSNumber * dragEnterEnabled;
@property (nonatomic, retain) NSSet *attempts;
@property (nonatomic, retain) NSSet *logs;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addAttemptsObject:(Attempt *)value;
- (void)removeAttemptsObject:(Attempt *)value;
- (void)addAttempts:(NSSet *)values;
- (void)removeAttempts:(NSSet *)values;

- (void)addLogsObject:(Log *)value;
- (void)removeLogsObject:(Log *)value;
- (void)addLogs:(NSSet *)values;
- (void)removeLogs:(NSSet *)values;

@end
