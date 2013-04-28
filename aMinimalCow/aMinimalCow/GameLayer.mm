//
//  IntroLayer.m
//  aMinimalCow
//
//  Created by Alex Gievsky on 27.04.13.
//  Copyright spotGames 2013. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"
#import "Hud.h"
#import "ContactListener.h"
#import "GameObject.h"
#import "Spike.h"
#import "Ground.h"
#import "Cow.h"
#import "Finish.h"
#import "Block64x64.h"
#import "SimpleAudioEngine.h"
#import "Star.h"
#import "Turn.h"
#import "Spring.h"
#import "GravitySwapper.h"

@interface GameLayer ()

- (void) initWorld;
- (void) initCow;
- (void) checkCollisions;

- (BOOL) isLevelValid: (int) levelIndex;

- (Spike *) loadSpikeFromData: (NSDictionary *) data;
- (Ground *) loadGroundFromData: (NSDictionary *) data;
- (Finish *) loadFinishFromData: (NSDictionary *) data;
- (Block64x64 *) loadBlock64x64FromData: (NSDictionary *) data;
- (Star *) loadStarFromData: (NSDictionary *) data;
- (Turn *) loadTurnFromData: (NSDictionary *) data;
- (Spring *) loadSpringFromData: (NSDictionary *) data;
- (Spring *) loadGravitySwapperFromData: (NSDictionary *) data;
//- (Monster *) loadMonsterFromData: (NSDictionary *) data;
//- (Star *) loadStarFromData: (NSDictionary *) data;
//- (Wall *) loadWallFromData: (NSDictionary *) data;
//- (Spring *) loadSpringFromData: (NSDictionary *) data;
//- (Ice *) loadIceFromData: (NSDictionary *) data;
//- (Mud *) loadMudFormData: (NSDictionary *) data;

- (void) die;
- (void) run;
- (void) turn;
- (void) swapGravity;
- (void) onLevelCompleted;
- (void) destroyObject: (GameObject *) obj;

@end

@implementation GameLayer

@synthesize groundBody = _groundBody;
@synthesize world = _world;
@synthesize hud = _hud;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *gameLayer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: gameLayer];

    Hud *hud = [Hud node];
    [scene addChild: hud];
    
    hud.gameLayer = gameLayer;
    gameLayer.hud = hud;
    
    [gameLayer loadLevel: 0];
	
	// return the scene
	return scene;
}

#pragma mark - Level init stuff

- (void) dealloc {
    
    delete _world;
	_world = NULL;
	
	delete _debugDraw;
	_debugDraw = NULL;
    
    delete _contactListener;
    _contactListener = NULL;

    
    [_objects release];
    
    [super dealloc];
}

//
-(id) init
{
	if((self = [super init])) {
        self.isTouchEnabled = YES;
        
        _back = [CCSprite spriteWithFile: @"bg.png"];
        _back.position = ccp(512, 384);
        
        [self addChild: _back z: zTMX - 1];
        
        _objects = [[NSMutableArray alloc] init];
        
        [self scheduleUpdate];
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic: @"bgMusic.mp3"];
	}
	
	return self;
}

- (void) die {
    _gameOver = YES;
    
    _world->DestroyBody(_cowBody);
    _cowBody = NULL;
    
    __block GameLayer *bself = self;
    
    [[SimpleAudioEngine sharedEngine] playEffect: @"die.wav"];

    [_cow runAction:
                    [CCSequence actions:
                                    [CCSpawn actions:
                                                [CCJumpTo actionWithDuration: 0.4
                                                                    position: ccpAdd(_cow.position, ccp(100, -400))
                                                                      height: 250
                                                                       jumps: 1],
                                                [CCRotateTo actionWithDuration: 0.3 angle: 180], nil],
                                    [CCCallBlock actionWithBlock:^{
                                        [bself restartLevel];
                                    }], nil]
    ];
}

- (void) run {
    _gameOver = NO;
    _cowForce = kCowInitialForce;
}

- (void) turn {
    _cowForce *= -1;
    
    //_cowBody->SetLinearVelocity(b2Vec2(0, 0));
    
    [_cow turn];
}

