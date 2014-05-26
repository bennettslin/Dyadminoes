//
//  Match.m
//  Dyadminoes
//
//  Created by Bennett Lin on 5/19/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Match.h"
#import "NSObject+Helper.h"
#import "Player.h"

@interface Match ()

@property (nonatomic) NSUInteger numberOfConsecutivePasses;

@end

@implementation Match

#pragma mark - init methods

-(id)initWithPlayers:(NSArray *)players {
  self = [super init];
  if (self) {
    
    self.undoManager = [[NSUndoManager alloc] init];
    
    self.lastPlayed = [NSDate date];
//    self.wonPlayers = [[NSArray alloc] init];
    self.gameHasEnded = NO;
    self.numberOfConsecutivePasses = 0;
    
    self.players = players;
    self.currentPlayer = players[0];
    
    self.holdingContainer = @[];
    
    self.pile = [[NSMutableArray alloc] initWithCapacity:66];
    self.board = [[NSMutableArray alloc] initWithCapacity:66];
    
    [self generatePile];
    [self distributePileAmongstPlayers];
  }
  return self;
}

-(void)generatePile {
  for (int i = 1; i <= 66; i++) {
    NSNumber *dyadNumber = [NSNumber numberWithInt:i];
    [self.pile addObject:dyadNumber];
  }
}

-(void)distributePileAmongstPlayers {
  for (Player *player in self.players) {
    [self addFromPileToRackOfPlayer:player];
    
      // this won't be here in real game, should keep player's desired order
    [player.dyadminoesInRack sortUsingSelector:@selector(compare:)];
  }
}

-(void)addFromPileToRackOfPlayer:(Player *)player {
  while (player.dyadminoesInRack.count < kNumDyadminoesInRack && self.pile.count > 0) {
    NSUInteger randIndex = [self randomIntegerUpTo:self.pile.count];
    NSNumber *dyadNumber = [self.pile objectAtIndex:randIndex];
    [self.pile removeObjectAtIndex:randIndex];
    [player.dyadminoesInRack addObject:dyadNumber];
  }
}

-(Player *)switchToNextPlayer {
  
  NSUInteger index = [self.players indexOfObject:self.currentPlayer];
  if ([self checkNumberOfPlayersStillInGame] > 1) {

    while (index < self.players.count * 2) {
      Player *nextPlayer = self.players[(index + 1) % self.players.count];
      if (nextPlayer.resigned) {
        index++;
      } else {
        self.currentPlayer = nextPlayer;
        return nextPlayer;
      }
    }
  }
  
  return nil;
}

#pragma mark - game state change methods

-(void)recordDyadminoesFromPlayer:(Player *)player {
  
    // player passes
  if (self.holdingContainer.count == 0) {
    self.numberOfConsecutivePasses++;
    
      // enough players passed to end game
      // 1. two rotations if there are dyadminoes left in pile
      // 2. one rotation if no dyadminoes are left in pile
    if ((self.pile.count > 0 && self.numberOfConsecutivePasses >= self.players.count * 2) ||
        (self.pile.count == 0 && self.numberOfConsecutivePasses >= self.players.count)) {
      [self endGame];
      return;
    }
    
      // player submitted dyadminoes
  } else {
    
      // reset number of consecutive passes
    self.numberOfConsecutivePasses = 0;
      /// obviously scorekeeping will be more sophisticated
      /// and will consider chords formed
    player.playerScore += self.holdingContainer.count;
    
    [self.board addObjectsFromArray:self.holdingContainer];
    
    for (NSNumber *number in self.holdingContainer) {
      if ([player.dyadminoesInRack containsObject:number]) {
        [player.dyadminoesInRack removeObject:number];
      }
    }
    
      // if player ran out and pile is empty, then end game
    if ([self checkPlayerFirstToRunOut]) {
      [self endGame];
      return;
        // else just refill the rack
    } else {
      [self addFromPileToRackOfPlayer:player];
    }
      // sort the board and pile
    [self sortBoardAndPileArrays];
  }
  
  self.holdingContainer = @[];
  [self.undoManager removeAllActions];
  
    // whether pass or not, game continues
  self.lastPlayed = [NSDate date];
  [self switchToNextPlayer];
}

-(void)resignPlayer:(Player *)player {

  player.resigned = YES;
  [self.pile addObjectsFromArray:player.dyadminoesInRack];
  [self sortBoardAndPileArrays];
  
  self.holdingContainer = @[];
  [self.undoManager removeAllActions];
  
  [player.dyadminoesInRack removeAllObjects];
  if (![self switchToNextPlayer]) {
    [self endGame];
  }
}

-(void)endGame {
  self.currentPlayer = nil;
  
  self.holdingContainer = @[];
  [self.undoManager removeAllActions];
  
    // rules out that players with no points can win
  NSUInteger maxScore = 1;
  NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:self.players.count];
  
  for (Player *player in self.players) {
    if (!player.resigned) {
      if (player.playerScore > maxScore) {
        [tempArray removeAllObjects];
        [tempArray addObject:player];
        maxScore = player.playerScore;
      } else if (player.playerScore == maxScore) {
        [tempArray addObject:player];
      }
    }
  }

  self.wonPlayers = [NSArray arrayWithArray:tempArray];
  self.gameHasEnded = YES;
  [self.delegate handleEndGame];
}

#pragma mark - helper methods

-(BOOL)checkPlayerFirstToRunOut {
  if (self.currentPlayer.dyadminoesInRack.count == 0 && self.pile.count == 0) {
    return YES;
  } else {
    return NO;
  }
}

-(NSUInteger)checkNumberOfPlayersStillInGame {
  NSUInteger numberOfPlayersInGame = 0;
  for (Player *player in self.players) {
    if (player.resigned == NO) {
      numberOfPlayersInGame++;
    }
  }
  return numberOfPlayersInGame;
}

-(void)sortBoardAndPileArrays {
    // this will have to change when dyadminoes
  [self.pile sortUsingSelector:@selector(compare:)];
  [self.board sortUsingSelector:@selector(compare:)];
}

#pragma mark - undo manager

-(void)addToHoldingContainer:(NSNumber *)dyadmino {
  
  if (![self.holdingContainer containsObject:dyadmino]) {
    NSMutableArray *tempContainer = [NSMutableArray arrayWithArray:self.holdingContainer];
    [tempContainer addObject:dyadmino];
    self.holdingContainer = [NSArray arrayWithArray:tempContainer];
  }
}

-(void)setHoldingContainer:(NSArray *)newHoldingContainer {
  
  if (!_holdingContainer || !newHoldingContainer) {
    _holdingContainer = newHoldingContainer;
  } else if (_holdingContainer != newHoldingContainer) {
    [self.undoManager registerUndoWithTarget:self selector:@selector(setHoldingContainer:) object:_holdingContainer];
    _holdingContainer = newHoldingContainer;
  }
}

-(void)undoDyadminoToHoldingContainer {
  [self.undoManager undo];
}

-(void)redoDyadminoToHoldingContainer {
  [self.undoManager redo];
}

@end
