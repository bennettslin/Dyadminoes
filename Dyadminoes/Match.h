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

#pragma mark - setup methods

-(void)initialPlayers:(NSSet *)players
             andRules:(GameRules)rules
             andSkill:(GameSkill)skill
          withContext:(NSManagedObjectContext *)managedObjectContext
              forTest:(BOOL)forTest;

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

#pragma mark - move query method

-(PlacementResult)checkPlacementOfDataDyadmino:(DataDyadmino *)dataDyad
                              onBottomHexCoord:(HexCoord)bottomHexCoord
                               withOrientation:(DyadminoOrientation)orientation;

-(NSAttributedString *)stringForPlacementOfDataDyadmino:(DataDyadmino *)dataDyad
                                       onBottomHexCoord:(HexCoord)bottomHexCoord
                                        withOrientation:(DyadminoOrientation)orientation
                                          withCondition:(GetNewOrExtendedChords)condition
                                      withInitialString:(NSString *)initialString
                                        andEndingString:(NSString *)endingString;

-(NSUInteger)pointsForPlacingDyadmino:(DataDyadmino *)dataDyad
                     onBottomHexCoord:(HexCoord)bottomHexCoord
                      withOrientation:(DyadminoOrientation)orientation;

-(NSUInteger)pointsForAllChordsThisTurn;

#pragma mark - scene game progression methods

  // reset methods
-(void)resetToStartOfTurn;

  // play rack dyadmino (scene only calls in playDyadmino)
-(BOOL)playDataDyadmino:(DataDyadmino *)dataDyad
       onBottomHexCoord:(HexCoord)bottomHexCoord
        withOrientation:(DyadminoOrientation)orientation;

  // play moved board dyadmino (scene only calls in finishHovering)
-(BOOL)moveBoardDataDyadmino:(DataDyadmino *)dataDyad
            toBottomHexCoord:(HexCoord)bottomHexCoord
             withOrientation:(DyadminoOrientation)orientation;

  // undo
-(DataDyadmino *)undoLastPlayedDyadmino;

  // swap
-(BOOL)passTurnBySwappingDyadminoes:(NSSet *)dyadminoesToSwap;

  // pass or complete turn
-(void)recordDyadminoesFromCurrentPlayerWithSwap:(BOOL)swap;

  // resign
-(void)resignPlayer:(Player *)player;

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

#pragma mark - replay methods

-(void)startReplay;
-(void)first;
-(BOOL)previous;
-(BOOL)next;
-(void)last;
-(void)leaveReplay;

#pragma mark - scene query methods

-(NSUInteger)wonPlayersCount;
-(Player *)playerForIndex:(NSUInteger)index;
-(DataDyadmino *)dataDyadminoForIndex:(NSUInteger)index;
-(UIColor *)colourForPlayer:(Player *)player forLabel:(BOOL)forLabel light:(BOOL)light;
-(Player *)returnCurrentPlayer;
-(DataDyadmino *)mostRecentDyadminoPlayed;

#pragma mark - label methods

-(NSString *)endGameResultsText;
-(NSString *)turnTextLastPlayed:(BOOL)lastPlayed;

#pragma mark - scene getter methods

-(GameRules)returnRules;
-(GameSkill)returnSkill;
-(GameType)returnType;
-(BOOL)returnGameHasEnded;
-(NSUInteger)returnFirstDataDyadIndex;
-(NSInteger)returnRandomNumber1To24;

#pragma mark - holding container helper methods

-(BOOL)holdingsContainsDataDyadmino:(DataDyadmino *)dataDyad;
-(NSArray *)dataDyadsInIndexContainer:(NSArray *)holdingContainer;

  // this is called by scene to determine whether to show reset button
-(BOOL)boardDyadminoesHaveMovedSinceStartOfTurn;

#pragma mark - methods for unit tests only

  // for tests
-(BOOL)testAddToHoldingContainer:(DataDyadmino *)dataDyad;
-(DataDyadmino *)testUndoLastPlayedDyadmino;
-(void)testRecordDyadminoesFromCurrentPlayerWithSwap:(BOOL)swap;
-(BOOL)testUpdateDataCellsForPlacedDyadminoID:(NSInteger)dyadminoID
                                  orientation:(DyadminoOrientation)orientation
                         onBottomCellHexCoord:(HexCoord)bottomHexCoord;
-(BOOL)testUpdateDataCellsForRemovedDyadminoID:(NSInteger)dyadminoID
                                   orientation:(DyadminoOrientation)orientation
                        fromBottomCellHexCoord:(HexCoord)bottomHexCoord;
-(void)testPersistChangedPositionForBoardDataDyadmino:(DataDyadmino *)dataDyad;
-(void)testEndGame;
-(PhysicalPlacementResult)testValidatePhysicallyPlacingDyadminoID:(NSUInteger)dyadminoID
                                                  withOrientation:(DyadminoOrientation)orientation
                                                 onBottomHexCoord:(HexCoord)bottomHexCoord;
-(NSSet *)testSonoritiesFromPlacingDyadminoID:(NSUInteger)dyadminoID
                             onBottomHexCoord:(HexCoord)bottomHexCoord
                              withOrientation:(DyadminoOrientation)orientation;
-(NSSet *)testSurroundingCellsOfSurroundingCellsOfDyadminoBottomHexCoord:(HexCoord)bottomHexCoord
                                                          andOrientation:(DyadminoOrientation)orientation;
-(NSSet *)testSurroundingCellsOfDyadminoBottomHexCoord:(HexCoord)bottomHexCoord
                                        andOrientation:(DyadminoOrientation)orientation;
-(BOOL)testPlayDataDyadmino:(DataDyadmino *)placedDataDyad anywherePhysicallyLegalByDataDyadmino:(DataDyadmino *)nextToDataDyad;
-(BOOL)testStrandedDyadminoesAfterRemovingDataDyadmino:(DataDyadmino *)dataDyadmino;

@end

@interface Turns : NSValueTransformer

@end

@interface HoldingIndexContainer : NSValueTransformer

@end

@interface ArrayOfChordsAndPoints : NSValueTransformer

@end

@protocol MatchDelegate <NSObject>

-(BOOL)isFirstAndOnlyDyadminoID:(NSUInteger)dyadminoID;
-(void)handleSwitchToNextPlayer;
-(void)handleEndGame;

@end