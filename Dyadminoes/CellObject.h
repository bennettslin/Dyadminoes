//
//  CellObject.h
//  Dyadminoes
//
//  Created by Bennett Lin on 6/14/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Helper.h"
@class Board;
@class Dyadmino;

#import <SpriteKit/SpriteKit.h>

@interface CellObject : NSObject

@property (nonatomic) BOOL hidden;
@property (nonatomic) CGPoint position;
@property (nonatomic) CGSize size;
@property (strong, nonatomic) NSString *name;


@property (strong, nonatomic) Board *board;
@property (nonatomic) HexCoord hexCoord;
@property (strong, nonatomic) Dyadmino *myDyadmino;
@property (nonatomic) NSInteger myPC; // signed integer because myPC is -1 if no PC

-(id)initWithBoard:(Board *)board
        andTexture:(SKTexture *)texture
       andHexCoord:(HexCoord)hexCoord
   andVectorOrigin:(CGVector)vectorOrigin;

-(void)addSnapPointsToBoard;
-(void)removeSnapPointsFromBoard;

#pragma mark - testing methods

//-(void)updatePCLabel;

@end
