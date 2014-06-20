//
//  TypeBanner.m
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

#import "TypeBanner.h"

#define LETTERSPACING 10

@implementation TypeBanner

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		
		_highlightMode = BannerHighlightModeCharacter;
		_highlightColor = [UIColor yellowColor];
		_completedColor = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews
{
	CGFloat offsetX = 0;
	CGFloat spacing = _highlightMode == BannerHighlightModeSyllable ? 2 * LETTERSPACING : LETTERSPACING;
	
	if (_wrapper != nil)
		[_wrapper removeFromSuperview];
	
	_wrapper = [[UIView alloc] initWithFrame:self.bounds];
	
	for (int i = 0; i < [_bannerLabels count]; i++) {
		UILabel *label = [_bannerLabels objectAtIndex:i];
		label.font = _bannerFont;
		
		[label sizeToFit];
		
		CGRect frame = label.frame;
		frame.origin.x = offsetX;
		label.frame = frame;
		
		[_wrapper addSubview:label];
		offsetX += frame.size.width + spacing;
	}
	
	CGFloat width = offsetX - spacing;						// we added an extra spacing at end as part of the for loop above
	
	CGRect frame = _wrapper.frame;
	frame.size.width = width;
	frame.origin.x = (self.frame.size.width - width) / 2;
	_wrapper.frame = frame;
	
	[self addSubview:_wrapper];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setBannerText:(NSString *)bannerText
{
	_bannerText = bannerText;
	
	if (_highlightMode == BannerHighlightModeCharacter)
		[self initializeBannerlabelsWithCharacters];
	else [self initializeBannerLabelsWithSyllables];
	
	[self setNeedsLayout];
}

- (void)initializeBannerlabelsWithCharacters
{
	_bannerLabels = [NSMutableArray array];
	
	NSString *text = [_bannerText uppercaseString];
	NSInteger numLetters = text.length;
	
	for (int i = 0; i < numLetters; i++) {
		UILabel *letter = [[UILabel alloc] initWithFrame:CGRectZero];
		letter.backgroundColor = [UIColor clearColor];
		letter.text = [text substringWithRange:NSMakeRange(i, 1)];
		letter.alpha = 0.5;
		
		if (_bannerFont != nil)
			letter.font = _bannerFont;
		
		[_bannerLabels addObject:letter];
	}
}

- (void)initializeBannerLabelsWithSyllables
{
	_bannerLabels = [NSMutableArray array];
	NSArray *syllables = [_bannerText componentsSeparatedByString:@"-"];
	NSInteger numSyllables = [syllables count];
    
    if (numSyllables > 1) {
        numSyllables--;
    }
	
	for (int i = 0; i < numSyllables; i++) {
		UILabel *syllable = [[UILabel alloc] initWithFrame:CGRectZero];
		syllable.backgroundColor = [UIColor clearColor];
		syllable.text = [syllables objectAtIndex:i];
		syllable.alpha = 0.5;
		
		if (_bannerFont != nil)
			syllable.font = _bannerFont;
		
		[_bannerLabels addObject:syllable];
	}
}

-(void)setBannerFont:(UIFont *)bannerFont
{
	_bannerFont = bannerFont;
	
	[self setNeedsLayout];
}

- (void)highlightLabelAtPosition:(NSInteger)pos
{
	NSInteger numLables = [_bannerLabels count];
	
	if (pos < 0)
		pos = 0;
	else if (pos > numLables)
		pos = numLables;
	
	for (int i = 0; i < pos; i++) {
		UILabel *label = [_bannerLabels objectAtIndex:i];
		label.textColor = _completedColor;
	}
	
	if (pos == numLables)											// we have marked all labels as completed
		return;														// nothing to highlight...
	
	UILabel *label = [_bannerLabels objectAtIndex:pos];
	label.textColor = _highlightColor;
	label.alpha = 1;
}

@end
