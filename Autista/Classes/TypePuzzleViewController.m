//
//  TypePuzzleViewController.m
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
#import "TypePuzzleViewController.h"
#import "AdminViewController.h"
#import "GuidedModeViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "PuzzlePieceView.h"
#import "TypeBanner.h"
#import "Scene.h"
#import "PuzzleObject.h"
#import "Piece.h"
#import "SoundEffect.h"
#import "EventLogger.h"
#import "GlobalPreferences.h"

@interface TypePuzzleViewController ()

#define PADDING		  20
#define MAX_ATTEMPTS 100

@property NSMutableArray *accelerometerDataArray;

@end

@implementation TypePuzzleViewController
@synthesize myPlayer = _myPlayer;
@synthesize motionManager, pathLayer;

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
	_launchedInGuidedMode = _prefs.guidedModeEnabled;
    _backButtonPressed = NO;
    _puzzleComplete = NO;
    
	_loopDetectorCount = 0;
	_pieces = [NSMutableArray array];
	_keys = @[AKey, BKey, CKey, DKey, EKey, FKey, GKey, HKey, IKey, JKey, KKey, LKey, MKey, NKey, OKey, PKey, QKey, RKey, SKey, TKey, UKey, VKey, WKey, XKey, YKey, ZKey];
	
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
	
	[_placeHolder removeFromSuperview];																// this got loaded via the NIB so we remove it and recreate this later
	_placeHolder = nil;
	
	[self performSelector:@selector(initializePuzzleState) withObject:nil afterDelay:0.3];
	
	[[EventLogger sharedLogger] logEvent:LogEventCodePuzzlePresented eventInfo:@{@"Mode": @"Type"}];
    
    self.accelerometerDataArray = [NSMutableArray array];
    self.motionManager = [[CMMotionManager alloc] init];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    if (motionManager.accelerometerAvailable) {
        motionManager.accelerometerUpdateInterval = 1.0 / 10.0; [motionManager startAccelerometerUpdatesToQueue:queue withHandler: ^(CMAccelerometerData *accelerometerData, NSError *error){
            NSString *labelText;
            if (error) {
                [motionManager stopAccelerometerUpdates]; labelText = [NSString stringWithFormat:
                                                                       @"Accelerometer encountered error: %@", error];
            } else {
                labelText = [NSString stringWithFormat:
                             @"Accelerometer\n-----------\nx: %+.2f\ny: %+.2f\nz: %+.2f", accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z];
            }
//            [accelerometerLabel performSelectorOnMainThread:@selector(setText:)
//                                                 withObject:labelText waitUntilDone:NO];
            [[EventLogger sharedLogger] logEvent:LogEventCodeTypeAccelerometer eventInfo:@{@"X": [NSString stringWithFormat:@"%+.2f\n", accelerometerData.acceleration.x], @"Y": [NSString stringWithFormat:@"%+.2f\n", accelerometerData.acceleration.y], @"Z": [NSString stringWithFormat:@"%+.2f\n", accelerometerData.acceleration.z]}];
            //[self.accelerometerDataArray addObject:accelerometerData];
            NSLog(@"%@", labelText);
        }]; }
    else {
            //accelerometerLabel.text = @"This device has no accelerometer.";
    }
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
	
	[self slideOutKeyboard];
    
	NSString *title = [_object.title uppercaseString];
	
	for (int i = 0; i < title.length; i++) {
		NSInteger asciiCode = [title characterAtIndex:i];
		UIButton *button = [self buttonFromASCIICode:asciiCode];
		
		button.adjustsImageWhenHighlighted = NO;													// Shashwat Parhi: disabled key hilighting on April 02, 2013, as per client request
		button.enabled = YES;
	}
	
	for (int i = 0; i < [_keys count]; i++) {
		UIButton *button = [_keys objectAtIndex:i];
		
		if (button.enabled == NO)
			button.titleLabel.text = @"";
	}
	
	_currentLetterPosition = -1;
	[self performSelector:@selector(playObjectTitleSound) withObject:nil afterDelay:0.5];
	[self performSelector:@selector(slideInKeyboard) withObject:nil afterDelay:1.5];				// pieces are initialized after keyboard slide in animation completes
}

