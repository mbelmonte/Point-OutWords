//
//  User.h
//  Autista
//
//  Created by Shashwat Parhi on 1/31/13.
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
