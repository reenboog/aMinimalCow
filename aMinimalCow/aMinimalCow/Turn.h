//
//  Turn.h
//  aMinimalCow
//
//  Created by Alex Gievsky on 28.04.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

#import "GameObject.h"

@interface Turn : GameObject {
    BOOL _turned;
}

@property (nonatomic, readonly) BOOL turned;

- (void) apply;

@end
