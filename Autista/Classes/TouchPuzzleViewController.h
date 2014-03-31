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
	/**
	 *  How many times a use has tried to place a puzzle piece
	 */
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
 *  The object that stores the current puzzle
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
/**
 *  Music player to play recorded sound effects and music from the library
 */
@property MPMusicPlayerController *myPlayer;
/**
 *  Background image
 */
@property (nonatomic, retain) IBOutlet UIImageView *background;
/**
 *  Placholder image for all puzzle frames
 */
@property (nonatomic, retain) IBOutlet UIImageView *placeHolder;


/**-----------------------------------------------------------------------------
 * @name Handling admin panel interations
 * -----------------------------------------------------------------------------
 */

/**
 *  When admin button is pressed, start a timer to show the admin overlay after 2s
 */
- (IBAction)handleAdminButtonPressed:(id)sender;
/**
 *  When admin button is released, invalidate the timer
 */
- (IBAction)handleAdminButtonReleased:(id)sender;
/**
 *  Show the admin overlay
 */
- (void)showAdminOverlay;

/**-----------------------------------------------------------------------------
 * @name Handling back button interations
 * -----------------------------------------------------------------------------
 */
/**
 * When back button is pressed, start a timer to show the admin overlay after 2s
 */
- (IBAction)handleBackButtonPressed:(id)sender;
/**
 *  When back button is released, release the timer
 */
- (IBAction)handleBackButtonReleased:(id)sender;
/**
 *  Call delayedDismissSelf to dismiss the current view controller and log puzzle completion status
 */
- (void)showBackOverlay;

/**-----------------------------------------------------------------------------
 * @name Handling sound effects
 * -----------------------------------------------------------------------------
 */
/**
 *  Play the sound of the puzzle title, e.g. Bath. Load the sound file based on puzzle name
 */
- (void)playObjectTitleSound;
/**
 *   Load sound files into SoundEffect objects, and hold on to them for later use
 */
- (void)setupSounds;
- (IBAction)playPieceSelectedSound;
- (IBAction)playPieceReleasedSound;
- (IBAction)playPiecePlacedSound;
- (IBAction)playPieceReturnedSound;
- (IBAction)playPuzzleCompletedSuccessfullySound;
/**
 *  Stop myPlayer from playing.
 */
- (void)stopPlaying;

/**-----------------------------------------------------------------------------
 * @name Initlizing the puzzle
 * -----------------------------------------------------------------------------
 */

/**
 *  Initialize the puzzle and setup puzzle detail, like all pieces' positions and puzzle title
 */
- (void)initializePuzzleState;
/**
 *  Randomize the locations for puzzle pieces.
 */
- (void)randomizeInitialPositionsOfPieces;

/**-----------------------------------------------------------------------------
 * @name Handling puzzle gesture interactions
 * -----------------------------------------------------------------------------
 */
/**
 *  Handle tap gesture. Determine whether a puzzle piece is slected after the adjustment of _prefs.selectDistance
 *  @param gesture the gesture recognizer of tap gesture
 */

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture;
/**
 *  Handle pan gesture - dragging puzzle piece. Determine which puzzle piece is being dragged 
 *  and snap the piece to correct frame with method snapPieceToFinalPosition:
 *  @param gesture the gesture recognizer of pan gesture
 */
- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture;
/**
 *  Snap the puzzle piece to the correct frame based on snapping distance.
 *
 *  @param piece the puzzle piece to be snapped
 */
- (CGRect)suggestSuitableFrameForPiece:(UIView *)piece;


/**-----------------------------------------------------------------------------
 * @name Handling puzzle completion
 * -----------------------------------------------------------------------------
 */
/**
 *  Check if a puzzle is completed
 */
- (void)checkPuzzleState;
/**
 *  Show animation when puzzle complete
 */
- (void)presentPuzzleCompletionAnimation;
/**
 *  Play sound when a puzzle is completed. 
 *  Choose correct sound based on the difficulties:
 *
 *  - Easy (<10) - WellDone;
 *  - Medium (10-12) - Super, Yay;
 *  - Difficult (>12) - GoodJob, Awesome;
 */
- (void)promptAndFinish;
/**
 *  Hit test to determine the puzzle piece touched
 *
 *  @param touchPoint point touched
 *
 *  @return puzzle piece
 */
- (PuzzlePieceView *)hitTest:(CGPoint)touchPoint;
/**
 *  Dismiss the current view and log down event
 */
- (void)delayedDismissSelf;


@end
