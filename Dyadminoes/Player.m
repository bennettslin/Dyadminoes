//
//  Player.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/10/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Player.h"

@implementation Player

-(id)initWithPlayerNumber:(NSUInteger)playerNumber
      andDyadminoesInRack:(NSMutableArray *)dyadminoesInRack {
  self = [super init];
  if (self) {
    self.playerNumber = playerNumber;
    self.dyadminoesInRack = dyadminoesInRack;
  }
  return self;
}

@end
