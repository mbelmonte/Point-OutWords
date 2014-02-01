//
//  EventLogger.h
//  Autista
//
//  Created by Shashwat Parhi on 2/2/13.
//  Copyright (c) 2013 Shashwat Parhi
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

#import <Foundation/Foundation.h>

typedef enum {
	PuzzleStateNotAttempted, PuzzleStateAutoCompleted, PuzzleStatePartiallyCompleted, PuzzleStateCompleted
} PuzzleState;

typedef enum {
	PuzzleModePoint, PuzzleModeSay, PuzzleModeType
} PuzzleMode;

@class User;
@class Event;
@class PuzzleObject;
@class AppDelegate;

typedef enum {
	LogEventCodeAppLaunched=1,
	LogEventCodeAppExited,
	LogEventCodeScenePresented,
	LogEventCodeSceneSelected,
	LogEventCodeSceneExited,
	LogEventCodeSceneCompleted,
	LogEventCodeObjectSelected,
	LogEventCodePuzzlePresented,
	LogEventCodePieceTapped,
	LogEventCodePieceDragBegan,
	LogEventCodePieceDragMoved,
	LogEventCodePieceReleased,
	LogEventCodePieceAutoAdvanced,
	LogEventCodePuzzleCompleted,
	LogEventCodeAdminModeEntered,
	LogEventCodeAdminModeExited,
	LogEventCodeTouchBegan,
	LogEventCodeTouchMoved,
	LogEventCodeTouchEnded,
	LogEventCodeKeyPressed,
	LogEventCodeKeyReleased,
	LogEventCodeSoundDetected,
	LogEventCodeSyllableNotRecognized,
	LogEventCodeSyllableRecognized

} LogEventCode;

@interface EventLogger : NSObject {
	AppDelegate *_appDelegate;
	BOOL _canSendAnonymousData;
	
	NSManagedObjectContext *_context;
	User *_currentUser;
	NSDate *_appEnteredForegroundOn;
	NSArray *_events;
	NSMutableArray *_dragMoves;
	
	PuzzleObject *_trackingObject;
	PuzzleMode _trackingMode;
	NSInteger _modeRepeatCount;
}

+ (id)sharedLogger;
+ (NSInteger)numberOfLogs;

- (void)logEvent:(LogEventCode)eventCode eventInfo:(NSDictionary *)eventInfo;
- (void)logAttemptForPuzzle:(PuzzleObject *)puzzleObject inMode:(PuzzleMode)mode state:(PuzzleState)state;

- (NSDictionary *)getScoresFromAttempsForUser:(User *)user;

- (PuzzleMode)suggestModeForPuzzle:(PuzzleObject *)object;
- (NSDictionary *)suggestPuzzle;

- (NSData *)logData;
- (void)deleteLogData;
- (void)deleteAllUserData;
- (void)deleteAttempts;

@end
