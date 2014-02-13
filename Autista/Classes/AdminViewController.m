//
//  AdminViewController.m
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
#import "AdminViewController.h"
#import "PuzzleStateView.h"
#import "Scene.h"
#import "PuzzleObject.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Attempt.h"
#import "EventLogger.h"
#import "GlobalPreferences.h"
#import "AppDelegate.h"
#import "AutistaIAPHelper.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AdminViewController ()

@end

@implementation AdminViewController

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
    [TestFlight passCheckpoint:@"Admin Screen opened"];
    _prefs = [GlobalPreferences sharedGlobalPreferences];

    if (_prefs.betaTesting) {
        self.restoreButton.hidden=YES;
        self.restoreButton.userInteractionEnabled=NO;
    }

	UIFont *avenir = [UIFont fontWithName:@"AvenirNext" size:12.];
	
	if (avenir == nil) {
		_guidedModeInfoLabel.font = [UIFont systemFontOfSize:12];
		_snapBackInfoLabel.font = [UIFont systemFontOfSize:12];
		_keyHighlightingInfoLabel.font = [UIFont systemFontOfSize:12];
		_slidersInfoLabel.font = [UIFont systemFontOfSize:12];
	}
    
	_resetSlidersButton.layer.cornerRadius = 13.5;
	
	if ([MFMailComposeViewController canSendMail] == NO) {
		_sendLogsButton.hidden = YES;
		_logSizeLabel.hidden = YES;
	}
	else {
		_sendLogsButton.layer.cornerRadius = 13.5;
		_logSizeLabel.text = [NSString stringWithFormat:@"Log size: %u entries", [EventLogger numberOfLogs]];
	}
	
	_backgroundMusicSwitch.on = _prefs.backgroundMusicEnabled;
	_guidedModeSwitch.on = _prefs.guidedModeEnabled;
	_snapbackSwitch.on = _prefs.snapBackEnabled;
	_highlightKeySwitch.on = _prefs.keyHighlightingEnabled;
    
    _praisePromptSwitch.on = _prefs.praisePromptEnabled;

    _ampThresh.value = _prefs.ampThresh;
    _snapDistance.value = _prefs.snapDistance;
	_adjustDragFrequency.value = _prefs.dragPuzzleFrequency;
	_adjustSpeakFrequency.value = _prefs.speakPuzzleFrequency;
	_adjustTypeFrequency.value = _prefs.typePuzzleFrequency;
	
	if (_scene != nil) {
		UIView *dummyStateView = [_sceneDashboard viewWithTag:100];							// we placed one sample into the XIB file for good measure
		CGRect stateRect = dummyStateView.frame;

		[dummyStateView removeFromSuperview];												// get rid of it...
		
		for (PuzzleObject *object in _scene.puzzleObjects) {
			NSDictionary *statesDict = [self puzzleStatesForPuzzle:object];
			PuzzleStateView *stateView = [[PuzzleStateView alloc] initWithFrame:stateRect];
			stateView.imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:object.completedImage]];
			stateView.dragState = [statesDict[@"dragState"] intValue];
			stateView.typeState = [statesDict[@"typeState"] intValue];
			stateView.sayState = [statesDict[@"sayState"] intValue];
			
			[_sceneDashboard addSubview:stateView];
			stateRect = CGRectOffset(stateRect, stateView.frame.size.width, 0);
		}
		
		CGRect frame = _sceneDashboard.frame;
		frame.size.width = stateRect.origin.x;
		frame.origin.x = (1024 - frame.size.width) / 2;
		_sceneDashboard.frame = frame;
		_sceneDashboard.layer.cornerRadius = 10;
		_sceneDashboard.layer.borderColor = [UIColor whiteColor].CGColor;
		_sceneDashboard.layer.borderWidth = 2;
		
		_sceneDashboard.hidden = NO;
	}
	
	[[EventLogger sharedLogger] logEvent:LogEventCodeAdminModeEntered eventInfo:nil];
}

