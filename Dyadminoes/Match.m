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

@end

@implementation Match

#pragma mark - init methods

-(id)initWithPlayers:(NSArray *)players {
  self = [super init];
  if (self) {
    self.lastPlayed = [NSDate date];
    self.wonPlayers = [[NSArray alloc] init];
    
    self.players = players;
    self.currentPlayer = players[0];
    
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

-(void)recordDyadminoes:(NSMutableArray *)dyadminoes fromPlayer:(Player *)player {
  
    // obviously scorekeeping will be more sophisticated
    // and will consider chords formed
  player.playerScore += dyadminoes.count;
  
  [self.board addObjectsFromArray:dyadminoes];
  
  for (NSNumber *number in dyadminoes) {
    if ([player.dyadminoesInRack containsObject:number]) {
      [player.dyadminoesInRack removeObject:number];
    }
  }
  
  [self addFromPileToRackOfPlayer:player];
  [self sortArrays];
  
  self.lastPlayed = [NSDate date];
  [self switchToNextPlayer];
}

-(void)resignPlayer:(Player *)player {
  player.resigned = YES;
  [self.pile addObjectsFromArray:player.dyadminoesInRack];
  [self sortArrays];
  
  [player.dyadminoesInRack removeAllObjects];
  if (![self switchToNextPlayer]) {
    [self endGame];
  }
}

-(void)endGame {
  self.currentPlayer = nil;
  NSUInteger maxScore = 0;
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
  [self.delegate handleEndGame];
}

#pragma mark - helper methods

-(NSUInteger)checkNumberOfPlayersStillInGame {
  NSUInteger numberOfPlayersInGame = 0;
  for (Player *player in self.players) {
    if (player.resigned == NO) {
      numberOfPlayersInGame++;
    }
  }
  return numberOfPlayersInGame;
}

-(void)sortArrays {
    // this will have to change when dyadminoes
  [self.pile sortUsingSelector:@selector(compare:)];
  [self.board sortUsingSelector:@selector(compare:)];
}

@end
