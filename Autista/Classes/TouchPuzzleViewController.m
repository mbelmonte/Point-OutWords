//
//  TouchPuzzleViewController.m
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

#import <QuartzCore/QuartzCore.h>
#import "TouchPuzzleViewController.h"
#import "AdminViewController.h"
#import "GuidedModeViewController.h"
#import "PuzzlePieceView.h"
#import "TypeBanner.h"
#import "Scene.h"
#import "PuzzleObject.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Piece.h"
#import "SoundEffect.h"
#import "EventLogger.h"
#import "GlobalPreferences.h"

//#define SNAP_DISTANCE 200
#define PADDING		  20
#define MAX_ATTEMPTS 100
#define MIN_LOG_DRAG_DISTANCE 15

@interface TouchPuzzleViewController ()

@end

@implementation TouchPuzzleViewController
@synthesize myPlayer = _myPlayer;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[self setupSounds];
	
	_prefs = [GlobalPreferences sharedGlobalPreferences];
    SNAP_DISTANCE = _prefs.snapDistance;
	_launchedInGuidedMode = _prefs.guidedModeEnabled;
    _backButtonPressed = NO;
	_loopDetectorCount = 0;
	_pieces = [NSMutableArray array];
	
	_background.image = [UIImage imageWithData:_object.scene.puzzleBackgroundImage];
	
    _banner = [[TypeBanner alloc] initWithFrame:titleLabel.frame];
    //	_banner.bannerFont = titleLabel.font;
    UIFont *avenirBold = [UIFont fontWithName:@"AvenirNext-Bold" size:48.];
    
	if (avenirBold == nil)
    _banner.bannerFont = [UIFont systemFontOfSize:48.];
    else
    _banner.bannerFont = avenirBold;
    
    NSLog(@"banner font : %@, title font : %@", _banner.bannerFont.fontName, titleLabel.font.fontName);
	_banner.bannerText = _object.title;
	
	[self.view addSubview:_banner];
	titleLabel.hidden = YES;

	[_placeHolder removeFromSuperview];
	_placeHolder = nil;

	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
	UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
	
	[self.view addGestureRecognizer:tapGesture];
	[self.view addGestureRecognizer:panGesture];
	
	[self performSelector:@selector(initializePuzzleState) withObject:nil afterDelay:0.3];
	
	[[EventLogger sharedLogger] logEvent:LogEventCodePuzzlePresented eventInfo:@{@"Mode": @"Drag"}];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

	if (_adminVC != nil && _prefs.guidedModeEnabled == NO)											// Shashwat Parhi: if returning from Admin screen
		[self dismissViewControllerAnimated:NO completion:nil];										// dismiss self, added on April 02, 2013 as per client request
	
	if (_launchedInGuidedMode == NO && _prefs.guidedModeEnabled == YES)								// most likely, admin changed this setting mid-stream
		[self dismissViewControllerAnimated:NO completion:nil];										// so bail out
}

- (void)initializePuzzleState
{
	_placeHolder = [[UIImageView alloc] initWithImage:[UIImage imageWithData:_object.placeholderImage]];
	_placeHolder.center = CGPointMake(512, 384);
	
	[self.view addSubview:_placeHolder];

	CGFloat offsetX = _placeHolder.frame.origin.x;
	CGFloat offsetY = _placeHolder.frame.origin.y;
	
	for (Piece *piece in _object.pieces) {
		PuzzlePieceView *pieceView = [[PuzzlePieceView alloc] initWithImage:[UIImage imageWithData:piece.pieceImage]];
		pieceView.userInteractionEnabled = YES;
		pieceView.title = piece.imageName;
		pieceView.initialPoint = CGPointMake(0, 0);
		
		CGPoint finalPosition = CGPointMake([piece.finalPositionX floatValue], [piece.finalPositionY floatValue]);
		finalPosition = CGPointMake(offsetX + finalPosition.x, offsetY + finalPosition.y);
        pieceView.finalPoint = finalPosition;
		
        //MRG: Major fix - adding letters to puzzle pieces (put in labels of pieces in plist file)
        //NSLog(@"Piece label : %@, for Puzzle : %@, image width : %f, image ht : %f", piece.label, _object.title, pieceView.image.size.width, pieceView.image.size.height);
        UILabel *pieceLabel = [[UILabel alloc] initWithFrame:pieceView.frame];
        pieceLabel.backgroundColor = [UIColor clearColor];
        pieceLabel.font = [UIFont systemFontOfSize:18];
        pieceLabel.textAlignment = UITextAlignmentCenter;
        pieceLabel.text = piece.label;
        //[pieceView addSubview:pieceLabel];
        
		[self.view addSubview:pieceView];
		[_pieces addObject:pieceView];
	}
    
    [self performSelector:@selector(playObjectTitleSound) withObject:nil afterDelay:0.5];
	[self randomizeInitialPositionsOfPieces];
}

