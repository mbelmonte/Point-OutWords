//
//  TypePuzzleViewController.h
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMotion/CoreMotion.h>

@class PuzzleObject;
@class PuzzlePieceView;
@class TypeBanner;
@class GlobalPreferences;
@class SoundEffect;
@class AdminViewController;

/**
 *  View controller handling puzzles in type mode
 */
@interface TypePuzzleViewController : UIViewController <UIGestureRecognizerDelegate> {
	GlobalPreferences *_prefs;
	BOOL _launchedInGuidedMode;
	BOOL _backButtonPressed;
	BOOL _puzzleComplete;
    
	IBOutlet UIButton *AKey;
	IBOutlet UIButton *BKey;
	IBOutlet UIButton *CKey;
	IBOutlet UIButton *DKey;
	IBOutlet UIButton *EKey;
	IBOutlet UIButton *FKey;
	IBOutlet UIButton *GKey;
	IBOutlet UIButton *HKey;
	IBOutlet UIButton *IKey;
	IBOutlet UIButton *JKey;
	IBOutlet UIButton *KKey;
	IBOutlet UIButton *LKey;
	IBOutlet UIButton *MKey;
	IBOutlet UIButton *NKey;
	IBOutlet UIButton *OKey;
	IBOutlet UIButton *PKey;
	IBOutlet UIButton *QKey;
	IBOutlet UIButton *RKey;
	IBOutlet UIButton *SKey;
	IBOutlet UIButton *TKey;
	IBOutlet UIButton *UKey;
	IBOutlet UIButton *VKey;
	IBOutlet UIButton *WKey;
	IBOutlet UIButton *XKey;
	IBOutlet UIButton *YKey;
	IBOutlet UIButton *ZKey;
	
	NSArray *_keys;
	
	NSInteger _loopDetectorCount;
	NSInteger _currentLetterPosition;
	NSInteger _autoCompletedPieces;
	
	TypeBanner *_banner;
	IBOutlet UILabel *titleLabel;
	
	SoundEffect *_keyClickSound;
	SoundEffect *_correctKeyPressedSound;
	SoundEffect *_wrongKeyPressedSound;
	SoundEffect *_puzzleCompletedSuccessfullySound;
	
	AVAudioPlayer *_alphabetPlayer;
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

@property CAShapeLayer *pathLayer;

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
/**
 *  Keyborad event outlet
 */
@property (nonatomic, retain) IBOutlet UIView *keyboard;

@property (strong, nonatomic) CMMotionManager *motionManager;


@property NSMutableArray *animationPathLayerArray;
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
- (IBAction)playKeyClickSound:(id)sender;
- (IBAction)playCorrectKeyPressedSound;
- (IBAction)playWrongKeyPressedSound;
- (IBAction)playPuzzleCompletedSuccessfullySound;
/**
 *  Stop myPlayer from playing.
 */
- (void)stopPlaying;

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
 * @name Initlizing the puzzle
 * -----------------------------------------------------------------------------
 */
/**
 *  Initialize the puzzle and setup puzzle detail, like all pieces' positions and puzzle title
 */
- (void)initializePuzzleState;
//Make TYPE mode closer to POINT mode to ensure smoother transition from POINT to TYPE
- (void)randomizeInitialPositionsOfPieces;

-(void)addCharacterOnPuzzlePiece;


/**-----------------------------------------------------------------------------
 * @name Handling puzzle keyboard interactions
 * -----------------------------------------------------------------------------
 */
/**
 *  Get the keys associated with the current puzzle, handle keypressing events and give user feedbacks(animations, ).
 */
- (IBAction)handleKeyPressed:(id)sender;
- (void)advanceToNextLetterPosition;

- (void)slideOutKeyboard;
- (void)slideInKeyboard;

/**
 *  Set up an animation to hightlight the character on the keyboard,
 *  remind the user to type the keyboard instead of dragging the puzzle pieces
 *  Call changeBGColorBack to change the background of the keys back at the end of the animation
 *
 *  @param recognizer gesture recognizor
 */
- (void)remindAnimation:(UIGestureRecognizer *)recognizer;
/**
 *  Change background color back
 */
- (void)changeBGColorBack;
/**
 *  Get the key corresponding to a character's ASCII code
 *
 *  @param asciiCode ASCII code for a character
 *
 *  @return Pointer the correct button
 */
- (UIButton *)buttonFromASCIICode:(NSInteger)asciiCode;


/**-----------------------------------------------------------------------------
 * @name Handling puzzle gesture interactions
 * -----------------------------------------------------------------------------
 */
/**
 *  Delegate function used to recognize key strokes from the point of departure on the touch-screen.
 *
 *  @param touches a set
 *  @param event   event delegate
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;


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
 *  Dismiss the current view and log down event
 */
- (void)delayedDismissSelf;


/**-----------------------------------------------------------------------------
 * @name Image manipulation methods
 * -----------------------------------------------------------------------------
 */
/**
 *
 */
- (void)applyShadowToObject:(UIView *)object;
- (void)applyGlowToObject:(UIView *)object;
- (void)removeGlowFromObject:(UIView *)object;

- (IBAction)handleKeyPressed:(id)sender;

@end
