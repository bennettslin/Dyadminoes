//
//  MatchTests.m
//  Dyadminoes
//
//  Created by Bennett Lin on 12/2/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TestHelper.h"
#import "TestMatch.h"
#import "Player.h"
#import "DataDyadmino.h"

@interface MatchTests : XCTestCase

@property (strong, nonatomic) NSManagedObjectContext *myContext;
@property (strong, nonatomic) TestMatch *myMatch;
@property (strong, nonatomic) NSArray *playerNames;

@end

@implementation MatchTests

-(void)setUp {
  [super setUp];
  self.myContext = [TestHelper managedObjectContextForTests];
  self.playerNames = @[@"Bennett", @"Lauren", @"Julia", @"Mary"];
}

-(void)tearDown {
  self.myContext = nil;
  [super tearDown];
}

#pragma mark - initial setup tests

-(void)testMatchIsProperTypeForNumberOfPlayers {
  
    // test 1 to 4 players
  for (int i = 1; i <= kMaxNumPlayers; i++) {
    [self setupGameForNumberOfPlayers:i];
    
    GameType expectedType = (i == 1) ? kSelfGame : kPnPGame;
    GameType returnedType = (GameType)[self.myMatch.type unsignedIntegerValue];
    
    XCTAssertTrue(returnedType == expectedType, @"Game type is incorrect for %i players", i);
  }
}

-(void)testCorrectCountOfPileDistribution {
  
    // test 1 to 4 players
  for (int i = 0; i < kMaxNumPlayers; i++) {
    NSUInteger numberOfPlayers = i + 1;
    [self setupGameForNumberOfPlayers:numberOfPlayers];

      // pile count is 66, minus 1 on board, and 6 in each player's rack
    NSUInteger expectedPileCount = kPileCount - (numberOfPlayers * kNumDyadminoesInRack) - 1;
    XCTAssertTrue(self.myMatch.pile.count == expectedPileCount, @"Pile count is not as expected for %lu players", (unsigned long)numberOfPlayers);
    XCTAssertTrue(self.myMatch.board.count == 1, @"There isn't one dyadmino on board for %lu players", (unsigned long)numberOfPlayers);
    
    for (int j = 0; j <= i; j++) {
      Player *player = [self.myMatch playerForIndex:j];
      NSArray *dataDyadminoIndexesThisTurn = (NSArray *)player.dataDyadminoIndexesThisTurn;
      NSUInteger numberOfDataDyadminoesThisTurn = dataDyadminoIndexesThisTurn.count;
      XCTAssertTrue(numberOfDataDyadminoesThisTurn == kNumDyadminoesInRack, @"There isn't six dyadminoes in player %i's hand for %lu players", j, (unsigned long)numberOfPlayers);
    }
  }
}

-(void)testAllDyadminoesArePresent {
  
    // test 1 to 4 players
  for (int i = 0; i < kMaxNumPlayers; i++) {
    
    NSMutableArray *allDyadminoes = [NSMutableArray new];
    
    NSUInteger numberOfPlayers = i + 1;
    [self setupGameForNumberOfPlayers:numberOfPlayers];
    
    BOOL allNumbersAreInPile = YES;
    
      // add dyadminoes from pile, board, and player racks to array
    for (DataDyadmino *dataDyad in self.myMatch.pile) {
      NSNumber *dataDyadNumber = dataDyad.myID;
      [allDyadminoes addObject:dataDyadNumber];
    }

    for (DataDyadmino *dataDyad in self.myMatch.board) {
      NSNumber *dataDyadNumber = dataDyad.myID;
      NSLog(@"board dyadmino is %@", dataDyadNumber);
      [allDyadminoes addObject:dataDyadNumber];
    }
    
    for (int j = 0; j <= i; j++) {
      Player *player = [self.myMatch playerForIndex:j];
      NSArray *dataDyadminoIndexesThisTurn = (NSArray *)player.dataDyadminoIndexesThisTurn;
      [allDyadminoes addObjectsFromArray:dataDyadminoIndexesThisTurn];
    }

    for (NSUInteger k = 0; k < allDyadminoes.count; k++) {
      NSNumber *dataDyadNumber = [NSNumber numberWithUnsignedInteger:k];
      if (![allDyadminoes containsObject:dataDyadNumber]) {
        allNumbersAreInPile = NO;
        NSLog(@"doesn't contain %@", dataDyadNumber);
      }
    }

    XCTAssertTrue(allNumbersAreInPile, @"Some numbers are missing in pile for %lu players", (unsigned long)numberOfPlayers);
  }
}

