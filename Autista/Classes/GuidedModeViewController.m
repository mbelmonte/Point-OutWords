//
//  GuidedModeViewController.m
//  Autista
//
//  Created by Shashwat Parhi on 3/1/13.
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

#import "GuidedModeViewController.h"
#import "TouchPuzzleViewController.h"
#import "SayPuzzleViewController.h"
#import "TypePuzzleViewController.h"
#import "EventLogger.h"
#import "PuzzleObject.h"

@interface GuidedModeViewController ()

@end

@implementation GuidedModeViewController

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
	
	[self presentNextPuzzle];
}

#pragma mark - UIPageViewController Delegate Methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
	return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
	return nil;
}

//this method never gets called.......
- (void)presentNextPuzzle
{
	NSDictionary *puzzleDict = [[EventLogger sharedLogger] suggestPuzzle];
	PuzzleObject *object = [puzzleDict valueForKey:@"puzzle"];
	PuzzleMode mode = [[puzzleDict valueForKey:@"mode"] intValue];
	
	switch (mode) {
		case PuzzleModePoint:
			[self presentTouchPuzzleView:object];
			break;
			
		case PuzzleModeSay:
			[self presentSayPuzzleView:object];
			break;
			
		case PuzzleModeType:
			[self presentTypePuzzleView:object];
			break;
	}
}

- (void)presentTouchPuzzleView:(PuzzleObject *)object
{
	TouchPuzzleViewController *puzzleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TouchPuzzleViewController"];
	puzzleVC.object = object;
	
	NSArray *viewControllers = @[puzzleVC];
	
	__block GuidedModeViewController *blocksafeSelf = self;
	
	[self setViewControllers:viewControllers
				   direction:UIPageViewControllerNavigationDirectionForward
					animated:YES
				  completion:^(BOOL finished) {
					  if(finished)
					  {
						  dispatch_async(dispatch_get_main_queue(), ^{
							  [blocksafeSelf setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
						  });
					  }
				  }
	 ];
	
//	[puzzleVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
//	[self presentViewController:puzzleVC animated:YES completion:nil];
}

- (void)presentTypePuzzleView:(PuzzleObject *)object
{
	TypePuzzleViewController *puzzleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TypePuzzleViewController"];
	puzzleVC.object = object;
	
	NSArray *viewControllers = @[puzzleVC];
	
	__block GuidedModeViewController *blocksafeSelf = self;
	
	[self setViewControllers:viewControllers
				   direction:UIPageViewControllerNavigationDirectionForward
					animated:YES
				  completion:^(BOOL finished) {
					  if(finished)
					  {
						  dispatch_async(dispatch_get_main_queue(), ^{
							  [blocksafeSelf setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
						  });
					  }
				  }
	 ];
	
//	[puzzleVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
//	[self presentViewController:puzzleVC animated:YES completion:nil];
}

- (void)presentSayPuzzleView:(PuzzleObject *)object
{
	SayPuzzleViewController *puzzleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SayPuzzleViewController"];
	puzzleVC.object = object;
	
	NSArray *viewControllers = @[puzzleVC];
	
	__block GuidedModeViewController *blocksafeSelf = self;
	
	[self setViewControllers:viewControllers
				   direction:UIPageViewControllerNavigationDirectionForward
					animated:YES
				  completion:^(BOOL finished) {
					  if(finished)
					  {
						  dispatch_async(dispatch_get_main_queue(), ^{
							  [blocksafeSelf setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
						  });
					  }
				  }
	 ];
	
//	[puzzleVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
//	[self presentViewController:puzzleVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
