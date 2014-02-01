//
//  PuzzlePieceView.h
//  Autista
//
//  Created by Shashwat Parhi on 10/20/12.
//  Copyright (c) 2012 Shashwat Parhi
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

@class SoundEffect;

@interface PuzzlePieceView : UIImageView {
	SoundEffect *_pieceSelectedSound;
	SoundEffect *_pieceReleasedSound;
}

@property (nonatomic, assign) NSString *title;							// required while logging user activity on this piece

@property (nonatomic, assign) CGPoint initialPoint;
@property (nonatomic, assign) CGPoint finalPoint;
@property (nonatomic, assign) BOOL isCompleted;
@property (nonatomic, assign) NSInteger belongsToSyllable;

@end