#pragma mark - Sound Effects

// Load sound files into SoundEffect objects, and hold on to them for later use
- (void)setupSounds
{
    NSBundle *mainBundle = [NSBundle mainBundle];
	
	_keyClickSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"KeyClick" ofType:@"caf"]];
	_correctKeyPressedSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"CorrectKeyPressed" ofType:@"caf"]];
	_wrongKeyPressedSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"WrongKeyPressed" ofType:@"caf"]];
	_puzzleCompletedSuccessfullySound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"PuzzleCompletedSuccessfully02" ofType:@"caf"]];
}

- (IBAction)playKeyClickSound:(id)sender
{
	NSString *title = [_object.title uppercaseString];
	UIButton *expectedButton = [self buttonFromASCIICode:[title characterAtIndex:_currentLetterPosition]];
    
	if (sender == expectedButton)																	// Shashwat Parhi: disabled key press sound on April 15, 2013
		[_keyClickSound play];																		// for wrong key, as per client request
}

- (IBAction)playCorrectKeyPressedSound {
	[_correctKeyPressedSound play];
}

- (IBAction)playWrongKeyPressedSound {
	//	[_wrongKeyPressedSound play];																// Shashwat Parhi: commented out on April 02, 2013, as per request from client
}

- (IBAction)playPuzzleCompletedSuccessfullySound {
	[_puzzleCompletedSuccessfullySound play];
}

- (void)playObjectTitleSound
{
	NSString *wordSoundFile = [[NSBundle mainBundle] pathForResource:_object.title ofType:@"caf"];
	NSURL *url = [NSURL fileURLWithPath:wordSoundFile];
	_wordPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
	_wordPlayer.volume = 1.0;
	[_wordPlayer play];
}

#pragma mark - Helper Functions

