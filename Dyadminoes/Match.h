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

  // relationship properties
@property (strong, nonatomic) NSSet *dataDyadminoes;
@property (strong, nonatomic) NSSet *players;

  // match properties
@property (retain, nonatomic) NSNumber *rules;
@property (retain, nonatomic) NSNumber *skill;
@property (retain, nonatomic) NSNumber *type;

  // date
@property (strong, nonatomic) NSDate *lastPlayed;

  // game properties
@property (retain, nonatomic) NSNumber *firstDataDyadIndex;

  // player properties
@property (retain, nonatomic) NSNumber *currentPlayerIndex;
@property (retain, nonatomic) NSNumber *gameHasEnded;

  // turns and undo
@property (retain, nonatomic) NSNumber *replayTurn;

  // NSArray
@property (retain, nonatomic) id turns; // turns start from 1

  // temp containers, persisted for one turn
  // NSArray, contains dataDyad indices as NSNumbers
@property (retain, nonatomic) id holdingIndexContainer;

  // NSSet, contains dataDyad indices as NSNumbers
@property (retain, nonatomic) id swapIndexContainer;

  // NSArray of NSDictionaries each representing a played dyadmino or moved board dyadmino
  // each of dyadmino is an NSDictionary of chordSonorities: NSSet, points: NSNumber, and fromRack: NSNumber
  // each chordSonorities is an NSSet of objects representing sets of sonorities
  // each sonority is an NSSet of notes
  // each note is an NSDictionary of pc: NSNumbers and dyadmino: NSNumbers
  // dyadmino information is not retained
@property (retain, nonatomic) id arrayOfChordsAndPoints;

@property (retain, nonatomic) NSNumber *randomNumber1To24;

  // these are not persisted
@property (strong, nonatomic) NSMutableSet *replayBoard;
@property (weak, nonatomic) id <MatchDelegate> delegate;

  // these will be lazily loaded with dataDyadminoes, depending on place status
@property (readonly, nonatomic) NSMutableArray *pile; // was mutable array
@property (readonly, nonatomic) NSMutableSet *board; // was mutable set
@property (readonly, nonatomic) NSMutableSet *occupiedCells;

  // establish initial properties method
-(void)initialPlayers:(NSSet *)players andRules:(GameRules)rules andSkill:(GameSkill)skill withContext:(NSManagedObjectContext *)managedObjectContext;

#pragma mark - cell methods

-(BOOL)updateCellsForPlacedDyadminoID:(NSInteger)dyadminoID pc1:(NSInteger)pc1 pc2:(NSInteger)pc2 orientation:(DyadminoOrientation)orientation onBottomCellHexCoord:(HexCoord)bottomHexCoord;

-(BOOL)updateCellsForRemovedDyadminoID:(NSInteger)dyadminoID pc1:(NSInteger)pc1 pc2:(NSInteger)pc2 orientation:(DyadminoOrientation)orientation fromBottomCellHexCoord:(HexCoord)bottomHexCoord;

-(HexCoord)retrieveTopHexCoordForBottomHexCoord:(HexCoord)bottomHexCoord andOrientation:(DyadminoOrientation)orientation;

-(NSSet *)sonoritiesFromPlacingDyadminoID:(NSUInteger)dyadminoID onBottomHexCoord:(HexCoord)bottomHexCoord withOrientation:(DyadminoOrientation)orientation rulingOutRecentRackID:(NSInteger)recentRackDyadminoID;

#pragma mark - physical cell methods

-(PhysicalPlacementResult)validatePhysicallyPlacingDyadminoID:(NSUInteger)dyadminoID withOrientation:(DyadminoOrientation)orientation onBottomHexCoord:(HexCoord)bottomHexCoord;

  // game state change methods
-(void)recordDyadminoesFromCurrentPlayerWithSwap:(BOOL)swap;
-(void)persistChangedPositionForBoardDataDyadmino:(DataDyadmino *)dataDyad;
-(BOOL)swapDyadminoesFromCurrentPlayer;
-(void)resignPlayer:(Player *)player;

  // holding container change methods
-(BOOL)addToHoldingContainer:(DataDyadmino *)dyadmino;
-(DataDyadmino *)undoDyadminoToHoldingContainer;

  // array of chords and points change methods
-(BOOL)addToArrayOfChordsAndPointsTheseChordSonorities:(NSSet *)chordSonorities
                               extendedChordSonorities:(NSSet *)extendedChordSonorities
                                        fromDyadminoID:(NSInteger)dyadminoID;

-(BOOL)undoFromArrayOfChordsAndPointsThisDyadminoID:(NSInteger)dyadminoID;

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
-(NSUInteger)pcForDyadminoIndex:(NSUInteger)index isPC1:(BOOL)isPC1;

  // array of chords and points helper methods
-(NSUInteger)sumOfPointsThisTurn;

  // chord sonorities are also in extended chord sonorities
-(NSUInteger)pointsForChordSonorities:(NSSet *)chordSonorities extendedChordSonorities:(NSSet *)extendedChordSonorities;

  // holding container helper methods
-(BOOL)holdingsContainsDataDyadmino:(DataDyadmino *)dataDyad;
-(NSArray *)dataDyadsInIndexContainer:(NSArray *)holdingContainer;

  // swap container helper methods
-(BOOL)swapContainerContainsDataDyadmino:(DataDyadmino *)dataDyad;
-(void)addToSwapDataDyadmino:(DataDyadmino *)dataDyad;
-(void)removeFromSwapDataDyadmino:(DataDyadmino *)dataDyad;
-(void)removeAllSwaps;

  // reset methods
-(void)resetDyadminoesOnBoard;
-(BOOL)boardDyadminoesHaveMovedSinceStartOfTurn;

#pragma mark - query number methods

-(GameRules)returnRules;
-(GameSkill)returnSkill;
-(GameType)returnType;
-(NSUInteger)returnCurrentPlayerIndex;
-(BOOL)returnGameHasEnded;
-(NSUInteger)returnFirstDataDyadIndex;
-(NSUInteger)returnReplayTurn;
-(NSInteger)returnRandomNumber1To24;

#pragma mark - helper methods

-(UIColor *)colourForPlayer:(Player *)player forLabel:(BOOL)forLabel light:(BOOL)light;
-(Player *)returnCurrentPlayer;

@end

@interface Turns : NSValueTransformer

@end

@interface HoldingIndexContainer : NSValueTransformer

@end

@interface SwapIndexContainer : NSValueTransformer

@end

@interface ArrayOfChordsAndPoints : NSValueTransformer

@end

@protocol MatchDelegate <NSObject>

-(NSAttributedString *)stringForSonorities:(NSSet *)sonorities
                         withInitialString:(NSString *)initialString
                           andEndingString:(NSString *)endingString;

-(BOOL)sonority:(NSSet *)sonority containsNote:(NSDictionary *)note;
-(BOOL)sonority:(NSSet *)smaller IsSubsetOfSonority:(NSSet *)larger;
-(BOOL)isFirstAndOnlyDyadminoID:(NSUInteger)dyadminoID;
-(void)handleSwitchToNextPlayer;
-(void)handleEndGame;

@end