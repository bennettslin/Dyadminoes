//
//  Match+Helper.m
//  Dyadminoes
//
//  Created by Bennett Lin on 12/5/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Match+Helper.h"

@implementation Match (Helper)

-(void)removeFromPileNumberOfDataDyadminoes:(NSUInteger)numberToRemove {
  for (int i = 0; i < numberToRemove; i++) {
    NSUInteger randomIndex = arc4random() % self.pile.count;
    [self.pile removeObjectAtIndex:randomIndex];
  }
}

@end