#pragma mark - pass tests

-(void)testPassesToNextPlayer {
  
    // test 1 to 4 players
  for (int i = 1; i <= kMaxNumPlayers; i++) {
    [self setupGameForNumberOfPlayers:i];
    NSInteger numberOfPlayers = self.myMatch.players.count;
    
      // test that passes to next player for any number of players
    for (int j = 1; j <= numberOfPlayers; j++) {
      Player *currentPlayer = [self.myMatch returnCurrentPlayer];
      NSInteger currentPlayerIndex = [currentPlayer returnPlayerOrder];
      
      [self.myMatch recordDyadminoesFromCurrentPlayerWithSwap:NO];
      
      Player *nextPlayer = [self.myMatch returnCurrentPlayer];
      NSInteger nextPlayerIndex = [nextPlayer returnPlayerOrder];
      
        // next player will be current player for solo game
      BOOL switchesCorrectlyToNextPlayer = ([self.myMatch returnType] == kSelfGame) ?
          (nextPlayerIndex == currentPlayerIndex) :
          ((nextPlayerIndex - currentPlayerIndex + numberOfPlayers) % numberOfPlayers) == 1;
      
      XCTAssertTrue(switchesCorrectlyToNextPlayer, @"Does not switch to next player correctly.");
    }
  }
}

-(void)testCorrectNumberOfPassesEndMatchForAllNumbersOfPlayers {
  /*
   
   // test 1 to 4 players
   for (int i = 1; i <= kMaxNumPlayers; i++) {
   [self setupGameForNumberOfPlayers:i];
   
   // abort test if number of turns reaches 100
   while ([(NSArray *)self.myMatch.turns count] < 100 || !self.myMatch.gameHasEnded) {
   
   NSUInteger currentPlayerIndex = [[self.myMatch currentPlayerIndex] unsignedIntegerValue];
   Player *currentPlayer = [self.myMatch playerForIndex:currentPlayerIndex];
   [self.myMatch recordDyadminoesFromPlayer:currentPlayer withSwap:NO];
   
   
   }
   
   // 1. two rotations if there are dyadminoes left in pile
   // 2. one rotation if no dyadminoes are left in pile
   
   XCTAssertTrue(true, @"Game did not pass after certain number of turns for %i players", i);
   }
   */
}

#pragma mark - swap tests

-(void)testSwapPassesToNextPlayer {
    // duplicates testPassesToNextPlayer, except with swap
  
    // test 1 to 4 players
  for (int i = 1; i <= kMaxNumPlayers; i++) {
    [self setupGameForNumberOfPlayers:i];
    NSInteger numberOfPlayers = self.myMatch.players.count;
    
      // test that passes to next player for any number of players
    for (int j = 1; j <= numberOfPlayers; j++) {
      Player *currentPlayer = [self.myMatch returnCurrentPlayer];
      NSInteger currentPlayerIndex = [currentPlayer returnPlayerOrder];
      
        // random data dyadmino
      NSUInteger randomDataDyadminoRackIndex = arc4random() % [(NSArray *)currentPlayer.dataDyadminoIndexesThisTurn count];
      NSNumber *randomDataDyadminoIndex = [(NSArray *)currentPlayer.dataDyadminoIndexesThisTurn objectAtIndex:randomDataDyadminoRackIndex];
      DataDyadmino *dataDyadmino = [self.myMatch dataDyadminoForIndex:[randomDataDyadminoIndex unsignedIntegerValue]];
      
      [self.myMatch addToSwapDataDyadmino:dataDyadmino];
      [self.myMatch swapDyadminoesFromCurrentPlayer];
      
      Player *nextPlayer = [self.myMatch returnCurrentPlayer];
      NSInteger nextPlayerIndex = [nextPlayer returnPlayerOrder];
      
        // next player will be current player for solo game
      BOOL switchesCorrectlyToNextPlayer = ([self.myMatch returnType] == kSelfGame) ?
      (nextPlayerIndex == currentPlayerIndex) :
      ((nextPlayerIndex - currentPlayerIndex + numberOfPlayers) % numberOfPlayers) == 1;
      
      XCTAssertTrue(switchesCorrectlyToNextPlayer, @"Does not switch to next player after swap correctly.");
    }
  }
}

