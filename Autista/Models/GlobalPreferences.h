//
//  GlobalPreferences.h
//  Units
//
//  Created by Shashwat Parhi on 12/21/12.
//  Copyright 2008 Deanza
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

@interface GlobalPreferences : NSObject

@property (nonatomic, retain) NSString *prefsVersion;						// app version stored in prefs

@property (nonatomic, assign) BOOL betaTesting;
@property (nonatomic, assign) BOOL backgroundMusicEnabled;
@property (nonatomic, assign) BOOL guidedModeEnabled;
@property (nonatomic, assign) BOOL snapBackEnabled;
@property (nonatomic, assign) BOOL keyHighlightingEnabled;
@property (nonatomic, assign) BOOL audioLevelsVisible;
@property (nonatomic, assign) BOOL sceneCompletionStatusVisible;
@property (nonatomic, assign) BOOL sendAnonymousData;

@property (nonatomic, assign) CGFloat snapDistance;
@property (nonatomic, assign) CGFloat ampThresh;
@property (nonatomic, assign) CGFloat dragPuzzleFrequency;
@property (nonatomic, assign) CGFloat typePuzzleFrequency;
@property (nonatomic, assign) CGFloat speakPuzzleFrequency;

+ (GlobalPreferences *)sharedGlobalPreferences;

- (void)saveState;
- (void)forgetState;
- (void)restoreFromSavedState;
- (void)resetToFactoryDefaults;

- (NSDictionary *)packagedSettings;											// return a dictionary of all the settings

@end
