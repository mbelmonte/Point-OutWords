//
//  Scene.h
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
