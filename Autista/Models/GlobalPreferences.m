//
//  GlobalPreferences.m
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

#import "GlobalPreferences.h"
#import "AppDelegate.h"
#import "User.h"

@implementation GlobalPreferences

+ (id)sharedGlobalPreferences
{
	static dispatch_once_t pred = 0;
	__strong static id _sharedObject = nil;
	dispatch_once(&pred, ^{
		_sharedObject = [[self alloc] init];					// call our init method
	});
	return _sharedObject;
}

- (id)init {
	[self resetToFactoryDefaults];
    
	return self;
}

- (void)saveState
{
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	[userDefaults setObject:delegate.appVersion forKey:@"prefsVersion"];

	[userDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"reset_userdata"];								// reset this for next invocation

	[userDefaults setObject:[NSNumber numberWithBool:_sendAnonymousData] forKey:@"sendData_preference"];
	
	[userDefaults setObject:[NSNumber numberWithBool:_backgroundMusicEnabled] forKey:@"betaTesting"];
	[userDefaults setObject:[NSNumber numberWithBool:_backgroundMusicEnabled] forKey:@"backgroundMusicEnabled"];
	[userDefaults setObject:[NSNumber numberWithBool:_guidedModeEnabled] forKey:@"guidedModeEnabled"];
	[userDefaults setObject:[NSNumber numberWithBool:_snapBackEnabled] forKey:@"snapBackEnabled"];
	[userDefaults setObject:[NSNumber numberWithBool:_praisePromptEnabled] forKey:@"praisePromptEnabled"];
	[userDefaults setObject:[NSNumber numberWithBool:_keyHighlightingEnabled] forKey:@"keyHighlightingEnabled"];
	[userDefaults setObject:[NSNumber numberWithBool:_audioLevelsVisible] forKey:@"audioLevelsVisible"];
	[userDefaults setObject:[NSNumber numberWithBool:_sceneCompletionStatusVisible] forKey:@"sceneCompletionStatusVisible"];
	[userDefaults setObject:[NSNumber numberWithBool:_sendAnonymousData] forKey:@"sendAnonymousData"];

    [userDefaults setObject:[NSNumber numberWithFloat:_ampThresh] forKey:@"ampThresh"];
    [userDefaults setObject:[NSNumber numberWithFloat:_snapDistance] forKey:@"snapDistance"];
    [userDefaults setObject:[NSNumber numberWithFloat:_selectDistance] forKey:@"selectDistance"];
	[userDefaults setObject:[NSNumber numberWithFloat:_dragPuzzleFrequency] forKey:@"dragPuzzleFrequency"];
	[userDefaults setObject:[NSNumber numberWithFloat:_typePuzzleFrequency] forKey:@"typePuzzleFrequency"];
	[userDefaults setObject:[NSNumber numberWithFloat:_speakPuzzleFrequency] forKey:@"speakPuzzleFrequency"];
    [userDefaults setObject:[NSNumber numberWithFloat:_sayModeDifficulty] forKey:@"sayModeDifficulty"];
	
    [userDefaults setObject:[NSNumber numberWithInteger:self.whetherRecordVoice] forKey:@"whetherRecordVoice"];
    [userDefaults setObject:[NSNumber numberWithInteger:self.whetherRecordActivity] forKey:@"whetherRecordActivity"];

    [userDefaults setObject:[NSNumber numberWithFloat:self.typeSignificancy] forKey:@"typeSignificancy"];
    
	[userDefaults synchronize];
}

