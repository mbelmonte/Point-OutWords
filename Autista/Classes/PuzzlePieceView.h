//
//  PuzzlePieceView.h
//  Autista
//
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
