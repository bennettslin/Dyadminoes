//
//  Match.m
//  Dyadminoes
//
//  Created by Bennett Lin on 5/19/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Match.h"
#import "Player.h"
#import "DataDyadmino.h"

@interface Match () <PlayerDelegate>

@property (nonatomic) NSUInteger numberOfConsecutivePasses;
@property (strong, nonatomic) DataDyadmino *firstDyadmino;

@end

@implementation Match

#pragma mark - archiver methods

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self) {
    self.rules = [[aDecoder decodeObjectForKey:@"rules"] unsignedIntValue];
    self.skill = [[aDecoder decodeObjectForKey:@"skill"] unsignedIntValue];
    self.type = [[aDecoder decodeObjectForKey:@"type"] unsignedIntValue];
    
    self.lastPlayed = [aDecoder decodeObjectForKey:@"lastPlayed"];
    
    self.players = [aDecoder decodeObjectForKey:@"players"];
    
    for (Player *player in self.players) {
      player.delegate = self;
    }
    
    self.currentPlayer = [aDecoder decodeObjectForKey:@"currentPlayer"];
    self.wonPlayers = [aDecoder decodeObjectForKey:@"wonPlayers"];
    self.gameHasEnded = [aDecoder decodeBoolForKey:@"gameHasEnded"];
    
    self.pile = [aDecoder decodeObjectForKey:@"pile"];
    self.board = [aDecoder decodeObjectForKey:@"board"];
    
    self.tempScore = [[aDecoder decodeObjectForKey:@"tempScore"] unsignedIntegerValue];
    self.holdingContainer = [aDecoder decodeObjectForKey:@"holdingContainer"];
    self.swapContainer = [aDecoder decodeObjectForKey:@"swapContainer"];
    self.replayCounter = [[aDecoder decodeObjectForKey:@"replayCounter"] unsignedIntegerValue];
    self.turns = [aDecoder decodeObjectForKey:@"turns"];
    
    self.numberOfConsecutivePasses = [[aDecoder decodeObjectForKey:@"consecutivePasses"] unsignedIntegerValue];
    self.firstDyadmino = [aDecoder decodeObjectForKey:@"firstDyadmino"];
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:[NSNumber numberWithUnsignedInt:self.rules] forKey:@"rules"];
  [aCoder encodeObject:[NSNumber numberWithUnsignedInt:self.skill] forKey:@"skill"];
  [aCoder encodeObject:[NSNumber numberWithUnsignedInt:self.type] forKey:@"type"];

  [aCoder encodeObject:self.lastPlayed forKey:@"lastPlayed"];
  
  [aCoder encodeObject:self.players forKey:@"players"];
  [aCoder encodeObject:self.currentPlayer forKey:@"currentPlayer"];
  [aCoder encodeObject:self.wonPlayers forKey:@"wonPlayers"];
  [aCoder encodeBool:self.gameHasEnded forKey:@"gameHasEnded"];
  
  [aCoder encodeObject:self.pile forKey:@"pile"];
  [aCoder encodeObject:self.board forKey:@"board"];
  
  [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.tempScore] forKey:@"tempScore"];
  [aCoder encodeObject:self.holdingContainer forKey:@"holdingContainer"];
  [aCoder encodeObject:self.swapContainer forKey:@"swapContainer"];
  [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.replayCounter] forKey:@"replayCounter"];
  [aCoder encodeObject:self.turns forKey:@"turns"];
  
  [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.numberOfConsecutivePasses] forKey:@"consecutivePasses"];
  [aCoder encodeObject:self.firstDyadmino forKey:@"firstDyadmino"];
}

#pragma mark - init methods

-(id)initWithPlayers:(NSArray *)players andRules:(GameRules)rules andSkill:(GameSkill)skill andType:(GameType)type {
  self = [super init];
  if (self) {
    
    self.rules = rules;
    self.skill = skill;
    self.type = type;
    
    self.lastPlayed = [NSDate date];
    self.gameHasEnded = NO;
    self.numberOfConsecutivePasses = 0;
    
    self.players = players;
    self.currentPlayer = players[0];
    
    for (Player *player in self.players) {
      player.delegate = self;
    }
    
    self.holdingContainer = @[];
    self.swapContainer = [NSMutableArray new];
    
    self.pile = [[NSMutableArray alloc] initWithCapacity:kPileCount];
    self.board = [[NSMutableSet alloc] initWithCapacity:kPileCount];
    self.turns = [NSMutableArray new];
    self.replayCounter = 0;
    
    [self generatePile];
    [self placeFirstDyadminoOnBoard];
    [self distributePileAmongstPlayers];
  }
  return self;
}

-(void)generatePile {
  for (int i = 1; i <= kPileCount; i++) {
    DataDyadmino *dataDyad = [[DataDyadmino alloc] initWithID:i];
    [self.pile addObject:dataDyad];
  }
}

-(void)distributePileAmongstPlayers {
  for (Player *player in self.players) {
    [self fillRackFromPileForPlayer:player];
    
      // this won't be here in real game, should keep player's desired order
    [self sortDyadminoes:player.dataDyadminoesThisTurn];
  }
}

