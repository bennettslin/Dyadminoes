//
//  Match.h
//  Dyadminoes
//
//  Created by Bennett Lin on 5/19/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Helper.h"
@class Player;
@class DataDyadmino;

@protocol MatchDelegate;

@interface Match : NSObject <NSCoding>

  // match properties
@property (nonatomic) GameRules rules;
@property (nonatomic) GameSkill skill;
@property (nonatomic) GameType type;

  // date
@property (strong, nonatomic) NSDate *lastPlayed;

  // player properties
@property (strong, nonatomic) NSArray *players;
@property (strong, nonatomic) Player *currentPlayer;
@property (strong, nonatomic) NSArray *wonPlayers;
@property (nonatomic) BOOL gameHasEnded;

  // data dyadmino arrays
@property (strong, nonatomic) NSMutableArray *pile;
@property (strong, nonatomic) NSMutableSet *board;

  // turns and undo
@property (nonatomic) NSUInteger tempScore;
@property (strong, nonatomic) NSArray *holdingContainer;
@property (strong, nonatomic) NSMutableArray *swapContainer;
@property (strong, nonatomic) NSUndoManager *undoManager;
@property (nonatomic) NSUInteger replayCounter;
@property (strong, nonatomic) NSMutableArray *turns;

@property (weak, nonatomic) id <MatchDelegate> delegate;

  // init methods
-(id)initWithPlayers:(NSArray *)players andRules:(GameRules)rules andSkill:(GameSkill)skill andType:(GameType)type;

  // game state change methods
-(Player *)switchToNextPlayer;
-(void)recordDyadminoesFromPlayer:(Player *)player;
-(void)swapDyadminoesFromCurrentPlayer;
-(void)resignPlayer:(Player *)player;

  // undo methods
-(void)addToHoldingContainer:(DataDyadmino *)dyadmino;
-(DataDyadmino *)undoDyadminoToHoldingContainer;
-(void)redoDyadminoToHoldingContainer;
-(void)resetHoldingContainerAndUndo; // for swap purposes

  // replay methods
-(void)first;
-(BOOL)previous;
-(BOOL)next;
-(void)lastOrLeaveReplay;

@end

@protocol MatchDelegate <NSObject>

-(void)handleSwitchToNextPlayer;
-(void)handleEndGame;

@end