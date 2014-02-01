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

#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioSession.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <UIKit/UIKit.h>

@class VULevelMeter;
@class PuzzleObject;
@class PuzzlePieceView;
@class TypeBanner;
@class SoundEffect;
@class GlobalPreferences;
@class AdminViewController;

@interface SayPuzzleViewController : UIViewController {
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

@property (nonatomic, retain) PuzzleObject *object;
@property (nonatomic, retain) NSMutableArray *pieces;
@property (nonatomic, retain) NSArray *syllables;
@property (nonatomic, retain) AVQueuePlayer *qplayer;
@property (nonatomic, retain) AVAudioPlayer *finishPrompt;
@property (nonatomic, retain) AVPlayerItem * sayItem;
@property (nonatomic, retain) AVPlayerItem * firstSyllItem;
@property (nonatomic, retain) IBOutlet UIImageView *background;
@property (nonatomic, retain) IBOutlet UIImageView *placeHolder;

- (void)levelTimerCallback:(NSTimer *)timer;
- (Float32)audioVolume;

- (IBAction)handleAdminButtonPressed:(id)sender;
- (IBAction)handleAdminButtonReleased:(id)sender;
- (IBAction)handleBackButtonPressed:(id)sender;
- (IBAction)handleBackButtonReleased:(id)sender;

@end
