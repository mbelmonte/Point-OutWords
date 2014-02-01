//
//  SayPuzzleViewController.m
//  Autista
//
//  Created by Shashwat Parhi on 11/26/12.
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

#import <QuartzCore/QuartzCore.h>
#import "SayPuzzleViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AdminViewController.h"
#import "GuidedModeViewController.h"
#import "PuzzlePieceView.h"
#import "TypeBanner.h"
#import "Scene.h"
#import "PuzzleObject.h"
#import "Piece.h"
#import "EventLogger.h"
#import "GlobalPreferences.h"

#import "VULevelMeter.h"
#import "SoundEffect.h"
//#include "SpeakHereController.h"

#define LOW_SYLL_VOL_FAC 0.6
#define HIGH_SYLL_VOL_FAC 0.2
#define HIGHER_SYLL_VOL_FAC 0.1
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

/*
#define DBOFFSET -80.0
#define LOWER_THRESHOLD 0.5
#define UPPER_THRESHOLD 0.7
*/

@interface SayPuzzleViewController () {
    UIActivityIndicatorView *activityIndicator;
}
@property LanguageModelGenerator *lmGenerator;
@property PocketsphinxController*pocketsphinxController;
@property OpenEarsEventsObserver *openEarsEventsObserver;
@end

@implementation SayPuzzleViewController
@synthesize  lmGenerator,pocketsphinxController,openEarsEventsObserver;

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
    
    //initliaze the OpenEarsEventsObserver
    [self.openEarsEventsObserver setDelegate:self];
    lmGenerator=[[LanguageModelGenerator alloc]init];
    NSArray *words = [NSArray arrayWithObjects:@"UP", @"DOWN", @"LEFT", @"RIGHT", nil];
    NSString *name = @"NameIWantForMyLanguageModelFiles";
    NSError *err = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to create a Spanish language model instead of an English one.
    
    
    NSDictionary *languageGeneratorResults = nil;
    
    NSString *lmPath = nil;
    NSString *dicPath = nil;
    
    if([err code] == noErr) {
        
        languageGeneratorResults = [err userInfo];
        
        lmPath = [languageGeneratorResults objectForKey:@"LMPath"];
        dicPath = [languageGeneratorResults objectForKey:@"DictionaryPath"];
        
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
    
    //start to listen to the dialog
    [self.pocketsphinxController startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
    

    
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
 
	_prefs = [GlobalPreferences sharedGlobalPreferences];
	_launchedInGuidedMode = _prefs.guidedModeEnabled;
    _backButtonPressed = NO;
    sayNa.hidden = YES;
    syllLabel.hidden = YES;
    
    UPPER_THRESHOLD = log10 (_prefs.ampThresh);
    LOWER_THRESHOLD = 0.71*UPPER_THRESHOLD; //70% of upper_thresh
    DBOFFSET = -80 * (UPPER_THRESHOLD / .69); //.7 is default value of upper_thresh
    
    _pieces = [NSMutableArray array];
	_syllables = [_object.syllables componentsSeparatedByString:@"-"];

	[self setupSounds];
	[self initializeAudioEngine];
	[self performSelector:@selector(startRecordingEngine) withObject:nil afterDelay:1];
		
	_background.image = [UIImage imageWithData:_object.scene.puzzleBackgroundImage];
	
	_banner = [[TypeBanner alloc] initWithFrame:titleLabel.frame];
	_banner.highlightMode = BannerHighlightModeSyllable;
//	_banner.bannerFont = titleLabel.font;
    UIFont *avenirBold = [UIFont fontWithName:@"AvenirNext-Bold" size:80.];
    
	if (avenirBold == nil)
		_banner.bannerFont = [UIFont systemFontOfSize:80.];
    else
        _banner.bannerFont = avenirBold;

	_banner.bannerText = _object.syllables;
	
	[self.view addSubview:_banner];
    
    CGSize size = self.view.bounds.size;										// coordinates are flipped at this point
	CGFloat temp = size.width;
	size.width = size.height;
	size.height = temp;
    activityIndicator.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
    activityIndicator.center = CGPointMake(size.width / 2, size.height / 2);
    activityIndicator.layer.backgroundColor = [[UIColor colorWithWhite:0.5f alpha:0.5f] CGColor];
    [self.view addSubview:activityIndicator];

    //NSLog(@"Added activity monitor to scrollview and now starting animation at coordinates : %f, %f", size.width / 2, size.height / 2);

	titleLabel.hidden = YES;
	
	[_placeHolder removeFromSuperview];																// this got loaded via the NIB so we remove it and recreate this later
	_placeHolder = nil;

	[[NSNotificationCenter defaultCenter] postNotificationName:@"StartingSayTypePuzzle" object:nil];
	[[EventLogger sharedLogger] logEvent:LogEventCodePuzzlePresented eventInfo:@{@"Mode": @"Say"}];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (_adminVC != nil && _prefs.guidedModeEnabled == NO)		{
        [recorder stop];
        [levelTimer invalidate];
 
        // Shashwat Parhi: if returning from Admin screen
		[self dismissViewControllerAnimated:NO completion:nil];										// dismiss self, added on April 02, 2013 as per client request
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
	
	if (_launchedInGuidedMode == NO && _prefs.guidedModeEnabled == YES)	{							// most likely, admin changed this setting mid-stream
        [recorder stop];
        [levelTimer invalidate];
        
		[self dismissViewControllerAnimated:NO completion:nil];										// so bail out
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
	
	[self initializePuzzleState];
    [activityIndicator startAnimating];
    [self.view bringSubviewToFront:activityIndicator];
}

#pragma mark - Sound Effects

// Load sound files into SoundEffect objects, and hold on to them for later use
- (void)setupSounds {
    NSBundle *mainBundle = [NSBundle mainBundle];
	
	_puzzleCompletedSuccessfullySound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"PuzzleCompletedSuccessfully02" ofType:@"caf"]];
    
    _soundsMissing = NO;
    NSString * sayPath = [[NSBundle mainBundle] pathForResource:@"Say" ofType:@"caf"];
    NSURL *sayURL = [NSURL fileURLWithPath:sayPath];
    _sayItem = [AVPlayerItem playerItemWithURL:sayURL];
    
    NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];//pathForResource:@"Watermelon" ofType:nil inDirectory:@"Resources/Syllables/Fruits"];
    //NSLog(@"directory found ====== %@",bundleRoot);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:bundleRoot error:nil];
    NSString * objectName = [_object.syllables stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSPredicate *fltr;
    if ([_syllables count] == 1) {
        fltr = [NSPredicate predicateWithFormat:@"(self ENDSWITH '.caf') AND (self CONTAINS[c] %@)", objectName];
    }
    else {
        fltr = [NSPredicate predicateWithFormat:@"(self ENDSWITH '.caf') AND (self CONTAINS[c] %@) AND (self CONTAINS[c] 'Syll')", objectName];
    }
    NSArray *onlyWAVs = [dirContents filteredArrayUsingPredicate:fltr];
    //NSLog(@"directoryContents ====== %@",onlyWAVs);
    
    /*
    NSString *audioFilePath = [[NSBundle mainBundle] pathForResource:@"ss" ofType:@"wav"];
    NSURL *audioFileURL = [NSURL fileURLWithPath:audioFilePath];
    AVAudioPlayer *audioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:nil] autorelease];
    [audioPlayer prepareToPlay];
    [audioPlayer play];
    */

    if ([onlyWAVs count]>0) {
        _syllableSounds = [[NSMutableArray alloc] init];
        //_syllableURLs = [[NSMutableArray alloc] init];
        
        if ([_syllables count] == 1) {
            NSString *audioFilePath = [[NSBundle mainBundle] pathForResource:[onlyWAVs[0] stringByDeletingPathExtension] ofType:@"caf"];
            NSURL *audioFileURL = [NSURL fileURLWithPath:audioFilePath];
            AVAudioPlayer *syllableSound = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:nil];
            [_syllableSounds addObject:syllableSound];
            //[_syllableURLs addObject:audioFileURL];
            _firstSyllItem = [AVPlayerItem playerItemWithURL:audioFileURL];
        }
        else {
            for (int i = 0; i < [_syllables count]; i++) {
                NSString *str;
                str = [NSString stringWithFormat:@"Syll_%d",(i+1)];
                NSPredicate *syll = [NSPredicate predicateWithFormat:@"(self CONTAINS[c] %@)", str];
                NSArray *syllWAV = [onlyWAVs filteredArrayUsingPredicate:syll];
                //NSLog(@"str is %@, adding sound for %@", str, syllWAV[0]);

                NSString *audioFilePath = [[NSBundle mainBundle] pathForResource:[syllWAV[0] stringByDeletingPathExtension] ofType:@"caf"];
                NSURL *audioFileURL = [NSURL fileURLWithPath:audioFilePath];
                AVAudioPlayer *syllableSound = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:nil];
                [_syllableSounds addObject:syllableSound];
                if (i==0)
                    _firstSyllItem = [AVPlayerItem playerItemWithURL:audioFileURL];
                //[_syllableURLs addObject:audioFileURL];
            }
        }
    }
    else {
        _soundsMissing = YES;
        TFLog (@"Syllable sounds missing for this object");
    }
}

