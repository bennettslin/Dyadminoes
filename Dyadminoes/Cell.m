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

#define kPaddingBetweenCells (kIsIPhone ? 0.f : 0.f)

@interface Cell ()

@end

@implementation Cell {
  CGFloat _red, _green, _blue, _alpha;
}

-(id)initWithBoard:(Board *)board andTexture:(SKTexture *)texture andHexCoord:(HexCoord)hexCoord andVectorOrigin:(CGVector)vectorOrigin {
  self = [super init];
  if (self) {
    
    self.board = board;
    self.cellNodeTexture = texture;

    [self resetForNewMatch];
    [self reuseCellWithHexCoord:hexCoord andVectorOrigin:vectorOrigin];
  }
  return self;
}

-(void)reuseCellWithHexCoord:(HexCoord)hexCoord andVectorOrigin:(CGVector)vectorOrigin {
  
  self.currentlyColouringNeighbouringCells = NO;
  self.hexCoord = hexCoord;
  self.name = [NSString stringWithFormat:@"cell %li, %li", (long)self.hexCoord.x, (long)self.hexCoord.y];
  
    // establish cell position
  self.cellNodePosition = [self establishCellPositionWithVectorOrigin:vectorOrigin forResize:NO];
  
    // establish logic default
  self.myPC = -1;
  
    // create snap points
  [self createSnapPoints];
  
  if (!self.cellNode) {
    [self instantiateCellNode];
  } else {
    [self initPositionCellNode];
  }
}

-(void)resetForNewMatch {
  
  self.currentlyColouringNeighbouringCells = NO;
  self.myDyadmino = nil;
  self.myPC = -1;
  
    // reset colour
  _red = 0.2f;
  _green = 0.2f;
  _blue = 0.2f;
  _alpha = 0.4f;
  
  if (self.cellNode) {
    self.cellNode.colorBlendFactor = 0.9f;
    self.cellNode.color = [SKColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self addColourWithRed:_red green:_green blue:_blue alpha:_alpha];
  }
      // establish cell size
    self.cellNodeSize = [self establishCellSizeForResize:NO];
}

#pragma mark - cell node methods

-(void)instantiateCellNode {
  
//  NSLog(@"cell node instantiated for %@", self.name);
    // cellNode properties
    // comment out this block to not instantiate cellNode (about one second faster)
    ///*
  self.cellNode = [[SKSpriteNode alloc] init];
  self.cellNode.name = @"cellNode";
  self.cellNode.texture = self.cellNodeTexture;
  self.cellNode.zPosition = kZPositionBoardCell;
  [self addColourWithRed:_red green:_green blue:_blue alpha:_alpha];
  self.cellNode.colorBlendFactor = .9f;
  self.cellNode.size = self.cellNodeSize;
  [self initPositionCellNode];
  
    //// for testing purposes
  if (self.cellNode) {
    [self createHexCoordLabel];
    [self updateHexCoordLabel];
    [self createPCLabel];
    [self updatePCLabel];
  }
    // */
}

-(void)initPositionCellNode {
  self.cellNode.position = self.cellNodePosition;
  self.cellNode.size = self.cellNodeSize;
  [self updateHexCoordLabel];
  [self updatePCLabel];
}

#pragma mark - snap points methods

-(void)createSnapPoints {
  self.boardSnapPointTwelveOClock = [[SnapPoint alloc] initWithSnapPointType:kSnapPointBoardTwelveOClock];
  self.boardSnapPointTwoOClock = [[SnapPoint alloc] initWithSnapPointType:kSnapPointBoardTwoOClock];
  self.boardSnapPointTenOClock = [[SnapPoint alloc] initWithSnapPointType:kSnapPointBoardTenOClock];
  
  [self positionSnapPointsForResize:NO];
  
  self.boardSnapPointTwelveOClock.name = @"snap 12";
  self.boardSnapPointTwoOClock.name = @"snap 2";
  self.boardSnapPointTenOClock.name = @"snap 10";
  self.boardSnapPointTwelveOClock.myCell = self;
  self.boardSnapPointTwoOClock.myCell = self;
  self.boardSnapPointTenOClock.myCell = self;
}

