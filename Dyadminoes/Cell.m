//
//  Cell.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/16/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Cell.h"
#import "SnapPoint.h"
#import "Board.h"

@interface Cell ()

@property (strong, nonatomic) SnapPoint *boardSnapPointTwelveOClock;
@property (strong, nonatomic) SnapPoint *boardSnapPointTwoOClock;
@property (strong, nonatomic) SnapPoint *boardSnapPointTenOClock;

@end

@implementation Cell

-(id)initWithBoard:(Board *)board andTexture:(SKTexture *)texture andHexCoord:(HexCoord)hexCoord andVectorOrigin:(CGVector)vectorOrigin {
  self = [super init];
  if (self) {
    
    self.board = board;
    self.hexCoord = hexCoord;
    self.name = [NSString stringWithFormat:@"cell %li, %li", (long)self.hexCoord.x, (long)self.hexCoord.y];
    
      // establish cell size
    CGFloat paddingBetweenCells = kIsIPhone ? 1.5f : 3.f; // 5.f : 7.5f;
    
    CGFloat ySize = kDyadminoFaceRadius * 2 - paddingBetweenCells;
    CGFloat widthToHeightRatio = kTwoOverSquareRootOfThree;
    CGFloat xSize = widthToHeightRatio * ySize;

    self.cellNodeSize = CGSizeMake(xSize, ySize);
    
      // establish cell position
    CGFloat yOffset = kDyadminoFaceRadius; // to make node between two faces the center
    CGFloat cellWidth = self.cellNodeSize.width;
    CGFloat cellHeight = self.cellNodeSize.height;
    CGFloat newX = (self.hexCoord.x - vectorOrigin.dx) * (0.75 * cellWidth + paddingBetweenCells);
    CGFloat newY = (self.hexCoord.y - vectorOrigin.dy + self.hexCoord.x * 0.5) * (cellHeight + paddingBetweenCells) - yOffset;
    
    self.cellNodePosition = CGPointMake(newX, newY);
    
      // cellNode properties
      // comment out this block to not instantiate cellNode (about one second faster)
///*
    self.cellNode = [[SKSpriteNode alloc] init];
    self.cellNode.texture = texture;
    self.cellNode.zPosition = kZPositionBoardCell;
    self.cellNode.alpha = 0.8f; // was 0.8 before board patterning attempt
    self.cellNode.size = CGSizeMake(xSize, ySize);
    self.cellNode.position = CGPointMake(newX, newY);
// */
    
      // establish logic default
    self.myPC = -1;

      // create snap points
    [self createSnapPoints];

      //// for testing purposes
    
    if (self.cellNode) {
      [self createHexCoordLabel];
      [self createPCLabel];
      [self updatePCLabel];
    }
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
  
  self.boardSnapPointTwelveOClock.position = [self addToThisPoint:self.cellNodePosition
                                                        thisPoint:CGPointMake(0.f, faceOffset)];
  self.boardSnapPointTwoOClock.position = [self addToThisPoint:self.cellNodePosition
                                                     thisPoint:CGPointMake(faceOffsetX, faceOffsetY)];
  self.boardSnapPointTenOClock.position = [self addToThisPoint:self.cellNodePosition
                                                     thisPoint:CGPointMake(-faceOffsetX, faceOffsetY)];
  
  self.boardSnapPointTwelveOClock.name = @"snap 12";
  self.boardSnapPointTwoOClock.name = @"snap 2";
  self.boardSnapPointTenOClock.name = @"snap 10";
  self.boardSnapPointTwelveOClock.myCell = self;
  self.boardSnapPointTwoOClock.myCell = self;
  self.boardSnapPointTenOClock.myCell = self;
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

#pragma mark - testing methods

-(void)createHexCoordLabel {
  NSString *boardXYString = [NSString stringWithFormat:@"%li, %li", (long)self.hexCoord.x, (long)self.hexCoord.y];
  self.hexCoordLabel = [[SKLabelNode alloc] init];
  self.hexCoordLabel.name = boardXYString;
  self.hexCoordLabel.text = boardXYString;
  self.hexCoordLabel.fontColor = [SKColor whiteColor];
  
  if (self.hexCoord.x == 0 || self.hexCoord.y == 0 || self.hexCoord.x + self.hexCoord.y == 0)
    self.hexCoordLabel.fontColor = [SKColor yellowColor];
  
  if (self.hexCoord.x == 0 && (self.hexCoord.y == 0 || self.hexCoord.y == 1))
    self.hexCoordLabel.fontColor = [SKColor greenColor];
  
  self.hexCoordLabel.fontSize = 12.f;
  self.hexCoordLabel.alpha = 0.7f;
  self.hexCoordLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
  self.hexCoordLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
  self.hexCoordLabel.position = CGPointMake(0, 5.f);
  self.hexCoordLabel.hidden = YES;
  [self.cellNode addChild:self.hexCoordLabel];
}

-(void)createPCLabel {
  self.pcLabel = [[SKLabelNode alloc] init];
  self.pcLabel.fontColor = kTestRed;
  self.pcLabel.fontSize = 14.f;
  self.pcLabel.alpha = 1.f;
  self.pcLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
  self.pcLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
  self.pcLabel.position = CGPointMake(0, -9.f);
  [self.cellNode addChild:self.pcLabel];
}

-(void)updatePCLabel {
  NSString *pcString;
  if (self.myPC == -1) {
    pcString = @"";
  } else {
    pcString = [NSString stringWithFormat:@"%li", (long)self.myPC];
  }
  self.pcLabel.name = pcString;
  self.pcLabel.text = pcString;
}

@end
