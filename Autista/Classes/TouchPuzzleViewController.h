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

@property (nonatomic, retain) PuzzleObject *object;
@property (nonatomic, retain) NSMutableArray *pieces;
@property (nonatomic, retain) AVAudioPlayer *finishPrompt;

@property (nonatomic, retain) IBOutlet UIImageView *background;
@property (nonatomic, retain) IBOutlet UIImageView *placeHolder;

@property MPMusicPlayerController *myPlayer;

- (IBAction)handleAdminButtonPressed:(id)sender;
- (IBAction)handleAdminButtonReleased:(id)sender;
- (IBAction)handleBackButtonPressed:(id)sender;
- (IBAction)handleBackButtonReleased:(id)sender;

@end
