//
//  Event.h
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

@class Log;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSNumber * eventCode;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *logs;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addLogsObject:(Log *)value;
- (void)removeLogsObject:(Log *)value;
- (void)addLogs:(NSSet *)values;
- (void)removeLogs:(NSSet *)values;

@end
