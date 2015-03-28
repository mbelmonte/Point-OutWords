//
//  TypeBanner.h
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

/**
 *  The banner on the top part of the screen in type mode, it is used to show the progress of the puzzle
 */
#import <UIKit/UIKit.h>

typedef enum {
	BannerHighlightModeCharacter, BannerHighlightModeSyllable
} BannerHighlightMode;

@interface TypeBanner : UIView {
    //This stores the individual letters or syllables as labels for the banner
	NSMutableArray *_bannerLabels;
	
	UIView *_wrapper;
}
/**-----------------------------------------------------------------------------
 * @name Properties
 * -----------------------------------------------------------------------------
 */
/**
 *  Text on the banner
 */
@property (nonatomic, retain) NSString *bannerText;
@property (nonatomic, retain) UIFont *bannerFont;
/**
 *  Highlight the banner.
 *  It interpret bannerText as syllables or as independent characters.
 *
 */
@property (nonatomic, assign) BannerHighlightMode highlightMode;
@property (nonatomic, retain) UIColor *highlightColor;
@property (nonatomic, retain) UIColor *completedColor;

/**-----------------------------------------------------------------------------
 * @name Banner setups methods
 * -----------------------------------------------------------------------------
 */

/**
 *  Set the text on the banner
 *
 */
- (void)setBannerText:(NSString *)bannerText;
/**
 *  Set banner label with characters
 */
- (void)initializeBannerlabelsWithCharacters;
/**
 *  Set banner label with syllables
 */
- (void)initializeBannerLabelsWithSyllables;
- (void)setBannerFont:(UIFont *)bannerFont;
/**
 *  Automatically colors labels before pos using completedColor
 */
- (void)highlightLabelAtPosition:(NSInteger)pos;

@end
