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

  // not persisted
//@synthesize delegate;

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
        andPlayerOrder:(NSUInteger)playerOrder {
  
//  self = [super init];
//  
//  if (self) {
  self.uniqueID = uniqueID;
  self.playerName = playerName;
  self.playerOrder = [NSNumber numberWithUnsignedInteger:playerOrder];
  
    // game state
  self.dataDyadminoIndexesThisTurn = [[NSMutableArray alloc] initWithCapacity:kNumDyadminoesInRack];
  self.resigned = [NSNumber numberWithBool:NO];
  self.won = [NSNumber numberWithBool:NO];
//  }
//  
//  return self;
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
  NSNumber *number = [NSNumber numberWithUnsignedInteger:[dataDyad returnMyID]];
  if ([self thisTurnContainsDataDyadmino:dataDyad]) {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataDyadminoIndexesThisTurn];
    [tempArray removeObject:number];
    self.dataDyadminoIndexesThisTurn = [NSArray arrayWithArray:tempArray];
  }
}

-(void)removeAllDataDyadminoesThisTurn {
  self.dataDyadminoIndexesThisTurn = nil;
  self.dataDyadminoIndexesThisTurn = [NSMutableArray new];
}

//-(NSArray *)dataDyadsForThisTurn {
//  NSMutableArray *tempArray = [NSMutableArray new];
//  NSLog(@"data dyadmino indices this turn %@", self.dataDyadminoIndexesThisTurn);
//  for (NSNumber *number in self.dataDyadminoIndexesThisTurn) {
//    DataDyadmino *dataDyad = [self.match dataDyadminoForIndex:[number unsignedIntegerValue]];
//    [tempArray addObject:dataDyad];
//  }
//  return [NSArray arrayWithArray:tempArray];
//}

  // repeated in Match class
//-(DataDyadmino *)dataDyadminoForIndex:(NSUInteger)index {
//  for (NSNumber *number in self.dataDyadminoIndexesThisTurn) {
//    if ([number unsignedIntegerValue] == index) {
//      return [self.match dataDyadminoForIndex:index];
//    }
//  }
//  return nil;
//}

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