//
//  Match.h
//  Dyadminoes
//
//  Created by Bennett Lin on 5/19/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Player;

@protocol MatchDelegate;

@interface Match : NSObject

@property (strong, nonatomic) NSDate *lastPlayed;

@property (strong, nonatomic) NSArray *players;
@property (strong, nonatomic) Player *currentPlayer;
@property (strong, nonatomic) NSArray *wonPlayers;
@property (nonatomic) BOOL gameHasEnded;

@property (strong, nonatomic) NSMutableArray *pile;
@property (strong, nonatomic) NSMutableArray *board;

@property (weak, nonatomic) id <MatchDelegate> delegate;

  // init methods
-(id)initWithPlayers:(NSArray *)players;

  // game state change methods
-(Player *)switchToNextPlayer;
-(void)recordDyadminoes:(NSMutableArray *)dyadminoes fromPlayer:(Player *)player;
-(void)resignPlayer:(Player *)player;

@end

@protocol MatchDelegate <NSObject>

-(void)handleEndGame;

@end