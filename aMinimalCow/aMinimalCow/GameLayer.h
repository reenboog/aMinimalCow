//
//  IntroLayer.h
//  aMinimalCow
//
//  Created by Alex Gievsky on 27.04.13.
//  Copyright spotGames 2013. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "GameConfig.h"

@class Hud;
@class Cow;

class ContactListener;
// HelloWorldLayer
@interface GameLayer : CCLayer
{
    b2World			*_world;
	GLESDebugDraw	*_debugDraw;
    
	b2Body			*_groundBody;
    
    CCSprite *_back;
    
    b2Body *_cowBody;
    Cow *_cow;
    
    b2Vec2 _cowForce;
	
    ContactListener *_contactListener;
    
    NSMutableArray *_objects;
    
    int _currentLevel;
    
    //gui stuff
    Hud *_hud;
    
    int _stars;
    BOOL _gameOver;
    
    //joints
    MouseJointMap mouseJoints;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@property (nonatomic, readonly) b2Body *groundBody;
@property (nonatomic, readonly) b2World *world;
@property (nonatomic, assign) Hud *hud;

- (void) loadLevel: (int) levelIndex;

- (void) loadNextLevel;
- (void) loadPreviousLevel;

- (void) restartLevel;

@end
