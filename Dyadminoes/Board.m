//
//  Board.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Board.h"
#import "SnapPoint.h"
#import "Cell.h"

@implementation Board

-(id)initWithColor:(UIColor *)color andSize:(CGSize)size
    andAnchorPoint:(CGPoint)anchorPoint
   andHomePosition:(CGPoint)homePosition
      andZPosition:(CGFloat)zPosition {
  self = [super init];
  if (self) {
    
    self.name = @"board";
    self.color = color;
    self.size = size;
    self.anchorPoint = anchorPoint;
    self.homePosition = homePosition;
    self.position = self.homePosition;
    self.zPosition = zPosition;
    
      // add board cover
    self.boardCover = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:size];
    self.boardCover.name = @"boardCover";
    self.boardCover.position = CGPointZero;
    self.boardCover.zPosition = kZPositionBoardCoverHidden;
    self.boardCover.alpha = kBoardCoverAlpha;
    [self addChild:self.boardCover];
    self.boardCover.hidden = YES;

      // instantiate board node arrays
    self.snapPointsTwelveOClock = [NSMutableSet new];
    self.snapPointsTwoOClock = [NSMutableSet new];
    self.snapPointsTenOClock = [NSMutableSet new];
  }
  return self;
}

-(void)layoutBoardCellsAndSnapPoints {
  
    // board grid is a hexagon, establish its size
  NSInteger hexSize = 10;
  
  for (int i = -hexSize; i <= hexSize; i++) {
    for (int j = -hexSize; j <= hexSize; j++) {
      
        // this keeps it hexagonal
      if (i + j <= hexSize && i + j >= -hexSize) {
        
        Cell *blankCell = [Cell spriteNodeWithImageNamed:@"blankSpace"];
        blankCell.name = @"cell";
        blankCell.zPosition = kZPositionBoardCell;
        
          // establish cell size
        CGFloat paddingBetweenCells = 5.f;
        CGFloat ySize = kDyadminoFaceRadius * 2.f - paddingBetweenCells;
        CGFloat widthToHeightRatio = blankCell.texture.size.width / blankCell.texture.size.height;
        CGFloat xSize = widthToHeightRatio * ySize;
        blankCell.size = CGSizeMake(xSize, ySize);

          // establish cell position
        CGFloat cellWidth = blankCell.size.width;
        CGFloat cellHeight = blankCell.size.height;
        CGFloat newX = i * (0.75f * cellWidth + paddingBetweenCells);
        CGFloat newY = (j + i * 0.5f) * (cellHeight + paddingBetweenCells);
        blankCell.position = CGPointMake(newX, newY);
        
        [self addChild:blankCell];
        
        blankCell.alpha = 0.6f;
        blankCell.boardXY = [self boardXYFromX:i andY:j];
        
          // test
        NSString *boardXYString = [NSString stringWithFormat:@"%i, %i", blankCell.boardXY.x, blankCell.boardXY.y];
        SKLabelNode *labelNode = [[SKLabelNode alloc] init];
        labelNode.name = boardXYString;
        labelNode.text = boardXYString;
        labelNode.fontColor = [SKColor whiteColor];
        
        if (i == 0 || j == 0 || i + j == 0)
          labelNode.fontColor = [SKColor yellowColor];
        
        if (i == 0 && j == 0)
          labelNode.fontColor = [SKColor redColor];
        
        labelNode.fontSize = 14.f;
        labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        [blankCell addChild:labelNode];
        
        [blankCell addSnapPointsToBoard:self];
        
          // test
        if (i == 0 && j == 0)
          NSLog(@"blankCell size is %f, %f, at position %f, %f", cellWidth, cellHeight, blankCell.position.x, blankCell.position.y);
      }
    }
  }
}

-(CGPoint)getOffsetFromPoint:(CGPoint)point {
  return [self fromThisPoint:point subtractThisPoint:self.position];
}

-(CGPoint)getOffsetForPoint:(CGPoint)point withTouchOffset:(CGPoint)touchOffset {
  CGPoint offsetPoint = [self fromThisPoint:point subtractThisPoint:touchOffset];
  return [self fromThisPoint:offsetPoint subtractThisPoint:self.position];
}

#pragma mark - board cover methods

-(void)revealBoardCover {
    // TODO: make this animated
  self.boardCover.hidden = NO;
  self.boardCover.zPosition = kZPositionBoardCover;
}

-(void)hideBoardCover {
  self.boardCover.hidden = YES;
  self.boardCover.zPosition = kZPositionBoardCoverHidden;
}

@end
