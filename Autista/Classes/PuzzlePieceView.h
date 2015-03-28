//
//  PuzzlePieceView.h
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

/**
 *  The view controller for each puzzle piece.
 */

#import <UIKit/UIKit.h>

@class SoundEffect;

@interface PuzzlePieceView : UIImageView {
	SoundEffect *_pieceSelectedSound;
	SoundEffect *_pieceReleasedSound;
}
/**-----------------------------------------------------------------------------
 * @name Properties
 * -----------------------------------------------------------------------------
 */
/**
 *  Title for the puzzle piece.
 *  Required while logging user activity on this piece
 */
@property (nonatomic, assign) NSString *title;
/**
 *  Initial point of the puzzle piece
 */
@property (nonatomic, assign) CGPoint initialPoint;
/**
 *  Final point of the puzzle piece
 */
@property (nonatomic, assign) CGPoint finalPoint;

@property (nonatomic, assign) BOOL isCompleted;
/**
 *  The syllable current puzzle piece is associated with
 */
@property (nonatomic, assign) NSInteger belongsToSyllable;

/**-----------------------------------------------------------------------------
 * @name Sound effect handling
 * -----------------------------------------------------------------------------
 */
/**
 *  Setup sound effects from file
 */
- (void)setupSounds;
- (IBAction)playPieceSelectedSound;
- (IBAction)playPieceReleasedSound;

/**-----------------------------------------------------------------------------
 * @name Touch event handling
 * -----------------------------------------------------------------------------
 */
/**
 *
 *
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