-(void)positionSnapPointsForResize:(BOOL)resize {
  CGFloat faceOffset = resize ? kDyadminoFaceRadius * kZoomResizeFactor : kDyadminoFaceRadius;
  
    // based on a 30-60-90 degree triangle
  CGFloat faceOffsetX = faceOffset * 0.5 * kSquareRootOfThree;
  CGFloat faceOffsetY = faceOffset * 0.5;
  
  CGPoint position = self.cellNode ? self.cellNode.position : self.cellNodePosition;
  self.boardSnapPointTwelveOClock.position = [self addToThisPoint:position
                                                        thisPoint:CGPointMake(0.f, faceOffset)];
  self.boardSnapPointTwoOClock.position = [self addToThisPoint:position
                                                     thisPoint:CGPointMake(faceOffsetX, faceOffsetY)];
  self.boardSnapPointTenOClock.position = [self addToThisPoint:position
                                                     thisPoint:CGPointMake(-faceOffsetX, faceOffsetY)];
}

-(void)addSnapPointsToBoard {
  [self positionSnapPointsForResize:NO];
  
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
  if ([self.board.snapPointsTwoOClock containsObject:self.boardSnapPointTwoOClock]) {
    [self.board.snapPointsTwoOClock removeObject:self.boardSnapPointTwoOClock];
  }
  if ([self.board.snapPointsTenOClock containsObject:self.boardSnapPointTenOClock]) {
    [self.board.snapPointsTenOClock removeObject:self.boardSnapPointTenOClock];
  }
}

#pragma mark - cell view helper methods

-(void)addColourWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
  _red += red;
  _green += green;
  _blue += blue;
  _alpha += alpha;
    //  NSLog(@"%.2f, %.2f, %.2f, %.2f", _red, _green, _blue, _alpha);
  self.cellNode.color = [SKColor colorWithRed:_red green:_green blue:_blue alpha:1.f];
  self.cellNode.alpha = _alpha;
}

-(void)resizeCell:(BOOL)resize withVectorOrigin:(CGVector)vectorOrigin {
  if (resize) {
    self.cellNode.size = [self establishCellSizeForResize:YES];
    self.cellNode.position = [self establishCellPositionWithVectorOrigin:vectorOrigin forResize:YES];
    [self positionSnapPointsForResize:YES];
  } else {
    self.cellNode.size = self.cellNodeSize;
    self.cellNode.position = self.cellNodePosition;
    [self positionSnapPointsForResize:NO];
  }
}

#pragma mark - cell size and position helper methods

-(CGSize)establishCellSizeForResize:(BOOL)resize {
  
  CGFloat factor = resize ? kZoomResizeFactor : 1.f;
  CGFloat ySize = (kDyadminoFaceRadius * 2 - kPaddingBetweenCells) * factor;
  CGFloat widthToHeightRatio = kTwoOverSquareRootOfThree;
  CGFloat xSize = widthToHeightRatio * ySize;
  return CGSizeMake(xSize, ySize);
}

-(CGPoint)establishCellPositionWithVectorOrigin:(CGVector)vectorOrigin forResize:(BOOL)resize {
  
    // to make node between two faces the center
  CGFloat factor = resize ? kZoomResizeFactor : 1.f;
  CGFloat yOffset = kDyadminoFaceRadius * factor;
  CGFloat padding = kPaddingBetweenCells * factor;
  CGFloat cellWidth = self.cellNodeSize.width * factor;
  CGFloat cellHeight = self.cellNodeSize.height * factor;
  CGFloat newX = (self.hexCoord.x - vectorOrigin.dx) * (0.75 * cellWidth + padding);
  CGFloat newY = (self.hexCoord.y - vectorOrigin.dy + self.hexCoord.x * 0.5) * (cellHeight + padding) - yOffset;
  
  return CGPointMake(newX, newY);
}

#pragma mark - testing methods

-(void)createHexCoordLabel {
  self.hexCoordLabel = [[SKLabelNode alloc] init];

  self.hexCoordLabel.fontSize = 12.f;
  self.hexCoordLabel.alpha = 1.f;
  self.hexCoordLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
  self.hexCoordLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
  self.hexCoordLabel.position = CGPointMake(0, 5.f);
  self.hexCoordLabel.hidden = YES;
  [self.cellNode addChild:self.hexCoordLabel];
}

-(void)updateHexCoordLabel {
  NSString *boardXYString = [NSString stringWithFormat:@"%li, %li", (long)self.hexCoord.x, (long)self.hexCoord.y];
  self.hexCoordLabel.name = boardXYString;
  self.hexCoordLabel.text = boardXYString;
  
    // determine font colour
  self.hexCoordLabel.fontColor = [SKColor whiteColor];
  if (self.hexCoord.x == 0 || self.hexCoord.y == 0 || self.hexCoord.x + self.hexCoord.y == 0)
    self.hexCoordLabel.fontColor = [SKColor yellowColor];
  if (self.hexCoord.x == 0 && (self.hexCoord.y == 0 || self.hexCoord.y == 1))
    self.hexCoordLabel.fontColor = [SKColor greenColor];
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
