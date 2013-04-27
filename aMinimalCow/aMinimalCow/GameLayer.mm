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

@interface GameLayer ()

- (void) initWorld;
- (void) initCow;
- (void) checkCollisions;

- (BOOL) isLevelValid: (int) levelIndex;

- (Spike *) loadSpikeFromData: (NSDictionary *) data;
- (Ground *) loadGroundFromData: (NSDictionary *) data;
//- (Monster *) loadMonsterFromData: (NSDictionary *) data;
//- (Star *) loadStarFromData: (NSDictionary *) data;
//- (Wall *) loadWallFromData: (NSDictionary *) data;
//- (Spring *) loadSpringFromData: (NSDictionary *) data;
//- (Ice *) loadIceFromData: (NSDictionary *) data;
//- (Mud *) loadMudFormData: (NSDictionary *) data;

- (void) onLevelCompleted;

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
        
        _objects = [[NSMutableArray alloc] init];
        
        [self scheduleUpdate];
		
	}
	
	return self;
}

- (void) initCow {
    _cow = [Cow cowWithGameDelegate: self];
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
    
    //reset gui
    [_hud clear];
    
    [self initWorld];
    [self initCow];
    
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
                        } else if([type isEqualToString: @"ground"]) {
                            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt: pos.x], @"x",
                                                  [NSNumber numberWithInt: pos.y], @"y", nil];
                            
                            obj = [self loadGroundFromData: data];
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
    [self loadNextLevel];
}

- (Spike *) loadSpikeFromData: (NSDictionary *) data {
    Spike *obj = [Spike objectWithData: data gameDelegate: self];
    
    return obj;
}

- (Ground *) loadGroundFromData: (NSDictionary *) data {
    Ground *obj = [Ground objectWithData: data gameDelegate: self];
    
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
    
    if(!_world) {
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
        myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
	}
}

- (void) checkCollisions {
    ContactsVector contacts = _contactListener->GetContacts();
    
    ContactsVector::iterator itEnd = contacts.end();
    
    
    for(ContactsVector::iterator it = contacts.begin(); it != itEnd; ++it) {
        b2Fixture *fixtureA = it->fixtureA;
        b2Fixture *fixtureB = it->fixtureB;
        
        b2Body *bodyA = fixtureA->GetBody();
        b2Body *bodyB = fixtureB->GetBody();
        
        for(GameObject *obj in _objects) {
//            for(Bullet *bullet in _bullets) {
//                b2Body *objBody = (b2Body *)obj.userData;
//                b2Body *bulletBody = (b2Body *)bullet.userData;
//                
//                if((objBody == bodyA && bulletBody == bodyB) || (objBody == bodyB && objBody == bodyA)) {
//                }
//                }
        }
    }
}
@end
