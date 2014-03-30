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
#import <AVFoundation/AVFoundation.h>


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
@interface AdminViewController ()<AVAudioRecorderDelegate>
//for record
@property NSMutableArray *recordFilePathArray;
@property AVAudioRecorder *recorder;
@property AVAudioPlayer *player;
@property NSMutableArray * praiseFileLabelArray;
//for itunes
@property MPMusicPlayerController *myPlayer;
@property NSMutableArray *praiseFileLabelArrayForPlist;
@property NSMutableArray *iTunesPlayList;

//for default
@property NSMutableArray *defaultPromptArray;
@property NSMutableArray *allPromptArray;

@property int currentSelection;

@property BOOL isEdited;

@property NSArray *recordPlayBtnArray;
@property NSArray *itunesPlayBtnArray;
@property  UIActivityIndicatorView *indicator;
@end

@implementation AdminViewController

@synthesize recorder,player,recordFilePathArray, praiseFileLabelArray,praiseFileLabelArrayForPlist,iTunesPlayList,defaultPromptArray,allPromptArray;

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
    _selectDistance.value = _prefs.selectDistance;
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
    
    
    NSDictionary *plistDictionary = [self createPlistForPraisePrefs];
    recordFilePathArray =  [[NSMutableArray alloc]initWithArray:[plistDictionary objectForKey:@"RecordedPraise"]];
    
    praiseFileLabelArrayForPlist = [[NSMutableArray alloc]initWithArray:[plistDictionary objectForKey:@"FileName"]];
    
    iTunesPlayList = [[NSMutableArray alloc]initWithArray:[plistDictionary objectForKey:@"iTunesPraiseURL"]];
    
    defaultPromptArray = [[NSMutableArray alloc]initWithArray:[plistDictionary objectForKey:@"DefaultPrompt"]];
   
    int segmentControlIndex = [((NSNumber *)[plistDictionary objectForKey:@"PromptPrefs"]) intValue];
    
    
    CGRect currentFrame = self.sayModeView.frame;
    currentFrame.origin.y = 328;
    self.sayModeView.frame = currentFrame;
    self.promptSourceSelectionView.hidden = YES;
    self.isEdited = NO;
    
    praiseFileLabelArray = [NSMutableArray array];
    [praiseFileLabelArray addObject:self.super_fileLabel];
    [praiseFileLabelArray addObject:self.awesome_fileLabel];
    [praiseFileLabelArray addObject:self.welldone_fileLabel];
    [praiseFileLabelArray addObject:self.try_fileLabel];
    
    self.recordPlayBtnArray = [NSArray arrayWithObjects:self.super_Btn_Play,self.awesome_Btn_Play, self.welldone_Btn_Play,self.try_Btn_Play, nil];
    
    self.itunesPlayBtnArray = [NSArray arrayWithObjects:self.super_itunes_Btn_Play, self.awesome_itunes_Btn_Play, self.welldone_itunes_Btn_Play,self.try_itunes_Btn_Play, nil];
    for (int i =0; i < [praiseFileLabelArray count]; i++) {
        ((UILabel *)[praiseFileLabelArray objectAtIndex:i]).text = [praiseFileLabelArrayForPlist objectAtIndex:i];
       
    }
    
    [self.promptSourceSegment setSelectedSegmentIndex:segmentControlIndex];
    [self updatePromptViewWith:segmentControlIndex];
    
//    [self.promptPickerView setDelegate:self];
//    [self.promptPickerView setDataSource:self];
//    self.promptPickerView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
//    
//    [self getPromptFilesFromDirectory];

}