- (void)forgetState
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	[userDefaults removeObjectForKey:@"prefsVersion"];

	[userDefaults removeObjectForKey:@"betaTesting"];
	[userDefaults removeObjectForKey:@"backgroundMusicEnabled"];
	[userDefaults removeObjectForKey:@"guidedModeEnabled"];
	[userDefaults removeObjectForKey:@"snapBackEnabled"];
	[userDefaults removeObjectForKey:@"praisePromptEnabled"];
	[userDefaults removeObjectForKey:@"keyHighlightingEnabled"];
	[userDefaults removeObjectForKey:@"audioLevelsVisible"];
	[userDefaults removeObjectForKey:@"sceneCompletionStatusVisible"];
	[userDefaults removeObjectForKey:@"sendAnonymousData"];

    [userDefaults removeObjectForKey:@"ampThresh"];
    [userDefaults removeObjectForKey:@"snapDistance"];
    [userDefaults removeObjectForKey:@"selectDistance"];
	[userDefaults removeObjectForKey:@"dragPuzzleFrequency"];
	[userDefaults removeObjectForKey:@"typePuzzleFrequency"];
	[userDefaults removeObjectForKey:@"speakPuzzleFrequency"];
    [userDefaults removeObjectForKey:@"sayModeDifficulty"];
    
    [userDefaults removeObjectForKey:@"whetherRecordVoice"];
    [userDefaults removeObjectForKey:@"whetherRecordActivity"];
    
    [userDefaults removeObjectForKey:@"typeSignificancy"];
    
	[userDefaults synchronize];
	
	[self resetToFactoryDefaults];
}

- (void)restoreFromSavedState
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	if ([userDefaults objectForKey:@"sendData_preference"] != nil)								// this one courtesy of Settings.bundle
		_sendAnonymousData = [[userDefaults objectForKey:@"sendData_preference"] boolValue];
	
	if ([userDefaults objectForKey:@"prefsVersion"] != nil)
		_prefsVersion = [userDefaults objectForKey:@"prefsVersion"];

    if ([userDefaults objectForKey:@"betaTesting"] != nil)
		_betaTesting = [[userDefaults objectForKey:@"betaTesting"] boolValue];
    
	if ([userDefaults objectForKey:@"backgroundMusicEnabled"] != nil)
		_backgroundMusicEnabled = [[userDefaults objectForKey:@"backgroundMusicEnabled"] boolValue];

	if ([userDefaults objectForKey:@"guidedModeEnabled"] != nil)
		_guidedModeEnabled = [[userDefaults objectForKey:@"guidedModeEnabled"] boolValue];

	if ([userDefaults objectForKey:@"snapBackEnabled"] != nil)
		_snapBackEnabled = [[userDefaults objectForKey:@"snapBackEnabled"] boolValue];
    
    if ([userDefaults objectForKey:@"praisePromptEnabled"] != nil)
		_praisePromptEnabled = [[userDefaults objectForKey:@"praisePromptEnabled"] boolValue];
	
	if ([userDefaults objectForKey:@"keyHighlightingEnabled"] != nil)
		_keyHighlightingEnabled = [[userDefaults objectForKey:@"keyHighlightingEnabled"] boolValue];
	
	if ([userDefaults objectForKey:@"audioLevelsVisible"] != nil)
		_audioLevelsVisible = [[userDefaults objectForKey:@"audioLevelsVisible"] boolValue];

	if ([userDefaults objectForKey:@"sceneCompletionStatusVisible"] != nil)
		_sceneCompletionStatusVisible = [[userDefaults objectForKey:@"sceneCompletionStatusVisible"] boolValue];

	if ([userDefaults objectForKey:@"sendAnonymousData"] != nil)
		_sendAnonymousData = [[userDefaults objectForKey:@"sendAnonymousData"] boolValue];

    if ([userDefaults objectForKey:@"ampThresh"] != nil)
		_ampThresh = [[userDefaults objectForKey:@"ampThresh"] floatValue];

    if ([userDefaults objectForKey:@"snapDistance"] != nil)
		_snapDistance = [[userDefaults objectForKey:@"snapDistance"] floatValue];
    
    if ([userDefaults objectForKey:@"selectDistance"] != nil)
		_selectDistance = [[userDefaults objectForKey:@"selectDistance"] floatValue];

	if ([userDefaults objectForKey:@"dragPuzzleFrequency"] != nil)
		_dragPuzzleFrequency = [[userDefaults objectForKey:@"dragPuzzleFrequency"] floatValue];

	if ([userDefaults objectForKey:@"typePuzzleFrequency"] != nil)
		_typePuzzleFrequency = [[userDefaults objectForKey:@"typePuzzleFrequency"] floatValue];

	if ([userDefaults objectForKey:@"speakPuzzleFrequency"] != nil)
		_speakPuzzleFrequency = [[userDefaults objectForKey:@"speakPuzzleFrequency"] floatValue];
    if ([userDefaults objectForKey:@"sayModeDifficulty"] != nil)
		_sayModeDifficulty = [[userDefaults objectForKey:@"sayModeDifficulty"] floatValue];
    if ([userDefaults objectForKey:@"whetherRecordVoice"] != nil)
		self.whetherRecordVoice = [[userDefaults objectForKey:@"whetherRecordVoice"] integerValue];
    
    if ([userDefaults objectForKey:@"whetherRecordActivity"] != nil)
		self.whetherRecordActivity = [[userDefaults objectForKey:@"whetherRecordActivity"] integerValue];
    
    if ([userDefaults objectForKey:@"typeSignificancy"] != nil)
		self.typeSignificancy = [[userDefaults objectForKey:@"typeSignificancy"] floatValue];
    
}

