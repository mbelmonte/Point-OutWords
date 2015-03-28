//
//  SceneSelectorViewController.h
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
/**
 *  The SceneSelectorViewController is the view that a user choose a scene.
 *
 *  A scene is a collection of puzzles of a certain theme.
 *  Each scene has its own background music, image, etc.
 *
 *  As definied in PuzzleDataWithPhonetics.plist, there're a total of 5 scenes:
 *
 *  - Birthday Party
 *  - Kitchen
 *  - Picnic
 *  - Bathroom
 *  - Playground
 */

@class Scene;
@class GlobalPreferences;

@interface SceneSelectorViewController : UIViewController <UIScrollViewDelegate, AVAudioPlayerDelegate> {
	GlobalPreferences *_prefs;
	
	BOOL _pageControlUsed;
	CGFloat ratio;
	Scene *_presentedScene;
	Scene *_selectedScene;
	UIButton *_selectedSceneButton;
    //RD
	UIButton *_lockedSceneButton;
	
	AVAudioPlayer *musicPlayer;
	
	NSTimer *_adminOverlayTimer;
}

/**-----------------------------------------------------------------------------
 * @name Properties
 * -----------------------------------------------------------------------------
 */

/**
 *  An array of scenes.
 */
@property (nonatomic, strong) NSArray *scenes;
/**
 *  The scrollable view that contain the scenes.
 */
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
/**
 *  Admin button
 */
@property (nonatomic, retain) IBOutlet UIButton *adminOverlayButton;
/**
 *  Unlock all button (unused)
 */
@property (nonatomic, retain) IBOutlet UIButton *unlockAllButton;
/**
 *  Button to go to the previous scene.
 */
@property (nonatomic, retain) IBOutlet UIButton *prevButton;
/**
 *  Button to go the the next scene.
 */
@property (nonatomic, retain) IBOutlet UIButton *nextButton;

/**-----------------------------------------------------------------------------
 * @name Initializing the view and handling view events
 * -----------------------------------------------------------------------------
 */

/**
 *
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (void)viewDidLoad;
- (void)viewDidAppear:(BOOL)animated;
- (void)reload;
- (void)didReceiveMemoryWarning;
- (NSUInteger)supportedInterfaceOrientations;

- (void)viewWillAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

/**-----------------------------------------------------------------------------
 * @name Handling scene display and interactions
 * -----------------------------------------------------------------------------
 */
/**
 *  Load the appropriate scene
 */
- (void)loadScenes;
- (void)handleSceneTapped:(id)sender;

/**-----------------------------------------------------------------------------
 * @name Handling scroll view interations
 * -----------------------------------------------------------------------------
 */

/**
 *  Set the scrollView to the appropriate page
 */
- (void)scrollToPage:(int)page;
- (void) checkNextPrev:(int) page;
- (IBAction)changePage:(id)sender;
- (IBAction)prevTapped:(id)sender;
- (IBAction)nextTapped:(id)sender;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;


/**-----------------------------------------------------------------------------
 * @name Handling admin panel interations
 * -----------------------------------------------------------------------------
 */

/**
 *  Start a timer of 2s to show the admin overlay
 */
- (IBAction)handleAdminButtonPressed:(id)sender;
/**
 *  Invalidate the timer when button released
 */
- (IBAction)handleAdminButtonReleased:(id)sender;
/**
 *  Show the admin overlay
 */
- (void)showAdminOverlay;




/**-----------------------------------------------------------------------------
 * @name Music playback
 * -----------------------------------------------------------------------------
 */

/**
 *  Description
 */
- (void)initializeMusicPlayback:(NSString *)audioFilename;
- (void)playBackgroundMusic;
- (void)stopBackgroundMusic;
- (void)pauseBackgroundMusic;
- (void)resumeBackgroundMusic;
- (void)playMusicForScene:(Scene *)scene;

/**-----------------------------------------------------------------------------
 * @name Other methods
 * -----------------------------------------------------------------------------
 */
/**
 *  Show the app info screens
 */
- (IBAction)infoTapped:(id)sender;
/**
 *  Show the feedback screen
 */
- (IBAction)feedbackTapped:(id)sender;
/**
 *  Handle in app purchase (unused)
 */
- (void)productPurchased:(NSNotification *)notification;
/**
 *  Handle unlock button (unused)
 *
 *  @param sender <#sender description#>
 */
- (IBAction)handleUnlockAllTapped:(id)sender;
- (void)handleLockTapped:(id)sender;

@end
