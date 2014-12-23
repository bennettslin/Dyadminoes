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

-(void)setColouredByNeighbouringCells:(NSInteger)colouredByNeighbouringCells {
  _colouredByNeighbouringCells = colouredByNeighbouringCells;
  self.cellNode.hidden = (colouredByNeighbouringCells <= 0) ? YES : NO;
}

-(id)initWithBoard:(Board *)board andTexture:(SKTexture *)texture andHexCoord:(HexCoord)hexCoord andHexOrigin:(CGVector)hexOrigin andSize:(CGSize)cellSize {
  self = [super init];
  if (self) {
    
    self.board = board;
    self.cellNodeTexture = texture;
    self.colouredByNeighbouringCells = 0;
    
    [self resetForNewMatch];
    [self reuseCellWithHexCoord:hexCoord andHexOrigin:hexOrigin andSize:cellSize];
  }
  return self;
}

-(void)reuseCellWithHexCoord:(HexCoord)hexCoord andHexOrigin:(CGVector)hexOrigin andSize:(CGSize)cellSize {
  
  self.colouredByNeighbouringCells = NO;
  self.currentlyColouringNeighbouringCells = NO;
  self.hexCoord = hexCoord;
  self.name = [NSString stringWithFormat:@"cell %li, %li", (long)self.hexCoord.x, (long)self.hexCoord.y];
  
    // establish cell position
  self.cellNodePosition = [Cell establishCellPositionWithCellSize:cellSize andHexOrigin:hexOrigin andHexCoord:self.hexCoord forResize:NO];
  
    // establish logic default
  self.myPC = -1;
  
    // create snap points
  [self createSnapPoints];
  
  self.cellNode ? [self initPositionCellNodeWithSize:cellSize] : [self instantiateCellNodeWithSize:cellSize];
}

-(void)resetForNewMatch {
  
  self.currentlyColouringNeighbouringCells = NO;
  self.colouredByNeighbouringCells = 0;
  self.myDyadmino = nil;
  self.myPC = -1;
  
    // reset colour
  _red = 0.2f;
  _green = 0.2f;
  _blue = 0.2f;
  _alpha = 0.f;
  
  if (self.cellNode) {
    self.cellNode.colorBlendFactor = 0.9f;
    self.cellNode.color = [SKColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self addColourWithRed:_red green:_green blue:_blue alpha:_alpha];
  }
}

#pragma mark - cell node methods

-(void)instantiateCellNodeWithSize:(CGSize)cellSize {
  
    // cellNode properties
    // comment out this block to not instantiate cellNode (about one second faster)
    ///*
  self.cellNode = [[SKSpriteNode alloc] init];
  self.cellNode.name = @"cellNode";
  self.cellNode.texture = self.cellNodeTexture;
  self.cellNode.zPosition = kZPositionBoardCell;
  [self addColourWithRed:_red green:_green blue:_blue alpha:_alpha];
  self.cellNode.colorBlendFactor = .9f;
  self.cellNode.size = cellSize;
  self.colouredByNeighbouringCells = NO;
  [self initPositionCellNodeWithSize:cellSize];
  
    //// for testing purposes
  if (self.cellNode) {
    [self createHexCoordLabel];
    [self updateHexCoordLabel];
    [self createPCLabel];
    [self updatePCLabel];
  }
    // */
}

-(void)initPositionCellNodeWithSize:(CGSize)cellSize {
  self.cellNode.position = self.cellNodePosition;
  self.cellNode.size = cellSize;
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
  self.cellNode.color = [SKColor colorWithRed:_red green:_green blue:_blue alpha:_alpha];
}

-(void)resizeCell:(BOOL)resize withHexOrigin:(CGVector)hexOrigin andSize:(CGSize)cellSize {
  
  self.cellNode.size = cellSize;

  if (resize) {
    self.cellNode.position = [Cell establishCellPositionWithCellSize:cellSize andHexOrigin:hexOrigin andHexCoord:self.hexCoord forResize:resize];
  } else {
    self.cellNode.position = self.cellNodePosition;
  }
  
  [self positionSnapPointsForResize:resize];
}

#pragma mark - cell size and position helper methods

+(CGSize)establishCellSizeForResize:(BOOL)resize {
  
  CGFloat factor = resize ? kZoomResizeFactor : 1.f;
  CGFloat ySize = (kDyadminoFaceRadius * 2 - kPaddingBetweenCells) * factor;
  CGFloat widthToHeightRatio = kTwoOverSquareRootOfThree;
  CGFloat xSize = widthToHeightRatio * ySize;
  return CGSizeMake(xSize, ySize);
}

+(CGPoint)establishCellPositionWithCellSize:(CGSize)cellSize andHexOrigin:(CGVector)hexOrigin andHexCoord:(HexCoord)hexCoord forResize:(BOOL)resize {
  
    // to make node between two faces the center
  CGFloat factor = resize ? kZoomResizeFactor : 1.f;
  CGFloat yOffset = kDyadminoFaceRadius * factor;
  CGFloat padding = kPaddingBetweenCells * factor;
  
  CGFloat cellWidth = cellSize.width;
  CGFloat cellHeight = cellSize.height;
  CGFloat newX = (hexCoord.x - hexOrigin.dx) * (0.75 * cellWidth + padding);
  CGFloat newY = (hexCoord.y - hexOrigin.dy + hexCoord.x * 0.5) * (cellHeight + padding) - yOffset;
  
  return CGPointMake(newX, newY);
}

+(CGPoint)positionCellAgnosticDyadminoGivenHexOrigin:(CGVector)hexOrigin andHexCoord:(HexCoord)hexCoord andOrientation:(DyadminoOrientation)orientation andResize:(BOOL)resize {
  
    // get hypothetical cellPosition
  CGSize cellSize = [Cell establishCellSizeForResize:resize];
  CGPoint cellPosition = [Cell establishCellPositionWithCellSize:cellSize andHexOrigin:hexOrigin andHexCoord:hexCoord forResize:resize];
  
    // next get hypothetical cell's snap point
  CGFloat faceOffset = resize ? kDyadminoFaceRadius * kZoomResizeFactor : kDyadminoFaceRadius;
  
    // based on a 30-60-90 degree triangle
  CGFloat faceOffsetX = faceOffset * 0.5 * kSquareRootOfThree;
  CGFloat faceOffsetY = faceOffset * 0.5;
  
  CGPoint celllessDyadminoPosition;
  
  switch (orientation) {
    case kPC1atTwelveOClock:
    case kPC1atSixOClock:
      celllessDyadminoPosition = [self addToThisPoint:cellPosition thisPoint:CGPointMake(0.f, faceOffset)];
      break;
    case kPC1atTwoOClock:
    case kPC1atEightOClock:
      celllessDyadminoPosition = [self addToThisPoint:cellPosition thisPoint:CGPointMake(faceOffsetX, faceOffsetY)];
      break;
    case kPC1atFourOClock:
    case kPC1atTenOClock:
      celllessDyadminoPosition = [self addToThisPoint:cellPosition thisPoint:CGPointMake(-faceOffsetX, faceOffsetY)];
      break;
    default:
      break;
  }
  return celllessDyadminoPosition;
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
  self.pcLabel.hidden = YES;
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
