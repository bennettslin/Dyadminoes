//
//  DataCell.m
//  Dyadminoes
//
//  Created by Bennett Lin on 12/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "DataCell.h"

@interface DataCell ()

@property (readwrite, nonatomic) NSUInteger myPC;
@property (readwrite, nonatomic) NSUInteger myDyadminoID;
@property (readwrite, nonatomic) NSInteger hexX;
@property (readwrite, nonatomic) NSInteger hexY;

@end

@implementation DataCell

-(instancetype)initWithPC:(NSUInteger)pc dyadminoID:(NSUInteger)dyadminoID hexCoord:(HexCoord)hexCoord {
  self = [super init];
  if (self) {
    self.myPC = pc;
    self.myDyadminoID = dyadminoID;
    self.hexX = hexCoord.x;
    self.hexY = hexCoord.y;
  }
  return self;
}

-(BOOL)isOccupiedByDyadminoID:(NSInteger)dyadminoIndex {
  return (self.myDyadminoID == dyadminoIndex);
}

-(HexCoord)hexCoord {
  return [self hexCoordFromX:self.hexX andY:self.hexY];
}

-(BOOL)isContainedRegardlessOfPCAndDyadminoInfoInSet:(NSSet *)set {
  for (id object in set) {
    if ([object isKindOfClass:[DataCell class]]) {
      DataCell *setCell = (DataCell *)object;
      if (setCell.hexX == self.hexX && setCell.hexY == self.hexY) {
        return YES;
      }
    }
  }
  return NO;
}

@end
