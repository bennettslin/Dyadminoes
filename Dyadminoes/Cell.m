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
    self.texture = texture;
//    [self addChild:[self createCellShape]];
    
    self.hexCoord = hexCoord;
    self.name = [NSString stringWithFormat:@"cell %li, %li", (long)self.hexCoord.x, (long)self.hexCoord.y];
    self.zPosition = kZPositionBoardCell;
    self.alpha = 0.3f;
    
      // establish cell size
    CGFloat paddingBetweenCells = kIsIPhone ? 0 : 0; // 5.f : 7.5f;
    
    CGFloat ySize = kDyadminoFaceRadius * 2 - paddingBetweenCells;
    CGFloat widthToHeightRatio = self.texture.size.width / self.texture.size.height;
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

      //// for testing purposes
    [self createHexCoordLabel];
    [self createPCLabel];
    [self updatePCLabel];
    
//      // test doesn't seem to work!
//    CGFloat randomTime1 = [self randomFloatUpTo:0.6f];
//    CGFloat randomTime2 = [self randomFloatUpTo:0.6f];
//    SKAction *orangeColour = [SKAction runBlock:^{
//      self.color = [SKColor orangeColor];
//    }];
////    SKAction *wait1 = [SKAction waitForDuration:randomTime1];
//    SKAction *blueColour = [SKAction runBlock:^{
//      self.color = [SKColor blueColor];
//      NSLog(@"blue");
//    }];
////    SKAction *wait2 = [SKAction waitForDuration:randomTime2];
//    SKAction *repeatAction = [SKAction repeatActionForever:[SKAction sequence:@[orangeColour, blueColour]]];
//    [self runAction:repeatAction];
  }
  return self;
}

