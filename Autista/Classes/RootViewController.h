//
//  RootViewController.h
//  Autista
//
//  Created by Shashwat Parhi on 3/6/13.
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