- (void)randomizeInitialPositionsOfPieces
{
	CGRect screenRect = CGRectMake(0, 0, 1024, 768);
	screenRect = CGRectInset(screenRect, PADDING, PADDING);
	
	int i = 0;
	int numAttempts = 0;
	
	[_pieces sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {							// first sort pieces by size: large pieces first
		UIView *view1 = (UIView *)obj1;
		UIView *view2 = (UIView *)obj2;
		CGFloat area1 = view1.frame.size.width * view1.frame.size.height;
		CGFloat area2 = view2.frame.size.width * view2.frame.size.height;
		
		if (area1 > area2)
			return NSOrderedAscending;
		else return NSOrderedDescending;
	}];

    NSArray * fixedPiecesX;
    NSArray * fixedPiecesY;
    
    BOOL _useFixedArrays = YES;
    
    if ([_object.title isEqualToString:@"Bath"]) {
        fixedPiecesX = @[@0, @0, @600, @800];
        fixedPiecesY = @[@0, @500, @0, @500];
    }
    else if ([_object.title isEqualToString:@"Watermelon"]) {
        fixedPiecesX = @[@0, @0, @0, @0, @400, @400, @800, @800, @800, @800];
        fixedPiecesY = @[@0, @200, @400, @600, @0, @600, @0, @200, @400, @600];
    }
    else {
        _useFixedArrays = NO;
    }
    
	while (i < [_pieces count]) {																// iterate through all pieces
		PuzzlePieceView *aPiece = [_pieces objectAtIndex:i];
		CGRect pieceFrame = aPiece.frame;
		CGFloat pieceWidth = pieceFrame.size.width + 2 * PADDING;
		CGFloat pieceHeight = pieceFrame.size.height + 2 * PADDING;
		CGFloat offsetX;
        CGFloat offsetY;
        
        if (_useFixedArrays) {
            offsetX = [fixedPiecesX[i] floatValue];
            offsetY = [fixedPiecesY[i] floatValue];
        }
        else {
            offsetX = arc4random() % (int)(screenRect.size.width - pieceWidth);					// randomly pick X,Y coordinates
            offsetY = arc4random() % (int)(screenRect.size.height - pieceHeight);
        }
		  
		CGRect pieceRect = CGRectMake(offsetX, offsetY, pieceWidth, pieceHeight);
		
		int j = 0;
		BOOL intersects = NO;
		
		while (j < [_pieces count] && intersects == NO && numAttempts < MAX_ATTEMPTS) {				// make sure piece does not intersect with any of the
			PuzzlePieceView *piece = [_pieces objectAtIndex:j];										// other pieces in their final positions
			CGRect finalRect = piece.frame;
			finalRect.origin = piece.finalPoint;
			
			if ((CGRectIntersectsRect(pieceRect, finalRect) == YES)) {								// this gives a better fit than simply avoiding placeHolder's rect
				intersects = YES;
				numAttempts++;
				break;
			}
			else j++;
		}
		
		if (intersects == YES)
        {
            //NSLog(@"Object 1st time : %@", _object.title);
            //fprintf (stdout, "Num Attempts = %d\n", numAttempts);
            // too bad, this doesn't make for a good fit...
			continue;
        }
        // try again
		
		j = 0;

		while (j < i && intersects == NO && numAttempts < MAX_ATTEMPTS) {							// now that this piece does not overaly any final positions
			UIView *bPiece = [_pieces objectAtIndex:j];
			
			if (CGRectIntersectsRect(pieceRect, bPiece.frame) == YES) {								// make sure it does not intersect any of the pieces
				intersects = YES;																	// we have already covered until now
				numAttempts++;
				break;
			}
			else j++;
		}
		
		if (intersects == YES && numAttempts < MAX_ATTEMPTS)        {
            //NSLog(@"Object 2nd time : %@", _object.title);
            //fprintf (stdout, "Num Attempts = %d\n", numAttempts);
            continue;
		}
		
        pieceFrame.origin = CGPointMake(offsetX, offsetY);											// if we made it so far, it means we found a suitable place
		aPiece.frame = pieceFrame;																	// for this piece
		aPiece.initialPoint = pieceFrame.origin;													// set initialPoint to return to if snapback is enabled
		i++;																						// move to next one
	}
}

