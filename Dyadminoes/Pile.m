//
//  Pile.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Pile.h"
#import "Dyadmino.h"

#define kNumDyadminoesInRack 6

@implementation Pile {

}

-(id)init {
  self = [super init];
  if (self) {
    self.allDyadminoes = [[NSMutableSet alloc] initWithCapacity:66];
    self.dyadminoesInPlayer1Rack = [[NSMutableArray alloc] initWithCapacity:kNumDyadminoesInRack];
    for (int i = 0; i < 12; i++) {
      for (int j = 0; j < 12; j++) {
        if (i != j && i < j) {
          NSUInteger orientation = [self randomValueUpTo:2];
          Dyadmino *dyadmino = [[Dyadmino alloc] initWithPC1:i andPC2:j andOrientation:orientation];
          [self.allDyadminoes addObject:dyadmino];
        }
      }
    }
    [self populatePlayer1Rack];
  }
  return self;
}

-(NSUInteger)randomValueUpTo:(NSUInteger)high {
  NSUInteger randInteger = ((int) arc4random() % high);
  return randInteger;
}

-(void)populatePlayer1Rack {
  for (int i = 0; i < kNumDyadminoesInRack; i++) {
    NSUInteger randIndex = [self randomValueUpTo:[self.allDyadminoes count]];
    NSArray *tempArray = [self.allDyadminoes allObjects];
    Dyadmino *tempDyadmino = tempArray[randIndex];
    
    [self.allDyadminoes removeObject:tempDyadmino];
    [self.dyadminoesInPlayer1Rack addObject:tempDyadmino];
  }
}

@end
