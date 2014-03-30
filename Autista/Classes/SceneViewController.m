//
//  SceneViewController.m
//  Autista
//
//  Created by Shashwat Parhi on 9/15/12.
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
#import "SceneViewController.h"
#import "TouchPuzzleViewController.h"
#import "TypePuzzleViewController.h"
#import "SayPuzzleViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AdminViewController.h"
#import "Scene.h"
#import "Attempt.h"
#import "AppDelegate.h"
#import "EventLogger.h"
#import "GlobalPreferences.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface SceneViewController ()

@end

@implementation SceneViewController

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
	
	_prefs = [GlobalPreferences sharedGlobalPreferences];
	_objects = [NSMutableArray array];
	_background.image = [UIImage imageWithData:_scene.sceneBackgroundImage];

    NSArray *puzzleObjects = [_scene.puzzleObjects allObjects];
    
	for (int i = 0; i < [puzzleObjects count]; i++) {
		PuzzleObject *object = [puzzleObjects objectAtIndex:i];
		
		CGRect frame = CGRectMake([object.offsetX floatValue], [object.offsetY floatValue], [object.width floatValue], [object.height floatValue]);
		UIButton *button = [[UIButton alloc] initWithFrame:frame];
		button.tag = i+1;

        [button setImage:[UIImage imageWithData:object.placeholderImage] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(handleObjectPressed:) forControlEvents:UIControlEventTouchDown];
		[button addTarget:self action:@selector(cancelObjectPressed:) forControlEvents:UIControlEventTouchCancel];
		[button addTarget:self action:@selector(cancelObjectPressed:) forControlEvents:UIControlEventTouchDragExit];
		[button addTarget:self action:@selector(handleObjectReleased:) forControlEvents:UIControlEventTouchUpInside];
		
		[self applyShadowToObject:button];
		[self.view insertSubview:button belowSubview:_closeButton];
		[_objects addObject:button];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    _sayIndex = -1;
    //RD
    //can optimize by only checking for the object which u have come back from to this view & only if its successful and its count earlier was 0
    NSArray *puzzleObjects = [_scene.puzzleObjects allObjects];
	for (int i = 0; i < [puzzleObjects count]; i++) {
		PuzzleObject *object = [puzzleObjects objectAtIndex:i];
		UIButton *button = (UIButton*)[[self view] viewWithTag:i+1];
        [button setImage:[UIImage imageWithData:object.placeholderImage] forState:UIControlStateNormal];

        for (Attempt *attempt in object.attempts) {
            //NSLog(@"Puzzlestatecompleted value : %d, Puzzlestatepartiallycompleted value : %d, Puzzlestatenotattempted value : %d, Puzzlestateautocompleted value : %d", PuzzleStateCompleted, PuzzleStatePartiallyCompleted, PuzzleStateNotAttempted, PuzzleStateAutoCompleted);
            //NSLog(@"attempt.score : %d, for object : %@", [attempt.score intValue], object.title);
            if (attempt.score == [NSNumber numberWithInt:PuzzleStateCompleted])
                [button setImage:[UIImage imageWithData:object.completedImage] forState:UIControlStateNormal];
      }
	}
    
	if (_prefs.guidedModeEnabled == YES)								// most likely, admin changed this setting mid-stream
		[self dismissViewControllerAnimated:NO completion:nil];
	else {
		for (UIButton *button in _objects) {
			[self applyShadowToObject:button];
		}
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Cancel"]) {
        PuzzleObject *object = [[_scene.puzzleObjects allObjects] objectAtIndex:_sayIndex];
        _sayIndex = -1;
        [[EventLogger sharedLogger] logAttemptForPuzzle:object inMode:PuzzleModeSay state:PuzzleStatePartiallyCompleted];
        [[EventLogger sharedLogger] logEvent:LogEventCodePuzzleCompleted eventInfo:@{@"status": @"unsuccessful"}];
    }

    if([title isEqualToString:@"DONE"])
    {
        Float32 vol;
        vol = [self audioVolume];

//        if (vol > .5) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Speaker Volume Too High"
//                                                            message:@"To avoid the mic from detecting the speaker's sounds, please set the Speaker Volume to less than 50% and click DONE."
//                                                           delegate:self
//                                                  cancelButtonTitle:@"Cancel"
//                                                  otherButtonTitles:@"DONE", nil];
//            [alert show];
//        }
//        (vol <= .5) &&

        if (_sayIndex > -1) {
            PuzzleObject *object = [[_scene.puzzleObjects allObjects] objectAtIndex:_sayIndex];
            _sayIndex = -1;
            [self presentSayPuzzleView:object];
        }
    }
}

#pragma mark - User Interactions

