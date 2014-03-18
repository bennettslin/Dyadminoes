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
  
    // initially hardcoded bounds, these values will change as dyadminoes are moved and added
  NSInteger boundsTop = 7;
  NSInteger boundsBottom = -6;
  NSInteger boundsLeft = -4;
  NSInteger boundsRight = 4;
  
  for (int i = boundsLeft; i <= boundsRight; i++) {
    for (int j = boundsBottom; j <= boundsTop; j++) {

        // this keeps it relatively square
      if ((j >= 0 && i + (2 * j) < (boundsTop + 0.5 * (boundsRight - boundsLeft))) ||
          (j < 0 && i + (2 * j) > (boundsBottom + 0.5 * (boundsLeft - boundsRight)))) {
        Cell *blankCell = [Cell spriteNodeWithImageNamed:@"blankSpace"];
        blankCell.name = @"cell";
        blankCell.zPosition = kZPositionBoardCell;
        
          // establish cell size
        CGFloat paddingBetweenCells = 5.f;
        CGFloat ySize = kDyadminoFaceRadius * 2 - paddingBetweenCells;
        CGFloat widthToHeightRatio = blankCell.texture.size.width / blankCell.texture.size.height;
        CGFloat xSize = widthToHeightRatio * ySize;
        blankCell.size = CGSizeMake(xSize, ySize);

          // establish cell position
        CGFloat cellWidth = blankCell.size.width;
        CGFloat cellHeight = blankCell.size.height;
        CGFloat newX = i * (0.75 * cellWidth + paddingBetweenCells);
        CGFloat newY = (j + i * 0.5) * (cellHeight + paddingBetweenCells);
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