- (UIButton *)buttonFromASCIICode:(NSInteger)asciiCode
{
	UIButton *button;
	
	asciiCode -= 65;
	
	switch (asciiCode) {
		case 0:
			button = AKey;
			break;
			
		case 1:
			button = BKey;
			break;
			
		case 2:
			button = CKey;
			break;
			
		case 3:
			button = DKey;
			break;
			
		case 4:
			button = EKey;
			break;
			
		case 5:
			button = FKey;
			break;
			
		case 6:
			button = GKey;
			break;
			
		case 7:
			button = HKey;
			break;
			
		case 8:
			button = IKey;
			break;
			
		case 9:
			button = JKey;
			break;
			
		case 10:
			button = KKey;
			break;
			
		case 11:
			button = LKey;
			break;
			
		case 12:
			button = MKey;
			break;
			
		case 13:
			button = NKey;
			break;
			
		case 14:
			button = OKey;
			break;
			
		case 15:
			button = PKey;
			break;
			
		case 16:
			button = QKey;
			break;
			
		case 17:
			button = RKey;
			break;
			
		case 18:
			button = SKey;
			break;
			
		case 19:
			button = TKey;
			break;
			
		case 20:
			button = UKey;
			break;
			
		case 21:
			button = VKey;
			break;
			
		case 22:
			button = WKey;
			break;
			
		case 23:
			button = XKey;
			break;
			
		case 24:
			button = YKey;
			break;
			
		case 25:
			button = ZKey;
			break;
			
		default:
			break;
	}
	
	return button;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:touch.view];
    
    CGPoint point = [self.view convertPoint:touchLocation toView:self.keyboard];
    
    NSString *title = [_object.title uppercaseString];
	UIButton *expectedButton = [self buttonFromASCIICode:[title characterAtIndex:_currentLetterPosition]];
    
    NSLog(@"%f, %f, %f, %f", expectedButton.frame.origin.x, expectedButton.frame.origin.y, expectedButton.frame.size.height, expectedButton.frame.size.width);
    NSLog(@"%f - %f", point.x, point.y);
    
    if (CGRectContainsPoint(expectedButton.frame, point)) {
        [expectedButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    return YES;
}

- (IBAction)handleKeyPressed:(id)sender
{
	NSString *title = [_object.title uppercaseString];
	UIButton *expectedButton = [self buttonFromASCIICode:[title characterAtIndex:_currentLetterPosition]];
    
	PuzzlePieceView *piece = [_pieces objectAtIndex:_currentLetterPosition];
	CGRect frame = piece.frame;
	
    if (_puzzleComplete) return;
    
	if (sender == expectedButton) {
		frame.origin = piece.finalPoint;
		
		[self playCorrectKeyPressedSound];
		
		[[EventLogger sharedLogger] logEvent:LogEventCodeKeyReleased eventInfo:@{@"key": @"correct"}];
	}
	else if (_loopDetectorCount > 3) {
		frame.origin = piece.finalPoint;
		
		[self playWrongKeyPressedSound];
		_loopDetectorCount = 0;
		_autoCompletedPieces++;
		
		[[EventLogger sharedLogger] logEvent:LogEventCodeKeyReleased eventInfo:@{@"key": @"autoAdvanced"}];
	}
	else {
		[self playWrongKeyPressedSound];
		_loopDetectorCount++;
		[[EventLogger sharedLogger] logEvent:LogEventCodeKeyReleased eventInfo:@{@"key": @"wrong"}];
		
		return;												// without doing the animations
	}
	
	self.view.userInteractionEnabled = NO;
	
	[UIView animateWithDuration:0.5
						  delay:0
						options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 piece.frame = frame;
					 }
					 completion:^(BOOL finished) {
						 piece.isCompleted = YES;
						 
						 [self checkPuzzleState];
						 
						 self.view.userInteractionEnabled = YES;
					 }
	 ];
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
	
	if (isCompleted == NO)
		[self advanceToNextLetterPosition];
	else {
        _puzzleComplete = YES;
        [self presentPuzzleCompletionAnimation];
    }
}

- (void)advanceToNextLetterPosition
{
	NSString *title = [_object.title uppercaseString];
	UIButton *button = [self buttonFromASCIICode:[title characterAtIndex:_currentLetterPosition]];
	[self removeGlowFromObject:button];
	button.alpha = 0.5;
	
	_currentLetterPosition++;
	button = [self buttonFromASCIICode:[title characterAtIndex:_currentLetterPosition]];
	button.alpha = 1.0;
	
	if (_prefs.keyHighlightingEnabled == YES)
		[self applyGlowToObject:button];
	
	[_banner highlightLabelAtPosition:_currentLetterPosition];
	
	NSString *alphabet = [title substringWithRange:NSMakeRange(_currentLetterPosition, 1)];
	
	if ([alphabet isEqualToString:@"Z"])
		alphabet = @"Zee";
	
	NSString *alphabetSoundFile = [[NSBundle mainBundle] pathForResource:alphabet ofType:@"aifc"];
	NSURL *url = [NSURL fileURLWithPath:alphabetSoundFile];
	_alphabetPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
	_alphabetPlayer.volume = 1.0;
	[_alphabetPlayer play];
}