-(void)updatePromptViewWith:(int)controlIndex
{
    switch (controlIndex) {
        case 0:
            self.awesome_descLabel.text = @"A praise prompt to encourage the child once a hard puzzle is completed.";
            self.super_descLabel.text = @"A praise prompt to encourage the child once a medium puzzle is completed.";
            self.welldone_descLabel.text = @"A praise prompt to encourage the child once a easy puzzle is completed.";
            self.tryagain_descLabel.text = @"A praise prompt to encourage the child once a puzzle is not completed.";
            
            self.recordView.hidden = YES;
            self.itunesView.hidden = YES;
            for (int i = 0; i < [praiseFileLabelArray count]; i++) {
                ((UILabel *)[self.praiseFileLabelArray objectAtIndex:i]).text = [[self.defaultPromptArray objectAtIndex:i] stringByAppendingString:@".caf"];
            }
            
            
            
            break;
            
        case 1:
            self.awesome_descLabel.text = @"Record a praise prompt to encourage the child once a hard puzzle is completed. (Less than 2 seconds)";
            self.super_descLabel.text = @"Record a praise prompt to encourage the child once a medium puzzle is completed. (Less than 2 seconds)";
            self.welldone_descLabel.text = @"Record a praise prompt to encourage the child once a easy puzzle is completed (Less than 2 seconds).";
            self.tryagain_descLabel.text = @"Record a praise prompt to encourage the child once a puzzle is not completed (Less than 2 seconds).";
            
            self.recordView.hidden = NO;
            self.itunesView.hidden = YES;
            
            for (int i =0; i<[praiseFileLabelArrayForPlist count]; i++) {
                [((UILabel *)[praiseFileLabelArray objectAtIndex:i]) setText:[praiseFileLabelArrayForPlist objectAtIndex:i]];
                if ([[praiseFileLabelArrayForPlist objectAtIndex:i]isEqualToString:@""]) {
                    ((UIButton *)[self.recordPlayBtnArray objectAtIndex:i]).hidden = YES;
                }
                else{
                    ((UIButton *)[self.recordPlayBtnArray objectAtIndex:i]).hidden = NO;
                }
                
            }
            
            break;
            
        case 2:
            self.awesome_descLabel.text = @"Select a praise prompt to encourage the child once a hard puzzle is completed. (Less than 2 seconds)";
            self.super_descLabel.text = @"Select a praise prompt to encourage the child once a medium puzzle is completed. (Less than 2 seconds)";
            self.welldone_descLabel.text = @"Select a praise prompt to encourage the child once a easy puzzle is completed. (Less than 2 seconds)";
            self.tryagain_descLabel.text = @"Select a praise prompt to encourage the child once a puzzle is not completed. (Less than 2 seconds)";
            
            self.recordView.hidden = YES;
            self.itunesView.hidden = NO;
            
            for (int i =0; i<[iTunesPlayList count]; i++) {
                [((UILabel *)[praiseFileLabelArray objectAtIndex:i]) setText:[iTunesPlayList objectAtIndex:i]];
                
                if ([[iTunesPlayList objectAtIndex:i]isEqualToString:@""]) {
                    ((UIButton *)[self.itunesPlayBtnArray objectAtIndex:i]).hidden = YES;
                }
                else{
                    ((UIButton *)[self.itunesPlayBtnArray objectAtIndex:i]).hidden = NO;
                }
                
            }
            
            break;
    }
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
    if (_prefs.selectDistance != _selectDistance.value)
        [TestFlight passCheckpoint:@"Admin Setting changed : Selecting Distance"];
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
    _prefs.selectDistance = _selectDistance.value;
    _prefs.ampThresh = _ampThresh.value;
    
    //save the recorded sound url to the plist
    NSMutableDictionary *currentDict = [[NSMutableDictionary alloc]init];
    [currentDict setValue:recordFilePathArray forKey:@"RecordedPraise"];
    [currentDict setValue:praiseFileLabelArrayForPlist forKey:@"FileName"];
    [currentDict setValue:iTunesPlayList forKey:@"iTunesPraiseURL"];
    [currentDict setValue:defaultPromptArray forKey:@"DefaultPrompt"];
    NSNumber* segmentIndex = [NSNumber numberWithInteger:[self.promptSourceSegment selectedSegmentIndex]];
    [currentDict setValue: segmentIndex forKey:@"PromptPrefs"];
    [self savePraiseIntoPlist:currentDict];
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
	[_selectDistance setValue:50 animated:YES];
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
- (IBAction)editPromptSource:(id)sender {
    self.isEdited = 1-self.isEdited;
    if (self.isEdited) {
        [self moveSpaceForSelectionViewWith:610];
        [self.promptSourceEdit_Btn setTitle:@"Save" forState:UIControlStateNormal];
        
    }
    else{
         self.promptSourceSelectionView.hidden = YES;
        [self moveSpaceForSelectionViewWith:328];
        [self.promptSourceEdit_Btn setTitle:@"Edit" forState:UIControlStateNormal];

        
    }
   
}


- (IBAction)chosePromptSoure:(id)sender
{
    
    [self updatePromptViewWith:self.promptSourceSegment.selectedSegmentIndex];
   
}

- (IBAction)recordPrompt:(id)sender
{
    UIButton *currentBtn = (UIButton *)sender;
    self.currentSelection = currentBtn.tag;
    ((UIButton *)[self.recordPlayBtnArray objectAtIndex:currentBtn.tag]).hidden = NO;
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    CGRect currentFrame =  self.indicator.frame;
    currentFrame.origin.y= 0.5*((UIButton *)[self.recordPlayBtnArray objectAtIndex:currentBtn.tag]).frame.size.height - currentFrame.size.height*0.5 ;
     currentFrame.origin.x= 0.5*((UIButton *)[self.recordPlayBtnArray objectAtIndex:currentBtn.tag]).frame.size.width - currentFrame.size.width*0.5 ;
    self.indicator.frame = currentFrame;
    [((UIButton *)[self.recordPlayBtnArray objectAtIndex:currentBtn.tag]) setImage:nil forState:UIControlStateNormal];
    [((UIButton *)[self.recordPlayBtnArray objectAtIndex:currentBtn.tag]) addSubview:self.indicator];
    [self.indicator startAnimating];
    
    [self startRecordingWith:currentBtn.tag];
    
}


- (IBAction)playRecordedPrompt:(id)sender
{
    UIButton *currentBtn = (UIButton *)sender;
    
    player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath: [recordFilePathArray objectAtIndex:currentBtn.tag ] ] error:nil];
    [player play];
    
    
}

