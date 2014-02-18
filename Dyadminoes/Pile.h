//
//  Pile.h
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Pile : NSObject

@property (strong, nonatomic) NSMutableSet *allDyadminoes;
@property (strong, nonatomic) NSMutableSet *dyadminoesOnBoard;
@property (strong, nonatomic) NSMutableArray *dyadminoesInPlayer1Rack;
@property (strong, nonatomic) NSMutableArray *dyadminoesInPlayer2Rack;

-(void)populatePlayer1Rack;

@end
