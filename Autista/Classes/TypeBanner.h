//
//  TypeBanner.h
//  Autista
//
//  Created by Shashwat Parhi on 1/29/13.
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
