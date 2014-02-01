//
//  GlobalPreferences.m
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
	[userDefaults setObject:[NSNumber numberWithBool:_keyHighlightingEnabled] forKey:@"keyHighlightingEnabled"];
	[userDefaults setObject:[NSNumber numberWithBool:_audioLevelsVisible] forKey:@"audioLevelsVisible"];
	[userDefaults setObject:[NSNumber numberWithBool:_sceneCompletionStatusVisible] forKey:@"sceneCompletionStatusVisible"];
	[userDefaults setObject:[NSNumber numberWithBool:_sendAnonymousData] forKey:@"sendAnonymousData"];

    [userDefaults setObject:[NSNumber numberWithFloat:_ampThresh] forKey:@"ampThresh"];
    [userDefaults setObject:[NSNumber numberWithFloat:_snapDistance] forKey:@"snapDistance"];
	[userDefaults setObject:[NSNumber numberWithFloat:_dragPuzzleFrequency] forKey:@"dragPuzzleFrequency"];
	[userDefaults setObject:[NSNumber numberWithFloat:_typePuzzleFrequency] forKey:@"typePuzzleFrequency"];
	[userDefaults setObject:[NSNumber numberWithFloat:_speakPuzzleFrequency] forKey:@"speakPuzzleFrequency"];
	
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
	[userDefaults removeObjectForKey:@"keyHighlightingEnabled"];
	[userDefaults removeObjectForKey:@"audioLevelsVisible"];
	[userDefaults removeObjectForKey:@"sceneCompletionStatusVisible"];
	[userDefaults removeObjectForKey:@"sendAnonymousData"];

    [userDefaults removeObjectForKey:@"ampThresh"];
    [userDefaults removeObjectForKey:@"snapDistance"];
	[userDefaults removeObjectForKey:@"dragPuzzleFrequency"];
	[userDefaults removeObjectForKey:@"typePuzzleFrequency"];
	[userDefaults removeObjectForKey:@"speakPuzzleFrequency"];
	
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

	if ([userDefaults objectForKey:@"dragPuzzleFrequency"] != nil)
		_dragPuzzleFrequency = [[userDefaults objectForKey:@"dragPuzzleFrequency"] floatValue];

	if ([userDefaults objectForKey:@"typePuzzleFrequency"] != nil)
		_typePuzzleFrequency = [[userDefaults objectForKey:@"typePuzzleFrequency"] floatValue];

	if ([userDefaults objectForKey:@"speakPuzzleFrequency"] != nil)
		_speakPuzzleFrequency = [[userDefaults objectForKey:@"speakPuzzleFrequency"] floatValue];
}

- (void)resetToFactoryDefaults
{
	_betaTesting = YES;
	_backgroundMusicEnabled = YES;
	_guidedModeEnabled = NO;
	_snapBackEnabled = YES;
	_keyHighlightingEnabled = YES;
	_audioLevelsVisible = YES;
	_sceneCompletionStatusVisible = NO;
	_sendAnonymousData = YES;
    _ampThresh = 4; //log10 (4) ~ .6 - currentd efault for high threshold
    _snapDistance = 100;
	_dragPuzzleFrequency = 60;
	_typePuzzleFrequency = 20;
	_speakPuzzleFrequency = 20;
}

- (NSDictionary *)packagedSettings
{
	NSMutableDictionary *settingsDict = [NSMutableDictionary dictionary];

	[settingsDict setObject:[NSNumber numberWithBool:_betaTesting] forKey:@"betaTesting"];
	[settingsDict setObject:[NSNumber numberWithBool:_backgroundMusicEnabled] forKey:@"backgroundMusicEnabled"];
	[settingsDict setObject:[NSNumber numberWithBool:_guidedModeEnabled] forKey:@"guidedModeEnabled"];
	[settingsDict setObject:[NSNumber numberWithBool:_snapBackEnabled] forKey:@"snapBackEnabled"];
	[settingsDict setObject:[NSNumber numberWithBool:_keyHighlightingEnabled] forKey:@"keyHighlightingEnabled"];
	[settingsDict setObject:[NSNumber numberWithBool:_audioLevelsVisible] forKey:@"audioLevelsVisible"];
	[settingsDict setObject:[NSNumber numberWithBool:_sceneCompletionStatusVisible] forKey:@"sceneCompletionStatusVisible"];
	[settingsDict setObject:[NSNumber numberWithBool:_sendAnonymousData] forKey:@"sendAnonymousData"];

    [settingsDict setObject:[NSNumber numberWithFloat:_ampThresh] forKey:@"ampThresh"];
	[settingsDict setObject:[NSNumber numberWithFloat:_snapDistance] forKey:@"snapDistance"];
	[settingsDict setObject:[NSNumber numberWithFloat:_dragPuzzleFrequency] forKey:@"dragPuzzleFrequency"];
	[settingsDict setObject:[NSNumber numberWithFloat:_typePuzzleFrequency] forKey:@"typePuzzleFrequency"];
	[settingsDict setObject:[NSNumber numberWithFloat:_speakPuzzleFrequency] forKey:@"speakPuzzleFrequency"];

	return settingsDict;
}

@end
