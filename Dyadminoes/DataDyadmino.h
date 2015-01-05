//
//  DataDyadmino.h
//  Dyadminoes
//
//  Created by Bennett Lin on 6/1/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSObject+Helper.h"
@class Match;

@interface DataDyadmino : NSManagedObject

@property (retain, nonatomic) NSNumber *myID;
@property (retain, nonatomic) NSNumber *myOrientation;

@property (retain, nonatomic) NSNumber *hexX;
@property (retain, nonatomic) NSNumber *hexY;

@property (retain, nonatomic) NSNumber *myRackOrder;

  // this persists pile and board for match
@property (retain, nonatomic) NSNumber *placeStatus;

  // for replay mode, remembers turns that involved change of state
@property (retain, nonatomic) id turnChanges;
@property (strong, nonatomic) Match *match;

  // not persisted, gets from hexX and hexY
@property (assign, nonatomic) HexCoord myHexCoord;

  // query number properties
-(NSUInteger)returnMyID;
-(DyadminoOrientation)returnMyOrientation;
-(NSInteger)returnMyRackOrder;
-(PlaceStatus)returnPlaceStatus;

-(void)initWithID:(NSUInteger)myID;
-(void)resetHexCoord;
-(void)randomRackOrientation;
-(HexCoord)getHexCoordForTurn:(NSUInteger)turn;
-(DyadminoOrientation)getOrientationForTurn:(NSUInteger)turn;

@end

@interface TurnChanges : NSValueTransformer

@end

@interface ChordsThisPlay : NSValueTransformer

@end