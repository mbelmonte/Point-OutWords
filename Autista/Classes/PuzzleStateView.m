//
//  PuzzleStateView.m
//  Autista
//
//  Created by Shashwat Parhi on 2/21/13.
//  Copyright (c) 2013 Shashwat Parhi
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
