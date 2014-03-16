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

@implementation Board {
  CGFloat _xOffset;
  CGFloat _xPadding;
  CGFloat _yPadding;
}

-(id)initWithColor:(UIColor *)color andSize:(CGSize)size
    andAnchorPoint:(CGPoint)anchorPoint
       andPosition:(CGPoint)position
      andZPosition:(CGFloat)zPosition {
  self = [super init];
  if (self) {
    
    self.name = @"board";
    self.color = color;
    self.size = size;
    self.anchorPoint = anchorPoint;
    self.position = position;
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
  for (int xCoord = 0; xCoord < 5; xCoord++) {
    for (int yCoord = 0; yCoord < 28; yCoord++) {
      Cell *blankCell = [Cell spriteNodeWithImageNamed:@"blankSpace"];
      blankCell.name = @"blankCell";
      blankCell.zPosition = kZPositionBoardCell;
      _xOffset = 0.f; // for odd rows
        // TODO: continue to tweak these numbers
      _xPadding = 5.35f;
      _yPadding = _xPadding * .5f; // this is 2.59
      
      if (yCoord % 2 == 0) {
        _xOffset = blankCell.size.width * 0.75f + _xPadding;
      }
      
      blankCell.position = CGPointMake(xCoord * (blankCell.size.width * 1.5f + 2.f * _xPadding) + _xOffset, yCoord * (blankCell.size.height / 2.f + _yPadding));
      blankCell.alpha = 0.1f;
      [self addChild:blankCell];
      
      [blankCell addSnapPointsToBoard:self];
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
