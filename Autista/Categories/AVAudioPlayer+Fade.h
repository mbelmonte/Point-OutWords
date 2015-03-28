//
//  AVAudioPlayer+Fade.h
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
