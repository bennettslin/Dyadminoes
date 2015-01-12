//
//  Match+Helper.m
//  Dyadminoes
//
//  Created by Bennett Lin on 12/5/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Match+Helper.h"
#import "Player.h"
#import "DataDyadmino.h"

@implementation Match (Helper)

-(void)removeFromPileNumberOfDataDyadminoes:(NSUInteger)numberToRemove {
  for (int i = 0; i < numberToRemove; i++) {
    NSUInteger randomIndex = arc4random() % self.pile.count;
    [self.pile removeObjectAtIndex:randomIndex];
  }
}

//-(void)recordDyadminoesWithMockScoreFromCurrentPlayerWithSwap:(BOOL)swap {
//  
//    // adds a mock score if there is a dyadmino in the holding container
//    // because recordDyadminoes method uses this score to determine if turn was pass or play
//  
//  if ([self.holdingIndexContainer count] != 0) {
//    NSMutableArray *tempArray = [NSMutableArray new];
//    NSDictionary *newDictionary = @{@"points":@1};
//    [tempArray addObject:newDictionary];
//  }
//  
//  [self recordDyadminoesFromCurrentPlayerWithSwap:swap];
//
//}

@end
