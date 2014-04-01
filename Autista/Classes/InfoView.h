//
//  InfoView.h
//  Autista
//
//  Created by Shashwat Parhi on 1/27/13.
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

/**
 *  The InfoView hold the information displayed at the FirstLaunchViewController
 */
@interface InfoView : UIView

/**-----------------------------------------------------------------------------
 * @name Properties
 * -----------------------------------------------------------------------------
 */

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) UIButton *dismissButton;

/**-----------------------------------------------------------------------------
 * @name Methods
 * -----------------------------------------------------------------------------
 */
/**
 *
 */
- (void)layoutSubviews;
- (void)setImageView:(UIImageView *)imageView;
- (void)setDismissButton:(UIButton *)dismissButton;
@end
