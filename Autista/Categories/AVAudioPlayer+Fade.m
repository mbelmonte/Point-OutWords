//
//  AVAudioPlayer+Fade.m
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

#import <objc/runtime.h>
#import "AVAudioPlayer+Fade.h"

//==============================================================================
// Macro shenanigans to define methods that simulate properities using
// associative references

#define ASSOCIATIVE_PROPERTY_BASIC(NAME, SET_NAME, TYPE, NSNUMBER_MAKE, NSNUMBER_GET) \
static char NAME##Key; \
- (TYPE) NAME \
{ \
NSNumber *number = (NSNumber *)objc_getAssociatedObject(self, & NAME##Key); \
\
return number ? number.NSNUMBER_GET : (TYPE)0; \
}\
\
- (void) SET_NAME:(TYPE)value \
{\
	objc_setAssociatedObject(self, & NAME##Key, [NSNumber NSNUMBER_MAKE:value], OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
}

#define ASSOCIATIVE_PROPERTY_OBJ_COPY(NAME, SET_NAME, TYPE) \
\
static char NAME##Key; \
- (TYPE) fadeCompletion { return (TYPE)objc_getAssociatedObject(self, & NAME##Key); } \
- (void) setFadeCompletion:(TYPE)value { objc_setAssociatedObject(self, & NAME##Key, value, OBJC_ASSOCIATION_COPY_NONATOMIC); }

//==============================================================================

static const NSTimeInterval fadeInterval    = 0.05;
static const float          floatNearEnough = 0.1;

static char fadeVolumeDeltaKey, fadeCompletionKey;

@implementation AVAudioPlayer (Fade)

#pragma mark Properties

ASSOCIATIVE_PROPERTY_BASIC(fading,                  setFading,                  BOOL,  numberWithBool,  boolValue)
ASSOCIATIVE_PROPERTY_BASIC(playStopOriginalVolume,  setPlayStopOriginalVolume,  float, numberWithFloat, floatValue)
ASSOCIATIVE_PROPERTY_BASIC(fadeTargetVolume,        setFadeTargetVolume,        float, numberWithFloat, floatValue)
ASSOCIATIVE_PROPERTY_BASIC(fadeVolumeDelta,         setFadeVolumeDelta,         float, numberWithFloat, floatValue)
ASSOCIATIVE_PROPERTY_OBJ_COPY(fadeCompletion,       setFadeCompletion,          AVAudioPlayerFadeCompletionBlock)

#pragma mark Fading mechanics

- (void) fadeFunction
{
    if (!self.fading) return;
	
    const float target        = self.fadeTargetVolume;
    const float current       = self.volume;
    const float delta         = target-current;
    const float changePerStep = self.fadeVolumeDelta;
	
    if (fabs(delta) > fabs(changePerStep))
    {
        self.volume = current+changePerStep;
        [self performSelector:@selector(fadeFunction) withObject:nil afterDelay:fadeInterval];
    }
    else
    {
        self.volume = target;
        self.fading = NO;
        AVAudioPlayerFadeCompletionBlock completion = self.fadeCompletion;
        if (completion) completion();
        self.fadeCompletion = nil;
    }
}

- (void) fadeToVolume:(float)targetVolume duration:(NSTimeInterval)duration
{
    [self fadeToVolume:targetVolume duration:duration completion:nil];
}

- (void) fadeToVolume:(float)targetVolume duration:(NSTimeInterval)duration completion:(AVAudioPlayerFadeCompletionBlock)completion
{
    if (duration <= 0 || fabs(targetVolume-self.volume) < floatNearEnough)
    {
        // Volume change is close enough, just go there immediately
        self.volume = targetVolume;
        return;
    }
	
    self.fading             = YES;
    self.fadeTargetVolume   = targetVolume;
    self.fadeVolumeDelta    = (targetVolume-self.volume)/(duration/fadeInterval);
    self.fadeCompletion     = completion;
	
    [self play];
    [self fadeFunction];
}

- (void) stopWithFadeDuration:(NSTimeInterval)duration
{
    if (self.playing)
    {
        if (!self.fading) self.playStopOriginalVolume = self.volume;
        __block const float currentVolume = self.playStopOriginalVolume;
		
        [self fadeToVolume:0 duration:duration completion:^{
            [self stop];
            self.volume = currentVolume;
        }];
    }
}

- (void) playWithFadeDuration:(NSTimeInterval)duration
{
    if (!self.fading) self.playStopOriginalVolume = self.volume;
    if (!self.playing) self.volume = 0;
    [self fadeToVolume:self.playStopOriginalVolume duration:duration];
}

@end