- (void) swapGravity {
    b2Vec2 gravity = _world->GetGravity();
    gravity *= -1;
    
    _world->SetGravity(gravity);
    
    [_cow onGravitySwapped];
}

- (void) initCow {
    _cow = [Cow cowWithGameDelegate: self andPos: _initialCowPos];
    
    _cowBody = (b2Body *)_cow.userData;
    
    [self addChild: _cow z: zCow];
}

- (void) initWorld {
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
	
    _world = new b2World(gravity);
	
	_world->SetAllowSleeping(true);
	_world->SetContinuousPhysics(false);
	
	_debugDraw = new GLESDebugDraw(PTM_RATIO);
    
    uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
    //		flags += b2Draw::e_jointBit;
    //		flags += b2Draw::e_aabbBit;
    //		flags += b2Draw::e_pairBit;
    //		flags += b2Draw::e_centerOfMassBit;
	_debugDraw->SetFlags(flags);
    
	_world->SetDebugDraw(_debugDraw);
    
    _contactListener = new ContactListener();
    _world->SetContactListener(_contactListener);
    
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0, 0);
    
    _groundBody = _world->CreateBody(&groundBodyDef);
    
    b2EdgeShape edge;
    
    b2FixtureDef groundFixtureDef;
	groundFixtureDef.shape = &edge;
	groundFixtureDef.density = 1.0f;
	groundFixtureDef.friction = 10.3f;
    groundFixtureDef.restitution = 0.7;
    
    edge.Set(b2Vec2(0, 0), b2Vec2(0, coco2ptm(size.height)));
    _groundBody->CreateFixture(&groundFixtureDef);
    
    edge.Set(b2Vec2(0, coco2ptm(size.height)), b2Vec2(coco2ptm(size.width), coco2ptm(size.height)));
    _groundBody->CreateFixture(&groundFixtureDef);
    
    edge.Set(b2Vec2(coco2ptm(size.width), coco2ptm(size.height)), b2Vec2(coco2ptm(size.width), 0));
    _groundBody->CreateFixture(&groundFixtureDef);
    
    edge.Set(b2Vec2(0, 0), b2Vec2(coco2ptm(size.width), 0));
    _groundBody->CreateFixture(&groundFixtureDef);
}

