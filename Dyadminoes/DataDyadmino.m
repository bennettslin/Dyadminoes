//
//  DataDyadmino.m
//  Dyadminoes
//
//  Created by Bennett Lin on 6/1/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "DataDyadmino.h"

@interface DataDyadmino ()

@end

@implementation DataDyadmino

  // persisted
@dynamic myID;
@dynamic myOrientation;
@dynamic hexX;
@dynamic hexY;
@dynamic myRackOrder;
@dynamic turnChanges;
@dynamic placeStatus;
@dynamic match;

  // not persisted
@synthesize myHexCoord = _myHexCoord;

#pragma mark - attribute methods

-(void)initWithID:(NSUInteger)myID {

  self.myID = @(myID);
  self.placeStatus = @(kInPile);
  self.hexX = @(INT32_MAX);
  self.hexY = @(INT32_MAX);
  
    // set rack orientation randomly
  int randNum = arc4random() % 2;
  self.myOrientation = (randNum == 0) ?
      @(kPC1atTwelveOClock) :
      @(kPC1atSixOClock);
}

-(NSUInteger)getTurnAdded {
  NSNumber *turnAdded = [[self.turnChanges firstObject] objectForKey:@"turn"];
  return turnAdded ? [turnAdded unsignedIntegerValue] : 0;
}

-(HexCoord)getHexCoordForTurn:(NSUInteger)turn {
  
    // return nothing if dyadmino was added after queried turn
  if (turn < [self getTurnAdded]) {
    return [self hexCoordFromX:NSIntegerMax andY:NSIntegerMax];
  }
  
  NSNumber *lastHexX;
  NSNumber *lastHexY;
  
    // start with most recent turn changes by iterating backwards
  NSArray *turnChanges = self.turnChanges;
  NSInteger hexCoordCounter = turnChanges.count - 1;
  while ((!lastHexX || !lastHexY) && hexCoordCounter >= 0) {
    NSDictionary *lastDictionary = (NSDictionary *)self.turnChanges[hexCoordCounter];
    
    NSUInteger lastTurn = [(NSNumber *)[lastDictionary objectForKey:@"turn"] unsignedIntegerValue];
    
      // ensure that last turn was before queried turn
    if (lastTurn <= turn) {
      lastHexX = (NSNumber *)[lastDictionary objectForKey:@"hexX"];
      lastHexY = (NSNumber *)[lastDictionary objectForKey:@"hexY"];
    }
    hexCoordCounter--;
  }
  
  if (!lastHexX || !lastHexY) {
    return [self hexCoordFromX:NSIntegerMax andY:NSIntegerMax]; // this should *never* get called
  } else {
    return [self hexCoordFromX:[lastHexX integerValue] andY:[lastHexY integerValue]];
  }
}

-(DyadminoOrientation)getOrientationForTurn:(NSUInteger)turn {
  NSNumber *lastOrientation;
  
    // return nothing if dyadmino was added after queried turn
    // this value doesn't actually matter, since dyadmino won't be seen
  if (turn < [self getTurnAdded]) {
    return INT32_MAX;
  }
  
    // start with most recent turn changes by iterating backwards
  NSArray *turnChanges = self.turnChanges;
  NSInteger orientationCounter = turnChanges.count - 1;
  while (!lastOrientation && orientationCounter >= 0) {
    NSDictionary *lastDictionary = (NSDictionary *)self.turnChanges[orientationCounter];
    
    NSUInteger lastTurn = [(NSNumber *)[lastDictionary objectForKey:@"turn"] unsignedIntegerValue];
    
      // ensure that last turn was before queried turn
    if (lastTurn <= turn) {
      lastOrientation = (NSNumber *)[lastDictionary objectForKey:@"orientation"];
    }
    orientationCounter--;
  }
  
  if (!lastOrientation) {
    return INT32_MAX; // this should *never* get called
  } else {
    return (DyadminoOrientation)[lastOrientation unsignedIntegerValue];
  }
}

#pragma mark - custom accessor methods

-(HexCoord)myHexCoord {
  return [self hexCoordFromX:[self.hexX integerValue] andY:[self.hexY integerValue]];
}

-(void)setMyHexCoord:(HexCoord)myHexCoord {
  _myHexCoord = myHexCoord;
  self.hexX = [NSNumber numberWithInteger:myHexCoord.x];
  self.hexY = [NSNumber numberWithInteger:myHexCoord.y];
}

#pragma mark - return query properties

-(NSUInteger)returnMyID {
  return [self.myID unsignedIntegerValue];
}

-(DyadminoOrientation)returnMyOrientation {
  return (DyadminoOrientation)[self.myOrientation unsignedIntegerValue];
}

-(NSInteger)returnMyRackOrder {
  return [self.myRackOrder integerValue];
}

-(PlaceStatus)returnPlaceStatus {
  return (PlaceStatus)[self.placeStatus unsignedIntegerValue];
}

@end

@implementation TurnChanges

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