-(void) moveSpaceForSelectionViewWith:(float)space
{
    CGRect frameForSayMode = self.sayModeView.frame;
    CGRect frameForPointMode = self.pointModeView.frame;
    
    frameForSayMode.origin.y = space;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.sayModeView.frame = frameForSayMode;
                     }
                     completion:^(BOOL finished){
                         if (self.isEdited) {
                              self.promptSourceSelectionView.hidden = NO;
                         }
                         
                     }];

}

-(void)startRecordingWith:(int)index{
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    
    
    // Create a new dated file
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [now description];
    NSMutableString* fileName = [[NSMutableString alloc]initWithFormat:caldate];
    fileName = [[fileName substringToIndex:10] stringByAppendingString:@".caf"];
    
    //set the label text here...
    
    NSString* recorderFilePath = [NSString stringWithFormat:@"%@/%@.caf", DOCUMENTS_FOLDER, caldate];
   
    if ([recordFilePathArray objectAtIndex:index]) {
        [recordFilePathArray removeObjectAtIndex:index];
    }
    [recordFilePathArray insertObject:recorderFilePath atIndex:index];
    
    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    err = nil;
    recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    if(!recorder){
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //prepare to record
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    
    BOOL audioHWAvailable = audioSession.inputIsAvailable;
    if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: @"Audio input hardware not available"
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [cantRecordAlert show];
        
        return;
    }
    
    // start recording
    [recorder recordForDuration:(NSTimeInterval) 1.5];
    if ([praiseFileLabelArrayForPlist objectAtIndex:index]) {
        [praiseFileLabelArrayForPlist removeObjectAtIndex:index];
    }
    [praiseFileLabelArrayForPlist insertObject:fileName atIndex:index];
    [((UILabel *)[self.praiseFileLabelArray objectAtIndex:index])setText: fileName];

}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    [((UIActivityIndicatorView *)[((UIButton *)[self.recordPlayBtnArray objectAtIndex:self.currentSelection]).subviews lastObject]) stopAnimating];
    [((UIActivityIndicatorView *)[((UIButton *)[self.recordPlayBtnArray objectAtIndex:self.currentSelection]).subviews lastObject]) removeFromSuperview];
    [((UIButton *)[self.recordPlayBtnArray objectAtIndex:self.currentSelection]) setImage:[UIImage imageNamed:@"play_icon.png"] forState:UIControlStateNormal];
}


- (IBAction)itunesSelection:(id)sender {
    
    self.currentSelection = ((UIButton *)sender).tag;
    MPMediaPickerController *picker =
    [[MPMediaPickerController alloc]
     initWithMediaTypes: MPMediaTypeAnyAudio];
    [picker setDelegate: self];
    [picker setAllowsPickingMultipleItems: YES];
    picker.prompt =
    NSLocalizedString (@"Add songs to play",
                       "Prompt in media item picker");
    [self presentModalViewController: picker animated: YES];

}

- (IBAction)playItunes:(id)sender {
    self.myPlayer = [MPMusicPlayerController applicationMusicPlayer];
    self.currentSelection = ((UIButton *)sender).tag;
    MPMediaPropertyPredicate *playlistPredicate = [MPMediaPropertyPredicate predicateWithValue:[iTunesPlayList objectAtIndex:self.currentSelection]forProperty:MPMediaItemPropertyTitle];
    NSSet *predicateSet = [NSSet setWithObjects:playlistPredicate, nil];
    MPMediaQuery *mediaTypeQuery = [[MPMediaQuery alloc] initWithFilterPredicates:predicateSet];
    [self.myPlayer setQueueWithQuery:mediaTypeQuery];
    [self.myPlayer play];
}


