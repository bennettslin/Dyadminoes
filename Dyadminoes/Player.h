//
//  Player.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/10/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject

@property (nonatomic) NSUInteger playerNumber;
@property (strong, nonatomic) NSMutableArray *dyadminoesInRack;

-(id)initWithPlayerNumber:(NSUInteger)playerNumber
      andDyadminoesInRack:(NSMutableArray *)dyadminoesInRack;

@end
