//
//  SayPuzzleViewController.h
//  Autista
//
//  Created by Shashwat Parhi on 11/26/12.
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
/**
 *  View controller handling puzzles in say mode
 */
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioSession.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <UIKit/UIKit.h>
#import <OpenEars/LanguageModelGenerator.h>
#import <OpenEars/AcousticModel.h>
#import <OpenEars/OpenEarsEventsObserver.h>
#import <OpenEars/PocketsphinxController.h>
#import <MediaPlayer/MediaPlayer.h>

@class VULevelMeter;
@class PuzzleObject;
@class PuzzlePieceView;
@class TypeBanner;
@class SoundEffect;
@class GlobalPreferences;
@class AdminViewController;

@interface SayPuzzleViewController : UIViewController<OpenEarsEventsObserverDelegate> {
	GlobalPreferences *_prefs;
	BOOL _launchedInGuidedMode;
	BOOL _backButtonPressed;
    
    AVAudioSession *audioSession;
	AVAudioRecorder *recorder;
	NSTimer *levelTimer;
	NSTimer *timeOutTimer;
	double lowPassResults;
    CGFloat UPPER_THRESHOLD;
    CGFloat DBOFFSET;
    CGFloat LOWER_THRESHOLD;
	
	IBOutlet VULevelMeter *vuMeter;
	IBOutlet TypeBanner *_banner;
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *syllLabel;
	IBOutlet UIImageView *sayNa;
	
	PuzzlePieceView *_currentPiece;
	NSInteger _currentSyllable;
	
	BOOL waitingForSilence;
    BOOL _soundsMissing;
	
	SoundEffect *_puzzleCompletedSuccessfullySound;
    //RD
    SoundEffect *_promptSound;
    NSMutableArray *_syllableSounds;
    NSMutableArray *_syllableURLs;
	
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


@property (nonatomic, retain) NSArray *syllables;
@property (nonatomic, retain) NSArray *phonetics;
@property (nonatomic, retain) AVQueuePlayer *qplayer;

@property (nonatomic, retain) AVPlayerItem * sayItem;
@property (nonatomic, retain) AVPlayerItem * firstSyllItem;

@property (strong, nonatomic) IBOutlet UILabel *recognizerFeedback;
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

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
/**
 *  Stop myPlayer from playing.
 */
- (void)stopPlaying;
- (IBAction)playPuzzleCompletedSuccessfullySound;

/**-----------------------------------------------------------------------------
 * @name Initlizing the puzzle
 * -----------------------------------------------------------------------------
 */

/**
 *  Initialize the puzzle and setup puzzle detail, like all pieces' positions and puzzle title
 */
- (void)initializePuzzleState;


/**-----------------------------------------------------------------------------
 * @name Handling speech recognition
 * -----------------------------------------------------------------------------
 */

-(Float32)audioVolume;
-(Float32)audioVolumeFac;

/**
 *  Setup the audio instruction for a puzzle
 */
- (void)initializeAudioEngine;
/**
 *  Start audio recording
 */
- (void)startRecordingEngine;
/**
 *  Start audio recognition
 */
- (void)startListening;
/**
 *  Setup speech recognizer
 */
- (void)levelTimerCallback:(NSTimer *)timer;
- (void)resumeRecognition;
/**
 *  After a syllable is completed, proceed to next syllable in the puzzle.
 */
- (void)advanceToNextSyllable;

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


- (IBAction)handlePassButtonPressed:(id)sender;


/**-----------------------------------------------------------------------------
 * @name OpenEars Delegate Methods
 * -----------------------------------------------------------------------------
 */
/**
 */
- (OpenEarsEventsObserver *)openEarsEventsObserver;
- (PocketsphinxController *)pocketsphinxController;

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID;
- (void) pocketsphinxDidStartCalibration;
- (void) pocketsphinxDidCompleteCalibration;
- (void) pocketsphinxDidStartListening;
- (void) pocketsphinxDidDetectSpeech;
- (void) pocketsphinxDidDetectFinishedSpeech;
- (void) pocketsphinxDidStopListening;
- (void) pocketsphinxDidSuspendRecognition;
- (void) pocketsphinxDidResumeRecognition;
- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString;
- (void) pocketSphinxContinuousSetupDidFail;
- (void) testRecognitionCompleted;
@end
