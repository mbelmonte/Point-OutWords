//
//  VUMeterTable.m
//  Autista
//
//  Created by Shashwat Parhi on 11/26/12.
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

#import "VUMeterTable.h"

@implementation VUMeterTable

double DbToAmp(double inDb)
{
	return pow(10., 0.05 * inDb);
}

- (id)initWithMinDecibels:(CGFloat)minDecibels tableSize:(NSInteger)size responseCurve:(CGFloat)root
{
	_mMinDecibels = minDecibels;
	_mDecibelResolution = _mMinDecibels / (size - 1);
	_mScaleFactor = 1. / _mDecibelResolution;

	if (minDecibels >= 0.)
	{
		printf("MeterTable inMinDecibels must be negative");
		return nil;
	}
	
	_mTable = (float*)malloc(size * sizeof(float));
	
	double minAmp = DbToAmp(minDecibels);
	double ampRange = 1. - minAmp;
	double invAmpRange = 1. / ampRange;
	
	double rroot = 1. / root;
	
	for (size_t i = 0; i < size; ++i) {
		double decibels = i * _mDecibelResolution;
		double amp = DbToAmp(decibels);
		double adjAmp = (amp - minAmp) * invAmpRange;
		_mTable[i] = pow(adjAmp, rroot);
	}
	
	return self;
}

- (CGFloat)valueAt:(CGFloat)decibels
{
	if (decibels < _mMinDecibels)
		return  0.;
	
	if (decibels >= 0.)
		return 1.;
	
	int index = (int)(decibels * _mScaleFactor);
	return _mTable[index];
}

@end
