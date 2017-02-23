//
//  SceneViewController.h
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
#import "PuzzleObject.h";
/**
 *  Display puzzles under a certain scene, lead user to the puzzle he selected and choose the mode of the puzzle.
 */
@class Scene;
@class GlobalPreferences;
@class AdminViewController;

@interface SceneViewController : UIViewController {
	GlobalPreferences *_prefs;

//	AdminViewController *_adminVC;
	NSTimer *_adminOverlayTimer;
    NSInteger _sayIndex;
}
/**-----------------------------------------------------------------------------
 * @name Properties
 * -----------------------------------------------------------------------------
 */

/**
 *  Current scene.
 */
@property (nonatomic, retain) Scene *scene;
@property (nonatomic, retain) NSMutableArray *objects;

@property (nonatomic, retain) IBOutlet UIImageView *background;

@property (nonatomic, retain) IBOutlet UIButton *closeButton;
@property (nonatomic, retain) IBOutlet UIButton *adminOverlayButton;

/**-----------------------------------------------------------------------------
 * @name Initializing the view and handling view events
 * -----------------------------------------------------------------------------
 */
/**
 *  Init method for the view
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (void)viewDidLoad;
- (void)viewDidAppear:(BOOL)animated;

/**-----------------------------------------------------------------------------
 * @name Handling user interactions on puzzle objects
 * -----------------------------------------------------------------------------
 */
/**
 *  Animate the puzzle object when pressed
 */
- (IBAction)handleObjectPressed:(id)sender;
/**
 *  Lead the user to the puzzle he selected
 */
- (IBAction)handleObjectReleased:(id)sender;
- (IBAction)cancelObjectPressed:(id)sender;


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
 *  Show the app info screens
 */
- (IBAction)infoTapped:(id)sender;
/**
 *  Show the admin overlay
 */
- (void)showAdminOverlay;

/**-----------------------------------------------------------------------------
 * @name Puzzle mode handling
 * -----------------------------------------------------------------------------
 */
/**
 *  Go to touch mode
 */
- (void)presentTouchPuzzleView:(PuzzleObject *)object;
/**
 *  Go to type mode
 */
- (void)presentTypePuzzleView:(PuzzleObject *)object;
/**
 *  Go to say mode
 */
- (void)presentSayPuzzleView:(PuzzleObject *)object;

/**-----------------------------------------------------------------------------
 * @name Image Manipulation Methods
 * -----------------------------------------------------------------------------
 */
/**
 *  Apply shadow effect
 */
- (void)applyShadowToObject:(UIView *)object;

- (void)applyGlowToObject:(UIView *)object;

- (UIImage *)desaturateImageWithURL:(NSURL *)url;

- (UIImage *)desaturateImage:(UIImage *)image saturation:(CGFloat)saturation;

- (void)animateBackgroundSaturation;

//- (void)unwindPuzzleView:(UIStoryboardSegue *)segue;

/**-----------------------------------------------------------------------------
 * @name Other Methods
 * -----------------------------------------------------------------------------
 */
/**
 *  Close the scene
 */
- (IBAction)handleCloseScenePressed:(id)sender;
-(Float32)audioVolume;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
