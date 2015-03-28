//
//  VULevelMeter.m
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

#import "VULevelMeter.h"
#import "LevelMeter.h"
#import "GLLevelMeter.h"
#import "VUMeterTable.h"

@implementation VULevelMeter

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		_refreshHz = 1. / 30.;
		_showsPeaks = YES;
		_vertical = NO;
		_useGL = YES;
		_meterTable = [[VUMeterTable alloc] initWithMinDecibels:kMinDBvalue tableSize:400 responseCurve:2.0];
		_bgColor = nil;
		_borderColor = nil;
		[self layoutSubLevelMeters];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
		_refreshHz = 1. / 30.;
		_showsPeaks = YES;
		_vertical = NO;
		_useGL = NO;
		_meterTable = [[VUMeterTable alloc] initWithMinDecibels:kMinDBvalue tableSize:400 responseCurve:2.0];
		[self layoutSubLevelMeters];
	}
	return self;
}

-(void)setBorderColor: (UIColor *)borderColor
{
	_borderColor = borderColor;
	
	for (NSUInteger i=0; i < [_subLevelMeters count]; i++) {
		id meter = [_subLevelMeters objectAtIndex:i];
		if (_useGL)
		{
			((GLLevelMeter*)meter).borderColor = nil;
			((GLLevelMeter*)meter).borderColor = borderColor;
		}
		else
		{
			((LevelMeter*)meter).borderColor = nil;
			((LevelMeter*)meter).borderColor = borderColor;
		}
	}
}

-(void)setBackgroundColor: (UIColor *)bgColor
{
	_bgColor = bgColor;
	
	for (NSUInteger i=0; i < [_subLevelMeters count]; i++)
	{
		id meter = [_subLevelMeters objectAtIndex:i];
		if (_useGL) {
            ((GLLevelMeter*)meter).bgColor = nil;
			((GLLevelMeter*)meter).bgColor = bgColor;
		} else {
            ((GLLevelMeter*)meter).bgColor = nil;
			((LevelMeter*)meter).bgColor = bgColor;
        }
	}
	
}

- (void)layoutSubLevelMeters
{
	int i;
	for (i=0; i<[_subLevelMeters count]; i++)
	{
		UIView *thisMeter = [_subLevelMeters objectAtIndex:i];
		[thisMeter removeFromSuperview];
	}
	
	NSMutableArray *meters_build = [[NSMutableArray alloc] initWithCapacity:1];
	
	CGRect totalRect;
	
	if (_vertical) totalRect = CGRectMake(0., 0., [self frame].size.width + 2., [self frame].size.height);
	else  totalRect = CGRectMake(0., 0., [self frame].size.width, [self frame].size.height + 2.);
	
	CGRect fr;
	
	if (_vertical) {
		fr = CGRectMake(
						totalRect.origin.x + totalRect.size.width,
						totalRect.origin.y,
						totalRect.size.width - 2.,
						totalRect.size.height
						);
	}
	else {
		fr = CGRectMake(
						totalRect.origin.x,
						totalRect.origin.y,
						totalRect.size.width,
						totalRect.size.height - 2.
						);
	}
	
	LevelMeter *newMeter;
	
	if (_useGL) newMeter = [[GLLevelMeter alloc] initWithFrame:fr];
	else newMeter = [[LevelMeter alloc] initWithFrame:fr];
	
	newMeter.numLights = 4;
	newMeter.vertical = self.vertical;
	newMeter.bgColor = _bgColor;
	newMeter.borderColor = _borderColor;
	
	[meters_build addObject:newMeter];
	[self addSubview:newMeter];
	
//	_subLevelMeters = [[NSArray alloc] initWithArray:meters_build];
	_subLevelMeters = @[newMeter];
}

- (void)refreshWithValue:(CGFloat)newValue
{
//	BOOL success = NO;
	
	// if we have no queue, but still have levels, gradually bring them down
//	if (_aq == NULL)
//	{
//		CGFloat maxLvl = -1.;
//		CFAbsoluteTime thisFire = CFAbsoluteTimeGetCurrent();
//		// calculate how much time passed since the last draw
//		CFAbsoluteTime timePassed = thisFire - _peakFalloffLastFire;
//		for (LevelMeter *thisMeter in _subLevelMeters)
//		{
//			CGFloat newPeak, newLevel;
//			newLevel = thisMeter.level - timePassed * kLevelFalloffPerSec;
//			if (newLevel < 0.) newLevel = 0.;
//			thisMeter.level = newLevel;
//			if (_showsPeaks)
//			{
//				newPeak = thisMeter.peakLevel - timePassed * kPeakFalloffPerSec;
//				if (newPeak < 0.) newPeak = 0.;
//				thisMeter.peakLevel = newPeak;
//				if (newPeak > maxLvl) maxLvl = newPeak;
//			}
//			else if (newLevel > maxLvl) maxLvl = newLevel;
//			
//			[thisMeter setNeedsDisplay];
//		}
//		// stop the timer when the last level has hit 0
//		if (maxLvl <= 0.)
//		{
//			[_updateTimer invalidate];
//			_updateTimer = nil;
//		}
//		
//		_peakFalloffLastFire = thisFire;
//		success = YES;
//	} else {
		
	LevelMeter *channelView = [_subLevelMeters objectAtIndex:0];
	
	channelView.level = [_meterTable valueAt:newValue];
	if (_showsPeaks)
			channelView.peakLevel = [_meterTable valueAt:newValue];
	else channelView.peakLevel = 0.;
	
	[channelView setNeedsDisplay];
}

- (CGFloat)refreshHz { return _refreshHz; }
- (void)setRefreshHz:(CGFloat)v
{
	_refreshHz = v;
	if (_updateTimer)
	{
		[_updateTimer invalidate];
		_updateTimer = [NSTimer
						scheduledTimerWithTimeInterval:_refreshHz
						target:self
						selector:@selector(_refresh)
						userInfo:nil
						repeats:YES
						];
	}
}

- (BOOL)useGL { return _useGL; }
- (void)setUseGL:(BOOL)v
{
	_useGL = v;
	[self layoutSubLevelMeters];
}

#pragma Touch Events Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	_muteOn = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	_muteOn = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	_muteOn = NO;
}

@end
