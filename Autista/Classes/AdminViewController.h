//
//  AdminViewController.h
//  Autista
//
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
#import <MessageUI/MessageUI.h>
#import <MediaPlayer/MediaPlayer.h>


@class GlobalPreferences;
@class Scene;

@interface AdminViewController : UIViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate, MPMediaPickerControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate > {
	GlobalPreferences *_prefs;
	IBOutlet UIView *_sceneDashboard;
}
//create two views for transforming animation
@property (weak, nonatomic) IBOutlet UIView *pointModeView;
@property (weak, nonatomic) IBOutlet UIView *sayModeView;
@property (weak, nonatomic) IBOutlet UIView *promptSourceSelectionView;

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
@property (strong, nonatomic) IBOutlet UISlider *sayModeDifficulty;

@property (nonatomic, strong) IBOutlet UILabel *guidedModeInfoLabel;
@property (nonatomic, strong) IBOutlet UILabel *snapBackInfoLabel;
@property (nonatomic, strong) IBOutlet UILabel *keyHighlightingInfoLabel;
@property (nonatomic, strong) IBOutlet UILabel *slidersInfoLabel;
@property (nonatomic, strong) IBOutlet UILabel *logSizeLabel;

@property (nonatomic, strong) IBOutlet UISwitch *praisePromptSwitch;

@property (weak, nonatomic) IBOutlet UISegmentedControl *promptSourceSegment;

@property (weak, nonatomic) IBOutlet UIButton *super_Btn_Record;

@property (weak, nonatomic) IBOutlet UIButton *awesome_Btn_Record;

@property (weak, nonatomic) IBOutlet UIButton *welldone_Btn_Record;

@property (weak, nonatomic) IBOutlet UIButton *try_Btn_Record;

@property (weak, nonatomic) IBOutlet UIButton *super_Btn_Play;

@property (weak, nonatomic) IBOutlet UIButton *awesome_Btn_Play;

@property (weak, nonatomic) IBOutlet UIButton *welldone_Btn_Play;

@property (weak, nonatomic) IBOutlet UIButton *try_Btn_Play;

@property (weak, nonatomic) IBOutlet UIButton *super_itunes_Btn_Play;

@property (weak, nonatomic) IBOutlet UIButton *awesome_itunes_Btn_Play;

@property (weak, nonatomic) IBOutlet UIButton *welldone_itunes_Btn_Play;

@property (weak, nonatomic) IBOutlet UIButton *try_itunes_Btn_Play;

@property (weak, nonatomic) IBOutlet UIButton *itunes_Btn;

@property (weak, nonatomic) IBOutlet UILabel *super_fileLabel;
@property (weak, nonatomic) IBOutlet UILabel *awesome_fileLabel;
@property (weak, nonatomic) IBOutlet UILabel *welldone_fileLabel;
@property (weak, nonatomic) IBOutlet UILabel *try_fileLabel;

@property (weak, nonatomic) IBOutlet UIButton *promptSourceEdit_Btn;

@property (nonatomic, retain) Scene *scene;

@property (weak, nonatomic) IBOutlet UIView *recordView;
@property (weak, nonatomic) IBOutlet UIView *itunesView;

@property (weak, nonatomic) IBOutlet UILabel *super_descLabel;

@property (weak, nonatomic) IBOutlet UILabel *awesome_descLabel;

@property (weak, nonatomic) IBOutlet UILabel *welldone_descLabel;

@property (weak, nonatomic) IBOutlet UILabel *tryagain_descLabel;


//@property (weak, nonatomic) IBOutlet UIPickerView *promptPickerView;

- (IBAction)restoreTapped:(id)sender;
- (IBAction)handleSendLogDataPressed:(id)sender;
- (IBAction)handleCloseOverlayPressed:(id)sender;
- (IBAction)handleSliderChangedValue:(id)sender;
- (IBAction)handleAmpThreshChanged:(id)sender;
- (IBAction)handleBGMusicChanged:(id)sender;
- (IBAction)handleResetSlidersPressed:(id)sender;
- (IBAction)handleResetAppPressed:(id)sender;
- (IBAction)recordPrompt:(id)sender;


@end