#pragma mark - Sound Effects

- (void)setupSounds {																				// Load sound files into SoundEffect objects, and hold on to them for later use
    NSBundle *mainBundle = [NSBundle mainBundle];
	
	_pieceSelectedSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"PieceSelected" ofType:@"caf"]];
	_pieceReleasedSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"PieceReleased" ofType:@"caf"]];
	_piecePlacedSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"CorrectPiecePlaced" ofType:@"caf"]];
	_pieceReturnedSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"WrongPiecePlaced" ofType:@"caf"]];
	_puzzleCompletedSuccessfullySound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"PuzzleCompletedSuccessfully02" ofType:@"caf"]];
}

- (IBAction)playPieceSelectedSound {
	[_pieceSelectedSound play];
}

- (IBAction)playPieceReleasedSound {
	[_pieceReleasedSound play];
}

- (IBAction)playPiecePlacedSound {
	[_piecePlacedSound play];
}

- (IBAction)playPieceReturnedSound {
	[_pieceReturnedSound play];
}

- (IBAction)playPuzzleCompletedSuccessfullySound {
	[_puzzleCompletedSuccessfullySound play];
}

#pragma mark -Gesture Handling

//add code to handle interest area
- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
	CGPoint initialTouchPoint = [gesture locationInView:self.view];
	PuzzlePieceView *touchedPiece = [self hitTest:initialTouchPoint];
        
    if (_prefs.selectDistance != 0){
        CGRect currentRect=touchedPiece.frame;
        currentRect.origin.x = initialTouchPoint.x - touchedPiece.frame.size.width/2;
        currentRect.origin.y = initialTouchPoint.y - touchedPiece.frame.size.height/2;
        [UIView animateWithDuration:0.1 animations:^(void) { touchedPiece.frame = currentRect; }];
        
        [self snapPieceToFinalPosition:touchedPiece];
    }
    
	if (touchedPiece != nil && touchedPiece != _pieceTrackedByLoopDetector) {
		[self.view bringSubviewToFront:touchedPiece];
		_loopDetectorCount = 0;
		
		[self playPieceReleasedSound];
		
		NSNumber *locationX = [NSNumber numberWithFloat:initialTouchPoint.x];
		NSNumber *locationY = [NSNumber numberWithFloat:initialTouchPoint.y];
		
		[[EventLogger sharedLogger] logEvent:LogEventCodePieceTapped eventInfo:@{@"Piece": touchedPiece.title,  @"X": locationX, @"Y": locationY}];
	}
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateBegan) {
		CGPoint initialTouchPoint = [gesture locationOfTouch:0 inView:self.view];
		_draggedPiece = [self hitTest:initialTouchPoint];
		
		if (_draggedPiece == nil)
			return;
		
		[self.view bringSubviewToFront:_draggedPiece];												// bring piece to front so it doesn't get stuck underneath other pieces
        
        
        if (_prefs.selectDistance != 0){
            CGRect currentRect=_draggedPiece.frame;
            currentRect.origin.x = initialTouchPoint.x - _draggedPiece.frame.size.width/2;
            currentRect.origin.y = initialTouchPoint.y - _draggedPiece.frame.size.height/2;
            [UIView animateWithDuration:0.1 animations:^(void) { _draggedPiece.frame = currentRect;}];
        }
        
        
		_pieceTouchedAtPoint = initialTouchPoint;
		_lastLoggedPoint = initialTouchPoint;
	
		if (_draggedPiece.isCompleted == YES) {
			_draggedPiece = nil;
			return;
		}
				
		if (_pieceTrackedByLoopDetector == _draggedPiece)											// detect if user changed pieces or is still fiddling away with the same one
			_loopDetectorCount++;
		else {
			_loopDetectorCount = 0;
			_pieceTrackedByLoopDetector = _draggedPiece;
		}
		
		// log pan gesture start
		
		NSNumber *locationX = [NSNumber numberWithFloat:initialTouchPoint.x];
		NSNumber *locationY = [NSNumber numberWithFloat:initialTouchPoint.y];
		
		[[EventLogger sharedLogger] logEvent:LogEventCodePieceDragBegan eventInfo:@{@"Piece": _draggedPiece.title,  @"X": locationX, @"Y": locationY}];
	}
    else if (gesture.state == UIGestureRecognizerStateChanged) {
		if (_draggedPiece != nil) {
			CGPoint newLocation = [gesture locationOfTouch:0 inView:self.view];
			CGRect frame = _draggedPiece.frame;
			CGFloat deltaX = newLocation.x - _pieceTouchedAtPoint.x;
			CGFloat deltaY = newLocation.y - _pieceTouchedAtPoint.y;
			
			frame = CGRectOffset(frame, deltaX, deltaY);
			_pieceTouchedAtPoint = newLocation;
			
			[UIView animateWithDuration:0.1 animations:^(void) { _draggedPiece.frame = frame; }];

			// log drag movement if moved more than a certain amount so we don't go overboard trying to log every pixel shift in position
			
			deltaX = newLocation.x - _lastLoggedPoint.x;											// reusing same variables to calculate
			deltaY = newLocation.y - _lastLoggedPoint.y;											// displacement since last logged value
			
			if (abs(deltaX + deltaY) > MIN_LOG_DRAG_DISTANCE) {
				NSNumber *locationX = [NSNumber numberWithFloat:newLocation.x];
				NSNumber *locationY = [NSNumber numberWithFloat:newLocation.y];
				
				_lastLoggedPoint = newLocation;

				[[EventLogger sharedLogger] logEvent:LogEventCodePieceDragMoved eventInfo:@{@"Piece": _draggedPiece.title, @"X": locationX, @"Y": locationY}];
			}
		}
		else {
			// Shashwat Parhi: this case still needs to be implemented
			// drag must have started outside of a piece, so if we are currently over one of our pieces
			// that piece needs to start moving along with the drag
		}
    }
    else if (gesture.state == UIGestureRecognizerStateEnded | gesture.state == UIGestureRecognizerStateCancelled) {
		if (_draggedPiece != nil) {
			[self snapPieceToFinalPosition:_draggedPiece];
		}
	}
}

