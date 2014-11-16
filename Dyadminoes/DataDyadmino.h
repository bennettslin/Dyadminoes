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

@property (assign, nonatomic) NSUInteger myID;
@property (assign, nonatomic) DyadminoOrientation myOrientation;

@property (assign, nonatomic) NSInteger hexX;
@property (assign, nonatomic) NSInteger hexY;
@property (assign, nonatomic) HexCoord myHexCoord; // not persisted

@property (assign, nonatomic) NSInteger myRackOrder;

@property (assign, nonatomic) PlaceStatus placeStatus;

  // for replay mode, remembers turns that involved change of state
@property (strong, nonatomic) NSArray *turnChanges;

@property (strong, nonatomic) Match *match;

  // only needed for debugging
//@property (strong, nonatomic) NSString *name;



-(void)initialID:(NSUInteger)myID;
-(HexCoord)getHexCoordForTurn:(NSUInteger)turn;
-(DyadminoOrientation)getOrientationForTurn:(NSUInteger)turn;

@end