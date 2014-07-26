//
//  DataDyadmino.m
//  Dyadminoes
//
//  Created by Bennett Lin on 6/1/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "DataDyadmino.h"

@implementation DataDyadmino

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self) {
    self.myID = [[aDecoder decodeObjectForKey:@"myID"] unsignedIntegerValue];
    self.myOrientation = [[aDecoder decodeObjectForKey:@"myOrientation"] unsignedIntValue];
    self.turnChanges = [aDecoder decodeObjectForKey:@"turnChanges"];
    NSInteger xCoord = [aDecoder decodeIntegerForKey:@"hexX"];
    NSInteger yCoord = [aDecoder decodeIntegerForKey:@"hexY"];
    self.myHexCoord = [self hexCoordFromX:xCoord andY:yCoord];
    self.myRackOrder = [aDecoder decodeIntegerForKey:@"myRackOrder"];
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.myID] forKey:@"myID"];
  [aCoder encodeObject:[NSNumber numberWithUnsignedInt:self.myOrientation] forKey:@"myOrientation"];
  [aCoder encodeObject:self.turnChanges forKey:@"turnChanges"];
  [aCoder encodeInteger:self.myHexCoord.x forKey:@"hexX"];
  [aCoder encodeInteger:self.myHexCoord.y forKey:@"hexY"];
  [aCoder encodeInteger:self.myRackOrder forKey:@"myRackOrder"];
}

-(id)initWithID:(NSUInteger)id {
  self = [super init];
  if (self) {
    self.myID = id;
    
      // set rack orientation
    int randNum = arc4random() % 2;
    self.myOrientation = (randNum == 0) ? kPC1atTwelveOClock : kPC1atSixOClock;
  }
  return self;
}

-(HexCoord)getHexCoordForTurn:(NSUInteger)turn {
  
  NSNumber *lastHexX;
  NSNumber *lastHexY;
  
    // start with most recent turn changes by iterating backwards
  int hexCoordCounter = self.turnChanges.count - 1;
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
    NSLog(@"error: no last hexX or hexY for data dyadmino %i", self.myID);
    return [self hexCoordFromX:2147483647 andY:2147483647];
  } else {
    return [self hexCoordFromX:[lastHexX integerValue] andY:[lastHexY integerValue]];
  }
}

-(DyadminoOrientation)getOrientationForTurn:(NSUInteger)turn {
  NSNumber *lastOrientation;
  
    // start with most recent turn changes by iterating backwards
  int orientationCounter = self.turnChanges.count - 1;
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
    NSLog(@"error: no last orientation for data dyadmino %i", self.myID);
    return 2147483647;
  } else {
    return (DyadminoOrientation)[lastOrientation unsignedIntegerValue];
  }
}

@end