- (NSDictionary *)puzzleStatesForPuzzle:(PuzzleObject *)object
{
	PuzzleState dragState = PuzzleStateNotAttempted, sayState = PuzzleStateNotAttempted, typeState = PuzzleStateNotAttempted;
	
	for (Attempt *attempt in object.attempts) {
		NSInteger score = [attempt.score intValue];
		
		switch ([attempt.mode intValue]) {
			case PuzzleModePoint:
				dragState = dragState < score ? score : dragState;							// get the max score for this type of puzzle
				break;
			
			case PuzzleModeSay:
				sayState = sayState < score ? score : sayState;
				break;
			
			case PuzzleModeType:
				typeState = typeState < score ? score : typeState;
				break;
				
			default:
				break;
		}
	}
	
	return @{@"dragState":@(dragState), @"sayState":@(sayState), @"typeState":@(typeState)};
}

//- (void)viewWillAppear:(BOOL)animated
//{
//	self.view.transform = CGAffineTransformMakeScale(1.5, 1.5);
//	self.view.alpha = 0.5;
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//	self.view.transform = CGAffineTransformIdentity;
//	self.view.alpha = 1.0;
//}

- (IBAction)handleSendLogDataPressed:(id)sender
{
    AudioServicesPlaySystemSound(0x450);
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	
	NSString *timeZone = [dateFormatter.timeZone abbreviationForDate:[NSDate date]];	
	NSString *logFilename = [NSString stringWithFormat:@"Autista Logs %@ %@.txt", [dateFormatter stringFromDate:[NSDate date]], timeZone];

	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc]init];
	picker.mailComposeDelegate = self;
	[picker setSubject:@"Autista Log data from my iPad"];
	
	NSData *logData = [[EventLogger sharedLogger] logData];
	[picker addAttachmentData:logData mimeType:@"text/text" fileName:logFilename];
	[picker setMessageBody:@"I am sending Autista log data via email..." isHTML:YES];
	[picker setToRecipients:@[@"play@madratgames.com"]];
	
	[self presentModalViewController:picker animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[controller dismissViewControllerAnimated:YES completion:nil];
	
	if (result == MFMailComposeResultSaved || result == MFMailComposeResultSent) {
		[[EventLogger sharedLogger] deleteLogData];
	
		_logSizeLabel.text = @"Logs emptied";
	}
}

- (IBAction)handleCloseOverlayPressed:(id)sender
{
    AudioServicesPlaySystemSound(0x450);
    /*if (_prefs.backgroundMusicEnabled != _backgroundMusicSwitch.on)
        [TestFlight passCheckpoint:@"Admin Setting changed : Background Music switch"];
     */
    if (_prefs.ampThresh != _ampThresh.value)
        [TestFlight passCheckpoint:@"Admin Setting changed : Amplitude Threshold"];
    if (_prefs.snapBackEnabled != _snapbackSwitch.on)
        [TestFlight passCheckpoint:@"Admin Setting changed : Snap Back switch"];
    if (_prefs.praisePromptEnabled != _praisePromptSwitch.on)
        [TestFlight passCheckpoint:@"Admin Setting changed : Praise Prompt switch"];
    if (_prefs.snapDistance != _snapDistance.value)
        [TestFlight passCheckpoint:@"Admin Setting changed : Snapping Distance"];
    if ((_prefs.dragPuzzleFrequency != _adjustDragFrequency.value) || (_prefs.typePuzzleFrequency != _adjustTypeFrequency.value) || (_prefs.speakPuzzleFrequency != _adjustSpeakFrequency.value)) {
        [TestFlight passCheckpoint:@"Admin Setting changed : Point / Type / Say frequency"];
        NSString * str = [NSString stringWithFormat:@"Admin Setting changed : Point from %f to %f, Type from %f to %f, Say from %f to %f", _prefs.dragPuzzleFrequency, _adjustDragFrequency.value, _prefs.typePuzzleFrequency, _adjustTypeFrequency.value, _prefs.speakPuzzleFrequency, _adjustSpeakFrequency.value];
        [TestFlight passCheckpoint:str];
    }
    
	/*if (_prefs.backgroundMusicEnabled == YES && _backgroundMusicSwitch.on == NO) {
        _prefs.backgroundMusicEnabled = _backgroundMusicSwitch.on;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AdminWantsBackgroundMusicOffNotification" object:nil];
    }
	else if (_prefs.backgroundMusicEnabled == NO && _backgroundMusicSwitch.on == YES) {
        _prefs.backgroundMusicEnabled = _backgroundMusicSwitch.on;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AdminWantsBackgroundMusicNotification" object:nil];
    }*/
	
	_prefs.guidedModeEnabled = _guidedModeSwitch.on;
	_prefs.snapBackEnabled = _snapbackSwitch.on;
	_prefs.keyHighlightingEnabled = _highlightKeySwitch.on;
    
    _prefs.praisePromptEnabled = _praisePromptSwitch.on;

	_prefs.dragPuzzleFrequency = _adjustDragFrequency.value;
	_prefs.speakPuzzleFrequency = _adjustSpeakFrequency.value;
	_prefs.typePuzzleFrequency = _adjustTypeFrequency.value;
    _prefs.snapDistance = _snapDistance.value;
    _prefs.ampThresh = _ampThresh.value;
	
	[[EventLogger sharedLogger] logEvent:LogEventCodeAdminModeExited eventInfo:nil];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)handleBGMusicChanged:(id)sender
{
    if (_prefs.backgroundMusicEnabled != _backgroundMusicSwitch.on)
        [TestFlight passCheckpoint:@"Admin Setting changed : Background Music switch"];
    
	if (_prefs.backgroundMusicEnabled == YES && _backgroundMusicSwitch.on == NO) {
        _prefs.backgroundMusicEnabled = _backgroundMusicSwitch.on;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AdminWantsBackgroundMusicOffNotification" object:nil];
    }
	else if (_prefs.backgroundMusicEnabled == NO && _backgroundMusicSwitch.on == YES) {
        _prefs.backgroundMusicEnabled = _backgroundMusicSwitch.on;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AdminWantsBackgroundMusicNotification" object:nil];
    }
}