- (void)presentPuzzleCompletionAnimation
{
	[self playPuzzleCompletedSuccessfullySound];
	[[EventLogger sharedLogger] logEvent:LogEventCodePuzzleCompleted eventInfo:@{@"status": @"successful"}];
	
	//[self performSelector:@selector(delayedDismissSelf) withObject:nil afterDelay:1];
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
                else if ([_object.difficultyType doubleValue] < 10)
                    objectName = @"WellDone";
                else if ([_object.difficultyType doubleValue] > 12)
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
	
	[[EventLogger sharedLogger] logAttemptForPuzzle:_object inMode:PuzzleModeType state:state];
	[[EventLogger sharedLogger] logEvent:LogEventCodePuzzleCompleted eventInfo:@{@"status": status}];
    
	GlobalPreferences *prefs = [GlobalPreferences sharedGlobalPreferences];
	if (prefs.guidedModeEnabled == NO)
		[self dismissViewControllerAnimated:YES completion:nil];
	else [(GuidedModeViewController *)self.parentViewController presentNextPuzzle];
    
    self.motionManager = nil;
}

- (void)slideOutKeyboard
{
	CGRect frame = _keyboard.frame;
	_keyboard.frame = CGRectOffset(frame, 0, frame.size.height);
	_keyboard.hidden = NO;
}

- (void)slideInKeyboard
{
	CGRect frame = _keyboard.frame;
	CGFloat height = frame.size.height;
    
	[UIView animateWithDuration:0.5
						  delay:0.5
						options:0
					 animations:^{
						 _keyboard.frame = CGRectOffset(frame, 0, -height);
					 }
					 completion:nil
     ];
	
	[UIView animateWithDuration:0.5
						  delay:0.75
						options:0
					 animations:^{
						 _placeHolder.frame = CGRectOffset(_placeHolder.frame, 0, -height/4);
					 }
					 completion:^(BOOL finished) {
						 CGFloat offsetX = _placeHolder.frame.origin.x;
						 CGFloat offsetY = _placeHolder.frame.origin.y;
						 
						 for (Piece *piece in _object.pieces) {
							 PuzzlePieceView *pieceView = [[PuzzlePieceView alloc] initWithImage:[UIImage imageWithData:piece.pieceImage]];
							 pieceView.initialPoint = CGPointMake(0, 0);
							 CGPoint finalPosition = CGPointMake(offsetX + [piece.finalPositionX floatValue], offsetY + [piece.finalPositionY floatValue]);
							 pieceView.finalPoint = finalPosition;
							 
							 [self.view addSubview:pieceView];
                             
							 [_pieces addObject:pieceView];
						 }
						 
						 [self randomizeInitialPositionsOfPieces];
						 [self advanceToNextLetterPosition];
                         [self.view bringSubviewToFront:_keyboard];
					 }
	 ];
}

//Make TYPE mode closer to POINT mode to ensure smoother transition from POINT to TYPE

//TODO: refer to TouchPuzzleViewController randomizeInitialPositionsOfPieces
- (void)randomizeInitialPositionsOfPieces
{
	//CGRect outerRect = CGRectMake(0, 0, 2048, 1536);//include the outside of the screen
	CGRect screenRect = CGRectMake(0, 0, 1024, 768);//the main ipad screensize, but offsetted by(512,384)..
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

    
	while (i < [_pieces count]) {
		UIView *aPiece = [_pieces objectAtIndex:i];
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
       
        //detect the conflict between the piece and the placeholder
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
		

		pieceFrame.origin = CGPointMake(offsetX, offsetY);
		aPiece.frame = pieceFrame;
		i++;
	}
    // if all the pieces are outside the screen and do not intersct with each other...........
	for (UIView *piece in _pieces)
    {
		//piece.frame = CGRectOffset(piece.frame, -512, -384);//move all the pieces to origin(0,0)
        //add gesture to all the pieces..
        
        UIPanGestureRecognizer *pan =
        [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(remindAnimation:)];
        
        pan.delegate = self;
        
        pan.cancelsTouchesInView = NO;
       
        [self.view addGestureRecognizer:pan];
        
        piece.userInteractionEnabled = NO;
    }
    
    
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(remindAnimation:)];
    
    [self.view addGestureRecognizer:tap];
     tap.delegate = self;
     tap.cancelsTouchesInView = NO;

    //add text to pieces...
    [self addCharacterOnPuzzlePiece];
    
}

