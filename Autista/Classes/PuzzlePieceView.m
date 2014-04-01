//
//  PuzzlePieceView.m
//  Autista
//
//  Created by Shashwat Parhi on 10/20/12.
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

#import "PuzzlePieceView.h"
#import "SoundEffect.h"

@implementation PuzzlePieceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        // Initialization code
		
		[self setupSounds];
    }
    return self;
}


- (void)awakeFromNib
{
	
}

- (void)setupSounds {
    NSBundle *mainBundle = [NSBundle mainBundle];
	
	_pieceSelectedSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"PieceSelected" ofType:@"caf"]];
	_pieceReleasedSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"PieceReleased" ofType:@"caf"]];
}

- (IBAction)playPieceSelectedSound {
	[_pieceSelectedSound play];
}

- (IBAction)playPieceReleasedSound {
	[_pieceReleasedSound play];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self playPieceSelectedSound];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self playPieceReleasedSound];
}

@end
