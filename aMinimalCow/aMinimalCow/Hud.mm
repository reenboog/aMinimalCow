//
//  Gui.m
//  beetleLunch
//
//  Created by Alex Gievsky on 11.04.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

#import "Hud.h"
#import "GameLayer.h"

@interface Hud ()

- (void) onRestartBtnPressed;
- (void) onPrevLvlBtnPressed;
- (void) onNextLvlBtnPressed;

@end

@implementation Hud

@synthesize gameLayer = _gameDelegate;

- (void) dealloc {
    [super dealloc];
}

- (Hud *) init {
    if((self = [super init])) {
        _coinsLabel = [CCLabelTTF labelWithString: @"" fontName: @"Arial" fontSize: 15];
        _coinsLabel.anchorPoint = ccp(0, 0.5);
        _coinsLabel.position = ccp(10, 460);
        
        [self addChild: _coinsLabel];
        
        _restartBtn = [CCMenuItemImage itemWithNormalImage: @"restartBtn.png"
                                             selectedImage: @"restartBtn.png"
                                                    target: self
                                                  selector: @selector(onRestartBtnPressed)];
        //_restartBtn.position = ccp(310, 460);
        
        _prevLvltBtn = [CCMenuItemImage itemWithNormalImage: @"prevBtn.png"
                                              selectedImage: @"prevBtn.png"
                                                     target: self
                                                   selector: @selector(onPrevLvlBtnPressed)];
        
        _nextLvltBtn = [CCMenuItemImage itemWithNormalImage: @"nextBtn.png"
                                              selectedImage: @"nextBtn.png"
                                                     target: self
                                                   selector: @selector(onNextLvlBtnPressed)];        //_prevLvltBtn.position = ccp(310, 460);

        
        CCMenu *menu = [CCMenu menuWithItems: _prevLvltBtn, _nextLvltBtn, _restartBtn, nil];
        //menu.anchorPoint = ccp(1, 0.5);
        menu.position = ccp(910, 730);
        
        [menu alignItemsHorizontallyWithPadding: 15];
                
        [self addChild: menu];
        
        _star = [CCSprite spriteWithFile: @"star.png"];
        _star.scale = 0.6;
        _star.position = ccp(20, 740);
        
        [self addChild: _star];
        
        _starsLabel = [CCLabelTTF labelWithString: @""
                                         fontName: @"Arial"
                                         fontSize: 20];
        _starsLabel.anchorPoint = ccp(0, 0.5);
        _starsLabel.position = ccp(40, 740);
        
        [self addChild: _starsLabel];
    }
    
    return self;
}

#pragma mark - Callbacks

- (void) onRestartBtnPressed {
    [_gameDelegate restartLevel];
}

- (void) onPrevLvlBtnPressed {
    [_gameDelegate loadPreviousLevel];
}

- (void) onNextLvlBtnPressed {
    [_gameDelegate loadNextLevel];
}

#pragma mark - Logic

- (void) clear {
    [self setStars: 0];
}

- (void) setStars: (int) stars {
    _starsLabel.string = [NSString stringWithFormat: @"x %i", stars];
}

@end
