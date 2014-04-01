//
//  Scene.h
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

@class PuzzleObject;

@interface Scene : NSManagedObject

@property (nonatomic, retain) NSData * puzzleBackgroundImage;
@property (nonatomic, retain) NSData * sceneSelectorImage;
@property (nonatomic, retain) NSData * sceneBackgroundImage;
@property (nonatomic, retain) NSString * sceneMusicFilename;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *puzzleObjects;
@end

@interface Scene (CoreDataGeneratedAccessors)

- (void)addPuzzleObjectsObject:(PuzzleObject *)value;
- (void)removePuzzleObjectsObject:(PuzzleObject *)value;
- (void)addPuzzleObjects:(NSSet *)values;
- (void)removePuzzleObjects:(NSSet *)values;

@end
