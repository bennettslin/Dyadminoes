//
//  Match.h
//  Dyadminoes
//
//  Created by Bennett Lin on 5/19/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSObject+Helper.h"
@class Player;
@class DataDyadmino;

@protocol MatchDelegate;

@interface Match : NSManagedObject

  // match properties
@property (assign, nonatomic) GameRules rules;
@property (assign, nonatomic) GameSkill skill;
@property (assign, nonatomic) GameType type;

  // date
@property (strong, nonatomic) NSDate *lastPlayed;

  // player properties
@property (strong, nonatomic) NSSet *players; // was array
@property (strong, nonatomic) Player *currentPlayer;
//@property (strong, nonatomic) NSSet *wonPlayers; // was array
@property (assign, nonatomic) BOOL gameHasEnded;

  // data dyadmino arrays
@property (strong, nonatomic) NSMutableArray *pile; // was mutable array
@property (strong, nonatomic) NSMutableSet *board; // was mutable set

  // turns and undo
@property (assign, nonatomic) NSUInteger tempScore;
@property (strong, nonatomic) NSArray *holdingContainer; // was array
@property (strong, nonatomic) NSMutableArray *swapContainer; // was mutable array
@property (assign, nonatomic) NSUInteger replayTurn;
@property (strong, nonatomic) NSMutableArray *turns; // turns start from 1 // was mutable array

@property (nonatomic) NSUInteger numberOfConsecutivePasses;
@property (strong, nonatomic) DataDyadmino *firstDyadmino;

@property (assign, nonatomic) NSInteger randomNumber1To24;

  // these are not persisted
@property (strong, nonatomic) NSMutableSet *replayBoard;
@property (weak, nonatomic) id <MatchDelegate> delegate;

  // establish initial properties method
-(void)initialPlayers:(NSArray *)players andRules:(GameRules)rules andSkill:(GameSkill)skill;

  // game state change methods
-(Player *)switchToNextPlayer;
-(void)recordDyadminoesFromPlayer:(Player *)player withSwap:(BOOL)swap;
-(void)persistChangedPositionForBoardDataDyadmino:(DataDyadmino *)dataDyad;
-(void)swapDyadminoesFromCurrentPlayer;
-(void)resignPlayer:(Player *)player;

  // undo methods
-(void)addToHoldingContainer:(DataDyadmino *)dyadmino;
-(DataDyadmino *)undoDyadminoToHoldingContainer;
-(void)resetHoldingContainer; // for swap purposes

  // replay methods
-(void)startReplay;
-(void)first;
-(BOOL)previous;
-(BOOL)next;
-(void)last;
-(void)leaveReplay;

  // label methods
-(NSString *)endGameResultsText;
-(NSString *)turnTextLastPlayed:(BOOL)lastPlayed;
-(NSString *)keySigString;

  // helper methods
-(NSUInteger)wonPlayersCount;
-(Player *)playerForIndex:(NSUInteger)index;

#pragma mark - helper methods

-(UIColor *)colourForPlayer:(Player *)player;

@end

@protocol MatchDelegate <NSObject>

-(void)handleSwitchToNextPlayer;
-(void)handleEndGame;

@end