//
//  AdminViewController.h
//  Autista
//
//  Created by Shashwat Parhi on 11/26/12.
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
#import <MessageUI/MessageUI.h>

@class GlobalPreferences;
@class Scene;

@interface AdminViewController : UIViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate> {
	GlobalPreferences *_prefs;
	IBOutlet UIView *_sceneDashboard;
}

@property (nonatomic, strong) IBOutlet UISwitch *backgroundMusicSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *guidedModeSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *snapbackSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *highlightKeySwitch;
@property (nonatomic, strong) IBOutlet UIButton *restoreButton;
@property (nonatomic, strong) IBOutlet UIButton *closeOverlayButton;
@property (nonatomic, strong) IBOutlet UIButton *resetSlidersButton;
@property (nonatomic, strong) IBOutlet UIButton *sendLogsButton;
@property (nonatomic, strong) IBOutlet UISlider *snapDistance;
@property (nonatomic, strong) IBOutlet UISlider *selectDistance;
@property (nonatomic, strong) IBOutlet UISlider *ampThresh;
@property (nonatomic, strong) IBOutlet UISlider *adjustDragFrequency;
@property (nonatomic, strong) IBOutlet UISlider *adjustTypeFrequency;
@property (nonatomic, strong) IBOutlet UISlider *adjustSpeakFrequency;

@property (nonatomic, strong) IBOutlet UILabel *guidedModeInfoLabel;
@property (nonatomic, strong) IBOutlet UILabel *snapBackInfoLabel;
@property (nonatomic, strong) IBOutlet UILabel *keyHighlightingInfoLabel;
@property (nonatomic, strong) IBOutlet UILabel *slidersInfoLabel;
@property (nonatomic, strong) IBOutlet UILabel *logSizeLabel;

@property (nonatomic, strong) IBOutlet UISwitch *praisePromptSwitch;

@property (nonatomic, retain) Scene *scene;

- (IBAction)restoreTapped:(id)sender;
- (IBAction)handleSendLogDataPressed:(id)sender;
- (IBAction)handleCloseOverlayPressed:(id)sender;
- (IBAction)handleSliderChangedValue:(id)sender;
- (IBAction)handleAmpThreshChanged:(id)sender;
- (IBAction)handleBGMusicChanged:(id)sender;
- (IBAction)handleResetSlidersPressed:(id)sender;
- (IBAction)handleResetAppPressed:(id)sender;

@end
