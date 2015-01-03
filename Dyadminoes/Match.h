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

#pragma mark - persisted properties

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
@property (retain, nonatomic) NSNumber *currentPlayerOrder;
@property (retain, nonatomic) NSNumber *gameHasEnded;

  // NSArray
@property (retain, nonatomic) id turns; // turns start from 1

  // temp containers, persisted for one turn
  // NSArray, contains dataDyad indices as NSNumbers
@property (retain, nonatomic) id holdingIndexContainer;
@property (retain, nonatomic) NSNumber *randomNumber1To24;

#pragma mark - not persisted properties

@property (weak, nonatomic) id <MatchDelegate> delegate;

@property (strong, nonatomic) NSMutableSet *replayBoard;
@property (assign, nonatomic) NSUInteger replayTurn;

  // these will be lazily loaded with dataDyadminoes, depending on place status
@property (readonly, nonatomic) NSMutableArray *pile; // was mutable array
@property (readonly, nonatomic) NSMutableSet *board; // was mutable set
@property (readonly, nonatomic) NSMutableSet *occupiedCells;

@property (readonly, nonatomic) NSSet *preTurnChords;
@property (readonly, nonatomic) NSMutableSet *thisTurnChords;

#pragma mark - setup methods

-(void)initialPlayers:(NSSet *)players andRules:(GameRules)rules andSkill:(GameSkill)skill withContext:(NSManagedObjectContext *)managedObjectContext;

#pragma mark - cell methods

-(BOOL)updateCellsForPlacedDyadminoID:(NSInteger)dyadminoID pc1:(NSInteger)pc1 pc2:(NSInteger)pc2 orientation:(DyadminoOrientation)orientation onBottomCellHexCoord:(HexCoord)bottomHexCoord;

-(BOOL)updateCellsForRemovedDyadminoID:(NSInteger)dyadminoID pc1:(NSInteger)pc1 pc2:(NSInteger)pc2 orientation:(DyadminoOrientation)orientation fromBottomCellHexCoord:(HexCoord)bottomHexCoord;

-(HexCoord)retrieveTopHexCoordForBottomHexCoord:(HexCoord)bottomHexCoord andOrientation:(DyadminoOrientation)orientation;

-(NSSet *)sonoritiesFromPlacingDyadminoID:(NSUInteger)dyadminoID onBottomHexCoord:(HexCoord)bottomHexCoord withOrientation:(DyadminoOrientation)orientation rulingOutRecentRackID:(NSInteger)recentRackDyadminoID;

#pragma mark - physical cell methods

-(PhysicalPlacementResult)validatePhysicallyPlacingDyadminoID:(NSUInteger)dyadminoID withOrientation:(DyadminoOrientation)orientation onBottomHexCoord:(HexCoord)bottomHexCoord;

#pragma mark - game progression methods

  // play rack dyadmino
-(NSSet *)playDataDyadmino:(DataDyadmino *)dataDyad
          onBottomHexCoord:(HexCoord)bottomHexCoord
           withOrientation:(DyadminoOrientation)orientation
     rulingOutRecentRackID:(NSInteger)recentRackDyadminoID;

  // play moved board dyadmino
-(BOOL)addLegalChordsFormed:(NSSet *)chordsFormed
 fromMovedBoardDataDyadmino:(DataDyadmino *)dataDyad
           onBottomHexCoord:(HexCoord)bottomHexCoord
            withOrientation:(DyadminoOrientation)orientation;

  // undo
-(DataDyadmino *)undoLastPlayedDyadmino;

  // swap
-(BOOL)passTurnBySwappingDyadminoes:(NSSet *)dyadminoesToSwap;

  // pass or complete turn
-(void)recordDyadminoesFromCurrentPlayerWithSwap:(BOOL)swap;

  // resign
-(void)resignPlayer:(Player *)player;

#pragma mark - replay methods

-(void)startReplay;
-(void)first;
-(BOOL)previous;
-(BOOL)next;
-(void)last;
-(void)leaveReplay;

#pragma mark - chord methods

-(NSDictionary *)getNewChordsOrExtendingChordsFromTheseChords:(NSSet *)theseChords;

  // this method excludes duplicates, and takes into account extending chords
  // this method calculates player's score this turn when input with self.thisTurnChords
  // it can also be used to calculate points in action sheet for moved board dyadmino
-(NSUInteger)pointsForLegalChords:(NSSet *)legalChords;

  // holding container helper methods
-(BOOL)holdingsContainsDataDyadmino:(DataDyadmino *)dataDyad;
-(NSArray *)dataDyadsInIndexContainer:(NSArray *)holdingContainer;

  // reset methods
-(void)resetDyadminoesOnBoard;

#pragma mark - query methods

-(GameRules)returnRules;
-(GameSkill)returnSkill;
-(GameType)returnType;
-(BOOL)returnGameHasEnded;
-(NSUInteger)returnFirstDataDyadIndex;
-(NSInteger)returnRandomNumber1To24;

#pragma mark - label methods

-(NSString *)endGameResultsText;
-(NSString *)turnTextLastPlayed:(BOOL)lastPlayed;

#pragma mark - helper methods

-(NSUInteger)wonPlayersCount;
-(Player *)playerForIndex:(NSUInteger)index;
-(DataDyadmino *)dataDyadminoForIndex:(NSUInteger)index;
-(UIColor *)colourForPlayer:(Player *)player forLabel:(BOOL)forLabel light:(BOOL)light;
-(Player *)returnCurrentPlayer;

  // this is called by scene to determine whether to show reset button
-(BOOL)boardDyadminoesHaveMovedSinceStartOfTurn;

#pragma mark - methods for unit tests only

  // for tests
-(BOOL)testAddToHoldingContainer:(DataDyadmino *)dataDyad;
-(void)testPersistChangedPositionForBoardDataDyadmino:(DataDyadmino *)dataDyad;
-(NSUInteger)testPCForDyadminoIndex:(NSUInteger)index isPC1:(BOOL)isPC1;

@end

@interface Turns : NSValueTransformer

@end

@interface HoldingIndexContainer : NSValueTransformer

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