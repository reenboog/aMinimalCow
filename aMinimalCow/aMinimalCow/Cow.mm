//
//  Cow.m
//  aMinimalCow
//
//  Created by Alex Gievsky on 27.04.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

#import "Cow.h"
#import "GameLayer.h"

@implementation Cow

+ (Cow *) cowWithGameDelegate: (GameLayer *) gameDelegate {
    return [[[self alloc] initWithGameDelegate: gameDelegate] autorelease];
}

- (Cow *) initWithGameDelegate: (GameLayer *) gameDelegate {
    if((self = [super init])) {
        _spr = [CCSprite spriteWithFile: @"cow.png"];
        
        [self addChild: _spr];
        self.position = kCowInitialPos;
        
        b2World *world = gameDelegate.world;
        
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.position.Set(coco2ptm(self.position.x), coco2ptm(self.position.y));
        bodyDef.linearDamping = 1.3;
        bodyDef.angularDamping = 1;
        bodyDef.userData = self;
        
        b2Body *body = world->CreateBody(&bodyDef);
        self.userData = body;
        
        // Define another box shape for our dynamic body.
        b2CircleShape dynamicBox;
        dynamicBox.m_radius = coco2ptm(kCowSize / 2);
        
        // Define the dynamic body fixture.
        b2FixtureDef fixtureDef;
        fixtureDef.shape = &dynamicBox;
        fixtureDef.density = 0.10f;
        fixtureDef.friction = 0.3f;
        fixtureDef.restitution = 0.11;
        fixtureDef.filter.categoryBits = 0x001;
        //fixtureDef.isSensor = true;
        
        //fixtureDef.filter.groupIndex = kBallGroupType;
        //    fixtureDef.filter.categoryBits = MaskBitForType(obj.objectType);
        //    fixtureDef.filter.maskBits = MaskBitForType(obj.objectType);
        
        body->CreateFixture(&fixtureDef);
        self.tag = kCowTag;

    }
    
    return self;
}

- (void) turn {
    self.scaleX = -self.scaleX;
}

@end