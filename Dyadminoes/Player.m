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

  // persisted
@dynamic uniqueID;
@dynamic playerName;
@dynamic playerOrder;
@dynamic playerScore;
@dynamic dataDyadminoIndexesThisTurn;
@dynamic resigned;
@dynamic won;
@dynamic match;

-(void)initialUniqueID:(NSString *)uniqueID
         andPlayerName:(NSString *)playerName
        andPlayerOrder:(NSUInteger)playerOrder {

  self.uniqueID = uniqueID;
  self.playerName = playerName;
  self.playerOrder = [NSNumber numberWithUnsignedInteger:playerOrder];
  
    // game state
  self.dataDyadminoIndexesThisTurn = [[NSMutableArray alloc] initWithCapacity:kNumDyadminoesInRack];
  self.resigned = [NSNumber numberWithBool:NO];
  self.won = [NSNumber numberWithBool:NO];
}

-(BOOL)thisTurnContainsDataDyadmino:(DataDyadmino *)dataDyad {
  return [self.dataDyadminoIndexesThisTurn containsObject:[NSNumber numberWithUnsignedInteger:[dataDyad returnMyID]]];
}

-(void)addToThisTurnsDataDyadmino:(DataDyadmino *)dataDyad {
  NSNumber *number = [NSNumber numberWithUnsignedInteger:[dataDyad returnMyID]];
  if (![self thisTurnContainsDataDyadmino:dataDyad]) {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataDyadminoIndexesThisTurn];
    [tempArray addObject:number];
    self.dataDyadminoIndexesThisTurn = [NSArray arrayWithArray:tempArray];
  }
}

-(void)insertInThisTurnsDataDyadmino:(DataDyadmino *)dataDyad atIndex:(NSUInteger)index {
  NSNumber *number = [NSNumber numberWithUnsignedInteger:[dataDyad returnMyID]];
  if (![self thisTurnContainsDataDyadmino:dataDyad]) {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataDyadminoIndexesThisTurn];
    [tempArray insertObject:number atIndex:index];
    self.dataDyadminoIndexesThisTurn = [NSArray arrayWithArray:tempArray];
  }
}

-(void)removeFromThisTurnsDataDyadmino:(DataDyadmino *)dataDyad {
  if ([self thisTurnContainsDataDyadmino:dataDyad]) {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataDyadminoIndexesThisTurn];
    NSNumber *number = [NSNumber numberWithUnsignedInteger:[dataDyad returnMyID]];
    [tempArray removeObject:number];
    self.dataDyadminoIndexesThisTurn = [NSArray arrayWithArray:tempArray];
  }
}

-(void)removeAllDataDyadminoesThisTurn {
  self.dataDyadminoIndexesThisTurn = nil;
  self.dataDyadminoIndexesThisTurn = [NSMutableArray new];
}

#pragma mark - return query properties

-(NSUInteger)returnPlayerOrder {
  return [self.playerOrder unsignedIntegerValue];
}

-(NSUInteger)returnPlayerScore {
  return [self.playerScore unsignedIntegerValue];
}

-(BOOL)returnResigned {
  return [self.resigned boolValue];
}

-(BOOL)returnWon {
  return [self.won boolValue];
}

@end

@implementation DataDyadminoIndexesThisTurn

+(Class)transformedValueClass {
  return [NSArray class];
}

+(BOOL)allowsReverseTransformation {
  return YES;
}

-(id)transformedValue:(id)value {
  return [NSKeyedArchiver archivedDataWithRootObject:value];
}

-(id)reverseTransformedValue:(id)value {
  return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end