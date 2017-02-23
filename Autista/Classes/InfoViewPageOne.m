//
//  InfoViewPageOne.m
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

#import "InfoViewPageOne.h"

@implementation InfoViewPageOne

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		
		UIFont *avenirBold = [UIFont fontWithName:@"AvenirNext-Bold" size:28.];
		UIFont *avenirMedium = [UIFont fontWithName:@"AvenirNext-Medium" size:22.];
		
		if (avenirBold == nil) {
			avenirBold = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.];
			avenirMedium = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.];
		}
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 700, 20)];
		_titleLabel.font = avenirBold;
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.backgroundColor	= [UIColor clearColor];
        //		_titleLabel.textAlignment = UITextAlignmentCenter;
		
		[self addSubview:_titleLabel];
		
		_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 130, 780, 600)];
        _textView.editable = NO;
        _textView.scrollEnabled = YES;
        _textView.userInteractionEnabled = YES;
		_textView.font = avenirMedium;
		_textView.textColor = [UIColor whiteColor];
		_textView.backgroundColor	= [UIColor clearColor];
        _textView.showsVerticalScrollIndicator = YES;
        //_textView.textAlignment = NSTextAlignmentJustified;
		//_textLabel.numberOfLines = 0;
		
		[self addSubview:_textView];
	}
    return self;
}


- (void)layoutSubviews
{
	[_titleLabel sizeToFit];
	//[_textLabel sizeToFit];
	
	CGSize size = self.frame.size;
	
	CGRect frame = _titleLabel.frame;
	frame.origin.x = size.width / 2 - frame.size.width / 2;
	_titleLabel.frame = frame;
	
	frame = _textView.frame;
	frame.origin.x = size.width / 2 - frame.size.width / 2;
	_textView.frame = frame;	
}
@end
