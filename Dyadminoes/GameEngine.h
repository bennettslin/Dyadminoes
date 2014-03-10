//
//  Pile.h
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Dyadmino;
@class Player;

@interface GameEngine : NSObject

  // dyadminoes
@property (strong, nonatomic) NSMutableSet *allDyadminoes;
@property (strong, nonatomic) NSMutableSet *dyadminoesOnBoard;

+(GameEngine *)gameEngine;

-(Player *)getAssignedAsPlayer;
-(NSUInteger)getCommonPileCount;

-(BOOL)playOnBoardThisDyadmino:(Dyadmino *)dyadmino fromRackOfPlayer:(Player *)player;
-(BOOL)putDyadminoFromCommonPileIntoRackOfPlayer:(Player *)player;

@end