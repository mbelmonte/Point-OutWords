//
//  PuzzleObject.h
//  Autista
//
//  Created by Shashwat Parhi on 1/27/13.
//  Copyright (c) 2013 Shashwat Parhi
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
