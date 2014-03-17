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
    self.boardCover.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
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
  for (int i = -5; i < 6; i++) {
    for (int j = -10; j < 11; j++) {
      
        // keeps it relatively square
      if (i + j < 11 && i + j > -11) {
        
        Cell *blankCell = [Cell spriteNodeWithImageNamed:@"blankSpace"];
        blankCell.name = @"cell";
        blankCell.zPosition = kZPositionBoardCell;

        CGFloat cellWidth = blankCell.size.width;
        CGFloat cellHeight = blankCell.size.height;
        CGFloat padding = 0.12738095f * cellWidth;
        
        CGFloat newX = i * (0.75f * cellWidth + padding);
        CGFloat newY = (j + i / 2.f) * (cellHeight + padding);
        blankCell.position = CGPointMake(newX, newY);
        
        [self addChild:blankCell];
        
        blankCell.alpha = 0.7f;
        blankCell.boardXY = [self boardXYFromX:i andY:j];
        
          // test
        NSString *boardXYString = [NSString stringWithFormat:@"%i, %i", blankCell.boardXY.x, blankCell.boardXY.y];
        SKLabelNode *labelNode = [[SKLabelNode alloc] init];
        labelNode.name = boardXYString;
        labelNode.text = boardXYString;
        labelNode.color = [SKColor yellowColor];
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