#pragma marks audio picker delegate method

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker
   didPickMediaItems: (MPMediaItemCollection *) collection
{
    
    //if the user only select one item and the duration of the item is less than 3s....
    if (collection.count == 1 && ((NSNumber *)[((MPMediaItem *)[collection.items firstObject]) valueForProperty:MPMediaItemPropertyPlaybackDuration])<=3000) {
       
        // assign a playback queue containing all media items on the device
        //[self.myPlayer setQueueWithItemCollection:self.musicPlayCollection];
        
        ((UILabel *)[praiseFileLabelArray objectAtIndex:self.currentSelection]).text = [((MPMediaItem *)[collection.items firstObject]) valueForProperty:MPMediaItemPropertyTitle];
       
        if ([iTunesPlayList objectAtIndex:self.currentSelection]) {
            [iTunesPlayList removeObjectAtIndex:self.currentSelection];
        }
        [iTunesPlayList insertObject:[((MPMediaItem *)[collection.items firstObject]) valueForProperty:MPMediaItemPropertyTitle] atIndex:self.currentSelection];
        
        [self dismissModalViewControllerAnimated: YES];
        //[self updatePlayerQueueWithMediaCollection: collection];
        
        ((UIButton *)[self.itunesPlayBtnArray objectAtIndex:self.currentSelection]).hidden = NO;
        
    }
    else if(((NSNumber *)[((MPMediaItem *)[collection.items firstObject]) valueForProperty:MPMediaItemPropertyPlaybackDuration])>3000)
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to add music"
                                                        message:@"The music should be less than 3s"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        ((UIButton *)[self.itunesPlayBtnArray objectAtIndex:self.currentSelection]).hidden = YES;
        ((UILabel *)[self.praiseFileLabelArray objectAtIndex:self.currentSelection]).text = @"";
    }
    else
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to add music"
                                                        message:@"please select only one item"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        ((UIButton *)[self.itunesPlayBtnArray objectAtIndex:self.currentSelection]).hidden = YES;
        ((UILabel *)[self.praiseFileLabelArray objectAtIndex:self.currentSelection]).text = @"";
        [self dismissModalViewControllerAnimated: YES];
    }
    
    
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    [self dismissModalViewControllerAnimated: YES];
}

-(NSDictionary *)createPlistForPraisePrefs
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

-(void)savePraiseIntoPlist:(NSDictionary *)plistDict{
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
	// get documents path
	NSString *documentsPath = [paths objectAtIndex:0];
	// get the path to our Data/plist file
	NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"PraisePrefs.plist"];
    // check to see if Data.plist exists in documents
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
	{
		// if not in documents, get property list from main bundle
		
        NSError *newError = nil;
        [[NSFileManager defaultManager]copyItemAtPath: [[NSBundle mainBundle] pathForResource:@"PraisePrefs" ofType:@"plist"] toPath:plistPath error: &newError];

	}
    
    
	// create NSData from dictionary
    NSData *plistFile = [NSPropertyListSerialization dataFromPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
	
    // check is plistData exists
	if(plistFile)
	{
		// write plistData to our Data.plist file
        [plistFile writeToFile:plistPath atomically:YES];
    }
    else
	{
        NSLog(@"Error in saveData: %@", error);
        
    }

}
/*
#pragma mark picker delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    if ([defaultPromptArray objectAtIndex:self.currentSelection]) {
        [defaultPromptArray removeObjectAtIndex:self.currentSelection];
    }
    [defaultPromptArray insertObject:[allPromptArray objectAtIndex:self.currentSelection] atIndex:self.currentSelection];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger numRows = [allPromptArray count];
    
    return numRows;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    
    title = [allPromptArray objectAtIndex:row];
    
    return title;
}



-(void)getPromptFilesFromDirectory
{
    NSArray* currentpath = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:@"/Users/shawnwu/Documents/Autista/Autista/Prompts/Final" error:nil ];
    allPromptArray = [NSMutableArray array];
    for (NSString *name in currentpath) {
        NSMutableString *newName = [NSMutableString stringWithFormat:name];
        newName = [newName substringToIndex:newName.length-4];
        [allPromptArray addObject:newName];
    }

}

*/
@end
