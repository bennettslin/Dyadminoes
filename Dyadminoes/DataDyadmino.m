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

#pragma mark - custom accessor methods

-(HexCoord)myHexCoord {
  return [self hexCoordFromX:[self.hexX integerValue] andY:[self.hexY integerValue]];
}

-(void)setMyHexCoord:(HexCoord)myHexCoord {
  _myHexCoord = myHexCoord;
}

//-(id)initWithCoder:(NSCoder *)aDecoder {
//  self = [super init];
//  if (self) {
//    self.myID = [[aDecoder decodeObjectForKey:@"myID"] unsignedIntegerValue];
//    self.myOrientation = [[aDecoder decodeObjectForKey:@"myOrientation"] unsignedIntValue];
//    self.turnChanges = [aDecoder decodeObjectForKey:@"turnChanges"];
//    NSInteger xCoord = [aDecoder decodeIntegerForKey:@"hexX"];
//    NSInteger yCoord = [aDecoder decodeIntegerForKey:@"hexY"];
//    self.myHexCoord = [self hexCoordFromX:xCoord andY:yCoord];
//    self.myRackOrder = [aDecoder decodeIntegerForKey:@"myRackOrder"];
//  }
//  return self;
//}

//-(void)encodeWithCoder:(NSCoder *)aCoder {
//  [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.myID] forKey:@"myID"];
//  [aCoder encodeObject:[NSNumber numberWithUnsignedInt:self.myOrientation] forKey:@"myOrientation"];
//  [aCoder encodeObject:self.turnChanges forKey:@"turnChanges"];
//  [aCoder encodeInteger:self.myHexCoord.x forKey:@"hexX"];
//  [aCoder encodeInteger:self.myHexCoord.y forKey:@"hexY"];
//  [aCoder encodeInteger:self.myRackOrder forKey:@"myRackOrder"];
//}

-(void)initialID:(NSUInteger)myID {
//  self = [super init];
//  if (self) {
    self.myID = [NSNumber numberWithUnsignedInteger:myID];
    self.placeStatus = [NSNumber numberWithUnsignedInteger:kInPile];
    
      // set rack orientation randomly
    int randNum = arc4random() % 2;
    self.myOrientation = (randNum == 0) ? [NSNumber numberWithUnsignedInteger:kPC1atTwelveOClock] : [NSNumber numberWithUnsignedInteger:kPC1atSixOClock];
//  }
//  return self;
}

-(NSUInteger)getTurnAdded {
  NSNumber *turnAdded = [[self.turnChanges firstObject] objectForKey:@"turn"];
  return turnAdded ? [turnAdded unsignedIntegerValue] : 0;
}

-(HexCoord)getHexCoordForTurn:(NSUInteger)turn {
  
    // return nothing if dyadmino was added after queried turn
  if (turn < [self getTurnAdded]) {
//    NSLog(@"data dyadmino %i was added turn %i, after queried turn %i", self.myID, [self getTurnAdded], turn);
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
//    NSLog(@"error: no last hexX or hexY for data dyadmino %i for turn %i for queried turn %i", self.myID, [self getTurnAdded], turn);
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
//    NSLog(@"data dyadmino %i was added turn %i, after queried turn %i", self.myID, [self getTurnAdded], turn);
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
//    NSLog(@"error: no last orientation for data dyadmino %i for turn %i for queried turn %i", self.myID, [self getTurnAdded], turn);
    return INT32_MAX; // this should *never* get called
  } else {
    return (DyadminoOrientation)[lastOrientation unsignedIntegerValue];
  }
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
