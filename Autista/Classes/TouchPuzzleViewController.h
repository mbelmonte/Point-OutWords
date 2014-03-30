//
//  TouchPuzzleViewController.h
//  Autista
//
//  Created by Shashwat Parhi on 10/20/12.
//  Copyright (c) 2012 Shashwat Parhi
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
/**
 *  View controller handling puzzles in touch mode
 */

@class PuzzleObject;
@class PuzzlePieceView;
@class GlobalPreferences;
@class SoundEffect;
@class TypeBanner;
@class AdminViewController;

@interface TouchPuzzleViewController : UIViewController {
	GlobalPreferences *_prefs;
	BOOL _launchedInGuidedMode;
    BOOL _backButtonPressed;
	
	PuzzlePieceView *_draggedPiece;
	PuzzlePieceView *_pieceTrackedByLoopDetector;
	NSInteger _loopDetectorCount;
	NSInteger _autoCompletedPieces;
    CGFloat SNAP_DISTANCE;
	
    TypeBanner *_banner;
	IBOutlet UILabel *titleLabel;

	CGPoint _pieceTouchedAtPoint;
	CGPoint _lastLoggedPoint;
	
	SoundEffect *_pieceSelectedSound;
	SoundEffect *_pieceReleasedSound;
	SoundEffect *_piecePlacedSound;
	SoundEffect *_pieceReturnedSound;
	SoundEffect *_puzzleCompletedSuccessfullySound;
	
	AVAudioPlayer *_wordPlayer;
	NSTimer *_adminOverlayTimer;
    NSTimer *_backOverlayTimer;
	AdminViewController *_adminVC;
}
/**-----------------------------------------------------------------------------
 * @name Properties
 * -----------------------------------------------------------------------------
 */
/**
 *  
 */
@property (nonatomic, retain) PuzzleObject *object;
/**
 *  Array of all puzzle pieces.
 */
@property (nonatomic, retain) NSMutableArray *pieces;
/**
 *  Sound to be played when puzzle finished
 */
@property (nonatomic, retain) AVAudioPlayer *finishPrompt;

@property (nonatomic, retain) IBOutlet UIImageView *background;
@property (nonatomic, retain) IBOutlet UIImageView *placeHolder;
@property MPMusicPlayerController *myPlayer;

/**-----------------------------------------------------------------------------
 * @name Handling admin panel interations
 * -----------------------------------------------------------------------------
 */
/**
 */
- (void)showAdminOverlay;


- (IBAction)handleAdminButtonPressed:(id)sender;
- (IBAction)handleAdminButtonReleased:(id)sender;

/**-----------------------------------------------------------------------------
 * @name Handling admin panel interations
 * -----------------------------------------------------------------------------
 */
/**
 *  Handling back button
 */
- (IBAction)handleBackButtonPressed:(id)sender;
- (IBAction)handleBackButtonReleased:(id)sender;
- (void)showBackOverlay;

- (void)initializePuzzleState;
- (void)randomizeInitialPositionsOfPieces;

/**-----------------------------------------------------------------------------
 * @name Handling sound effects
 * -----------------------------------------------------------------------------
 */
/**
 *  Setup sound effects
 */
- (void)setupSounds;
- (IBAction)playPieceSelectedSound;
- (IBAction)playPieceReleasedSound;
- (IBAction)playPiecePlacedSound;
- (IBAction)playPieceReturnedSound;
- (IBAction)playPuzzleCompletedSuccessfullySound;
- (void)playObjectTitleSound;

/**-----------------------------------------------------------------------------
 * @name Handling gestures
 * -----------------------------------------------------------------------------
 */
/**
 *
 *
 */
- (void)handleTapGesture:(UITapGestureRecognizer *)gesture;
- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture;

/**-----------------------------------------------------------------------------
 * @name Puzzle piece handling
 * -----------------------------------------------------------------------------
 */
/**
 *  Show animation when puzzle complete
 */
- (void)presentPuzzleCompletionAnimation;
/**
 *  Snap the puzzle piece to the correct position
 *
 *  @param piece the puzzle piece to be snapped
 */
- (void)snapPieceToFinalPosition:(PuzzlePieceView *)piece;
/**
 *  Suggest a frame for the puzzle piece
 *
 *  @param piece puzzle piece
 *
 *  @return a frame based on the puzzle piece's coodination
 */

- (CGRect)suggestSuitableFrameForPiece:(UIView *)piece;
/**
 *  Check if a puzzle is completed
 */
- (void)checkPuzzleState;
- (void)promptAndFinish;
/**
 *  Hit test to determine the puzzle piece touched
 *
 *  @param touchPoint point touched
 *
 *  @return puzzle piece
 */
- (PuzzlePieceView *)hitTest:(CGPoint)touchPoint;
- (void)delayedDismissSelf;


@end
