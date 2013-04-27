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

+ (Cow *) cowWithGameDelegate: (GameLayer *) gameDelegate;
- (Cow *) initWithGameDelegate: (GameLayer *) gameDelegate;

@end