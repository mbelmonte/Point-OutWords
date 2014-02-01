//
//  VULevelMeter.h
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
