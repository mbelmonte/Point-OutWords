//
//  TypeBanner.h
//  Autista
//
//  Created by Shashwat Parhi on 1/29/13.
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

#import <UIKit/UIKit.h>

typedef enum {
	BannerHighlightModeCharacter, BannerHighlightModeSyllable
} BannerHighlightMode;

@interface TypeBanner : UIView {
	NSMutableArray *_bannerLabels;											// this stores the individual letters or syllables as labels for the banner
	
	UIView *_wrapper;
}

@property (nonatomic, retain) NSString *bannerText;
@property (nonatomic, retain) UIFont *bannerFont;
@property (nonatomic, assign) BannerHighlightMode highlightMode;			// whether to interpret bannerText as syllables or as independent characters
@property (nonatomic, retain) UIColor *highlightColor;
@property (nonatomic, retain) UIColor *completedColor;

- (void)highlightLabelAtPosition:(NSInteger)pos;							// this automatically colors labels before pos using completedColor

@end
