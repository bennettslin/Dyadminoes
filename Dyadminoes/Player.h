//
//  Player.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/10/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class DataDyadmino;
@class Match;

@protocol PlayerDelegate;

@interface Player : NSManagedObject

  // permanent properties
@property (strong, nonatomic) NSString *uniqueID;
@property (strong, nonatomic) NSString *playerName;
@property (assign, nonatomic) NSUInteger playerOrder;

  // game state properties
@property (nonatomic) NSUInteger playerScore;
@property (strong, nonatomic) NSArray *dataDyadminoesThisTurn;
@property (nonatomic) BOOL resigned;
@property (assign, nonatomic) BOOL won;

@property (strong, nonatomic) Match *match;

@property (weak, nonatomic) id <PlayerDelegate> delegate;

-(void)initialUniqueID:(NSString *)uniqueID
       andPlayerName:(NSString *)playerName
    andPlayerPicture:(UIImage *)playerPicture;

-(BOOL)thisTurnContainsDataDyadmino:(DataDyadmino *)dataDyad;
-(void)addToThisTurnsDataDyadmino:(DataDyadmino *)dataDyad;
-(void)insertInThisTurnsDataDyadmino:(DataDyadmino *)dataDyad atIndex:(NSUInteger)index;
-(void)removeFromThisTurnsDataDyadmino:(DataDyadmino *)dataDyad;
-(void)removeAllDataDyadminoesThisTurn;
-(NSArray *)dataDyadsForThisTurn;

@end

@protocol PlayerDelegate <NSObject>

@end