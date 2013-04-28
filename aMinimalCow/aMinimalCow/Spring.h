//
//  Spring.h
//  aMinimalCow
//
//  Created by Alex Gievsky on 28.04.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

#import "GameObject.h"

@interface Spring : GameObject {
    BOOL _shaking;
}

@property (nonatomic, readonly) BOOL shaking;

@end
