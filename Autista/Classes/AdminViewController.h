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
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "PuzzleObject.h"
/**
 *  View controller for admin view
 */

@class GlobalPreferences;
@class Scene;

@interface AdminViewController : UIViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate, MPMediaPickerControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate > {
	GlobalPreferences *_prefs;
	IBOutlet UIView *_sceneDashboard;
}
@property NSString *logFolderPath;
@property NSMutableData *responseData;

/**-----------------------------------------------------------------------------
 * @name Properties for three view groups of different modes
 * -----------------------------------------------------------------------------
 */

/**
 *  create two views for transforming animation
 */
@property (weak, nonatomic) IBOutlet UIView *pointModeView;
@property (weak, nonatomic) IBOutlet UIView *sayModeView;
@property (weak, nonatomic) IBOutlet UIView *promptSourceSelectionView;

/**-----------------------------------------------------------------------------
 * @name Properties to set praise prompts
 * -----------------------------------------------------------------------------
 */

//for record
/**
 *  <#Description#>
 */
@property NSMutableArray *recordFilePathArray;
@property AVAudioRecorder *recorder;
@property AVAudioPlayer *player;
@property NSMutableArray * praiseFileLabelArray;
//for itunes
@property MPMusicPlayerController *myPlayer;
@property NSMutableArray *praiseFileLabelArrayForPlist;
@property NSMutableArray *iTunesPlayList;

//for default
@property NSMutableArray *defaultPromptArray;
@property NSMutableArray *allPromptArray;

@property int currentSelection;
@property BOOL isEdited;

@property NSArray *recordPlayBtnArray;
@property NSArray *itunesPlayBtnArray;
@property  UIActivityIndicatorView *indicator;


/**-----------------------------------------------------------------------------
 * @name Properties UI elements
 * -----------------------------------------------------------------------------
 */
/**
 *  <#Description#>
 */

@property (nonatomic, strong) IBOutlet UISwitch *backgroundMusicSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *guidedModeSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *snapbackSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *highlightKeySwitch;
@property (nonatomic, strong) IBOutlet UIButton *restoreButton;
@property (nonatomic, strong) IBOutlet UIButton *closeOverlayButton;
@property (nonatomic, strong) IBOutlet UIButton *resetSlidersButton;
@property (weak, nonatomic) IBOutlet UIButton *resetAppButton;
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
@property (nonatomic, strong) IBOutlet UILabel *generalSlidersInfoLabel;
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

@property (weak, nonatomic) IBOutlet UISwitch *whetherAllowRecord_Switch;

@property (weak, nonatomic) IBOutlet UISlider *changeTypeScaleSignificancy;

/**-----------------------------------------------------------------------------
 * @name Properties UI element labels
 * -----------------------------------------------------------------------------
 */

@property (weak, nonatomic) IBOutlet UILabel *generalLabel;
@property (weak, nonatomic) IBOutlet UILabel *generalPointLabel;
@property (weak, nonatomic) IBOutlet UILabel *generalSpeakLabel;
@property (weak, nonatomic) IBOutlet UILabel *generalTypeLabel;

@property (weak, nonatomic) IBOutlet UILabel *pointModeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointModeSelectingDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointModeSelectingDistanceSliderInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointModeSnapBackLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointModeSnapBackInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointModeSnappingDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointModeSnappingDistanceSliderInfoLabel;

@property (weak, nonatomic) IBOutlet UILabel *speakModeLabel;
@property (weak, nonatomic) IBOutlet UILabel *speakModeSpeechLoudnessLabel;
@property (weak, nonatomic) IBOutlet UILabel *speakModeToleranceLabel;


@property (weak, nonatomic) IBOutlet UILabel *backgroundMusicLabel;

@property (weak, nonatomic) IBOutlet UILabel *praisePromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *praisePromptInfoLabel;

@property (weak, nonatomic) IBOutlet UILabel *praisePromptHardLabel;
@property (weak, nonatomic) IBOutlet UILabel *praisePromptMediumLabel;
@property (weak, nonatomic) IBOutlet UILabel *praisePromptEasyLabel;
@property (weak, nonatomic) IBOutlet UILabel *praisePromptTryAgainLabel;

@property (weak, nonatomic) NSString *applicationDocumentsDirectory;

@property (strong, nonatomic) IBOutlet UIProgressView *uploadProgressBar;
@property (strong, nonatomic) IBOutlet UIButton *uploadCancelBtn;
- (IBAction)uploadCancel:(id)sender;


//@property (weak, nonatomic) IBOutlet UIPickerView *promptPickerView;

/**-----------------------------------------------------------------------------
 * @name Methods handling changes in user preferences
 * -----------------------------------------------------------------------------
 */

/**
 * Unused
 *
 */
- (IBAction)restoreTapped:(id)sender;
- (IBAction)handleSendLogDataPressed:(id)sender;
- (IBAction)handleCloseOverlayPressed:(id)sender;

- (IBAction)handleSliderChangedValue:(id)sender;

- (IBAction)handleAmpThreshChanged:(id)sender;

- (IBAction)handleBGMusicChanged:(id)sender;

- (IBAction)handleResetSlidersPressed:(id)sender;

- (IBAction)handleResetAppPressed:(id)sender;

- (NSDictionary *)puzzleStatesForPuzzle:(PuzzleObject *)object;

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

/**-----------------------------------------------------------------------------
 * @name Handling praise prompt modifications
 * -----------------------------------------------------------------------------
 */

/**
 *  Load praise preferences from plist file /Supporting Files/PraisePrefs.plist, create one if none exist
 *
 *  @return dictionary for prainse prompt preferences
 */
- (NSDictionary *)createPlistForPraisePrefs;

/**
 *  Save praise prompt preferences to plist file
 *
 *  @param plistDict the location for praise prompt plist file
 */
- (void)savePraiseIntoPlist:(NSDictionary *)plistDict;

/**
 *  Switch between three control segments for praise prompt control ui element
 *
 *  @param index for control segments 0 defause 1 record 2 iTunes
 */
- (void)updatePromptViewWith:(int)controlIndex;

/**
 *  Move Say Mode View group down to make space for praise prompt view
 *
 *  @param space <#space description#>
 */
- (void) moveSpaceForSelectionViewWith:(float)space;

/**
 *  Edit button to display editing view
 *
 */
- (IBAction)editPromptSource:(id)sender;

/**
 *  Switch between three control segments, calls updatePromptViewWith:
 *
 */
- (IBAction)chosePromptSoure:(id)sender;

/**
 *  Allow user to record phases for praise prompt
 *
 */
- (IBAction)recordPrompt:(id)sender;

/**
 *  Playback user recorded praise prompt
 *
 */
- (IBAction)playRecordedPrompt:(id)sender;

/**
 *  Called by recordPrompt:
 *
 *  @param index index for which praise prompt user is recording
 */
- (void)startRecordingWith:(int)index;

/**
 *  Voice recording callback function, display the play button after a praise prompt is recorded
 *
 */
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag;

/**
 *  Play a selected iTunes song
 *
 */
- (IBAction)playItunes:(id)sender;

/**
 *  Select an iTunes song, open up a MPMediaPickerController
 *
 *  @param sender <#sender description#>
 */
- (IBAction)itunesSelection:(id)sender;

/**
 *  Dismiss the MPMediaPickerController
 *
 *  @param mediaPicker <#mediaPicker description#>
 */
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker;

/**
 *  Call back function after a song is selected, disabling selecting multiple songs and songs longer than 3s.
 *
 */
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) collection;


@end
