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

//@protocol PlayerDelegate;

@interface Player : NSManagedObject

  // permanent properties
@property (strong, nonatomic) NSString *uniqueID;
@property (strong, nonatomic) NSString *playerName;
@property (retain, nonatomic) NSNumber *playerOrder;

  // game state properties
@property (retain, nonatomic) NSNumber *playerScore;
@property (retain, nonatomic) id dataDyadminoIndexesThisTurn;
@property (retain, nonatomic) NSNumber *resigned;
@property (retain, nonatomic) NSNumber *won;

@property (strong, nonatomic) Match *match;

//@property (weak, nonatomic) id <PlayerDelegate> delegate;

-(void)initialUniqueID:(NSString *)uniqueID
         andPlayerName:(NSString *)playerName
        andPlayerOrder:(NSUInteger)playerOrder;

-(BOOL)thisTurnContainsDataDyadmino:(DataDyadmino *)dataDyad;
-(void)addToThisTurnsDataDyadmino:(DataDyadmino *)dataDyad;
-(void)insertInThisTurnsDataDyadmino:(DataDyadmino *)dataDyad atIndex:(NSUInteger)index;
-(void)removeFromThisTurnsDataDyadmino:(DataDyadmino *)dataDyad;
-(void)removeAllDataDyadminoesThisTurn;
//-(NSArray *)dataDyadsForThisTurn;

  // query number properties
-(NSUInteger)returnPlayerOrder;
-(NSUInteger)returnPlayerScore;
-(BOOL)returnResigned;
-(BOOL)returnWon;

@end

@interface DataDyadminoIndexesThisTurn : NSValueTransformer

@end

//@protocol PlayerDelegate <NSObject>
//
//@end