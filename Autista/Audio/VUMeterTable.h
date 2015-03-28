//
//  VUMeterTable.h
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

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

@interface VUMeterTable : NSObject {
	float	_mMinDecibels;
	float	_mDecibelResolution;
	float	_mScaleFactor;
	float	*_mTable;
}

- (id)initWithMinDecibels:(CGFloat)minDecibels tableSize:(NSInteger)size responseCurve:(CGFloat)root;
- (CGFloat)valueAt:(CGFloat)decibels;

@end