-(void)testSwapCorrectlyExchangesDataDyadminoesBetweenPileAndRack {
  
    // test 1 to 4 players
  for (int i = 1; i <= kMaxNumPlayers; i++) {
    
      // returns all subsets of dyadminoes
    NSArray *numberArray = [self arrayOfNumbersWithCount:kNumDyadminoesInRack];
    NSArray *powerSetArray = [self powerSet:numberArray];

      // for this particular combination of data dyadminoes to be swapped
    for (NSArray *rackOrderArray in powerSetArray) {
      
      [self setupGameForNumberOfPlayers:i];
      
      Player *player = [self.myMatch returnCurrentPlayer];
      NSArray *dataDyadminoIndexes = (NSArray *)player.dataDyadminoIndexesThisTurn;
      
      NSUInteger beforePileCount = self.myMatch.pile.count;
      NSUInteger beforeDataDyadminoIndexesCount = dataDyadminoIndexes.count;
      
      NSMutableArray *tempSwappedDataDyads = [NSMutableArray new];
      
      for (NSNumber *index in rackOrderArray) {
        NSUInteger rackOrderIndex = [index unsignedIntegerValue];
        NSUInteger dataDyadminoIndex = [dataDyadminoIndexes[rackOrderIndex] unsignedIntegerValue];
        DataDyadmino *dataDyad = [self.myMatch dataDyadminoForIndex:dataDyadminoIndex];
        [self.myMatch addToSwapDataDyadmino:dataDyad];
        [tempSwappedDataDyads addObject:dataDyad];
      }
      
      NSArray *swappedDataDyads = [NSArray arrayWithArray:tempSwappedDataDyads];
      
        // swapped!
      [self.myMatch swapDyadminoesFromCurrentPlayer];
      
      NSUInteger afterPileCount = self.myMatch.pile.count;
      NSUInteger afterDataDyadminoIndexesCount = [(NSArray *)player.dataDyadminoIndexesThisTurn count];
      
        // check pile count is same
      XCTAssertEqual(beforePileCount, afterPileCount, @"Pile count is different after swap.");
      
        // check player rack count is same
      XCTAssertEqual(beforeDataDyadminoIndexesCount, afterDataDyadminoIndexesCount, @"Player rack count is different after swap.");
      
        // check swapped dyadminoes are now in pile
      for (DataDyadmino *dataDyad in swappedDataDyads) {
        PlaceStatus placeStatus = (PlaceStatus)[dataDyad.placeStatus unsignedIntegerValue];
        XCTAssertTrue(placeStatus == kInPile, @"Data dyadmino is not back in pile.");
      }
    }
  }
}

