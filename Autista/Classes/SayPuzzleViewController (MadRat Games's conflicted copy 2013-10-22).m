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

#define DBOFFSET -80.0
#define LOWER_THRESHOLD 0.5
#define UPPER_THRESHOLD 0.7

@interface SayPuzzleViewController () {
    UIActivityIndicatorView *activityIndicator;
}
@end

@implementation SayPuzzleViewController

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

    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

	_prefs = [GlobalPreferences sharedGlobalPreferences];
	_launchedInGuidedMode = _prefs.guidedModeEnabled;
	
    _pieces = [NSMutableArray array];
	_syllables = [_object.syllables componentsSeparatedByString:@"-"];

	[self setupSounds];
	[self initializeAudioEngine];
	[self performSelector:@selector(startRecordingEngine) withObject:nil afterDelay:5];
		
	_background.image = [UIImage imageWithData:_object.scene.puzzleBackgroundImage];
	
	_banner = [[TypeBanner alloc] initWithFrame:titleLabel.frame];
	_banner.highlightMode = BannerHighlightModeSyllable;
	_banner.bannerFont = titleLabel.font;
	_banner.bannerText = _object.syllables;
	
	[self.view addSubview:_banner];
    
    CGSize size = self.view.bounds.size;										// coordinates are flipped at this point
	CGFloat temp = size.width;
	size.width = size.height;
	size.height = temp;
    activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    activityIndicator.center = CGPointMake(size.width / 2, size.height / 2);
    [self.view addSubview:activityIndicator];
    NSLog(@"Added activity monitor to scrollview and now starting animation at coordinates : %f, %f", size.width / 2, size.height / 2);

	titleLabel.hidden = YES;
	
	[_placeHolder removeFromSuperview];																// this got loaded via the NIB so we remove it and recreate this later
	_placeHolder = nil;

	[[NSNotificationCenter defaultCenter] postNotificationName:@"StartingSayTypePuzzle" object:nil];
	[[EventLogger sharedLogger] logEvent:LogEventCodePuzzlePresented eventInfo:@{@"Mode": @"Say"}];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (_adminVC != nil && _prefs.guidedModeEnabled == NO)											// Shashwat Parhi: if returning from Admin screen
		[self dismissViewControllerAnimated:NO completion:nil];										// dismiss self, added on April 02, 2013 as per client request
	
	if (_launchedInGuidedMode == NO && _prefs.guidedModeEnabled == YES)								// most likely, admin changed this setting mid-stream
		[self dismissViewControllerAnimated:NO completion:nil];										// so bail out
	
	[self initializePuzzleState];
    [activityIndicator startAnimating];
}

#pragma mark - Sound Effects

// Load sound files into SoundEffect objects, and hold on to them for later use
- (void)setupSounds {
    NSBundle *mainBundle = [NSBundle mainBundle];
	
	_puzzleCompletedSuccessfullySound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"PuzzleCompletedSuccessfully02" ofType:@"caf"]];
    
    
    NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];//pathForResource:@"Watermelon" ofType:nil inDirectory:@"Resources/Syllables/Fruits"];
    NSLog(@"directory found ====== %@",bundleRoot);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:bundleRoot error:nil];
    NSString * objectName = [_object.syllables stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSPredicate *fltr;
    if ([_syllables count] == 1) {
        fltr = [NSPredicate predicateWithFormat:@"(self ENDSWITH '.wav') AND (self CONTAINS[c] %@)", objectName];
    }
    else {
        fltr = [NSPredicate predicateWithFormat:@"(self ENDSWITH '.wav') AND (self CONTAINS[c] %@) AND (self CONTAINS[c] 'Syll')", objectName];
    }
    NSArray *onlyWAVs = [dirContents filteredArrayUsingPredicate:fltr];
    NSLog(@"directoryContents ====== %@",onlyWAVs);
    
    _syllableSounds = [[NSMutableArray alloc] init];
    
    if ([_syllables count] == 1) {
        SoundEffect *syllableSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:[onlyWAVs[0] stringByDeletingPathExtension] ofType:@"wav"]];
        [_syllableSounds addObject:syllableSound];
    }
    else {
        for (int i = 0; i < [_syllables count]; i++) {
            NSString *str;
            str = [NSString stringWithFormat:@"Syll_%d",(i+1)];
            NSPredicate *syll = [NSPredicate predicateWithFormat:@"(self CONTAINS[c] %@)", str];
            NSArray *syllWAV = [onlyWAVs filteredArrayUsingPredicate:syll];
            NSLog(@"str is %@, adding sound for %@", str, syllWAV[0]);
            
            SoundEffect *syllableSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:[syllWAV[0] stringByDeletingPathExtension] ofType:@"wav"]];
            [_syllableSounds addObject:syllableSound];
        }
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

- (void)initializeAudioEngine
{
	NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
	
	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
							  [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
							  [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
							  [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
							  nil];
	
	NSError *error = nil;
	
    //Below lines added for ios7. may have to put a condition for these to be only there for ios7 and not for ios5 / 6
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if(error) {
        NSLog(@"audioSession set category: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&error];
    if(error){
        NSLog(@"audioSession set active: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
        return;
    }
    UInt32 doSetProperty = 1;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doSetProperty), &doSetProperty);
    //
    
	recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
	if(error){
        NSLog(@"audioSession recorder init: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
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
    SoundEffect * syllableSound = _syllableSounds[_currentSyllable];
    [syllableSound play];
    [activityIndicator stopAnimating];
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

    //RD
	if (_currentSyllable < [_syllables count]) {
        SoundEffect * syllableSound = _syllableSounds[_currentSyllable];
        [syllableSound play];
        [activityIndicator stopAnimating];
	}
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
	[self performSelector:@selector(delayedDismissSelf) withObject:nil afterDelay:1];
}

- (void)delayedDismissSelf
{
	NSInteger state = PuzzleStateCompleted;
	NSString *status = @"successful";
	
	[[EventLogger sharedLogger] logAttemptForPuzzle:_object inMode:PuzzleModeSay state:state];
	[[EventLogger sharedLogger] logEvent:LogEventCodePuzzleCompleted eventInfo:@{@"status": status}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EndedSayTypePuzzle" object:nil];
	
	GlobalPreferences *prefs = [GlobalPreferences sharedGlobalPreferences];
	if (prefs.guidedModeEnabled == NO)
		[self dismissViewControllerAnimated:YES completion:nil];
	else [(GuidedModeViewController *)self.parentViewController presentNextPuzzle];
}

- (IBAction)handleAdminButtonPressed:(id)sender
{
	_adminOverlayTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(showAdminOverlay) userInfo:nil repeats:NO];
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

@end
