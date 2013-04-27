
#import "cocos2d.h"
#import "GameConfig.h"

@class GameLayer;

@interface Hud : CCLayer {
    GameLayer *_gameDelegate;
    
    CCLabelTTF *_coinsLabel;
    CCMenuItem *_restartBtn;
    CCMenuItem *_nextLvltBtn;
    CCMenuItem *_prevLvltBtn;
}

@property (nonatomic, assign) GameLayer *gameLayer;

- (void) clear;

@end