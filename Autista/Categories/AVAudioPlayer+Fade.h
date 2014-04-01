//
//  AVAudioPlayer+Fade.h
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

#import <AVFoundation/AVFoundation.h>

typedef void (^AVAudioPlayerFadeCompletionBlock)();

@interface AVAudioPlayer (Fade)

@property (nonatomic,readonly) BOOL  fading;
@property (nonatomic,readonly) float fadeTargetVolume;

- (void) fadeToVolume:(float)volume duration:(NSTimeInterval)duration;
- (void) fadeToVolume:(float)volume duration:(NSTimeInterval)duration completion:(AVAudioPlayerFadeCompletionBlock)completion;

- (void) stopWithFadeDuration:(NSTimeInterval)duration;
- (void) playWithFadeDuration:(NSTimeInterval)duration;

@end
