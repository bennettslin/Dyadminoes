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
@dynamic name;
@dynamic order;
@dynamic score;
@dynamic rackIndexes;
@dynamic resigned;
@dynamic won;
@dynamic match;

-(void)initialUniqueID:(NSString *)uniqueID
         andName:(NSString *)name
        andOrder:(NSUInteger)order {

  self.uniqueID = uniqueID;
  self.name = name;
  self.order = [NSNumber numberWithUnsignedInteger:order];
  
    // game state
  self.rackIndexes = [[NSMutableArray alloc] initWithCapacity:kNumDyadminoesInRack];
  self.resigned = @NO;
  self.won = @NO;
}

-(BOOL)doesRackContainDataDyadmino:(DataDyadmino *)dataDyad {
  return [self.rackIndexes containsObject:@([dataDyad returnMyID])];
}

-(void)addToRackDataDyadmino:(DataDyadmino *)dataDyad {
  NSNumber *number = @([dataDyad returnMyID]);
  if (![self doesRackContainDataDyadmino:dataDyad]) {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.rackIndexes];
    [tempArray addObject:number];
    self.rackIndexes = [NSArray arrayWithArray:tempArray];
  }
}

-(void)insertIntoRackDataDyadmino:(DataDyadmino *)dataDyad withOrderNumber:(NSUInteger)orderNumber {
  NSNumber *number = @([dataDyad returnMyID]);
  if (![self doesRackContainDataDyadmino:dataDyad]) {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.rackIndexes];
    [tempArray insertObject:number atIndex:orderNumber];
    self.rackIndexes = [NSArray arrayWithArray:tempArray];
  }
}

-(void)removeFromRackDataDyadmino:(DataDyadmino *)dataDyad {
  if ([self doesRackContainDataDyadmino:dataDyad]) {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.rackIndexes];
    NSNumber *number = @([dataDyad returnMyID]);
    [tempArray removeObject:number];
    self.rackIndexes = [NSArray arrayWithArray:tempArray];
  }
}

-(void)removeAllRackIndexes {
  self.rackIndexes = [NSMutableArray new];
}

#pragma mark - return query properties

-(NSUInteger)returnOrder {
  return [self.order unsignedIntegerValue];
}

-(NSUInteger)returnScore {
  return [self.score unsignedIntegerValue];
}

-(BOOL)returnResigned {
  return [self.resigned boolValue];
}

-(BOOL)returnWon {
  return [self.won boolValue];
}

@end

@implementation RackIndexes

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