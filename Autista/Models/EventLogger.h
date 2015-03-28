//
//  EventLogger.h
//  Autista
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
    LogEventCodeTypeReminder,
    LogEventCodeTypeAccelerometer,
	LogEventCodeSoundDetected,
	LogEventCodeSyllableNotRecognized,
	LogEventCodeSyllableRecognized,
    LogEventCodeSoundRecorded,
    LogEventCodePieceSkipped
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
- (void)logAccelerometer:(LogEventCode)eventCode eventInfo:(NSDictionary *)eventInfo;

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

- (void)removeLogFolder:(NSString *)documentsDirectory;

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
