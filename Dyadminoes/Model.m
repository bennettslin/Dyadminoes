//
//  Model.m
//  Dyadminoes
//
//  Created by Bennett Lin on 5/19/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Model.h"
#import "Match.h"
#import "Player.h"
#import "NSObject+Helper.h"

@interface Model () <NSCoding>

@end

@implementation Model

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self) {
    self.myMatches = [aDecoder decodeObjectForKey:kMatchesKey];
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:self.myMatches forKey:kMatchesKey];
}

-(void)instantiateHardCodedMatchesForDebugPurposes {
  
    //hard coded values
  NSArray *names = @[@"Julia", @"Pamela", @"Darcy", @"Mary"];
  NSArray *ids = @[@"12345", @"23456", @"34567", @"45678"];

  self.myMatches = [[NSMutableArray alloc] initWithCapacity:5];
  for (int i = 0; i < 8; i++) {
    
    int randValue = (arc4random() % 3) + 2;
    
    NSMutableArray *mutablePlayers = [[NSMutableArray alloc] initWithCapacity:randValue];
    for (int j = 0; j < randValue; j++) {
        // hard-coded player properties
      NSString *playerID = ids[(i + j) % randValue];
      NSString *playerName = names[(i + j) % randValue];
      Player *player = [[Player alloc] initWithUniqueID:playerID andPlayerName:playerName andPlayerPicture:nil];
      [mutablePlayers addObject:player];
    }
    
      // add players to match
    NSArray *players = [NSArray arrayWithArray:mutablePlayers];
      // hard-coded match properties for now
    Match *match = [[Match alloc] initWithPlayers:players andRules:kGameRulesPostTonal andSkill:kBeginner andType:kPnPGame];
    
      // add match to data
    [self.myMatches addObject:match];
  }
}

-(void)sortMyMatches {
  NSMutableArray *endedGames = [[NSMutableArray alloc] init];
  NSMutableArray *openGames = [[NSMutableArray alloc] init];
  
  for (Match *match in self.myMatches) {
    if (match.gameHasEnded) {
      [endedGames addObject:match];
    } else {
      [openGames addObject:match];
    }
  }
  
  NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastPlayed" ascending:YES];
  [openGames sortUsingDescriptors:@[dateSortDescriptor]];
  [endedGames sortUsingDescriptors:@[dateSortDescriptor]];
  
  [openGames addObjectsFromArray:endedGames];
  self.myMatches = openGames;
}

@end