- (void)snapPieceToFinalPosition:(PuzzlePieceView *)piece
{
	CGFloat deltaX = fabs(_draggedPiece.frame.origin.x - _draggedPiece.finalPoint.x);
	CGFloat deltaY = fabs(_draggedPiece.frame.origin.y - _draggedPiece.finalPoint.y);
	
	CGRect frame = piece.frame;
	
	if (deltaX < SNAP_DISTANCE && deltaY < SNAP_DISTANCE) {
		frame.origin = piece.finalPoint;
		piece.isCompleted = YES;
		_loopDetectorCount = 0;
		
		[self playPiecePlacedSound];
		
		[[EventLogger sharedLogger] logEvent:LogEventCodePieceReleased eventInfo:@{@"placement": @"correct"}];
	}
	else if (_loopDetectorCount > 2) {
		frame.origin = piece.finalPoint;
		piece.isCompleted = YES;
		_loopDetectorCount = 0;
		_autoCompletedPieces++;
		
		[self playPiecePlacedSound];
		
		[[EventLogger sharedLogger] logEvent:LogEventCodePieceAutoAdvanced eventInfo:nil];
	}
	else if (_prefs.snapBackEnabled == YES) {
		frame.origin = piece.initialPoint;
		piece.isCompleted = NO;
		
		[self playPieceReturnedSound];
		
		[[EventLogger sharedLogger] logEvent:LogEventCodePieceReleased eventInfo:@{@"placement": @"wrong"}];
	}
	else {
		[[EventLogger sharedLogger] logEvent:LogEventCodePieceReleased eventInfo:@{@"placement": @"midway"}];
		
		CGRect intersectRect = CGRectIntersection(CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width), frame);
		if (!CGRectEqualToRect(intersectRect, frame)) {
			frame = [self suggestSuitableFrameForPiece:piece];
			piece.isCompleted = NO;
		}
		else return;
	}
	
	[UIView animateWithDuration:0.3
					 animations:^(void) {
						 piece.frame = frame;
					 }
					 completion:^(BOOL finished) {
						 [self checkPuzzleState];
					 }
	 ];
}

