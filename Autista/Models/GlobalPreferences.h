//
//  GlobalPreferences.h
//  Units
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
 *  Store global accessible seetings
 *
 */

#import <UIKit/UIKit.h>

@interface GlobalPreferences : NSObject
/**-----------------------------------------------------------------------------
 * @name Properties
 * -----------------------------------------------------------------------------
 */

/**
* App version stored in prefs
*/
@property (nonatomic, retain) NSString *prefsVersion;

@property (nonatomic, assign) BOOL betaTesting;
@property (nonatomic, assign) BOOL backgroundMusicEnabled;
@property (nonatomic, assign) BOOL guidedModeEnabled;
@property (nonatomic, assign) BOOL snapBackEnabled;
@property (nonatomic, assign) BOOL praisePromptEnabled;
@property (nonatomic, assign) BOOL keyHighlightingEnabled;
@property (nonatomic, assign) BOOL audioLevelsVisible;
@property (nonatomic, assign) BOOL sceneCompletionStatusVisible;
@property (nonatomic, assign) BOOL sendAnonymousData;

@property (nonatomic, assign) CGFloat snapDistance;
@property (nonatomic, assign) CGFloat selectDistance;
@property (nonatomic, assign) CGFloat ampThresh;
@property (nonatomic, assign) CGFloat dragPuzzleFrequency;
@property (nonatomic, assign) CGFloat typePuzzleFrequency;
@property (nonatomic, assign) CGFloat speakPuzzleFrequency;
@property (nonatomic, assign) CGFloat sayModeDifficulty;

@property (nonatomic, assign) CGFloat typeSignificancy;

@property (nonatomic, assign) NSInteger *whetherRecordVoice;
@property (nonatomic, assign) NSInteger *whetherRecordActivity;

/**-----------------------------------------------------------------------------
 * @name Data manipulation methods
 * -----------------------------------------------------------------------------
 */
/**
 *  Set up shared instance of global preferences
 *
 *  @return sharedObject
 */
+ (GlobalPreferences *)sharedGlobalPreferences;

/**
 *  Save current preferences state
 */
- (void)saveState;

/**
 *  Forget all preferences state
 */
- (void)forgetState;

/**
 *  Restore preferences from saved state
 */
- (void)restoreFromSavedState;

/**
 *  Reset preferences to factory defaults
 */
- (void)resetToFactoryDefaults;

/**
 *  Save all preferences to a dictionary
 *
 *  @return settingsDict
 */
- (NSDictionary *)packagedSettings;											// return a dictionary of all the settings

@end
