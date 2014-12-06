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

#pragma mark - query number methods

  // match properties
@property (retain, nonatomic) NSNumber *rules;
@property (retain, nonatomic) NSNumber *skill;
@property (retain, nonatomic) NSNumber *type;

  // date
@property (strong, nonatomic) NSDate *lastPlayed;

  // player properties
@property (strong, nonatomic) NSSet *players; // was array
@property (retain, nonatomic) NSNumber *currentPlayerIndex;
@property (retain, nonatomic) NSNumber *gameHasEnded;

  // data dyadmino arrays
@property (strong, nonatomic) NSSet *dataDyadminoes;
@property (retain, nonatomic) NSNumber *firstDataDyadIndex;

  // turns and undo
@property (retain, nonatomic) NSNumber *tempScore;
@property (retain, nonatomic) NSNumber *replayTurn;
@property (retain, nonatomic) id turns; // turns start from 1 // was mutable array
@property (retain, nonatomic) id holdingIndexContainer; // contains dataDyad indices as NSNumbers // was array
@property (retain, nonatomic) id swapIndexContainer; // contains dataDyad indices as NSNumbers // was mutable array

@property (retain, nonatomic) NSNumber *numberOfConsecutivePasses;
@property (retain, nonatomic) NSNumber *randomNumber1To24;

  // these are not persisted
@property (strong, nonatomic) NSMutableSet *replayBoard;
@property (weak, nonatomic) id <MatchDelegate> delegate;

  // these will be lazily loaded by dataDyadminoes, depending on place status
@property (readonly, nonatomic) NSMutableArray *pile; // was mutable array
@property (readonly, nonatomic) NSMutableSet *board; // was mutable set

  // establish initial properties method
-(void)initialPlayers:(NSSet *)players andRules:(GameRules)rules andSkill:(GameSkill)skill withContext:(NSManagedObjectContext *)managedObjectContext;

  // game state change methods
-(void)recordDyadminoesFromCurrentPlayerWithSwap:(BOOL)swap;
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

  // helper methods
-(NSUInteger)wonPlayersCount;
-(Player *)playerForIndex:(NSUInteger)index;
-(DataDyadmino *)dataDyadminoForIndex:(NSUInteger)index;

  // holding container helper methods
-(BOOL)holdingsContainsDataDyadmino:(DataDyadmino *)dataDyad;
-(NSArray *)dataDyadsInIndexContainer:(NSArray *)holdingContainer;

  // swap container helper methods
-(BOOL)swapContainerContainsDataDyadmino:(DataDyadmino *)dataDyad;
-(void)addToSwapDataDyadmino:(DataDyadmino *)dataDyad;
-(void)removeFromSwapDataDyadmino:(DataDyadmino *)dataDyad;
-(void)removeAllSwaps;

#pragma mark - query number methods

-(GameRules)returnRules;
-(GameSkill)returnSkill;
-(GameType)returnType;
-(NSUInteger)returnCurrentPlayerIndex;
-(BOOL)returnGameHasEnded;
-(NSUInteger)returnFirstDataDyadIndex;
-(NSUInteger)returnTempScore;
-(NSUInteger)returnReplayTurn;
-(NSUInteger)returnNumberOfConsecutivePasses;
-(NSInteger)returnRandomNumber1To24;

#pragma mark - helper methods

-(UIColor *)colourForPlayer:(Player *)player;
-(Player *)returnCurrentPlayer;

@end

@interface Turns : NSValueTransformer

@end

@interface HoldingIndexContainer : NSValueTransformer

@end

@interface SwapIndexContainer : NSValueTransformer

@end

@protocol MatchDelegate <NSObject>

-(void)handleSwitchToNextPlayer;
-(void)handleEndGame;

@end