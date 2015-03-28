//
//  PuzzlePieceView.m
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
