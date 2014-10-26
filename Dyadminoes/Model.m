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
  NSLog(@"model saved.");
  [NSKeyedArchiver archiveRootObject:myModel toFile:[self getPathToArchive]];
}

+(Model *)getMyModel {
  NSLog(@"model retrieved.");
  return [NSKeyedUnarchiver unarchiveObjectWithFile:[self getPathToArchive]];
}

+(NSString *)getPathToArchive {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *directory = [paths objectAtIndex:0];
  NSString *pathString = [directory stringByAppendingPathComponent:@"model.plist"];
//  NSLog(@"the archive path is %@", pathString);
  return pathString;
}

-(Match *)instantiateNewLocalMatchWithNames:(NSMutableArray *)playerNames andRules:(GameRules)rules andSkill:(GameSkill)skill {

  NSMutableArray *players = [NSMutableArray new];
  for (int i = 0; i < playerNames.count; i++) {
    Player *player = [[Player alloc] initWithUniqueID:@"" andPlayerName:playerNames[i] andPlayerPicture:nil];
    [players addObject:player];
  }
  
  GameType gameType = (playerNames.count == 1) ? kSelfGame : kPnPGame;
  Match *newMatch = [[Match alloc] initWithPlayers:players andRules:rules andSkill:skill andType:gameType];
  [self.myMatches insertObject:newMatch atIndex:0];
  [Model saveMyModel:self];
  return newMatch;
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
