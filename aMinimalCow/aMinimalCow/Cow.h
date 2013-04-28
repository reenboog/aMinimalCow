//
//  Cow.h
//  aMinimalCow
//
//  Created by Alex Gievsky on 27.04.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

#import "cocos2d.h"

@class GameLayer;

@interface Cow: CCNode {
    CCSprite *_spr;
}

+ (Cow *) cowWithGameDelegate: (GameLayer *) gameDelegate andPos: (CGPoint) pos;
- (Cow *) initWithGameDelegate: (GameLayer *) gameDelegate andPos: (CGPoint) pos;

- (void) turn;
- (void) onGravitySwapped;

@end