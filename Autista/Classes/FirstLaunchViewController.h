//
//  FirstLaunchViewController.h
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

@class InfoView;

@interface FirstLaunchViewController : UIViewController  {
	BOOL _pageControlUsed;
	UIButton *_selectedScene;
}

/**-----------------------------------------------------------------------------
 * @name Properties
 * -----------------------------------------------------------------------------
 */

/**
 *  Scrollable startup guide
 */
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

/**
 *  Indicator of which page is being scrolled to
 */
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;

/**-----------------------------------------------------------------------------
 * @name Initializing the view and handling view events
 * -----------------------------------------------------------------------------
 */

/**
 *  Initialize the viewController
 *
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

- (void)viewDidLoad;

/**
 *  Setting up UI elements for the viewController
 *
 */
- (void)viewDidAppear:(BOOL)animated;

- (void)didReceiveMemoryWarning;

/**-----------------------------------------------------------------------------
 * @name Handling scrolling, ScrollViewDelegate methods
 * -----------------------------------------------------------------------------
 */

/**
 *  Description
 *
 *  @param page id in scrollView being scrolled to
 */
- (void)scrollToPage:(int)page;

/**
 *  Handling scrollViewDidScroll event. 
 *  We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
 *  which a scroll event generated from the user hitting the page control triggers updates from
 *  the delegate method. We use a boolean to disable the delegate logic when the page control is used.
 *
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

/**
 *  At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
 *
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

/**
 *  Update the scroll view to the appropriate page
 *
 */
- (IBAction)changePage:(id)sender;

/**-----------------------------------------------------------------------------
 * @name Handling orentations
 * -----------------------------------------------------------------------------
 */

/**
 *  Set supported orientation
 *
 */
- (NSUInteger)supportedInterfaceOrientations;

/**
 *  Auto rotate to UIInterfaceOrientationLandscapeLeft
 *
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

/**-----------------------------------------------------------------------------
 * @name Utility methods
 * -----------------------------------------------------------------------------
 */

/**
 * Method to dismiss the view when dismiss button is clicked
 */
- (void)handleDismissButtonPressed;


@end
