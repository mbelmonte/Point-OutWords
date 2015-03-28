//
//  RootViewController.m
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

#import "RootViewController.h"
#import "GlobalPreferences.h"
#import "AppDelegate.h"



@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
	NSString *initialViewControllerIdentifier;
	BOOL guidedModeEnabled = [[GlobalPreferences sharedGlobalPreferences] guidedModeEnabled];
	
	AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //Lead user to FirstLaunchView if first run
	if (appDelegate.runState == AppRunStateFirstRun) {
		appDelegate.runState = AppRunStateNormal;
		
		initialViewControllerIdentifier = @"FirstLaunchViewController";
	}
    
    //Lead user to GuidedModeView if guidedModeEnabled is true
	else if (guidedModeEnabled == YES)
		initialViewControllerIdentifier = @"GuidedModeViewController";
	else initialViewControllerIdentifier = @"SceneSelectorViewController";

	UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:initialViewControllerIdentifier];
	
	[self presentViewController:vc animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate
{
    return NO;
}


@end