-(void)addCharacterOnPuzzlePiece
{
    for (int i = 0; i < [_pieces count]; i++) {
        //get current character
        NSString *lableTitle=[[_object.title uppercaseString] substringWithRange:NSMakeRange(i, 1)];
        
        //set up background image, location and contentmode
        UIImageView *charBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KeyboardButton.png"] ];
        charBackground.contentMode = UIViewContentModeScaleAspectFill;
        charBackground.frame = CGRectMake(((UIView *)[_pieces objectAtIndex:i]).frame.size.width/2-20, ((UIView*)[_pieces objectAtIndex:i]).frame.size.height/2-20, 40, 40);
        
        
        //set up the text, location, color and font
        UILabel *fontLable = [[UILabel alloc] init];
        fontLable.frame = CGRectMake(((UIView *)[_pieces objectAtIndex:i]).frame.size.width/2-20, ((UIView*)[_pieces objectAtIndex:i]).frame.size.height/2-20, 40, 40);
        fontLable.textAlignment = UITextAlignmentCenter;
        fontLable.text = lableTitle;
        fontLable.textColor = [UIColor colorWithRed:(255.0/255.0) green:(255.0/255) blue:(255.0/255) alpha:1.0];
        [fontLable setBackgroundColor:[UIColor clearColor]];
        
        UIFont *avenirBold = [UIFont fontWithName:@"AvenirNext-Medium" size:24.];
        if (avenirBold == nil) {
            fontLable.font = [UIFont systemFontOfSize:24];
        }
        else {
            fontLable.font = avenirBold;
        }
        
        //add subviews
        [[_pieces objectAtIndex:i] addSubview: charBackground];
        [[_pieces objectAtIndex:i] addSubview: fontLable];
    }
}

#pragma mark - pieces Gesture method
- (void)remindAnimation:(UIGestureRecognizer *)recognizer {
    CGPoint touchPoint = [recognizer locationInView:self.view];
    
        
    if (pathLayer) {
        
        [pathLayer removeAllAnimations];
        [pathLayer removeFromSuperlayer];
        
    }
    
    CGPoint finalPoint = [self buttonFromASCIICode:[[_object.title uppercaseString] characterAtIndex:_currentLetterPosition]].layer.position;
    finalPoint = [self.view convertPoint:finalPoint fromView:self.keyboard];
    UIBezierPath *path = [UIBezierPath bezierPath];
//    CGPoint finalPoint = CGPointMake(touchedPiece.finalPoint.x + touchedPiece.frame.size.width/2, touchedPiece.finalPoint.y + touchedPiece.frame.size.height/2);
    [path moveToPoint:touchPoint];
    [path addLineToPoint:finalPoint];
    
    pathLayer = [CAShapeLayer layer];
    pathLayer.hidden = NO;
    pathLayer.frame = self.view.layer.bounds;
    pathLayer.geometryFlipped = NO;
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = [[UIColor colorWithWhite:1 alpha:0.6] CGColor];
    pathLayer.fillColor = nil;
    pathLayer.lineWidth = 9.0f;
    
    [self.view.layer addSublayer:pathLayer];
    
    CALayer *focusLayer = [CALayer layer];
    UIImage *foucsImage = [UIImage imageNamed:@"focus.png"];
    focusLayer.contents = (id)foucsImage.CGImage;
    focusLayer.frame = CGRectMake(touchPoint.x, touchPoint.y, 25, 25);
    focusLayer.position = CGPointZero;
    [pathLayer addSublayer:focusLayer];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 0.8;
    pathAnimation.delegate = self;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat: 1.0f];
    [pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
    CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    keyFrameAnimation.path = path.CGPath;
    keyFrameAnimation.delegate = self;
    keyFrameAnimation.duration = 0.8;
    [focusLayer addAnimation:keyFrameAnimation forKey:@"position"];
    
    
    for ( UIView *piece in _pieces) {
        
        if (CGRectContainsPoint(piece.frame, touchPoint)) {
            
            [((UIButton *)[self buttonFromASCIICode:[[_object.title uppercaseString] characterAtIndex:_currentLetterPosition]]) setBackgroundImage: [UIImage imageNamed:@"KeyboardButton_hightlighted"] forState:UIControlStateNormal];
            
            //set up animation
            CAKeyframeAnimation * anim = [ CAKeyframeAnimation animationWithKeyPath:@"transform" ] ;
            anim.values = @[ [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-_prefs.typeSignificancy, 0.0f, 0.0f) ], [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(_prefs.typeSignificancy, 0.0f, 0.0f) ] ] ;
            anim.autoreverses = YES ;
            anim.repeatCount = 4.0f ;
            anim.duration = 0.07f ;
            
            
            //animate the corresponding key on the keyboard
            [[self buttonFromASCIICode:[[_object.title uppercaseString] characterAtIndex:_currentLetterPosition]].layer addAnimation:anim forKey:nil];
            
            CAKeyframeAnimation * anim1 = [ CAKeyframeAnimation animationWithKeyPath:@"transform" ] ;
            anim1.values = @[ [ NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)], [ NSValue valueWithCATransform3D:CATransform3DMakeScale(_prefs.typeSignificancy*0.3, _prefs.typeSignificancy*0.3, 1.0f) ]];
            anim1.autoreverses = NO ;
            anim1.repeatCount = 4;
            anim1.duration = 0.07f ;
            
            [[self buttonFromASCIICode:[[_object.title uppercaseString] characterAtIndex:_currentLetterPosition]].layer addAnimation:anim1 forKey:nil];
            [self performSelector:@selector(changeBGColorBack)withObject:nil afterDelay:0.56];
            
            [[EventLogger sharedLogger] logEvent:LogEventCodeTypeReminder eventInfo:@{@"key": [[_object.title uppercaseString] substringWithRange:NSMakeRange(_currentLetterPosition, 1)]}];
            
            break;
        }
    }
}

