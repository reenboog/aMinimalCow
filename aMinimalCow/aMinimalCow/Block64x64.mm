//
//  SmallBlock.m
//  aMinimalCow
//
//  Created by Alex Gievsky on 27.04.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

#import "Block64x64.h"
#import "GameLayer.h"

@implementation Block64x64

- (void) loadWithData: (NSDictionary *) data gameDelegate: (GameLayer *) gameDelegate {
    b2World *world = gameDelegate.world;
    //_type = (GameObjectType)[[data objectForKey: @"type"] intValue];
    _type = GOT_Block;
    
    _spr = [CCSprite spriteWithFile: @"block64x64.png"];
    _spr.position = ccp(0, 0);

    [self addChild: _spr];
    
    int x = [[data objectForKey: @"x"] intValue];
    int y = [[data objectForKey: @"y"] intValue];
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_kinematicBody;
    bodyDef.position.Set(coco2ptm(x + kSpikeSize / 2.0), coco2ptm(y + kSpikeSize / 2.0));
    bodyDef.linearDamping = 1.3;
    bodyDef.angularDamping = 1;
    bodyDef.userData = self;
    bodyDef.gravityScale = 0;
    
    b2Body *body = world->CreateBody(&bodyDef);
    self.userData = body;
    
    // Define another box shape for our dynamic body.
    b2PolygonShape dynamicBox;
    dynamicBox.SetAsBox(coco2ptm(kSmallBlockSize / 2.0), coco2ptm(kSmallBlockSize / 2.0));
    
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &dynamicBox;
    fixtureDef.density = 1.10f;
    fixtureDef.friction = 1.3f;
    fixtureDef.restitution = 0.11;
    //fixtureDef.isSensor = true;
    
    //fixtureDef.filter.groupIndex = kBallGroupType;
    fixtureDef.filter.categoryBits = 0x002;
    fixtureDef.filter.maskBits = 0x001;
    
    body->CreateFixture(&fixtureDef);
    
    NSString *maxDistanceStr = [data objectForKey: @"useJoint"];
    if(maxDistanceStr) {
        body->SetType(b2_dynamicBody);
        
        b2PrismaticJointDef pjd;
        
        NSString *axisType = [data objectForKey: @"axisType"];
        
        b2Vec2 worldAxis(0.0, 1.0);
        
        if([axisType isEqualToString: @"v"]) {
            worldAxis = b2Vec2(0.0, 1.0);
        } else if([axisType isEqualToString: @"h"]) {
            worldAxis = b2Vec2(1.0, 0.0);
        } else {
            CCLOG(@"unknown axis: %@", axisType);
        }
        
        pjd.Initialize(gameDelegate.groundBody, body, body->GetWorldCenter(), worldAxis);
        pjd.lowerTranslation = [[data objectForKey: @"lowerDistance"] intValue];
        pjd.upperTranslation = [[data objectForKey: @"upperDistance"] intValue];
        pjd.enableLimit = true;
        pjd.maxMotorForce = 5.0;
        pjd.motorSpeed = [[data objectForKey: @"speed"] intValue];
        pjd.enableMotor = true;
        
        _joint = world->CreateJoint(&pjd);
        
        //[self scheduleUpdate];
    }
}

//- (void) update: (ccTime) dt {
//    static float time = 0;
//    time += dt;
//    //pure magic
//    float upperLimit = ((b2PrismaticJoint *)_joint)->GetUpperLimit() / coco2ptm(30);
//    //((b2PrismaticJoint *)_joint)->SetMotorSpeed(time);//(upperLimit * cosf(time * (2.0f / upperLimit)));
//}

@end