- (void) loadLevel: (int) levelIndex {
    
    if(![self isLevelValid: levelIndex]) {
        CCLOG(@"can't load level: %i", levelIndex);
        return;
    }
    
    _currentLevel = levelIndex;
    
    for(CCNode *node in _objects) {
        [self removeChild: node cleanup: YES];
    }
    
    [_objects removeAllObjects];
    
    if(_contactListener)
    {
        delete _contactListener;
        _contactListener = NULL;
    }
    
    if(_world)
    {
        delete _world;
        _world = NULL;
    }
    
    if(_debugDraw)
    {
        delete _debugDraw;
        _debugDraw = NULL;
    }
    
    if(_cow) {
        [self removeChild: _cow cleanup: YES];
        _cow = nil;
        _cowBody = nil;
    }
    
    mouseJoints.clear();
    
    _stars = 0;
    _gameOver = YES;
    
    //reset gui
    [_hud clear];
    
    [self initWorld];
    
    CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile: [NSString stringWithFormat: @"level%i.tmx", levelIndex]];
    [self addChild: map z: zTMX];
    
    CCTMXLayer *tiles = [map layerNamed: @"tiles"];
    //tiles.visible = NO;
    
    for(int i = 0; i < kLevelHTiles; ++i) {
        for(int j = 0; j < kLevelWTiles; ++j) {
            int tileGid = [tiles tileGIDAt: ccp(j, i)];
            if(tileGid) {
                NSDictionary *properties = [map propertiesForGID: tileGid];
                if(properties) {
                    NSString *type = properties[@"type"];
                    if(type) {
                        GameObject *obj = nil;
                        
                        CGPoint pos = [tiles positionAt: ccp(j, i)];
                        
                        if([type isEqualToString: @"spike"]) {
                            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt: pos.x], @"x",
                                                  [NSNumber numberWithInt: pos.y], @"y", nil];
                            
                            obj = [self loadSpikeFromData: data];
                        } else if ([type isEqualToString: @"uspike"]) {
                            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt: pos.x], @"x",
                                                  [NSNumber numberWithInt: pos.y], @"y",
                                                  @"uspike", @"type", nil];
                            
                            obj = [self loadSpikeFromData: data];
                        } else if([type isEqualToString: @"ground"]) {
                            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt: pos.x], @"x",
                                                  [NSNumber numberWithInt: pos.y], @"y", nil];
                            
                            obj = [self loadGroundFromData: data];
                        } else if ([type isEqualToString: @"finish"]) {
                            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt: pos.x], @"x",
                                                  [NSNumber numberWithInt: pos.y], @"y", nil];
                            
                            obj = [self loadFinishFromData: data];
                        } else if([type isEqualToString: @"block64x64"]) {
                            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt: pos.x], @"x",
                                                  [NSNumber numberWithInt: pos.y], @"y", nil];
                            
                            obj = [self loadBlock64x64FromData: data];
                        } else if([type isEqualToString: @"turn"]) {
                            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt: pos.x], @"x",
                                                  [NSNumber numberWithInt: pos.y], @"y", nil];
                            
                            obj = [self loadTurnFromData: data];
                        } else if([type isEqualToString: @"gravity"]) {
                            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt: pos.x], @"x",
                                                  [NSNumber numberWithInt: pos.y], @"y", nil];
                            
                            obj = [self loadGravitySwapperFromData: data];
                        } else {
                            CCLOG(@"unknown type: %@", type);
                            
                            continue;
                        }
                        
                        [_objects addObject: obj];
                        [self addChild: obj];
                    }
                }
            }
        }
    }
    
    CCTMXObjectGroup *objectsGroup = [map objectGroupNamed: @"blocks"];
    NSArray *objects = objectsGroup.objects;
    
    for(id objData in objects) {
        NSString *type = [objData objectForKey: @"type"];
        
        GameObject *obj = nil;
        int objZ = 0;
        
        if([type isEqualToString: @"64x64"]) {
            obj = [self loadBlock64x64FromData: objData];
        } else if([type isEqualToString: @"star"]) {
            obj = [self loadStarFromData: objData];
        } else if([type isEqualToString: @"spring"]) {
            obj = [self loadSpringFromData: objData];
        } else if([type isEqualToString: @"start"]) {
            int x = [[objData objectForKey: @"x"] intValue];
            int y = [[objData objectForKey: @"y"] intValue];
            
            _initialCowPos = ccp(x, y);
            _cowForce = kCowInitialForce;
            
            if([objData objectForKey: @"isForceNegative"]) {
                _cowForce *= -1;
            }
            continue;
        }
        
        [_objects addObject: obj];
        [self addChild: obj z: objZ];
    }
    
    [self initCow];
    [self run];
}

- (BOOL) isLevelValid: (int) levelIndex {
    NSString *fileName = [NSString stringWithFormat: @"level%i.tmx", levelIndex];
    
    NSURL *levelUrl =  [NSURL fileURLWithPath:
                        [[CCFileUtils sharedFileUtils] fullPathFromRelativePath: fileName]];
    
    NSData *data = [NSData dataWithContentsOfURL: levelUrl];
    
    if(data) {
        return YES;
    }
    
    return NO;
}

- (void) loadNextLevel {
    [self loadLevel: _currentLevel + 1];
}

- (void) loadPreviousLevel {
    [self loadLevel: _currentLevel - 1];
}

- (void) restartLevel {
    [self loadLevel: _currentLevel];
}

- (void) onLevelCompleted {
    
    CCLOG(@"level completed");
    //[self loadNextLevel];
    
    [self restartLevel];
}

- (void) destroyObject: (GameObject *) obj {
    b2Body *body = (b2Body *)obj.userData;
    
    _world->DestroyBody(body);
    
    [obj runAction:
                [CCSequence actions:
                                    [CCScaleTo actionWithDuration: 0.2 scale: 0.01], 
                                    [CCCallBlock actionWithBlock:^{
                                        //can something go wrong in here with retain count?
                                        [obj removeFromParentAndCleanup: NO];
                                        [_objects removeObject: obj];
                                    }], nil]];
}

