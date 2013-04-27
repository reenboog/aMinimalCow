//
//  GameObject.m
//  beetleLunch
//
//  Created by Alex Gievsky on 10.04.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

#import "GameObject.h"

@interface GameObject ()

//- (void) loadWithData: (NSDictionary *) data gameDelegate: (GameLayer *) gameDelegate;

@end

@implementation GameObject

@synthesize type = _type;

- (void) dealloc {
    [super dealloc];
}

+ (id) objectWithData: (NSDictionary *) data gameDelegate: (GameLayer *) gameDelegate {
    return [[[self alloc] initWithData: data gameDelegate: gameDelegate] autorelease];
}

- (GameObject *) initWithData: (NSDictionary *) data gameDelegate: (GameLayer *) gameDelegate {
    if((self = [super init])) {
        if([self respondsToSelector: @selector(loadWithData:gameDelegate:)]) {
            _gameDelegate = gameDelegate;
            [self loadWithData: data gameDelegate: gameDelegate];
        } else {
            CCLOG(@"Please, override loadWithData:gameDelegate:");
        }
    
    }
    return self;
}

//- (void) loadWithData: (NSDictionary *) data b2World: (b2World *) world gameDelegate: (GameLayer *) gameDelegate {
//    CCLOG(@"implement me! %@", NSStringFromSelector(_cmd));
//    //implement me
//}

@end