-(void)placeFirstDyadminoOnBoard {
  while (self.board.count == 0 && self.pile.count > 0) {
    NSUInteger randIndex = [self randomIntegerUpTo:self.pile.count];
    self.firstDyadmino = [self.pile objectAtIndex:randIndex];
    struct HexCoord myHex = {0, 0};
    self.firstDyadmino.myHexCoord = myHex;
    [self.pile removeObjectAtIndex:randIndex];
    [self.board addObject:self.firstDyadmino];
  }
}

#pragma mark - game play methods

-(void)fillRackFromPileForPlayer:(Player *)player {
    // reset rack order of data dyadminoes already in rack
  for (int i = 0; i < player.dataDyadminoesThisTurn.count; i++) {
    DataDyadmino *dataDyad = player.dataDyadminoesThisTurn[i];
    dataDyad.myRackOrder = i;
  }
  
  while (player.dataDyadminoesThisTurn.count < kNumDyadminoesInRack && self.pile.count > 0) {
    NSUInteger randIndex = [self randomIntegerUpTo:self.pile.count];
    DataDyadmino *dataDyad = [self.pile objectAtIndex:randIndex];
      // rack order is total count at the time
    dataDyad.myRackOrder = player.dataDyadminoesThisTurn.count;
    [self.pile removeObjectAtIndex:randIndex];
    [player.dataDyadminoesThisTurn addObject:dataDyad];
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
        
        [self.delegate handleSwitchToNextPlayer];
        return nextPlayer;
      }
    }
  }
  return nil;
}

#pragma mark - game state change methods

-(void)swapDyadminoesFromCurrentPlayer {
  Player *player = self.currentPlayer;
  for (DataDyadmino *dataDyad in self.swapContainer) {
    if ([player.dataDyadminoesThisTurn containsObject:dataDyad]) {
      [player.dataDyadminoesThisTurn removeObject:dataDyad];
    }
  }
  
  [self fillRackFromPileForPlayer:player];
  [self.pile addObjectsFromArray:self.swapContainer];
  [self.swapContainer removeAllObjects];
  
  [self resetHoldingContainer];
  [self recordDyadminoesFromPlayer:player withSwap:YES]; // this records turn as a pass
    // sort the board and pile
  [self sortBoardAndPileArrays];
}

