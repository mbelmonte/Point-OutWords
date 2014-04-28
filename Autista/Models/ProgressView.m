//
//  ProgressView.m
//  Autista
//
//  Created by Shawn Wu on 4/27/14.
//  Copyright (c) 2014 Shashwat Parhi. All rights reserved.
//

#import "ProgressView.h"

@implementation ProgressView

@synthesize currentProgress = _currentProgress;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _currentProgress = 0;
        
//        UIImageView *playButtonView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"play_icon.png"]];
//        CGRect currentFrame = playButtonView.frame;
//        
//        currentFrame.size.height = 35;
//        currentFrame.size.width = 35;
//        
//        [self addSubview:playButtonView];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIGraphicsPushContext(context);
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 20.0);
    [[UIColor colorWithRed:91.0/255.0 green:202.0/255.0 blue:92.0/255.0 alpha:0.3] set];
    CGContextAddArc(context, 17.5, 17.5, 17.5, 0, 2*M_PI, NO);
    CGContextStrokePath(context);
    UIGraphicsPopContext();
    
    UIGraphicsPushContext(context);
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 20.0);
    [[UIColor colorWithRed:60/255.0 green:52/255.0 blue:52/255.0 alpha:1]set];
    CGContextAddArc(context, 17.5, 17.5, 17.5, 0, 2*M_PI*_currentProgress, NO); // 360 degree (0 to 2pi) arc
    CGContextStrokePath(context);
    UIGraphicsPopContext();
    
}

@end
