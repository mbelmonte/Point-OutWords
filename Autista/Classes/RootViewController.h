//
//  RootViewController.h
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
/**
*    RootViewController is the entering point of the app. It leads a user to the next ViewController based on conditions:
*
*    - FirstLaunchViewController if it's the first time of app launch
*    - GuidedModeViewController if guidedModeEnabled is true
*    - SceneSelectorViewController otherwise
*
*/
@interface RootViewController : UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

/**
 *  Lead a user to next view based on conditions
 *
 *  @param animated true if animation is enabled
 */
- (void)viewDidAppear:(BOOL)animated;

- (void)didReceiveMemoryWarning;

@end