//
//  Log.h
//  Autista
//
//  Created by Shashwat Parhi on 1/27/13.
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