/*
-(SKNode *)createCellShape {
    // this is too expensive in terms of number of nodes, unfortunately
  
  SKNode *cellShape = [SKNode new];
  
  SKShapeNode *shapeNodeFill = [SKShapeNode new];
  CGMutablePathRef shapePathFill = CGPathCreateMutable();
  
  SKShapeNode *shapeNodeTop = [SKShapeNode new];
  CGMutablePathRef shapePathTop = CGPathCreateMutable();
  SKShapeNode *shapeNodeTopCorner = [SKShapeNode new];
  CGMutablePathRef shapePathTopCorner = CGPathCreateMutable();
  SKShapeNode *shapeNodeTopSide = [SKShapeNode new];
  CGMutablePathRef shapePathTopSide = CGPathCreateMutable();
  SKShapeNode *shapeNodeSideCorner = [SKShapeNode new];
  CGMutablePathRef shapePathSideCorner = CGPathCreateMutable();
  SKShapeNode *shapeNodeBottomSide = [SKShapeNode new];
  CGMutablePathRef shapePathBottomSide = CGPathCreateMutable();
  SKShapeNode *shapeNodeBottomCorner = [SKShapeNode new];
  CGMutablePathRef shapePathBottomCorner = CGPathCreateMutable();
  SKShapeNode *shapeNodeBottom = [SKShapeNode new];
  CGMutablePathRef shapePathBottom = CGPathCreateMutable();
  
  CGFloat cellSize = 0.85f;
  CGFloat cornerRadius = kDyadminoFaceWideRadius * cellSize;
  CGFloat edgeRadius = kDyadminoFaceRadius * cellSize;
  
  CGFloat roundedDegree = 5.f;

  CGPoint point1 = CGPointMake(cornerRadius / 2, edgeRadius);
  CGPoint point2 = CGPointMake(cornerRadius, 0);
  CGPoint point3 = CGPointMake(cornerRadius / 2, -edgeRadius);
  CGPoint point4 = CGPointMake(-cornerRadius / 2, -edgeRadius);
  CGPoint point5 = CGPointMake(-cornerRadius, 0);
  CGPoint point6 = CGPointMake(-cornerRadius / 2, edgeRadius);

  CGFloat cornerEnd = 0.15f;
  CGFloat otherCornerEnd = 1.f - cornerEnd;
  
  CGPoint left1 = {cornerEnd * point6.x + otherCornerEnd * point1.x, cornerEnd * point6.y + otherCornerEnd * point1.y};
  CGPoint left2 = {cornerEnd * point1.x + otherCornerEnd * point2.x, cornerEnd * point1.y + otherCornerEnd * point2.y};
  CGPoint left3 = {cornerEnd * point2.x + otherCornerEnd * point3.x, cornerEnd * point2.y + otherCornerEnd * point3.y};
  CGPoint left4 = {cornerEnd * point3.x + otherCornerEnd * point4.x, cornerEnd * point3.y + otherCornerEnd * point4.y};
  CGPoint left5 = {cornerEnd * point4.x + otherCornerEnd * point5.x, cornerEnd * point4.y + otherCornerEnd * point5.y};
  CGPoint left6 = {cornerEnd * point5.x + otherCornerEnd * point6.x, cornerEnd * point5.y + otherCornerEnd * point6.y};
  
  CGPoint right1 = {otherCornerEnd * point1.x + cornerEnd * point2.x, otherCornerEnd * point1.y + cornerEnd * point2.y};
  CGPoint right2 = {otherCornerEnd * point2.x + cornerEnd * point3.x, otherCornerEnd * point2.y + cornerEnd * point3.y};
  CGPoint right3 = {otherCornerEnd * point3.x + cornerEnd * point4.x, otherCornerEnd * point3.y + cornerEnd * point4.y};
  CGPoint right4 = {otherCornerEnd * point4.x + cornerEnd * point5.x, otherCornerEnd * point4.y + cornerEnd * point5.y};
  CGPoint right5 = {otherCornerEnd * point5.x + cornerEnd * point6.x, otherCornerEnd * point5.y + cornerEnd * point6.y};
  CGPoint right6 = {otherCornerEnd * point6.x + cornerEnd * point1.x, otherCornerEnd * point6.y + cornerEnd * point1.y};
  
  CGPathMoveToPoint(shapePathTop, NULL, right6.x, right6.y);
  CGPathAddLineToPoint(shapePathTop, NULL, left1.x, left1.y);
  
  CGPathMoveToPoint(shapePathTopCorner, NULL, left1.x, left1.y);
  CGPathAddArcToPoint(shapePathTopCorner, NULL, point1.x, point1.y, point2.x, point2.y, roundedDegree);
  CGPathAddLineToPoint(shapePathTopCorner, NULL, right1.x, right1.y);

  CGPathMoveToPoint(shapePathTopSide, NULL, right1.x, right1.y);
  CGPathAddLineToPoint(shapePathTopSide, NULL, left2.x, left2.y);
  
  CGPathMoveToPoint(shapePathSideCorner, NULL, left2.x, left2.y);
  CGPathAddArcToPoint(shapePathSideCorner, NULL, point2.x, point2.y, point3.x, point3.y, roundedDegree);
  CGPathAddLineToPoint(shapePathSideCorner, NULL, right2.x, right2.y);
  
  CGPathMoveToPoint(shapePathBottomSide, NULL, right2.x, right2.y);
  CGPathAddLineToPoint(shapePathBottomSide, NULL, left3.x, left3.y);

  CGPathMoveToPoint(shapePathBottomCorner, NULL, left3.x, left3.y);
  CGPathAddArcToPoint(shapePathBottomCorner, NULL, point3.x, point3.y, point4.x, point4.y, roundedDegree);
  CGPathAddLineToPoint(shapePathBottomCorner, NULL, right3.x, right3.y);
  
  CGPathMoveToPoint(shapePathBottom, NULL, right3.x, right3.y);
  CGPathAddLineToPoint(shapePathBottom, NULL, left4.x, left4.y);
  
  CGPathMoveToPoint(shapePathBottomCorner, NULL, left4.x, left4.y);
  CGPathAddArcToPoint(shapePathBottomCorner, NULL, point4.x, point4.y, point5.x, point5.y, roundedDegree);
  CGPathAddLineToPoint(shapePathBottomCorner, NULL, right4.x, right4.y);
  
  CGPathMoveToPoint(shapePathBottomSide, NULL, right4.x, right4.y);
  CGPathAddLineToPoint(shapePathBottomSide, NULL, left5.x, left5.y);
  
  CGPathMoveToPoint(shapePathSideCorner, NULL, left5.x, left5.y);
  CGPathAddArcToPoint(shapePathSideCorner, NULL, point5.x, point5.y, point6.x, point6.y, roundedDegree);
  CGPathAddLineToPoint(shapePathSideCorner, NULL, right5.x, right5.y);
  
  CGPathMoveToPoint(shapePathTopSide, NULL, right5.x, right5.y);
  CGPathAddLineToPoint(shapePathTopSide, NULL, left6.x, left6.y);
  
  CGPathMoveToPoint(shapePathTopCorner, NULL, left6.x, left6.y);
  CGPathAddArcToPoint(shapePathTopCorner, NULL, point6.x, point6.y, point1.x, point1.y, roundedDegree);
  CGPathAddLineToPoint(shapePathTopCorner, NULL, right6.x, right6.y);
  
  shapeNodeTop.path = shapePathTop;
  shapeNodeTop.lineWidth = 1.5f;
  shapeNodeTop.alpha = 1.f;
  shapeNodeTop.strokeColor = [SKColor redColor];
  [cellShape addChild:shapeNodeTop];
  
  shapeNodeTopCorner.path = shapePathTopCorner;
  shapeNodeTopCorner.lineWidth = 1.5f;
  shapeNodeTopCorner.alpha = 1.f;
  shapeNodeTopCorner.strokeColor = [SKColor orangeColor];
  [cellShape addChild:shapeNodeTopCorner];
  
  shapeNodeTopSide.path = shapePathTopSide;
  shapeNodeTopSide.lineWidth = 1.5f;
  shapeNodeTopSide.alpha = 1.f;
  shapeNodeTopSide.strokeColor = [SKColor yellowColor];
  [cellShape addChild:shapeNodeTopSide];
  
  shapeNodeSideCorner.path = shapePathSideCorner;
  shapeNodeSideCorner.lineWidth = 1.5f;
  shapeNodeSideCorner.alpha = 1.f;
  shapeNodeSideCorner.strokeColor = [SKColor greenColor];
  [cellShape addChild:shapeNodeSideCorner];
  
  shapeNodeBottomSide.path = shapePathBottomSide;
  shapeNodeBottomSide.lineWidth = 1.5f;
  shapeNodeBottomSide.alpha = 1.f;
  shapeNodeBottomSide.strokeColor = [SKColor cyanColor];
  [cellShape addChild:shapeNodeBottomSide];

  shapeNodeBottomCorner.path = shapePathBottomCorner;
  shapeNodeBottomCorner.lineWidth = 1.5f;
  shapeNodeBottomCorner.alpha = 1.f;
  shapeNodeBottomCorner.strokeColor = [SKColor blueColor];
  [cellShape addChild:shapeNodeBottomCorner];
  
  shapeNodeBottom.path = shapePathBottom;
  shapeNodeBottom.lineWidth = 1.5f;
  shapeNodeBottom.alpha = 1.f;
  shapeNodeBottom.strokeColor = [SKColor purpleColor];
  [cellShape addChild:shapeNodeBottom];
  
  CGPoint midPoint = {
    0.5 * (point6.x + point1.x),
    0.5 * (point6.y + point1.y)
  };
  
  CGPathMoveToPoint(shapePathFill, NULL, midPoint.x, midPoint.y);
  CGPathAddArcToPoint(shapePathFill, NULL, point1.x, point1.y, point2.x, point2.y, roundedDegree);
  CGPathAddArcToPoint(shapePathFill, NULL, point2.x, point2.y, point3.x, point3.y, roundedDegree);
  CGPathAddArcToPoint(shapePathFill, NULL, point3.x, point3.y, point4.x, point4.y, roundedDegree);
  CGPathAddArcToPoint(shapePathFill, NULL, point4.x, point4.y, point5.x, point5.y, roundedDegree);
  CGPathAddArcToPoint(shapePathFill, NULL, point5.x, point5.y, point6.x, point6.y, roundedDegree);
  CGPathAddArcToPoint(shapePathFill, NULL, point6.x, point6.y, point1.x, point1.y, roundedDegree);
  
  CGPathAddLineToPoint(shapePathFill, NULL, midPoint.x, midPoint.y);

  shapeNodeFill.path = shapePathFill;
  shapeNodeFill.lineWidth = 1.5f;
  shapeNodeFill.alpha = 1.f;
  shapeNodeFill.fillColor = [SKColor orangeColor];
  [cellShape addChild:shapeNodeFill];
  
  return cellShape;
}
*/

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
  [self addChild:self.hexCoordLabel];
}

-(void)createPCLabel {
  self.pcLabel = [[SKLabelNode alloc] init];
  self.pcLabel.fontColor = kTestRed;
  self.pcLabel.fontSize = 14.f;
  self.pcLabel.alpha = 1.f;
  self.pcLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
  self.pcLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
  self.pcLabel.position = CGPointMake(0, -9.f);
  [self addChild:self.pcLabel];
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
