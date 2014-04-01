//
//  EventLogger.h
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

/**
 *  Events logging
 */
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

/**-----------------------------------------------------------------------------
 * @name Class methods
 * -----------------------------------------------------------------------------
 */

/**
 *  Set up shared instance of Logger
 *
 *  @return sharedObject
 */
+ (id)sharedLogger;

/**
 *  Get count of Log entries
 *
 *  @return logs count
 */
+ (NSInteger)numberOfLogs;

/**-----------------------------------------------------------------------------
 * @name Handling events logging
 * -----------------------------------------------------------------------------
 */

/**
 *  Load events from Core Data
 */
- (void)loadEvents;

/**
 *  Load month old log data in background
 */
- (void)archiveMonthOldLogData;

/**
 *  Log a event to Core Data
 */
- (void)logEvent:(LogEventCode)eventCode eventInfo:(NSDictionary *)eventInfo;

/**
 *  Fetch event index from Core Data using event code
 */
- (NSInteger)getEventIndexWithCode:(LogEventCode)eventCode;

/**
 *  Log attempt information for puzzle
 *
 */

- (void)logAttemptForPuzzle:(PuzzleObject *)puzzleObject inMode:(PuzzleMode)mode state:(PuzzleState)state;

- (NSDictionary *)getScoresFromAttempsForUser:(User *)user;



/**-----------------------------------------------------------------------------
 * @name Log data related methods
 * -----------------------------------------------------------------------------
 */

/**
 *  Function to log data
 */
- (NSData *)logData;

- (void)deleteLogData;

- (void)deleteAllUserData;

- (void)deleteAttempts;

/**-----------------------------------------------------------------------------
 * @name Puzzle or puzzle mode randomization methods
 * -----------------------------------------------------------------------------
 */

/**
 *  Randomization process for modes for a specific puzzle
 *
 *  @param object Puzzle Object
 *
 *  @return suggested mode
 */
- (PuzzleMode)suggestModeForPuzzle:(PuzzleObject *)object;

- (NSDictionary *)suggestPuzzle;
@end
