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
  
    // layout cells for now
  
  NSInteger hexSize = 10;
  
  for (int i = -hexSize; i <= hexSize; i++) {
    for (int j = -hexSize; j <= hexSize; j++) {
      
        // keeps it relatively square
      if (i + j <= hexSize && i + j >= -hexSize) {
        
        Cell *blankCell = [Cell spriteNodeWithImageNamed:@"blankSpace"];
        blankCell.name = @"cell";
        blankCell.zPosition = kZPositionBoardCell;

          // does this squash yCoord a bit?
        CGFloat cellWidth = blankCell.size.width;
        CGFloat cellHeight = blankCell.size.height;
        CGFloat padding = 0.12738095f * cellWidth; // 5.35 from this before
        
        CGFloat newX = i * (0.75f * cellWidth + padding);
        CGFloat newY = (j + i * 0.5f) * (cellHeight + padding);
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

-(CGPoint)getRelativeToPoint:(CGPoint)point {
  return [self fromThisPoint:point subtractThisPoint:self.position];
}

-(CGPoint)getRelativeToPoint:(CGPoint)point withTouchOffset:(CGPoint)touchOffset {
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
