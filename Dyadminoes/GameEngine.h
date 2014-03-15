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

+(GameEngine *)gameEngine;
-(Player *)getAssignedAsPlayer;
-(NSUInteger)getCommonPileCount;

-(BOOL)playOnBoardThisDyadmino:(Dyadmino *)dyadmino fromRackOfPlayer:(Player *)player;
-(BOOL)putDyadminoFromPileIntoRackOfPlayer:(Player *)player;
-(void)swapTheseDyadminoes:(NSMutableArray *)fromPlayer fromPlayer:(Player *)player;

@end