- (IBAction)handleObjectPressed:(id)sender
{
    AudioServicesPlaySystemSound(0x450);
	UIView *button = sender;
	
	[UIView animateWithDuration:0.2
					 animations:^(void) {
						 button.layer.transform = CATransform3DMakeScale(0.95, 0.95, 1.0);
						 [self applyGlowToObject:button];
					 }
	];
}

- (IBAction)handleObjectReleased:(id)sender
{
	UIView *button = sender;
	NSInteger index = button.tag-1;
	
	[UIView animateWithDuration:0.2
					 animations:^(void) {
						 button.layer.transform = CATransform3DIdentity;
					 }
	];

	PuzzleObject *object = [[_scene.puzzleObjects allObjects] objectAtIndex:index];
	[[EventLogger sharedLogger] logEvent:LogEventCodeObjectSelected eventInfo:@{@"Object": object.title}];
	
	PuzzleMode mode = [[EventLogger sharedLogger] suggestModeForPuzzle:object];
    Float32 vol;
    vol = [self audioVolume];

	switch (mode) {
		case PuzzleModePoint:
			[self presentTouchPuzzleView:object];
			break;
		
		case PuzzleModeSay:
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
                [self presentSayPuzzleView:object];
//                if (vol > .5) {
//                    _sayIndex = index;
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Speaker Volume Too High"
//                                                                    message:@"To avoid the mic from detecting the speaker's sounds, please set the Speaker Volume to less than 50% and click DONE."
//                                                                   delegate:self
//                                                          cancelButtonTitle:@"Cancel"
//                                                          otherButtonTitles:@"DONE", nil];
//                    [alert show];
//                }
//                else
//                    [self presentSayPuzzleView:object];
            }
            else
                [self presentSayPuzzleView:object];
            break;

		case PuzzleModeType:
			[self presentTypePuzzleView:object];
			break;
	}
}

- (IBAction)cancelObjectPressed:(id)sender
{
	UIView *button = sender;
	
	[UIView animateWithDuration:0.2
					 animations:^(void) {
						 button.layer.transform = CATransform3DIdentity;
						 [self applyShadowToObject:button];
					 }
	 ];
}


// the function that really in charge of navigating views................
- (void)presentTouchPuzzleView:(PuzzleObject *)object
{
	TouchPuzzleViewController *puzzleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TouchPuzzleViewController"];
	puzzleVC.object = object;
	[puzzleVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
	[self presentViewController:puzzleVC animated:YES completion:nil];
}

- (void)presentTypePuzzleView:(PuzzleObject *)object
{
	TypePuzzleViewController *puzzleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TypePuzzleViewController"];
	puzzleVC.object = object;
	[puzzleVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
	[self presentViewController:puzzleVC animated:YES completion:nil];
}

- (void)presentSayPuzzleView:(PuzzleObject *)object
{
	SayPuzzleViewController *puzzleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SayPuzzleViewController"];
	puzzleVC.object = object;
	[puzzleVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
	[self presentViewController:puzzleVC animated:YES completion:nil];
}

- (IBAction)handleCloseScenePressed:(id)sender
{
    [TestFlight passCheckpoint:@"~Scene close Tapped"];
    AudioServicesPlaySystemSound(0x450);
    
    [self dismissViewControllerAnimated:NO completion:nil];
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
	
	//RD
    AdminViewController *_adminVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AdminViewController"];
    //_adminVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AdminViewController"];
	_adminVC.scene = _scene;
	[self presentViewController:_adminVC animated:YES completion:nil];
}

#pragma mark - Image Manipulation Methods

- (void)applyShadowToObject:(UIView *)object
{
	object.layer.shadowColor = [[UIColor whiteColor] CGColor];//blackColor
    object.layer.shadowOffset = CGSizeMake(0, 10);//0, 10
    object.layer.shadowOpacity = .25;//.25
    object.layer.shadowRadius = 5;//5
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

- (UIImage *)desaturateImageWithURL:(NSURL *)url
{
//	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"png"];
//	NSURL *fileNameAndPath = [NSURL fileURLWithPath:filePath];
	UIImage *image = [UIImage imageWithContentsOfFile:[url absoluteString]];
	
	return [self desaturateImage:image saturation:0];
}


- (UIImage *)desaturateImage:(UIImage *)image saturation:(CGFloat)saturation
{
	CIImage *beginImage = [CIImage imageWithCGImage:image.CGImage];
	CIContext *context = [CIContext contextWithOptions:nil];
//	CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues: kCIInputImageKey, beginImage, @"inputIntensity", [NSNumber numberWithFloat:0.8], nil];
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

- (void)animateBackgroundSaturation
{
	[UIView animateWithDuration:0.5
					 animations:^{
						 _background.alpha = 0;
					 }
	];
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
