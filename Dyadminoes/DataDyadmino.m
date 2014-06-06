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
    
    NSInteger xCoord = [aDecoder decodeIntegerForKey:@"hexX"];
    NSInteger yCoord = [aDecoder decodeIntegerForKey:@"hexY"];
    struct HexCoord hexCoord = {xCoord, yCoord};
    self.myHexCoord = hexCoord;
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.myID] forKey:@"myID"];
  [aCoder encodeObject:[NSNumber numberWithUnsignedInt:self.myOrientation] forKey:@"myOrientation"];
  [aCoder encodeInteger:self.myHexCoord.x forKey:@"hexX"];
  [aCoder encodeInteger:self.myHexCoord.y forKey:@"hexY"];

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

@end
