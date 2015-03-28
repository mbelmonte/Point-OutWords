//
//  VULevelMeter.h
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
#import "VUMeterTable.h"

#define kPeakFalloffPerSec	.7
#define kLevelFalloffPerSec .8
#define kMinDBvalue -80.0

@interface VULevelMeter : UIView {
	NSArray						*_subLevelMeters;
	VUMeterTable				*_meterTable;
	NSTimer						*_updateTimer;
	CGFloat						_refreshHz;
	BOOL						_showsPeaks;
	BOOL						_vertical;
	BOOL						_useGL;
	
	UIColor						*_bgColor, *_borderColor;
	CFAbsoluteTime				_peakFalloffLastFire;
}

@property (nonatomic, assign) CGFloat refreshHz;						// How many times per second to redraw
@property (nonatomic, assign) BOOL showsPeaks;							// Whether or not we show peak levels
@property (nonatomic, assign) BOOL vertical;							// Whether the view is oriented V or H
@property (nonatomic, assign) BOOL useGL;								// Whether or not to use OpenGL for drawing

@property (nonatomic, readonly) BOOL muteOn;							// If user is touching VU meter, mute

- (void)refreshWithValue:(CGFloat)newValue;
-(void)setBorderColor: (UIColor *)borderColor;
-(void)setBackgroundColor: (UIColor *)backgroundColor;

@end