- (CGRect)suggestSuitableFrameForPiece:(UIView *)piece
{
	CGRect frame = piece.frame;

	if (frame.origin.x < 10)
		frame.origin.x = 10;
	
	if (frame.origin.y < 10)
		frame.origin.y = 10;
	
	if (frame.origin.x + frame.size.width > 1014)
		frame.origin.x = 1014 - frame.size.width;
	
	if (frame.origin.y + frame.size.height > 758)
		frame.origin.y = 758 - frame.size.height;

	return frame;
}

- (void)checkPuzzleState
{
	BOOL isCompleted = YES;
	
	for (int i = 0; i < [_pieces count]; i++) {
		if ([[_pieces objectAtIndex:i] isCompleted] == NO) {
			isCompleted = NO;
			break;
		}
	}
	
	if (isCompleted == YES)
		[self presentPuzzleCompletionAnimation];
}

- (void)presentPuzzleCompletionAnimation
{
	[self playPuzzleCompletedSuccessfullySound];
	
	//[self performSelector:@selector(delayedDismissSelf) withObject:nil afterDelay:2.0];
    [self performSelector:@selector(promptAndFinish) withObject:nil afterDelay:0.5];
}

- (void) promptAndFinish
{
    //RD
    //Prompt : Easy (<10) - WellDone; Medium (10-12) - Super, Yay; Difficult (>12) - GoodJob, Awesome
    
    if (_prefs.praisePromptEnabled == YES){
        NSLog(@"Difficulty Level of the object %@ for Touch mode is : %@", _object.title, _object.difficultySpeak);
        NSDictionary *plistDict = [self readFromPlist];
        int currentPromptIndex = [((NSNumber *)[plistDict objectForKey:@"PromptPrefs"]) intValue];
        switch (currentPromptIndex) {
            case 0:
            {
              
                NSString * objectName = @"Super";
                if (_autoCompletedPieces > 0)
                    objectName = @"TryAgain";
                else if ([_object.difficultySpeak doubleValue] < 10)
                    objectName = @"WellDone";
                else if ([_object.difficultySpeak doubleValue] > 12)
                    objectName = @"Awesome";
                
                
                NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
                NSLog(@"directory found ====== %@",bundleRoot);
                NSFileManager *fm = [NSFileManager defaultManager];
                NSArray *dirContents = [fm contentsOfDirectoryAtPath:bundleRoot error:nil];
                NSPredicate *fltr;
                fltr = [NSPredicate predicateWithFormat:@"(self ENDSWITH '.caf') AND (self CONTAINS[c] %@)", objectName];
                NSArray *onlyWAVs = [dirContents filteredArrayUsingPredicate:fltr];
                NSLog(@"directoryContents ====== %@",onlyWAVs);
                
                NSString * promptPath = [[NSBundle mainBundle] pathForResource:[onlyWAVs[0] stringByDeletingPathExtension] ofType:@"caf"];
                NSURL *promptURL = [NSURL fileURLWithPath:promptPath];
                _finishPrompt = [[AVAudioPlayer alloc] initWithContentsOfURL:promptURL error:nil];
                [_finishPrompt prepareToPlay];
                [_finishPrompt play];

            
                break;
            }
            case 1:
            {
                
                NSMutableArray* recordFilePathArray =  [[NSMutableArray alloc]initWithArray:[plistDict objectForKey:@"RecordedPraise"]];
                NSString *playURL= [recordFilePathArray objectAtIndex:0];
                if (_autoCompletedPieces > 0)
                    playURL = [recordFilePathArray objectAtIndex:3];
                else if ([_object.difficultySpeak doubleValue] < 10)
                    playURL= [recordFilePathArray objectAtIndex:2];
                else if ([_object.difficultySpeak doubleValue] > 12)
                    playURL= [recordFilePathArray objectAtIndex:1];

                _finishPrompt = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath: playURL ] error:nil];
                [_finishPrompt prepareToPlay];
                [_finishPrompt play];
                
                break;
            }
            case 2:{
                
                NSMutableArray* iTunesPlayList = [[NSMutableArray alloc]initWithArray:[plistDict objectForKey:@"iTunesPraiseURL"]];
                
                NSString *songName= [iTunesPlayList objectAtIndex:0];
                if (_autoCompletedPieces > 0)
                    songName = @"";
                else if ([_object.difficultySpeak doubleValue] < 10)
                    songName= [iTunesPlayList objectAtIndex:2];
                else if ([_object.difficultySpeak doubleValue] > 12)
                    songName= [iTunesPlayList objectAtIndex:1];
                
                _myPlayer = [MPMusicPlayerController applicationMusicPlayer];
                MPMediaPropertyPredicate *playlistPredicate = [MPMediaPropertyPredicate predicateWithValue:songName forProperty:MPMediaItemPropertyTitle];
                NSSet *predicateSet = [NSSet setWithObjects:playlistPredicate, nil];
                MPMediaQuery *mediaTypeQuery = [[MPMediaQuery alloc] initWithFilterPredicates:predicateSet];
                [_myPlayer setQueueWithQuery:mediaTypeQuery];
                [_myPlayer play];
                [self performSelector:@selector(stopPlaying) withObject:nil afterDelay:3];
                break;
            }
                
        }
        //
       //
        [self performSelector:@selector(delayedDismissSelf) withObject:nil afterDelay:1];
    }
    else {
        [self performSelector:@selector(delayedDismissSelf) withObject:nil afterDelay:0.5];
    }
}

