
#import "Ground.h"
#import "GameLayer.h"
#import "Box2D.h"

@implementation Ground

- (void) loadWithData: (NSDictionary *) data gameDelegate: (GameLayer *) gameDelegate {
    b2World *world = gameDelegate.world;
    //_type = (GameObjectType)[[data objectForKey: @"type"] intValue];
    _type = GOT_Ground;
    
//    _spr = [CCSprite spriteWithFile: @"sparks.png"];
//    _spr.position = ccp(0, 0);
//    
//    [self addChild: _spr];
    //_spr.color = ColorForMonster(_color);
    
    int x = [[data objectForKey: @"x"] intValue];
    int y = [[data objectForKey: @"y"] intValue];
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(coco2ptm(x + kSpikeSize / 2.0), coco2ptm(y + kSpikeSize / 2.0));
    bodyDef.linearDamping = 1.3;
    bodyDef.angularDamping = 1;
    bodyDef.userData = self;
    
    b2Body *body = world->CreateBody(&bodyDef);
    self.userData = body;
    
    // Define another box shape for our dynamic body.
    b2PolygonShape dynamicBox;
    dynamicBox.SetAsBox(coco2ptm(32), coco2ptm(32));
    
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &dynamicBox;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 1.3f;
    fixtureDef.restitution = 0.11;
//    fixtureDef.isSensor = true;
    
    //fixtureDef.filter.groupIndex = kBallGroupType;
    //    fixtureDef.filter.categoryBits = MaskBitForType(obj.objectType);
    //    fixtureDef.filter.maskBits = MaskBitForType(obj.objectType);
    
    fixtureDef.filter.categoryBits = 0x002;
    fixtureDef.filter.maskBits = 0x001;
    
    body->CreateFixture(&fixtureDef);
}

@end
