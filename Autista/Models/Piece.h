//
//  Piece.h
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

@interface Piece : NSManagedObject

@property (nonatomic, retain) NSNumber * finalPositionX;
@property (nonatomic, retain) NSNumber * finalPositionY;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSString * imageName;
@property (nonatomic, retain) NSData * pieceImage;
@property (nonatomic, retain) PuzzleObject *puzzleObject;

@end
