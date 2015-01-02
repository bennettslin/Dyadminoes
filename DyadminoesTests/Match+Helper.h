//
//  Match+Helper.h
//  Dyadminoes
//
//  Created by Bennett Lin on 12/5/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Match.h"

@interface Match (Helper)

-(void)removeFromPileNumberOfDataDyadminoes:(NSUInteger)numberToRemove;
-(void)recordDyadminoesWithMockScoreFromCurrentPlayerWithSwap:(BOOL)swap;

@end
