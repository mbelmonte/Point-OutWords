//
//  AutistaIAPHelper.m
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