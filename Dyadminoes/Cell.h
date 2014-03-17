//
//  Cell.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/16/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+Helper.h"
@class Board;
@class Dyadmino;

@interface Cell : SKSpriteNode

@property (nonatomic) BoardXY boardXY;
@property (strong, nonatomic) Dyadmino *dyadmino;
@property (nonatomic) dyadminoPCOnCell pcOnCell;

-(void)addSnapPointsToBoard:(Board *)board;

@end
