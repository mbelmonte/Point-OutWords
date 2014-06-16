//
//  InfoViewPageThree.h
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
#import "GlobalPreferences.h"

@interface InfoViewPageThree : UIView

/**-----------------------------------------------------------------------------
 * @name Properties
 * -----------------------------------------------------------------------------
 */

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UISwitch *activitylogSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *audiologSwitch;
@property GlobalPreferences *prefs;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

/**-----------------------------------------------------------------------------
 * @name Methods
 * -----------------------------------------------------------------------------
 */
/**
 *
 */
- (void)layoutSubviews;
- (void)setImageView:(UIImageView *)imageView;
- (IBAction)flip:(id)sender;

@end
