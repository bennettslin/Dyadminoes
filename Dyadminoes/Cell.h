//
//  Cell.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/16/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+Helper.h"
@class Board;
@class Dyadmino;
@class SnapPoint;

@interface Cell : NSObject

@property (nonatomic) SKTexture *cellNodeTexture;
@property (nonatomic) CGPoint cellNodePosition;
@property (nonatomic) CGSize cellNodeSize;

@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) SnapPoint *boardSnapPointTwelveOClock;
@property (strong, nonatomic) SnapPoint *boardSnapPointTwoOClock;
@property (strong, nonatomic) SnapPoint *boardSnapPointTenOClock;

@property (strong, nonatomic) SKSpriteNode *cellNode;
@property (strong, nonatomic) Board *board;
@property (nonatomic) HexCoord hexCoord;
@property (strong, nonatomic) Dyadmino *myDyadmino;
@property (nonatomic) NSInteger myPC; // signed integer because myPC is -1 if no PC

@property (strong, nonatomic) SKLabelNode *hexCoordLabel;
@property (strong, nonatomic) SKLabelNode *pcLabel;

@property (nonatomic) BOOL currentlyColouringNeighbouringCells;

  // called for new cell
-(id)initWithBoard:(Board *)board
        andTexture:(SKTexture *)texture
       andHexCoord:(HexCoord)hexCoord
      andVectorOrigin:(CGVector)vectorOrigin;
-(void)instantiateCellNode;

  // called for dequeued cell
-(void)initCellWithHexCoord:(HexCoord)hexCoord andVectorOrigin:(CGVector)vectorOrigin;
-(void)initPositionCellNode;

-(void)addSnapPointsToBoard;
-(void)removeSnapPointsFromBoard;

-(void)resizeCell:(BOOL)resize withVectorOrigin:(CGVector)vectorOrigin;

#pragma mark - testing methods

-(void)updatePCLabel;

@end