- (void)resetToFactoryDefaults
{
	_betaTesting = YES;
	_backgroundMusicEnabled = NO;
	_guidedModeEnabled = NO;
	_snapBackEnabled = YES;
	_praisePromptEnabled = YES;
	_keyHighlightingEnabled = YES;
	_audioLevelsVisible = YES;
	_sceneCompletionStatusVisible = NO;
	_sendAnonymousData = YES;
    _ampThresh = 4; //log10 (4) ~ .6 - currentd efault for high threshold
    _snapDistance = 100;
    _selectDistance = 50;
	_dragPuzzleFrequency = 50;
	_typePuzzleFrequency = 50;
	_speakPuzzleFrequency = 0;
    _sayModeDifficulty = 0;
    self.whetherRecordVoice = 0;
    self.whetherRecordActivity = 0;
    
    self.typeSignificancy = 6.5;
}

- (NSDictionary *)packagedSettings
{
	NSMutableDictionary *settingsDict = [NSMutableDictionary dictionary];

	[settingsDict setObject:[NSNumber numberWithBool:_betaTesting] forKey:@"betaTesting"];
	[settingsDict setObject:[NSNumber numberWithBool:_backgroundMusicEnabled] forKey:@"backgroundMusicEnabled"];
	[settingsDict setObject:[NSNumber numberWithBool:_guidedModeEnabled] forKey:@"guidedModeEnabled"];
	[settingsDict setObject:[NSNumber numberWithBool:_snapBackEnabled] forKey:@"snapBackEnabled"];
	[settingsDict setObject:[NSNumber numberWithBool:_praisePromptEnabled] forKey:@"praisePromptEnabled"];
	[settingsDict setObject:[NSNumber numberWithBool:_keyHighlightingEnabled] forKey:@"keyHighlightingEnabled"];
	[settingsDict setObject:[NSNumber numberWithBool:_audioLevelsVisible] forKey:@"audioLevelsVisible"];
	[settingsDict setObject:[NSNumber numberWithBool:_sceneCompletionStatusVisible] forKey:@"sceneCompletionStatusVisible"];
	[settingsDict setObject:[NSNumber numberWithBool:_sendAnonymousData] forKey:@"sendAnonymousData"];

    [settingsDict setObject:[NSNumber numberWithFloat:_ampThresh] forKey:@"ampThresh"];
	[settingsDict setObject:[NSNumber numberWithFloat:_snapDistance] forKey:@"snapDistance"];
	[settingsDict setObject:[NSNumber numberWithFloat:_selectDistance] forKey:@"selectDistance"];
	[settingsDict setObject:[NSNumber numberWithFloat:_dragPuzzleFrequency] forKey:@"dragPuzzleFrequency"];
	[settingsDict setObject:[NSNumber numberWithFloat:_typePuzzleFrequency] forKey:@"typePuzzleFrequency"];
	[settingsDict setObject:[NSNumber numberWithFloat:_speakPuzzleFrequency] forKey:@"speakPuzzleFrequency"];
	[settingsDict setObject:[NSNumber numberWithFloat:_sayModeDifficulty] forKey:@"sayModeDifficulty"];

	[settingsDict setObject:[NSNumber numberWithInteger:self.whetherRecordVoice] forKey:@"whetherRecordVoice"];
    [settingsDict setObject:[NSNumber numberWithInteger:self.whetherRecordActivity] forKey:@"whetherRecordActivity"];
    return settingsDict;
}

@end
