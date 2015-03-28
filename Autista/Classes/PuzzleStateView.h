//
//  PuzzleStateView.h
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
