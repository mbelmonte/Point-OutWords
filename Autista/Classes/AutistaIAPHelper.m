//
//  AutistaIAPHelper.m
//  Autista
//
//  Created by MadRat Games on 04/10/13.
//  Copyright (c) 2013 Shashwat Parhi. All rights reserved.
//

#import "AutistaIAPHelper.h"

@implementation AutistaIAPHelper

+ (AutistaIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static AutistaIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.madratgames.testautista.bdayparty",
                                      @"com.madratgames.testautista.playground",
                                      @"com.madratgames.testautista.picnic",
                                      @"com.madratgames.testautista.kitchen",
                                      @"com.madratgames.testautista.unlockall",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end