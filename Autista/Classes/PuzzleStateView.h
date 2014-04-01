//
//  PuzzleStateView.h
//  Autista
//
//  Created by Shashwat Parhi on 2/21/13.
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
#import "EventLogger.h"

/**
 *  The view controller showing the acomplishing status of all puzzles in a scene. 
 *  The status for all three modes are displayed.
 *  A green dot denote completion.
 */

@interface PuzzleStateView : UIView

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) PuzzleState *dragState;
@property (nonatomic, assign) PuzzleState *typeState;
@property (nonatomic, assign) PuzzleState *sayState;

/**-----------------------------------------------------------------------------
 * @name UI drawing methods
 * -----------------------------------------------------------------------------
 */
/**
 *  Layout UI components
 */
- (void)drawRect:(CGRect)rect;
/**
 *  Choose a color for the puzzle's completion status in a mode
 *
 *  @param state puzzle completion status
 *
 *  @return color
 */
- (UIColor *)colorFromState:(PuzzleState)state;
/**
 *  Setup the image view
 */
- (void)setImageView:(UIImageView *)imageView;

@end