- (Spike *) loadSpikeFromData: (NSDictionary *) data {
    Spike *obj = [Spike objectWithData: data gameDelegate: self];
    
    return obj;
}

- (Ground *) loadGroundFromData: (NSDictionary *) data {
    Ground *obj = [Ground objectWithData: data gameDelegate: self];
    
    return obj;
}

- (Finish *) loadFinishFromData: (NSDictionary *) data {
    Finish *obj = [Finish objectWithData: data gameDelegate: self];
    
    return obj;
}

- (Block64x64 *) loadBlock64x64FromData: (NSDictionary *) data {
    Block64x64 *obj = [Block64x64 objectWithData: data gameDelegate: self];
    
    return obj;
}

- (Star *) loadStarFromData: (NSDictionary *) data {
    Star *obj = [Star objectWithData: data gameDelegate: self];
    
    return obj;
}

- (Turn *) loadTurnFromData: (NSDictionary *) data {
    Turn *obj = [Turn objectWithData: data gameDelegate: self];
    
    return obj;
}

- (Spring *) loadSpringFromData: (NSDictionary *) data {
    Spring *obj = [Spring objectWithData: data gameDelegate: self];
    
    return obj;
}

- (GravitySwapper *) loadGravitySwapperFromData: (NSDictionary *) data {
    GravitySwapper *obj = [GravitySwapper objectWithData: data gameDelegate: self];
    
    return obj;
}

#pragma mark - Draw % update

