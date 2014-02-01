//
//  SceneSelectorViewController.h
//  Autista
//
//  Created by Shashwat Parhi on 11/25/12.
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

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

@property (nonatomic, strong) NSArray *scenes;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) IBOutlet UIButton *adminOverlayButton;
@property (nonatomic, retain) IBOutlet UIButton *unlockAllButton;
@property (nonatomic, retain) IBOutlet UIButton *prevButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;

- (IBAction)changePage:(id)sender;
- (IBAction)handleAdminButtonPressed:(id)sender;
- (IBAction)handleAdminButtonReleased:(id)sender;
- (IBAction)handleUnlockAllTapped:(id)sender;
- (IBAction)infoTapped:(id)sender;
- (IBAction)feedbackTapped:(id)sender;
- (IBAction)prevTapped:(id)sender;
- (IBAction)nextTapped:(id)sender;

@end
