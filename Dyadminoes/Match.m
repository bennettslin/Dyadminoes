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
@property (strong, nonatomic) NSNumber *firstDyadmino;

@end

@implementation Match

#pragma mark - init methods

-(id)initWithPlayers:(NSArray *)players {
  self = [super init];
  if (self) {
    
    self.undoManager = [[NSUndoManager alloc] init];
    
    self.lastPlayed = [NSDate date];
    self.gameHasEnded = NO;
    self.numberOfConsecutivePasses = 0;
    
    self.players = players;
    self.currentPlayer = players[0];
    
    self.holdingContainer = @[];
    
    self.pile = [[NSMutableArray alloc] initWithCapacity:66];
    self.board = [[NSMutableArray alloc] initWithCapacity:66];
    self.turns = [NSMutableArray new];
    self.replayCounter = 0;
    
    [self generatePile];
    [self placeFirstDyadminoOnBoard];
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
    [self fillRackFromPileForPlayer:player];
    
      // this won't be here in real game, should keep player's desired order
    [player.dyadminoesInRack sortUsingSelector:@selector(compare:)];
  }
}

-(void)placeFirstDyadminoOnBoard {
  while (self.board.count == 0 && self.pile.count > 0) {
    NSUInteger randIndex = [self randomIntegerUpTo:self.pile.count];
    self.firstDyadmino = [self.pile objectAtIndex:randIndex];
    [self.pile removeObjectAtIndex:randIndex];
    [self.board addObject:self.firstDyadmino];
  }
}

#pragma mark - game play methods

-(void)fillRackFromPileForPlayer:(Player *)player {
  while (player.dyadminoesInRack.count < kNumDyadminoesInRack && self.pile.count > 0) {
    NSUInteger randIndex = [self randomIntegerUpTo:self.pile.count];
    NSNumber *dyadmino = [self.pile objectAtIndex:randIndex];
    [self.pile removeObjectAtIndex:randIndex];
    [player.dyadminoesInRack addObject:dyadmino];
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

-(void)swapDyadminoesFromPlayer:(Player *)player {
  
  for (NSNumber *dyadmino in self.holdingContainer) {
    if ([player.dyadminoesInRack containsObject:dyadmino]) {
      [player.dyadminoesInRack removeObject:dyadmino];
    }
  }
  
  [self fillRackFromPileForPlayer:player];
  [self.pile addObjectsFromArray:self.holdingContainer];
  
  [self resetHoldingContainer];
  [self recordDyadminoesFromPlayer:player]; // this records turn as a pass
                                            // sort the board and pile
  [self sortBoardAndPileArrays];
}

-(void)recordDyadminoesFromPlayer:(Player *)player {
  
  NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:self.currentPlayer, @"player", self.holdingContainer, @"container", nil];
  
  [self.turns addObject:dictionary];
  self.replayCounter = self.turns.count;
  
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
    
    for (NSNumber *dyadmino in self.holdingContainer) {
      if ([player.dyadminoesInRack containsObject:dyadmino]) {
        [player.dyadminoesInRack removeObject:dyadmino];
      }
    }
    
      // if player ran out and pile is empty, then end game
    if ([self checkPlayerFirstToRunOut]) {
      [self endGame];
      return;
        // else just refill the rack
    } else {
      [self fillRackFromPileForPlayer:player];
    }
      // sort the board and pile
    [self sortBoardAndPileArrays];
  }
  
      // whether pass or not, game continues
  
  self.holdingContainer = @[];
  [self.undoManager removeAllActions];
  
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
  
  [self resetHoldingContainer];
  
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

-(void)resetHoldingContainer {
  self.holdingContainer = @[];
  [self.undoManager removeAllActions];
}

#pragma mark - replay methods

-(void)first {
  
  if (self.replayCounter == 0) { // in case the replay is before any turn made
    return;
  }
  
  self.replayCounter = 1;
  [self.board removeAllObjects];
  [self.board addObject:self.firstDyadmino];
  NSArray *container = [self.turns[self.replayCounter - 1] objectForKey:@"container"];
  for (NSNumber *dyadmino in container) {
    if (![self.board containsObject:dyadmino]) {
      [self.board addObject:dyadmino];
    }
  }
}

-(BOOL)previous {

  if (self.replayCounter <= 1) {
    return NO;
    
  } else {
      NSArray *container = [self.turns[self.replayCounter - 1] objectForKey:@"container"];
      for (NSNumber *dyadmino in container) {
        if ([self.board containsObject:dyadmino]) {
          [self.board removeObject:dyadmino];
        }
      }
    self.replayCounter--;
    return YES;
  }
}

-(BOOL)next {
  
  if (self.replayCounter >= self.turns.count) {
    return NO;
    
  } else {
    self.replayCounter++;
      NSArray *container = [self.turns[self.replayCounter - 1] objectForKey:@"container"];
      for (NSNumber *dyadmino in container) {
        if (![self.board containsObject:dyadmino]) {
          [self.board addObject:dyadmino];
        }
      }
    return YES;
  }
}

-(void)lastOrLeaveReplay {
  self.replayCounter = self.turns.count;
  for (int i = 0; i < self.turns.count; i++) {
    NSArray *container = [self.turns[i] objectForKey:@"container"];
    for (NSNumber *dyadmino in container) {
      if (![self.board containsObject:dyadmino]) {
        [self.board addObject:dyadmino];
      }
    }
  }
}

@end
