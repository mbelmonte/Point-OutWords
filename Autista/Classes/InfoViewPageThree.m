//
//  InfoViewPageThree.m
//  Autista
//
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

#import "InfoViewPageThree.h"

@implementation InfoViewPageThree
@synthesize prefs = _prefs;

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
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 700, 20)];
		_titleLabel.font = avenirBold;
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.backgroundColor	= [UIColor clearColor];
        //		_titleLabel.textAlignment = UITextAlignmentCenter;
		
		[self addSubview:_titleLabel];
		
		_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 110, 780, 640)];
        _textView.editable = NO;
        _textView.scrollEnabled = YES;
        _textView.userInteractionEnabled = YES;
		_textView.font = avenirMedium;
		_textView.textColor = [UIColor whiteColor];
		_textView.backgroundColor	= [UIColor clearColor];
        _textView.showsVerticalScrollIndicator = YES;
		//_textLabel.numberOfLines = 0;
		
		[self addSubview:_textView];
        
        _prefs = [GlobalPreferences sharedGlobalPreferences];
        
        _audiologSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(700, 690, 55, 31)];
        [_audiologSwitch addTarget: self action: @selector(flip:) forControlEvents:UIControlEventValueChanged];
        
        _audiologSwitch.on = _prefs.whetherRecordVoice;
        
        [self addSubview: _audiologSwitch];
        
        _activitylogSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(700, 630, 55, 31)];
        [_activitylogSwitch addTarget: self action: @selector(flip:) forControlEvents:UIControlEventValueChanged];
        
        _activitylogSwitch.on = _prefs.whetherRecordActivity;
        
        [self addSubview: _activitylogSwitch];
	}
    return self;
}

- (IBAction)flip:(id)sender {
    
    if (_audiologSwitch.on) {
       
        NSLog(@"Audio Log Switch On");
        _prefs.whetherRecordVoice = 1;
        
    }
    
    else  {
        
        NSLog(@"Audio Log Switch Off");
        _prefs.whetherRecordVoice = 0;

    }
    
    if (_activitylogSwitch.on) {
        
        NSLog(@"Activity Log Switch On");
        _prefs.whetherRecordActivity = 1;
        
    }
    
    else  {
        
        NSLog(@"Activity Log Switch Off");
        _prefs.whetherRecordActivity = 0;
        
    }
    
    [_prefs saveState];
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
	
	
    //	if (_imageView != nil) {
    //		frame = self.frame;
    //		_imageView.frame = CGRectMake(0,0,1024, 768);
    
    
    //		frame = _imageView.frame;
    //		if (_imageOffsetX < 0)
    //			_imageOffsetX = self.frame.size.width + _imageOffsetX;
    //
    //		if (_imageOffsetY < 0)
    //			_imageOffsetY = self.frame.size.height + _imageOffsetY;
    //
    //		frame.origin = self.center; // CGPointMake(_imageOffsetX, _imageOffsetY);
    //		_imageView.frame = frame;
    //	}
}

- (void)setImageView:(UIImageView *)imageView
{
	_imageView = imageView;
	[self addSubview:_imageView];
}


@end
