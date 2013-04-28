
#ifndef _GAME_CONFIG_H
#define _GAME_CONFIG_H

#import "cocos2d.h"

#import <vector>
#import <list>
#import <map>

using namespace std;

#define PTM_RATIO 32.0f

#define ptm2coco(a)(PTM_RATIO * (a))
#define coco2ptm(a)((a)/PTM_RATIO)

#define ptm_vec2coco(a)(ccp(a.x * PTM_RATIO, a.y * PTM_RATIO))
#define coco_vec2ptm(a)(b2Vec2(a.x / PTM_RATIO, a.y / PTM_RATIO))

#define kCowTag 4335

#define kTMXTag 184
#define zTMX 0
#define zCow 1

#define kLevelWTiles 16
#define kLevelHTiles 12

#define kCowInitialPos ccp(80, 250)

#define kCowInitialForce b2Vec2(3, 0)

#define kSmallBlockSize 64
#define kSpikeSize 40
#define kFinishSize 64
#define kCowSize 90

typedef enum {
    GOT_Ground,
    GOT_Spike,
    GOT_Block,
    GOT_Finish,
    GOT_Star,
    GOT_Turn,
    GOT_Spring,
    GOT_Gravity
} GameObjectType;

@class GameObject;
class b2MouseJoint;

typedef map<UITouch *, b2MouseJoint *> MouseJointMap;
typedef vector<GameObject *> GameObjectVector;

#endif