- (IBAction)playPuzzleCompletedSuccessfullySound {
	[_puzzleCompletedSuccessfullySound play];
}

- (void)initializePuzzleState
{
	_placeHolder = [[UIImageView alloc] initWithImage:[UIImage imageWithData:_object.placeholderImage]];
	_placeHolder.center = CGPointMake(512, 384);

	_currentSyllable = 0;
	[_banner highlightLabelAtPosition:_currentSyllable];
	   
	CGFloat offsetX = _placeHolder.frame.origin.x;
	CGFloat offsetY = _placeHolder.frame.origin.y;
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"imageName" ascending:YES]];
	NSArray *sortedPieces = [_object.pieces sortedArrayUsingDescriptors:sortDescriptors];
	
	int posInTitle = 0;
	int startOfNextSyllable = [[_syllables objectAtIndex:0] length];
	int currentSyllable = 0;
	
	for (Piece *piece in sortedPieces) {
		UIImage *image = [UIImage imageWithData:piece.pieceImage];
		CGPoint finalPosition = CGPointMake(offsetX + [piece.finalPositionX floatValue], offsetY + [piece.finalPositionY floatValue]);
		
		PuzzlePieceView *pieceView = [[PuzzlePieceView alloc] initWithImage:image];
		pieceView.image = [self desaturateImage:image saturation:0];			// normal state is desaturated version of image
		pieceView.highlightedImage = image;

		CGRect frame = pieceView.frame;
		frame.origin = finalPosition;
		pieceView.frame = frame;
		
		pieceView.initialPoint = finalPosition;
		pieceView.finalPoint = finalPosition;

		if (posInTitle >= startOfNextSyllable) {
			currentSyllable++;
			startOfNextSyllable += [[_syllables objectAtIndex:currentSyllable] length];
		}
		posInTitle++;
		
		pieceView.belongsToSyllable = currentSyllable;
			
		[self.view addSubview:pieceView];
		[_pieces addObject:pieceView];
	}
}

