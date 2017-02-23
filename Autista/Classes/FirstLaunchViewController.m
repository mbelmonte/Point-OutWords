//
//  FirstLaunchViewController.m
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

/*
 This code is associated with the first launch view.
 The fisrt lauch view will be shown to the user if it is the first time 
 that the application is launched on the new device.
*/
#import "FirstLaunchViewController.h"
#import "InfoView.h"
#import "InfoViewPageOne.h"
#import "InfoViewPageThree.h"
#import "GlobalPreferences.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface FirstLaunchViewController ()

@end

@implementation FirstLaunchViewController

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
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"FirstLaunchInfoTextNew" ofType:@"plist"]; // The data (text and logo information will be loaded from a PList (e.g. XML format) created as FirstLaunchInfoTextNew.plist in /Resources.
	NSArray *pages = [NSArray arrayWithContentsOfFile:plistPath];
	
	NSInteger numPages = [pages count]; //Number of pages for the first launch view which is automatically decided by the number of elements in the pList.
	CGSize size = self.view.bounds.size; // coordinates are flipped at this point
	_scrollView.contentSize = CGSizeMake(numPages * size.width, size.height); //Changes the size of the scroll view to fit the height of the device and the width of total number of pages (calculated from the number of items in pList) multiplied by the width of the device.
	
	for (int i = 0; i < numPages; i++) {
        if (i == 0) { // for the first item in pList
            NSDictionary *pageDict = [pages objectAtIndex:i]; // creates a key value pair (a dictionary) for the infromation kept in the pList.
            // This part of the code creates subViews and adds them to the main scrollView in Firts Launch View.
            InfoViewPageOne *infoViewPageOne = [[InfoViewPageOne alloc] initWithFrame:self.view.bounds]; // creates a class of InfoViewPageOne.m
            infoViewPageOne.frame = CGRectOffset(infoViewPageOne.frame, i * size.width, 0); // determines the frame and its location for InfoViewPageOne.
            infoViewPageOne.titleLabel.text = [pageDict valueForKey:@"title"]; // sets the title label for the sub view.
            infoViewPageOne.textView.text = [pageDict valueForKey:@"text"]; // sets the information text for the sub view.
            [_scrollView addSubview:infoViewPageOne]; // adds the subview to the main scrollView in the First Launch View.
            // -------------------------------------------------------------------------------------------------
        }
        else if (i == 2){ // for the third item in pList
            NSDictionary *pageDict = [pages objectAtIndex:i]; // creates a key value pair (a dictionary) for the infromation kept in the pList.
            // This part of the code creates subViews and adds them to the main scrollView in Firts Launch View.
            InfoViewPageThree *infoViewPageThree = [[InfoViewPageThree alloc] initWithFrame:self.view.bounds]; // creates a class of InfoViewPageOne.m
            infoViewPageThree.frame = CGRectOffset(infoViewPageThree.frame, i * size.width, 0); // determines the frame and its location for InfoViewPageOne.
            infoViewPageThree.titleLabel.text = [pageDict valueForKey:@"title"]; // sets the title label for the sub view.
            infoViewPageThree.textView.text = [pageDict valueForKey:@"text"]; // sets the information text for the sub view.
            
            if ([pageDict valueForKey:@"imageName"] != nil) { // determines logos location in the scrollview and loads them in the page.
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[pageDict valueForKey:@"imageName"]]];
                
                CGFloat offsetX = [[pageDict valueForKey:@"offsetX"] floatValue];
                CGFloat offsetY = [[pageDict valueForKey:@"offsetY"] floatValue];
                
                if (offsetX < 0)
                    offsetX = size.width + offsetX;
                
                if (offsetY < 0)
                    offsetY = size.height + offsetY;
                
                CGRect frame = CGRectMake(0,0,.75*imageView.frame.size.width, .75*imageView.frame.size.height);
                frame.origin = CGPointMake(offsetX, offsetY);
                
                imageView.frame = frame;
                infoViewPageThree.imageView = imageView;
            }
            [_scrollView addSubview:infoViewPageThree]; // adds the subview to the main scrollView in the First Launch View.
            // -------------------------------------------------------------------------------------------------
        }
        else { // for other items in pList
            NSDictionary *pageDict = [pages objectAtIndex:i];
            InfoView *infoView = [[InfoView alloc] initWithFrame:self.view.bounds];
            infoView.frame = CGRectOffset(infoView.frame, i * size.width, 0);
            infoView.titleLabel.text = [pageDict valueForKey:@"title"];
            infoView.textView.text = [pageDict valueForKey:@"text"];
            
            if ([pageDict valueForKey:@"imageName"] != nil) {
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[pageDict valueForKey:@"imageName"]]];
                
                CGFloat offsetX = [[pageDict valueForKey:@"offsetX"] floatValue];
                CGFloat offsetY = [[pageDict valueForKey:@"offsetY"] floatValue];
                
                if (offsetX < 0)
                    offsetX = size.width + offsetX;
                
                if (offsetY < 0)
                    offsetY = size.height + offsetY;
                
                CGRect frame = CGRectMake(0,0,.75*imageView.frame.size.width, .75*imageView.frame.size.height);
                frame.origin = CGPointMake(offsetX, offsetY);
                
                imageView.frame = frame;
                infoView.imageView = imageView;
            }
            
            if (i == numPages - 1) { // for the last item in pList --> Loads a button (Get Started) in the view to start the app
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
                [button setImage:[UIImage imageNamed:@"BtnGetStartedOff.png"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"BtnGetStartedOn.png"] forState:UIControlStateHighlighted];
                [button addTarget:self action:@selector(handleDismissButtonPressed) forControlEvents:UIControlEventTouchUpInside];
                
                infoView.dismissButton = button;
            }
            
            [_scrollView addSubview:infoView];
        }
	}
	
	_pageControl.numberOfPages = numPages;
}

- (void)handleDismissButtonPressed
{
    //[TestFlight passCheckpoint:@"Get Started button Tapped"];
    AudioServicesPlaySystemSound(0x450);
    
	[self dismissViewControllerAnimated:YES completion:nil]; // the current view will be simply dismissed, resulting in the First Launch View to dsiappear. 
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {}];
    
}

#pragma mark - ScrollViewDelegate Methods

- (void)scrollToPage:(int)page
{
    if (page < 0) return;
    if (page >= _pageControl.numberOfPages) return;
	
	CGRect frame = _scrollView.frame;
	CGPoint newPoint = CGPointMake(frame.size.width * page, 0);
	
	[_scrollView setContentOffset:newPoint animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
	
	if (_pageControlUsed) {													 // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    CGFloat pageWidth = _scrollView.frame.size.width;						// Switch the indicator when more than 50% of the previous/next page is visible
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
	if (page < 0) return;
	if (page >= _pageControl.numberOfPages) return;
	
	_pageControl.currentPage = page;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	_pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender
{
    int page = _pageControl.currentPage;
	
	[self scrollToPage:page];
	
	CGRect frame = _scrollView.frame;								// update the scroll view to the appropriate page
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [_scrollView scrollRectToVisible:frame animated:YES];
    
    _pageControlUsed = YES;											// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
