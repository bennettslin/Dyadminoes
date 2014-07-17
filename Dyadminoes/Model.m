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

@interface Model ()

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

+(void)saveMyModel:(Model *)myModel {
  [NSKeyedArchiver archiveRootObject:myModel toFile:[self getPathToArchive]];
}

+(Model *)getMyModel {
  return [NSKeyedUnarchiver unarchiveObjectWithFile:[self getPathToArchive]];
}

+(NSString *)getPathToArchive {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *directory = [paths objectAtIndex:0];
  NSString *pathString = [directory stringByAppendingPathComponent:@"model.plist"];
//  NSLog(@"the archive path is %@", pathString);
  return pathString;
}

-(Match *)instantiateSoloMatchWithName:(NSString *)playerName andRules:(GameRules)rules andSkill:(GameSkill)skill {
  
    // In solo game, unique ID, rules, and skill are not important for now
  Player *player1 = [[Player alloc] initWithUniqueID:@"" andPlayerName:playerName andPlayerPicture:nil];
  
  Match *newSoloMatch = [[Match alloc] initWithPlayers:@[player1] andRules:rules andSkill:skill andType:kSelfGame];
  [self.myMatches addObject:newSoloMatch];
  [Model saveMyModel:self];
  return newSoloMatch;
}

-(Match *)instantiateHardCodededPassNPlayMatchForDebugPurposes {

  Player *player1 = [[Player alloc] initWithUniqueID:@"12345" andPlayerName:@"Julia" andPlayerPicture:nil];
  Player *player2 = [[Player alloc] initWithUniqueID:@"23456" andPlayerName:@"Pamela" andPlayerPicture:nil];
  Match *newPnPMatch = [[Match alloc] initWithPlayers:@[player1, player2] andRules:kGameRulesTonal andSkill:kBeginner andType:kPnPGame];
  [self.myMatches addObject:newPnPMatch];
  [Model saveMyModel:self];
  return newPnPMatch;
}

-(void)instantiateHardCodedMatchesForDebugPurposes {
//  NSLog(@"hard coded matches");
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
    Match *match = [[Match alloc] initWithPlayers:players andRules:kGameRulesTonal andSkill:kBeginner andType:kPnPGame];
    
      // add match to data
    [self.myMatches addObject:match];
  }
  [Model saveMyModel:self];
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

#pragma mark - singleton method

+(Model *)model {
  static dispatch_once_t pred;
  static Model *shared = nil;
  dispatch_once(&pred, ^{
    shared = [[Model alloc] init];
  });
  return shared;
}

@end