-(void)changeBGColorBack
{
    [((UIButton *)[self buttonFromASCIICode:[[_object.title uppercaseString] characterAtIndex:_currentLetterPosition]]) setBackgroundImage: [UIImage imageNamed:@"KeyboardButton.png"] forState:UIControlStateNormal];
}

#pragma mark - Image Manipulation Methods

- (void)applyShadowToObject:(UIView *)object
{
	object.layer.shadowColor = [[UIColor blackColor] CGColor];
    object.layer.shadowOffset = CGSizeMake(0, 10);
    object.layer.shadowOpacity = 0.25;
    object.layer.shadowRadius = 5;
    object.clipsToBounds = NO;
}

- (void)applyGlowToObject:(UIView *)object
{
	object.layer.shadowColor = [[UIColor yellowColor] CGColor];
    object.layer.shadowOffset = CGSizeMake(0, 0);
    object.layer.shadowOpacity = 10;
    object.layer.shadowRadius = 10;
    object.clipsToBounds = NO;
}

- (void)removeGlowFromObject:(UIView *)object
{
	object.layer.shadowColor = [[UIColor clearColor] CGColor];
    object.layer.shadowOffset = CGSizeMake(0, 0);
    object.layer.shadowOpacity = 0;
    object.layer.shadowRadius = 0;
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
    //[TestFlight passCheckpoint:@"Back button Tapped in Type mode"];
    
	[_backOverlayTimer invalidate];
	_backButtonPressed = YES;
	[self performSelector:@selector(delayedDismissSelf) withObject:nil afterDelay:0];
}

- (IBAction)handleAdminButtonPressed:(id)sender
{
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

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//	return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft;
//}

-(BOOL)shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark animation delegate method
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag{
    
    [pathLayer removeAllAnimations];
    pathLayer.hidden = YES;
    [pathLayer removeFromSuperlayer];
    
}

@end
