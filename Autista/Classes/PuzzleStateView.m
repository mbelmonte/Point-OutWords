//
//  PuzzleStateView.m
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

#import "PuzzleStateView.h"

@implementation PuzzleStateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
	}
    return self;
}

- (void)drawRect:(CGRect)rect
{
	UIImage *image = _imageView.image;
	CGFloat height = rect.size.height;
	CGFloat width = (height / image.size.height) * image.size.width;
	
	UIColor *dragColor = [self colorFromState:_dragState];
	UIColor *typeColor = [self colorFromState:_typeState];
	UIColor *sayColor = [self colorFromState:_sayState];
	
	[_imageView.image drawInRect:CGRectMake(0, 0, width, height)];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect statusRect = CGRectMake(width + 10, 0, 10, 10);
	
	CGContextSetFillColorWithColor(context, dragColor.CGColor);
	CGContextFillEllipseInRect(context, statusRect);

	statusRect = CGRectOffset(statusRect, 0, 18);
	
	CGContextSetFillColorWithColor(context, typeColor.CGColor);
	CGContextFillEllipseInRect(context, statusRect);
	
	statusRect = CGRectOffset(statusRect, 0, 18);
	
	CGContextSetFillColorWithColor(context, sayColor.CGColor);
	CGContextFillEllipseInRect(context, statusRect);
}

- (UIColor *)colorFromState:(PuzzleState)state
{
	UIColor *color;
	
	switch (state) {
		case PuzzleStateNotAttempted:
			color = [UIColor darkGrayColor];
			break;
			
		case PuzzleStateAutoCompleted:
			color = [UIColor redColor];
			break;
			
		case PuzzleStatePartiallyCompleted:
			color = [UIColor orangeColor];
			break;
			
		case PuzzleStateCompleted:
			color = [UIColor greenColor];
			
		default:
			break;
	}
	
	return color;
}

- (void)setImageView:(UIImageView *)imageView
{
	_imageView = imageView;
	
	UIImage *image = _imageView.image;
	CGFloat width = (self.frame.size.height / image.size.height) * image.size.width;
	
	CGRect frame = self.frame;
	frame.size.width = width + 10 + 10 + 30;
	
	self.frame = frame;
}

@end