-(void)testPlayerNeverGetsSameDyadminoesBackAfterSwap {
  
    // repeat 100 times to be sure
  for (int i = 0; i < 99; i++) {

    [self setupGameForNumberOfPlayers:1];
    NSMutableArray *tempSwappedDataDyadminoIndexes = [NSMutableArray new];
    Player *player = [self.myMatch returnCurrentPlayer];
    NSArray *dataDyadminoIndexes = (NSArray *)player.dataDyadminoIndexesThisTurn;
    
      // exchange all data dyadminoes in rack
    for (NSNumber *index in dataDyadminoIndexes) {
      DataDyadmino *dataDyad = [self.myMatch dataDyadminoForIndex:[index unsignedIntegerValue]];
      [tempSwappedDataDyadminoIndexes addObject:index];
      [self.myMatch addToSwapDataDyadmino:dataDyad];
    }
    
    [self.myMatch swapDyadminoesFromCurrentPlayer];
    NSArray *postSwapDataDyadminoIndexes = (NSArray *)player.dataDyadminoIndexesThisTurn;

    BOOL noDataDyadminoesReturnedToRack = YES;
    for (NSNumber *index in tempSwappedDataDyadminoIndexes) {
      if ([postSwapDataDyadminoIndexes containsObject:index]) {
        noDataDyadminoesReturnedToRack = NO;
      }
    }
    
    XCTAssertTrue(noDataDyadminoesReturnedToRack, @"Some data dyadminoes returned to rack after swap.");
  }
}

  // test that swap isn't possible when fewer data dyadminoes in pile
  // this will need a method



  // test end game

#pragma mark - play methods



#pragma mark - additional setup methods

-(void)setupGameForNumberOfPlayers:(NSUInteger)numberOfPlayers {
  self.myMatch = [NSEntityDescription insertNewObjectForEntityForName:@"Match" inManagedObjectContext:self.myContext];
  
  NSMutableSet *tempSet = [NSMutableSet new];
  for (NSUInteger i = 0; i < numberOfPlayers; i++) {
    Player *newPlayer = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:self.myContext];
    [newPlayer initialUniqueID:@"" andPlayerName:self.playerNames[i] andPlayerOrder:i];
    [tempSet addObject:newPlayer];
  }
  NSSet *players = [NSSet setWithSet:tempSet];
  
  [self.myMatch initialPlayers:players andRules:kGameRulesTonal andSkill:kBeginner withContext:self.myContext];
  
  NSError *error = nil;
  if (![self.myContext save:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
}

#pragma mark - helper methods

-(NSArray *)arrayOfNumbersWithCount:(NSUInteger)count {
  NSMutableArray *numberArray = [NSMutableArray new];
  NSUInteger counter = 0;
  while (counter < count) {
    [numberArray addObject:[NSNumber numberWithUnsignedInteger:counter]];
    counter++;
  }
  return [NSArray arrayWithArray:numberArray];
}

-(NSArray *)powerSet:(NSArray *)array {
    // return the powerset of an array:
    // an array of all possible subarrays of the passed array

  if (array.count == 0) {
    return [NSArray arrayWithObject:[NSArray array]];
  }
  
    // get an object from the array and the array without that object
  id lastObject = [array lastObject];
  NSArray *arrayLessOne = [array subarrayWithRange:NSMakeRange(0,array.count - 1)];
  
    // compute the powerset of the array without that object using recursion
  NSArray *powerSetLessOne = [self powerSet:arrayLessOne];
  
    // powerset is the union of the powerSetLessOne and powerSetLessOne where
    // each element is unioned with the removed element
  NSMutableArray *powerset = [NSMutableArray arrayWithArray:powerSetLessOne];
  
    // add the removed object to every element of the recursive power set
  for (NSArray *lessOneElement in powerSetLessOne) {
    [powerset addObject:[lessOneElement arrayByAddingObject:lastObject]];
  }
  
  return [NSArray arrayWithArray:powerset];
}

 -(void)testPowerSetMethod {
 NSArray *array = @[@1, @2, @3, @4, @5, @6];
 NSArray *powerSet = [self powerSet:array];
 NSLog(@"power set is: %@", powerSet);
 }
 
 -(void)testNumberArrayMethod {
 NSArray *numberArray = [self arrayOfNumbersWithCount:6];
 NSLog(@"number array is: %@", numberArray);
 }

@end
