
#import "cocos2d.h"
#import "GameConfig.h"

@class GameLayer;

@interface Hud : CCLayer {
    GameLayer *_gameDelegate;
    
    CCLabelTTF *_coinsLabel;
    CCMenuItem *_restartBtn;
    CCMenuItem *_nextLvltBtn;
    CCMenuItem *_prevLvltBtn;
    
    CCSprite *_star;
    CCLabelTTF *_starsLabel;
}

@property (nonatomic, assign) GameLayer *gameLayer;
@property (nonatomic, assign, setter = setStars:) int stars;

- (void) clear;

@end