-(void)stopPlaying
{
    [_myPlayer stop];
}

-(NSDictionary *)readFromPlist
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
	// get documents path
	NSString *documentsPath = [paths objectAtIndex:0];
	// get the path to our Data/plist file
	NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"PraisePrefs.plist"];
    // check to see if Data.plist exists in documents
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
	{
		// if not in documents, get property list from main bundle
        
        [[NSFileManager defaultManager]copyItemAtPath: [[NSBundle mainBundle] pathForResource:@"PraisePrefs" ofType:@"plist"] toPath:plistPath error: nil];
        
	}
    
    
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	// convert static property liost into dictionary object
	NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
	if (!temp)
	{
		NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
	}
    return temp;
 
}

- (void)playObjectTitleSound
{
	NSString *wordSoundFile = [[NSBundle mainBundle] pathForResource:_object.title ofType:@"caf"];
	NSURL *url = [NSURL fileURLWithPath:wordSoundFile];
	_wordPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
	_wordPlayer.volume = 1.0;
	[_wordPlayer play];
}

- (void)delayedDismissSelf
{
	NSString *status;
	NSInteger state;
	
	if (_backButtonPressed) {
		state = PuzzleStateAutoCompleted;
		status = @"unsuccessful";
    }
    else if (_autoCompletedPieces == 0) {
		state = PuzzleStateCompleted;
		status = @"successful";
	}
	else if (_autoCompletedPieces < [_pieces count]) {
		state = PuzzleStatePartiallyCompleted;
		status = @"partial";
	}
	else {
		state = PuzzleStateAutoCompleted;
		status = @"unsuccessful";
	}

	[[EventLogger sharedLogger] logAttemptForPuzzle:_object inMode:PuzzleModePoint state:state];
	[[EventLogger sharedLogger] logEvent:LogEventCodePuzzleCompleted eventInfo:@{@"status": status}];
	
	if (_prefs.guidedModeEnabled == NO)
		[self dismissViewControllerAnimated:YES completion:nil];
	else [(GuidedModeViewController *)self.parentViewController presentNextPuzzle];
}