- (IBAction)handleAmpThreshChanged:(id)sender
{
    /*if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Adjust Speaker Volume"
                                                        message:@"To avoid the mic from detecting the speaker's sounds, please adjust the Speaker Volume level close to 35%."
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }*/
}

- (IBAction)handleSliderChangedValue:(id)sender
{
	UISlider *slider1 = (UISlider *)sender;
	UISlider *slider2, *slider3;
	
	if (slider1 == _adjustDragFrequency) {
		slider2 = _adjustSpeakFrequency;
		slider3 = _adjustTypeFrequency;
	}
	else if (slider1 == _adjustSpeakFrequency) {
		slider2 = _adjustDragFrequency;
		slider3 = _adjustTypeFrequency;
	}
	else {
		slider2 = _adjustDragFrequency;
		slider3 = _adjustSpeakFrequency;
	}
	
	CGFloat slider1Value = slider1.value;
	CGFloat slider2Value = slider2.value;
	CGFloat slider3Value = slider3.value;
	
	CGFloat slider1ValueComplement = slider2Value + slider3Value;
	CGFloat prevSlider1Value = 100 - (slider1ValueComplement);
	CGFloat delta = slider1Value - prevSlider1Value;
	
	if (slider1ValueComplement > 0)
		slider2Value -= delta * slider2Value / slider1ValueComplement;
	else slider2Value = -1 * delta / 2;
	
	slider3Value = 100 - (slider1Value + slider2Value);
		
	[slider2 setValue:slider2Value animated:YES];
	[slider3 setValue:slider3Value animated:YES];
}

- (IBAction)restoreTapped:(id)sender {
    //NSLog(@"Tapped Restore button");
    [TestFlight passCheckpoint:@"Restore button Tapped"];

    [[AutistaIAPHelper sharedInstance] restoreCompletedTransactions];
}

- (IBAction)handleResetSlidersPressed:(id)sender
{
    AudioServicesPlaySystemSound(0x450);
	[_ampThresh setValue:4 animated:YES];
	[_snapDistance setValue:100 animated:YES];
	[_adjustDragFrequency setValue:60 animated:YES];
	[_adjustTypeFrequency setValue:20 animated:YES];
	[_adjustSpeakFrequency setValue:20 animated:YES];
}

- (IBAction)handleResetAppPressed:(id)sender
{
    AudioServicesPlaySystemSound(0x450);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                      message:@"This will reset the User data of the puzzles attempted so far."
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Reset", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Reset"])
    {
        [TestFlight passCheckpoint:@"Reset App button Tapped"];
        [[EventLogger sharedLogger] deleteAttempts];
    }
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
