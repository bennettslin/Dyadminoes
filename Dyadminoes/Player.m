//
//  Player.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/10/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Player.h"
#import "DataDyadmino.h"
#import "NSObject+Helper.h"

@interface Player ()

@end

@implementation Player

@dynamic uniqueID;
@dynamic playerName;
@dynamic playerOrder;
@dynamic playerScore;
@dynamic dataDyadminoesThisTurn;
@dynamic resigned;
@dynamic won;

@dynamic match;

  // FIXME: is this right?
@dynamic delegate;

//-(id)initWithCoder:(NSCoder *)aDecoder {
//  self = [super init];
//  if (self) {
//    self.uniqueID = [aDecoder decodeObjectForKey:@"uniqueID"];
//    self.playerName = [aDecoder decodeObjectForKey:@"playerName"];
//    self.playerScore = [[aDecoder decodeObjectForKey:@"playerScore"] unsignedIntegerValue];
//    self.dataDyadminoesThisTurn = [aDecoder decodeObjectForKey:@"dataDyadsThisTurn"];
//    self.resigned = [aDecoder decodeBoolForKey:@"resigned"];
//  }
//  return self;
//}

//-(void)encodeWithCoder:(NSCoder *)aCoder {
//  [aCoder encodeObject:self.uniqueID forKey:@"uniqueID"];
//  [aCoder encodeObject:self.playerName forKey:@"playerName"];
//  [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.playerScore] forKey:@"playerScore"];
//  [aCoder encodeObject:self.dataDyadminoesThisTurn forKey:@"dataDyadsThisTurn"];
//  [aCoder encodeBool:self.resigned forKey:@"resigned"];
//}

-(void)initialUniqueID:(NSString *)uniqueID
         andPlayerName:(NSString *)playerName
      andPlayerPicture:(UIImage *)playerPicture  {
  
//  self = [super init];
//  
//  if (self) {
  self.uniqueID = uniqueID;
  self.playerName = playerName;
  
    // game state
  self.dataDyadminoesThisTurn = [[NSMutableArray alloc] initWithCapacity:kNumDyadminoesInRack];
  self.resigned = NO;
  self.won = NO;
//  }
//  
//  return self;
}

-(BOOL)thisTurnContainsDataDyadmino:(DataDyadmino *)dataDyad {
  return [self.dataDyadminoesThisTurn containsObject:[NSNumber numberWithUnsignedInteger:dataDyad.myID]];
}

-(void)addToThisTurnsDataDyadmino:(DataDyadmino *)dataDyad {
  NSNumber *number = [NSNumber numberWithUnsignedInteger:dataDyad.myID];
  if (![self thisTurnContainsDataDyadmino:dataDyad]) {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataDyadminoesThisTurn];
    [tempArray addObject:number];
    self.dataDyadminoesThisTurn = [NSArray arrayWithArray:tempArray];
  }
}

-(void)insertInThisTurnsDataDyadmino:(DataDyadmino *)dataDyad atIndex:(NSUInteger)index {
  NSNumber *number = [NSNumber numberWithUnsignedInteger:dataDyad.myID];
  if (![self thisTurnContainsDataDyadmino:dataDyad]) {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataDyadminoesThisTurn];
    [tempArray insertObject:number atIndex:index];
    self.dataDyadminoesThisTurn = [NSArray arrayWithArray:tempArray];
  }
}

-(void)removeFromThisTurnsDataDyadmino:(DataDyadmino *)dataDyad {
  NSNumber *number = [NSNumber numberWithUnsignedInteger:dataDyad.myID];
  if ([self thisTurnContainsDataDyadmino:dataDyad]) {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataDyadminoesThisTurn];
    [tempArray removeObject:number];
    self.dataDyadminoesThisTurn = [NSArray arrayWithArray:tempArray];
  }
}

-(void)removeAllDataDyadminoesThisTurn {
  self.dataDyadminoesThisTurn = nil;
  self.dataDyadminoesThisTurn = [NSMutableArray new];
}

-(NSArray *)dataDyadsForThisTurn {
  NSMutableArray *tempArray = [NSMutableArray new];
  for (NSNumber *number in self.dataDyadminoesThisTurn) {
    DataDyadmino *dataDyad = [self dataDyadminoForIndex:[number unsignedIntegerValue]];
    [tempArray addObject:dataDyad];
  }
  return [NSArray arrayWithArray:tempArray];
}

  // repeated in Match class
-(DataDyadmino *)dataDyadminoForIndex:(NSUInteger)index {
  for (DataDyadmino *dataDyadmino in self.dataDyadminoesThisTurn) {
    if (dataDyadmino.myID == index) {
      return dataDyadmino;
    }
  }
  return nil;
}

@end