//add code to handle interest area
- (PuzzlePieceView *)hitTest:(CGPoint)touchPoint
{
    CGFloat distance = 1024;
    CGFloat newDistance = 1024;
    PuzzlePieceView *nearestPiece = nil;
    
    //go through all pieces, if one is clicked, return that one.
    for (PuzzlePieceView *piece in _pieces) {
		CGPoint point = [self.view convertPoint:touchPoint toView:piece];
		if (piece.isCompleted == NO && [piece pointInside:point withEvent:nil] == YES)
			return piece;
    }
    
    //go through all pieces, if no one is clicked, if is not completed, get nearest distance and piece.
	for (PuzzlePieceView *piece in _pieces) {
        CGPoint point = [self.view convertPoint:touchPoint toView:piece];
        
        if (piece.isCompleted == YES)
            continue;

        newDistance = sqrtf(pow(point.x, 2)+pow(point.y, 2));
        if (newDistance < distance){
            distance = newDistance;
            nearestPiece = piece;
        }
    }
    
    //check if this piece fits the selecting distance criteria
    CGPoint nearestPoint = [self.view convertPoint:touchPoint toView:nearestPiece];
    if ((abs(nearestPoint.x) - nearestPiece.frame.size.width) < _prefs.selectDistance && (abs(nearestPoint.y) - nearestPiece.frame.size.height) < _prefs.selectDistance){
        return nearestPiece;
    }
    
	return nil;
}

- (IBAction)handleBackButtonPressed:(id)sender
{
    AudioServicesPlaySystemSound(0x450);
	_backOverlayTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(showBackOverlay) userInfo:nil repeats:NO];
}

- (IBAction)handleBackButtonReleased:(id)sender
{
	[_backOverlayTimer invalidate];
}

- (void)showBackOverlay
{
    //[TestFlight passCheckpoint:@"Back button Tapped in Point mode"];

	[_backOverlayTimer invalidate];
	_backButtonPressed = YES;
	[self performSelector:@selector(delayedDismissSelf) withObject:nil afterDelay:0];
}

- (IBAction)handleAdminButtonPressed:(id)sender
{
    AudioServicesPlaySystemSound(0x450);
	_adminOverlayTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(showAdminOverlay) userInfo:nil repeats:NO];
}

- (IBAction)handleAdminButtonReleased:(id)sender
{
	[_adminOverlayTimer invalidate];
}

- (void)showAdminOverlay
{
	[_adminOverlayTimer invalidate];
	
	_adminVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AdminViewController"];
	[self presentViewController:_adminVC animated:YES completion:nil];
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationLandscapeLeft;
//}

-(BOOL)shouldAutorotate
{
    return NO;
}
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//	return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
