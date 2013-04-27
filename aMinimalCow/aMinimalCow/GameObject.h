//
//  GameObject.h
//  beetleLunch
//
//  Created by Alex Gievsky on 10.04.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GameConfig.h"

@class GameLayer;

@protocol GameObjectLoader <NSObject>

//mark this method as optional to prevent any xcode warning
//but actually, this method is required
@optional
- (void) loadWithData: (NSDictionary *) data gameDelegate: (GameLayer *) gameDelegate;

@end

@interface GameObject : CCNode <GameObjectLoader> {
    GameObjectType _type;
    GameLayer *_gameDelegate;
    
    CCSprite *_spr;
}

@property (nonatomic, readonly) GameObjectType type;

+ (id) objectWithData: (NSDictionary *) data gameDelegate: (GameLayer *) gameDelegate;
- (GameObject *) initWithData: (NSDictionary *) data gameDelegate: (GameLayer *) gameDelegate;

//- (void) loadWithData: (NSDictionary *) data gameDelegate: (GameLayer *) gameDelegate;

@end