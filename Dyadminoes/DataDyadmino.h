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

@interface DataDyadmino : NSManagedObject

@property (assign, nonatomic) NSUInteger myID;
@property (assign, nonatomic) DyadminoOrientation myOrientation;

@property (assign, nonatomic) NSInteger hexX;
@property (assign, nonatomic) NSInteger hexY;
@property (assign, nonatomic) HexCoord myHexCoord; // not persisted

@property (assign, nonatomic) NSInteger myRackOrder;

  // only needed for debugging
@property (strong, nonatomic) NSString *name;

  // for replay mode, remembers turns that involved change of state
@property (strong, nonatomic) NSArray *turnChanges;

-(id)initWithID:(NSUInteger)myID;
-(HexCoord)getHexCoordForTurn:(NSUInteger)turn;
-(DyadminoOrientation)getOrientationForTurn:(NSUInteger)turn;

@end