-(void)recordDyadminoesFromPlayer:(Player *)player withSwap:(BOOL)swap {
  
    // player passes
  if (self.holdingContainer.count == 0) {
    
      // if solo game, ends right away
      // FIXME: this will need to be changed to accommodate when board dyadmino
      // is moved to create a chord and nothing else, which counts as a turn and
      // not a pass
    if (self.type == kSelfGame && !swap) {
      [self endGame];
      return;
    }
    
    self.numberOfConsecutivePasses++;
    
      // enough players passed to end game
      // 1. two rotations if there are dyadminoes left in pile
      // 2. one rotation if no dyadminoes are left in pile
    if (self.type != kSelfGame && ((self.pile.count > 0 && self.numberOfConsecutivePasses >= self.players.count * 2) ||
        (self.pile.count == 0 && self.numberOfConsecutivePasses >= self.players.count))) {
      [self endGame];
      return;
    }
    
      // player submitted dyadminoes
  } else {
    
      // only counts as a turn if it's not a pass
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:self.currentPlayer, @"player", self.holdingContainer, @"container", nil];
    
    [self.turns addObject:dictionary];
    self.replayCounter = self.turns.count;
    
      // reset number of consecutive passes
    self.numberOfConsecutivePasses = 0;
      /// obviously scorekeeping will be more sophisticated
      /// and will consider chords formed
    player.playerScore += self.tempScore;
    
    [self.board addObjectsFromArray:self.holdingContainer];
    
    for (DataDyadmino *dataDyad in self.holdingContainer) {
      if ([player.dataDyadminoesThisTurn containsObject:dataDyad]) {
        [player.dataDyadminoesThisTurn removeObject:dataDyad];
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
  [self resetHoldingContainer];
  self.lastPlayed = [NSDate date];
  [self switchToNextPlayer];
}

-(void)resignPlayer:(Player *)player {
  
  player.resigned = YES;
  [self.pile addObjectsFromArray:player.dataDyadminoesThisTurn];
  [self sortBoardAndPileArrays];
  
  [self resetHoldingContainer];
  [player.dataDyadminoesThisTurn removeAllObjects];
  if (![self switchToNextPlayer]) {
    [self endGame];
  }
  
  self.lastPlayed = [NSDate date];
}

-(void)endGame {
  self.currentPlayer = nil;
  [self resetHoldingContainer];
  
    // if solo game, sole player is winner if any score at all
  if (self.type == kSelfGame) {
    Player *soloPlayer = self.players[0];
    self.wonPlayers = (soloPlayer.playerScore > 0) ?
      [NSArray arrayWithArray:self.players] :
      @[];
    
  } else {
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
  }

  self.gameHasEnded = YES;
  [self.delegate handleEndGame];
}

#pragma mark - helper methods

-(BOOL)checkPlayerFirstToRunOut {
  if (self.currentPlayer.dataDyadminoesThisTurn.count == 0 && self.pile.count == 0) {
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
  [self sortDyadminoes:self.pile];
//  [self sortDyadminoes:self.board];
}

-(void)sortDyadminoes:(NSMutableArray *)array {
  NSSortDescriptor *sortByID = [[NSSortDescriptor alloc] initWithKey:@"myID" ascending:YES];
  [array sortedArrayUsingDescriptors:@[sortByID]];
}

-(NSString *)endGameResultsText {
  
  NSString *resultsText;
    // there are winners if there is any score at all
  if (self.wonPlayers.count > 0) {
    
    NSMutableArray *wonPlayerNames = [[NSMutableArray alloc] initWithCapacity:self.wonPlayers.count];
    for (Player *player in self.wonPlayers) {
      [wonPlayerNames addObject:player.playerName];
    }
    
    NSString *wonPlayers = [wonPlayerNames componentsJoinedByString:@" and "];
    resultsText = [NSString stringWithFormat:@"%@ won!", wonPlayers];
    
      // solo game with no score
  } else if (self.type == kSelfGame) {
    resultsText = @"Scoreless game.";
    
  } else {
    resultsText = @"Draw game.";
  }
  
  return resultsText;
}

-(NSString *)turnTextLastPlayed:(BOOL)lastPlayed {
  Player *turnPlayer = [self.turns[self.replayCounter - 1] objectForKey:@"player"];
  NSArray *dyadminoesPlayed = [self.turns[self.replayCounter - 1] objectForKey:@"container"];
  NSString *dyadminoesPlayedString;
  if (dyadminoesPlayed.count > 0) {
    NSString *componentsString = [[dyadminoesPlayed valueForKey:kDyadminoIDKey] componentsJoinedByString:@", "];
    dyadminoesPlayedString = [NSString stringWithFormat:@"played %@", componentsString];
  } else {
    dyadminoesPlayedString = @"passed";
  }
  
  if (lastPlayed) {
    return [NSString stringWithFormat:@"%@ last %@.", turnPlayer.playerName, dyadminoesPlayedString];
  } else {
    return [NSString stringWithFormat:@"%@ %@ for turn %lu of %lu.", turnPlayer.playerName, dyadminoesPlayedString, (unsigned long)self.replayCounter, (unsigned long)self.turns.count];
  }
}

#pragma mark - undo manager

-(void)addToHoldingContainer:(DataDyadmino *)dataDyad {
  
    // modify scorekeeping methods, of course
    // especially since this will be used to call swap as well
  self.tempScore++;
  
  if (![self.holdingContainer containsObject:dataDyad]) {
    NSMutableArray *tempContainer = [NSMutableArray arrayWithArray:self.holdingContainer];
    [tempContainer addObject:dataDyad];
    self.holdingContainer = [NSArray arrayWithArray:tempContainer];
  }
}

-(void)setHoldingContainer:(NSArray *)newHoldingContainer {
  if (!_holdingContainer || !newHoldingContainer) {
    _holdingContainer = newHoldingContainer;
  } else if (_holdingContainer != newHoldingContainer) {
    _holdingContainer = newHoldingContainer;
  }
}

-(DataDyadmino *)undoDyadminoToHoldingContainer {
  if (self.holdingContainer.count > 0) {
    self.tempScore--;
    DataDyadmino *lastDataDyadmino = [self.holdingContainer lastObject];
    NSMutableArray *tempContainer = [NSMutableArray arrayWithArray:self.holdingContainer];
    [tempContainer removeObject:lastDataDyadmino];
    self.holdingContainer = [NSArray arrayWithArray:tempContainer];
    return lastDataDyadmino;
  }
  return nil;
}

-(void)resetHoldingContainer {
  self.holdingContainer = @[];
  self.tempScore = 0;
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
  for (DataDyadmino *dataDyad in container) {
    if (![self.board containsObject:dataDyad]) {
      [self.board addObject:dataDyad];
    }
  }
}

-(BOOL)previous {

  if (self.replayCounter <= 1) {
    return NO;
    
  } else {
      NSArray *container = [self.turns[self.replayCounter - 1] objectForKey:@"container"];
      for (DataDyadmino *dataDyad in container) {
        if ([self.board containsObject:dataDyad]) {
          [self.board removeObject:dataDyad];
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
      for (DataDyadmino *dataDyad in container) {
        if (![self.board containsObject:dataDyad]) {
          [self.board addObject:dataDyad];
        }
      }
    return YES;
  }
}

-(void)lastOrLeaveReplay {
  self.replayCounter = self.turns.count;
  for (int i = 0; i < self.turns.count; i++) {
    NSArray *container = [self.turns[i] objectForKey:@"container"];
    for (DataDyadmino *dataDyad in container) {
      if (![self.board containsObject:dataDyad]) {
        [self.board addObject:dataDyad];
      }
    }
  }
}

@end