- (void) draw {
    [super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    
    if(_world) {
	
        kmGLPushMatrix();
        
        _world->DrawDebugData();
        
        kmGLPopMatrix();
    }
}

- (void) update: (ccTime) dt {
    
    if(!_world || _gameOver) {
        return;
    }
    
    const int32 VELOCITY_ITERATIONS = 8;
    const int32 POSITION_ITERATIONS = 8;
    
    const float32 FIXED_TIMESTEP = 1.0f / 60.0f;
    const float32 MINIMUM_TIMESTEP = 1.0f / 600.0f;
    
    // maximum number of steps per tick to avoid spiral of death
    const int32 MAXIMUM_NUMBER_OF_STEPS = 25;
    
    //CCLOG(@"dt: %f", dt);
    
    float32 frameTime = dt;
    int stepsPerformed = 0;
    
    //camera
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    b2Vec2 force = _cowForce;
    force *= (dt * 84);
    
    _cowBody->ApplyForceToCenter(force);
    
    while((frameTime > 0.0f) && (stepsPerformed < MAXIMUM_NUMBER_OF_STEPS))
    {
        float32 deltaTime = ((frameTime < FIXED_TIMESTEP) ? frameTime : FIXED_TIMESTEP);
        
        frameTime -= deltaTime;
        
        if(frameTime < MINIMUM_TIMESTEP)
        {
            deltaTime += frameTime;
            frameTime = 0.0f;
        }
        
        _world->Step(deltaTime, VELOCITY_ITERATIONS, POSITION_ITERATIONS);
        stepsPerformed++;
        
        //update contacts
        //[self checkCollisions];
    }
    
    [self checkCollisions];
    
    for(b2Body *b = _world->GetBodyList(); b; b = b->GetNext())
	{
        if(b->GetUserData() == NULL)
        {
            continue;
        }
        
        CCNode *myActor = (CCNode *)b->GetUserData();
        myActor.position = CGPointMake(ptm2coco(b->GetPosition().x), ptm2coco(b->GetPosition().y));
        
        if(myActor.tag != kCowTag) {
            myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }
	}
}

- (void) checkCollisions {
    ContactsVector contacts = _contactListener->GetContacts();
    
    ContactsVector::iterator itEnd = contacts.end();
    GameObjectVector objectsToRemove;
    
    for(ContactsVector::iterator it = contacts.begin(); it != itEnd; ++it) {
        b2Fixture *fixtureA = it->fixtureA;
        b2Fixture *fixtureB = it->fixtureB;
        
        b2Body *bodyA = fixtureA->GetBody();
        b2Body *bodyB = fixtureB->GetBody();
        
        for(GameObject *obj in _objects) {
            b2Body *objBody = (b2Body *)obj.userData;
//
                if((objBody == bodyA && _cowBody == bodyB) || (objBody == bodyB && _cowBody == bodyA)) {
                    if(obj.type == GOT_Finish) {
                        [self onLevelCompleted];
                        return;
                    } else if(obj.type == GOT_Spike){
                        [self die];
                        return;
                    } else if(obj.type == GOT_Star) {
                        objectsToRemove.push_back(obj);
                        
                        _stars++;
                        _hud.stars = _stars;

                        [[SimpleAudioEngine sharedEngine] playEffect: @"star.wav"];
                        break;
                    } else if(obj.type == GOT_Turn && !((Turn *)obj).turned) {
                        [((Turn *)obj) apply];
                        [self turn];
                    } else if(obj.type == GOT_Gravity && !((GravitySwapper *)obj).turned) {
                        [((GravitySwapper *)obj) apply];
                        [self swapGravity];
                    } else if(obj.type == GOT_Spring) {
                        _cowBody->ApplyLinearImpulse(b2Vec2(0, 0.5), _cowBody->GetWorldCenter());
                    }
                }
        }
    }
    
    for(GameObjectVector::iterator it = objectsToRemove.begin(); it != objectsToRemove.end(); ++it) {
        //stars only
        [self destroyObject: *it];
//        _coins++;
//        _hud.coins = _coins;
    }
}

#pragma mark - Touches

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(!_world || _gameOver) {
        return;
    }
    
    for( UITouch *touch in touches ) {

		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
        location = [self convertToNodeSpace: location];
        
        b2Vec2 locationWorld = coco_vec2ptm(location);
        
        for(b2Body *body = _world->GetBodyList(); body; body = body->GetNext())
        {
            //assume, that each cube has only one shape
            b2Fixture *shape = body->GetFixtureList();
            if(body != _cowBody && body->GetType() == b2_dynamicBody && shape->TestPoint(locationWorld))
            {
                GameObject *actor = (GameObject *)body->GetUserData();
                if(actor && actor.type == GOT_Block) {
                    MouseJointMap::iterator it = mouseJoints.find(touch);
                    
                    if(it == mouseJoints.end()) {
                        b2MouseJointDef md;
                        md.bodyA = _groundBody;
                        md.bodyB = body;
                        md.target = locationWorld;
                        md.collideConnected = true;
                        md.maxForce = 1000.0f * body->GetMass();
                        
                        b2MouseJoint *mouseJoint = (b2MouseJoint *)_world->CreateJoint(&md);
                        body->SetAwake(true);
                        
                        mouseJoints.insert(make_pair<UITouch *, b2MouseJoint *>(touch, mouseJoint));
                    }
                }
                
                break;
            }
        }

    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(!_world || _gameOver) {
        return;
    }
    
    for( UITouch *touch in touches ) {
        
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
        location = [self convertToNodeSpace: location];
        
        b2Vec2 locationWorld = coco_vec2ptm(location);
        
        MouseJointMap::iterator it = mouseJoints.find(touch);
        if(it != mouseJoints.end()) {
            b2MouseJoint *mouseJoint = it->second;
            
            if(mouseJoint) {
                mouseJoint->SetTarget(locationWorld);
            }
        }
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(!_world || _gameOver) {
        return;
    }
    
    for( UITouch *touch in touches ) {
        
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
        location = [self convertToNodeSpace: location];
        
        //b2Vec2 locationWorld = coco_vec2ptm(location);
        
        MouseJointMap::iterator it = mouseJoints.find(touch);
        if(it != mouseJoints.end()) {
            b2MouseJoint *mouseJoint = it->second;
            
            if(mouseJoint) {
                _world->DestroyJoint(mouseJoint);
                mouseJoints.erase(it);
            }
        }
    }
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

@end