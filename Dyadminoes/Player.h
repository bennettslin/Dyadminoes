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

@interface Player : NSManagedObject

  // permanent properties
@property (strong, nonatomic) NSString *uniqueID;
@property (strong, nonatomic) NSString *name;
@property (retain, nonatomic) NSNumber *order;

  // match progression properties
@property (retain, nonatomic) NSNumber *score;
@property (retain, nonatomic) id rackIndexes;
@property (retain, nonatomic) NSNumber *resigned;
@property (retain, nonatomic) NSNumber *won;

@property (strong, nonatomic) Match *match;

-(void)initialUniqueID:(NSString *)uniqueID
         andName:(NSString *)name
        andOrder:(NSUInteger)order;

-(BOOL)doesRackContainDataDyadmino:(DataDyadmino *)dataDyad;
-(void)addToRackDataDyadmino:(DataDyadmino *)dataDyad;
-(void)insertIntoRackDataDyadmino:(DataDyadmino *)dataDyad
                  withOrderNumber:(NSUInteger)orderNumber;
-(void)removeFromRackDataDyadmino:(DataDyadmino *)dataDyad;
-(void)removeAllRackIndexes;

  // query number properties
-(NSUInteger)returnOrder;
-(NSUInteger)returnScore;
-(BOOL)returnResigned;
-(BOOL)returnWon;

@end

@interface RackIndexes : NSValueTransformer

@end