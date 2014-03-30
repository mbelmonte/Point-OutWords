//
//  RootViewController.m
//  Autista
//
//  Created by Shashwat Parhi on 3/6/13.
//  Copyright (c) 2013 Shashwat Parhi
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
