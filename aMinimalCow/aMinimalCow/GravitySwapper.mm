//
//  GravitySwapper.m
//  aMinimalCow
//
//  Created by Alex Gievsky on 28.04.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

#import "GravitySwapper.h"

@implementation GravitySwapper

- (void) loadWithData: (NSDictionary *) data gameDelegate: (GameLayer *) gameDelegate {
    [super loadWithData: data gameDelegate: gameDelegate];
    
    _type = GOT_Gravity;
}

@end