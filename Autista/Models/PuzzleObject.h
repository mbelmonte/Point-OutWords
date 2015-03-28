//
//  PuzzleObject.h
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

@class Attempt, Piece, Scene;

@interface PuzzleObject : NSManagedObject

@property (nonatomic, retain) NSData * completedImage;
@property (nonatomic, retain) NSNumber * difficultyDrag;
@property (nonatomic, retain) NSNumber * difficultySpeak;
@property (nonatomic, retain) NSNumber * difficultyType;
@property (nonatomic, retain) NSNumber * dragWeight;
@property (nonatomic, retain) NSNumber * speakWeight;
@property (nonatomic, retain) NSNumber * typeWeight;
@property (nonatomic, retain) NSData * placeholderImage;
@property (nonatomic, retain) NSString * syllables;
@property (nonatomic, retain) NSString * phonetics;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * offsetX;
@property (nonatomic, retain) NSNumber * offsetY;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSSet *attempts;
@property (nonatomic, retain) NSSet *pieces;
@property (nonatomic, retain) Scene *scene;
@end

@interface PuzzleObject (CoreDataGeneratedAccessors)

- (void)addAttemptsObject:(Attempt *)value;
- (void)removeAttemptsObject:(Attempt *)value;
- (void)addAttempts:(NSSet *)values;
- (void)removeAttempts:(NSSet *)values;

- (void)addPiecesObject:(Piece *)value;
- (void)removePiecesObject:(Piece *)value;
- (void)addPieces:(NSSet *)values;
- (void)removePieces:(NSSet *)values;

@end
