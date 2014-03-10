//
//  Pile.h
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Helper.h"
@class Dyadmino;

@interface Pile : NSObject

@property (strong, nonatomic) NSMutableSet *allDyadminoes;
@property (strong, nonatomic) NSMutableSet *dyadminoesInCommonPile;
@property (strong, nonatomic) NSMutableSet *dyadminoesOnBoard;
@property (strong, nonatomic) NSMutableArray *dyadminoesInPlayer1Rack;
@property (strong, nonatomic) NSMutableArray *dyadminoesInPlayer2Rack;

-(NSMutableArray *)populateOrCompletelySwapOutPlayer1Rack;
-(void)playFromPlayer1RackOntoBoard:(Dyadmino *)dyadmino;
-(BOOL)putDyadminoIntoPlayer1RackFromCommonPile;

@end