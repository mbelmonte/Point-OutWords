//
//  VUMeterTable.m
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
