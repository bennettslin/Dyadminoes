//
//  CellObject.m
//  Dyadminoes
//
//  Created by Bennett Lin on 6/14/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "CellObject.h"
#import "SnapPoint.h"
#import "Board.h"

@interface CellObject ()

@property (strong, nonatomic) SnapPoint *boardSnapPointTwelveOClock;
@property (strong, nonatomic) SnapPoint *boardSnapPointTwoOClock;
@property (strong, nonatomic) SnapPoint *boardSnapPointTenOClock;

@end

@implementation CellObject

-(id)initWithBoard:(Board *)board andTexture:(SKTexture *)texture andHexCoord:(HexCoord)hexCoord andVectorOrigin:(CGVector)vectorOrigin {
  self = [super init];
  if (self) {
    self.board = board;
//    self.texture = texture;
      //    [self addChild:[self createCellShape]];
    
    self.hexCoord = hexCoord;
    self.name = [NSString stringWithFormat:@"cell %li, %li", (long)self.hexCoord.x, (long)self.hexCoord.y];
//    self.zPosition = kZPositionBoardCell;
//    self.alpha = 0.3f;
    
      // establish cell size
    CGFloat paddingBetweenCells = kIsIPhone ? 0 : 0; // 5.f : 7.5f;
    
    CGFloat ySize = kDyadminoFaceRadius * 2 - paddingBetweenCells;
    CGFloat widthToHeightRatio = texture.size.width / texture.size.height;
    CGFloat xSize = widthToHeightRatio * ySize;
    self.size = CGSizeMake(xSize, ySize);
    
      // establish cell position
    CGFloat yOffset = kDyadminoFaceRadius; // to make node between two faces the center
    CGFloat cellWidth = self.size.width;
    CGFloat cellHeight = self.size.height;
    CGFloat newX = (self.hexCoord.x - vectorOrigin.dx) * (0.75 * cellWidth + paddingBetweenCells);
    CGFloat newY = (self.hexCoord.y - vectorOrigin.dy + self.hexCoord.x * 0.5) * (cellHeight + paddingBetweenCells) - yOffset;
    self.position = CGPointMake(newX, newY);
    
      // establish logic default
    self.myPC = -1;
    
      // create snap points
    [self createSnapPoints];
  }
  return self;
}

-(void)createSnapPoints {
  CGFloat faceOffset = kDyadminoFaceRadius;
  
    // based on a 30-60-90 degree triangle
  CGFloat faceOffsetX = faceOffset * 0.5 * kSquareRootOfThree;
  CGFloat faceOffsetY = faceOffset * 0.5;
  
  self.boardSnapPointTwelveOClock = [[SnapPoint alloc] initWithSnapPointType:kSnapPointBoardTwelveOClock];
  self.boardSnapPointTwoOClock = [[SnapPoint alloc] initWithSnapPointType:kSnapPointBoardTwoOClock];
  self.boardSnapPointTenOClock = [[SnapPoint alloc] initWithSnapPointType:kSnapPointBoardTenOClock];
  
  self.boardSnapPointTwelveOClock.position = [self addToThisPoint:self.position
                                                        thisPoint:CGPointMake(0.f, faceOffset)];
  self.boardSnapPointTwoOClock.position = [self addToThisPoint:self.position
                                                     thisPoint:CGPointMake(faceOffsetX, faceOffsetY)];
  self.boardSnapPointTenOClock.position = [self addToThisPoint:self.position
                                                     thisPoint:CGPointMake(-faceOffsetX, faceOffsetY)];
  
  self.boardSnapPointTwelveOClock.name = @"snap 12";
  self.boardSnapPointTwoOClock.name = @"snap 2";
  self.boardSnapPointTenOClock.name = @"snap 10";
//  self.boardSnapPointTwelveOClock.myCell = self;
//  self.boardSnapPointTwoOClock.myCell = self;
//  self.boardSnapPointTenOClock.myCell = self;
}

-(void)addSnapPointsToBoard {
  if (![self.board.snapPointsTwelveOClock containsObject:self.boardSnapPointTwelveOClock]) {
    [self.board.snapPointsTwelveOClock addObject:self.boardSnapPointTwelveOClock];
  }
  if (![self.board.snapPointsTwoOClock containsObject:self.boardSnapPointTwoOClock]) {
    [self.board.snapPointsTwoOClock addObject:self.boardSnapPointTwoOClock];
  }
  if (![self.board.snapPointsTenOClock containsObject:self.boardSnapPointTenOClock]) {
    [self.board.snapPointsTenOClock addObject:self.boardSnapPointTenOClock];
  }
}

-(void)removeSnapPointsFromBoard {
  if ([self.board.snapPointsTwelveOClock containsObject:self.boardSnapPointTwelveOClock]) {
    [self.board.snapPointsTwelveOClock removeObject:self.boardSnapPointTwelveOClock];
  }
  if ([self.board.snapPointsTwelveOClock containsObject:self.boardSnapPointTwelveOClock]) {
    [self.board.snapPointsTwoOClock removeObject:self.boardSnapPointTwoOClock];
  }
  if ([self.board.snapPointsTwelveOClock containsObject:self.boardSnapPointTwelveOClock]) {
    [self.board.snapPointsTenOClock removeObject:self.boardSnapPointTenOClock];
  }
}

@end