-(Float32)audioVolume
{
    /*//Include relevant files & frameworks - mediaplayer?
     musicPlayer = [[MPMusicPlayerController applicationMusicPlayer];
     currentVolume = musicPlayer.volume;
     */
    Float32 state;
    UInt32 propertySize = sizeof(CFStringRef);
    OSStatus n = AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareOutputVolume, &propertySize, &state);
    if( n )
        TFLog (@"audioVolume didnt work");// something didn't work...
    return state;
}

-(Float32)audioVolumeFac
{
    Float32 factor;
    Float32 vol;
    vol = [self audioVolume];
    factor = 1;
    
    if (vol >= .75)
        factor = HIGHER_SYLL_VOL_FAC;
    else if ((vol >= .5) & (vol < .75))
        factor = HIGH_SYLL_VOL_FAC;
    else if ((vol < .5) & (vol > .3))
        factor = LOW_SYLL_VOL_FAC;
    
    return factor;
}

- (void)initializeAudioEngine
{
	NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    //NSString *recorderFilePath = [NSString stringWithFormat:@"%@/%@.caf", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], @"cache"];
    //NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    
	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
							  [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
							  [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
							  [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
							  nil];
	
	NSError *error = nil;
	
    //Below lines added for ios7. may have to put a condition for these to be only there for ios7 and not for ios5 / 6
    audioSession = [AVAudioSession sharedInstance];
    //Older iPads
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        UInt32 doSetProperty = 1;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doSetProperty), &doSetProperty);
    }
    else
        [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    
    if(error) {
        TFLog(@"audioSession set category: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&error];
    if(error){
        TFLog(@"audioSession set active: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
        return;
    }
    
	recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
	if(error){
        TFLog(@"audioSession recorder init: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
        return;
    }
    
	if (recorder) {
		[recorder prepareToRecord];
        recorder.meteringEnabled = YES;
        [recorder record];
        lowPassResults = DBOFFSET;
        levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
    }
}

- (void)startRecordingEngine
{
    //RD
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        if (!_soundsMissing) {
                NSArray *queue = @[_sayItem, _firstSyllItem];
                _qplayer = [[AVQueuePlayer alloc] initWithItems:queue];
                _qplayer.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
                NSLog(@"system volume in start rec : %f", [self audioVolume]);
                /*if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
                    [_qplayer setVolume:[self audioVolumeFac]];
                 */
                [_qplayer play];
            }
    }
    sayNa.hidden = NO;
    syllLabel.text = _syllables[_currentSyllable];
    
    sayNa.alpha = 0.0f;
    // Then fades in after 1 second (the cross-fade animation will take 0.5s)
    [UIView animateWithDuration:0.5 delay:1.0 options:0 animations:^{
            sayNa.alpha = 1.0f;
        } completion:^(BOOL finished) {syllLabel.hidden = NO;     [activityIndicator stopAnimating];}
    ];

/*    AVAudioPlayer * syllableSound = _syllableSounds[_currentSyllable];
    [syllableSound prepareToPlay];
    [syllableSound play];
*/
}


- (void)levelTimerCallback:(NSTimer *)timer
{
	[recorder updateMeters];
	
	if (vuMeter.muteOn == YES)
		return;
	
	const double ALPHA = 0.05;
	double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
	lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
	Float32 decibelValue = 20.0*log10(lowPassResults);
	
	[vuMeter refreshWithValue:decibelValue];
	
	if (waitingForSilence == YES) {
        [activityIndicator startAnimating];
        //can put msg to be silent
		if (lowPassResults < LOWER_THRESHOLD) {
			waitingForSilence = NO;
            [activityIndicator stopAnimating];
            if (_currentSyllable < [_syllables count]) {
                syllLabel.text = _syllables[_currentSyllable];
                
                if (!_soundsMissing) {
                    AVAudioPlayer * syllableSound = _syllableSounds[_currentSyllable];
                    [syllableSound prepareToPlay];
                    NSLog(@"system volume in next syll : %f", [self audioVolume]);
                    /*if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
                     [syllableSound setVolume:[self audioVolumeFac]];
                     */
                    [syllableSound play];
                }
            }
        }
	}
	else if (lowPassResults > UPPER_THRESHOLD) {
		[self advanceToNextSyllable];
    }
}


- (void)advanceToNextSyllable
{
	if (_currentSyllable == [_syllables count])
		return;
    
	for (PuzzlePieceView *piece in _pieces) {
		if (piece.belongsToSyllable == _currentSyllable)
			piece.highlighted = YES;
	}

	_currentSyllable++;
	[_banner highlightLabelAtPosition:_currentSyllable];

	waitingForSilence = YES;
//	[levelTimer invalidate];
//	timeOutTimer = [NSTimer scheduledTimerWithTimeInterval: 2 target: self selector: @selector(timeoutTimerCallback:) userInfo: nil repeats: NO];
	
	if (_currentSyllable == [_syllables count])
		[self presentPuzzleCompletionAnimation];
}

- (void)timeoutTimerCallback:(NSTimer *)timer
{
	levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
}

- (UIImage *)desaturateImage:(UIImage *)image saturation:(CGFloat)saturation
{
	CIImage *beginImage = [CIImage imageWithCGImage:image.CGImage];
	CIContext *context = [CIContext contextWithOptions:nil];
	CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"
								  keysAndValues:kCIInputImageKey, beginImage,
						@"inputSaturation", [NSNumber numberWithFloat:saturation],
						@"inputBrightness", [NSNumber numberWithFloat:0.1],
						nil];
	
	CIImage *outputImage = [filter outputImage];
	CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
	UIImage *newImage = [UIImage imageWithCGImage:cgimg];
	
	CGImageRelease(cgimg);
	
	return newImage;
}

- (void)presentPuzzleCompletionAnimation
{
    [activityIndicator stopAnimating];

	[recorder stop];
	[levelTimer invalidate];

    [self playPuzzleCompletedSuccessfullySound];
    [self performSelector:@selector(promptAndFinish) withObject:nil afterDelay:0.5];
}

- (void) promptAndFinish
{
    //RD
    //Prompt : Easy (<10) - WellDone; Medium (10-12) - Super, Yay; Difficult (>12) - GoodJob, Awesome
    //NSLog(@"Difficulty Level of the object %@ for Say mode is : %@", _object.title, _object.difficultySpeak);
    NSString * objectName = @"Super";
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    /* When loop detection put in and auto_complete through loop detection enabled
     if (_autoCompletedPieces > 0)
        objectName = @"TryAgain";
     */
    if ([_object.difficultySpeak doubleValue] < 10)
        objectName = @"WellDone";
    else if ([_object.difficultySpeak doubleValue] > 12)
        objectName = @"Awesome";
    
    NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
    //NSLog(@"directory found ====== %@",bundleRoot);
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:bundleRoot error:nil];
    NSPredicate *fltr;
    fltr = [NSPredicate predicateWithFormat:@"(self ENDSWITH '.caf') AND (self CONTAINS[c] %@)", objectName];
    NSArray *onlyWAVs = [dirContents filteredArrayUsingPredicate:fltr];
    //NSLog(@"directoryContents ====== %@",onlyWAVs);
    
    NSString * promptPath = [[NSBundle mainBundle] pathForResource:[onlyWAVs[0] stringByDeletingPathExtension] ofType:@"caf"];
    NSURL *promptURL = [NSURL fileURLWithPath:promptPath];
    _finishPrompt = [[AVAudioPlayer alloc] initWithContentsOfURL:promptURL error:nil];
    [_finishPrompt prepareToPlay];
    [_finishPrompt play];

	[self performSelector:@selector(delayedDismissSelf) withObject:nil afterDelay:1];
}

- (void)delayedDismissSelf
{
    //NSLog(@"In Delayed Dismiss Self in Say Mode");
    //call to delayedDismissSelf needs chgs (as it cud be from back button too. in which case, state = completed etc shouldnt be there in this case (actually this attempt shud be cancelled coz it cant be classified as a failed try either)
    /*
	NSInteger state = PuzzleStateCompleted;
	NSString *status = @"successful";
	
	[[EventLogger sharedLogger] logAttemptForPuzzle:_object inMode:PuzzleModeSay state:state];
	[[EventLogger sharedLogger] logEvent:LogEventCodePuzzleCompleted eventInfo:@{@"status": status}];
    */
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EndedSayTypePuzzle" object:nil];
	
    NSString *status;
	NSInteger state;
	
	if (_backButtonPressed) {
		state = PuzzleStateAutoCompleted;
		status = @"unsuccessful";
	}
	else {
		state = PuzzleStateCompleted;
		status = @"successful";
	}
    
	[[EventLogger sharedLogger] logAttemptForPuzzle:_object inMode:PuzzleModeSay state:state];
	[[EventLogger sharedLogger] logEvent:LogEventCodePuzzleCompleted eventInfo:@{@"status": status}];
    
	GlobalPreferences *prefs = [GlobalPreferences sharedGlobalPreferences];
	if (prefs.guidedModeEnabled == NO)
		[self dismissViewControllerAnimated:YES completion:nil];
	else [(GuidedModeViewController *)self.parentViewController presentNextPuzzle];
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
    [TestFlight passCheckpoint:@"Back button Tapped in Say mode"];

    //NSLog(@"In Back Overlay");
	[_backOverlayTimer invalidate];
	
    [activityIndicator stopAnimating];
    
	[recorder stop];
	[levelTimer invalidate];
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

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - OpenEars Delegate Methods

- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (openEarsEventsObserver == nil) {
		openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	}
	return openEarsEventsObserver;
}
- (PocketsphinxController *)pocketsphinxController {
	if (pocketsphinxController == nil) {
		pocketsphinxController = [[PocketsphinxController alloc] init];
	}
	return pocketsphinxController;
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
	NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    //to do next......
}

- (void) pocketsphinxDidStartCalibration {
	NSLog(@"Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {
	NSLog(@"Pocketsphinx calibration is complete.");
}

- (void) pocketsphinxDidStartListening {
	NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
	NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
	NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
	NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
	NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
	NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
	NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFail { // This can let you know that something went wrong with the recognition loop startup. Turn on OPENEARSLOGGING to learn why.
	NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more.");
}
- (void) testRecognitionCompleted {
	NSLog(@"A test file that was submitted for recognition is now complete.");
}


@end
