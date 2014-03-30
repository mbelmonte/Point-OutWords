//
//  TypePuzzleViewController.h
//  Autista
//
//  Created by Shashwat Parhi on 10/22/12.
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

@class PuzzleObject;
@class PuzzlePieceView;
@class TypeBanner;
@class GlobalPreferences;
@class SoundEffect;
@class AdminViewController;

/**
 *  View controller handling puzzles in type mode
 */
@interface TypePuzzleViewController : UIViewController {
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
 *
 */
@property (nonatomic, retain) PuzzleObject *object;
/**
 *  Puzzle pieces
 */
@property (nonatomic, retain) NSMutableArray *pieces;
/**
 *  Sounds to be played when puzzle finished
 */
@property (nonatomic, retain) AVAudioPlayer *finishPrompt;

@property (nonatomic, retain) IBOutlet UIImageView *background;
@property (nonatomic, retain) IBOutlet UIImageView *placeHolder;
@property (nonatomic, retain) IBOutlet UIView *keyboard;

/**-----------------------------------------------------------------------------
 * @name Properties
 * -----------------------------------------------------------------------------
 */
/**
 *  <#Description#>
 *
 *  @param sender <#sender description#>
 */
- (IBAction)playKeyClickSound:(id)sender;
- (IBAction)handleKeyPressed:(id)sender;
/**-----------------------------------------------------------------------------
 * @name Handling admin panel interations
 * -----------------------------------------------------------------------------
 */
/**
 *  <#Description#>
 *
 *  @param sender <#sender description#>
 */
/**
 *
 */
- (void)showAdminOverlay;
- (IBAction)handleAdminButtonPressed:(id)sender;
- (IBAction)handleAdminButtonReleased:(id)sender;

- (IBAction)handleBackButtonPressed:(id)sender;
- (IBAction)handleBackButtonReleased:(id)sender;

@end
