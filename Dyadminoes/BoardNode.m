//
//  Board.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "BoardNode.h"
#import "SnapNode.h"

@implementation BoardNode {
  CGFloat _xOffset;
  CGFloat _xPadding;
  CGFloat _yPadding;
  CGFloat _nodePadding;
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
    self.boardNodesTwelveAndSix = [NSMutableSet new];
    self.boardNodesTwoAndEight = [NSMutableSet new];
    self.boardNodesFourAndTen = [NSMutableSet new];
    
      // layout cells and nodes
  }
  return self;
}

-(void)layoutBoardCellsAndNodes {
  
    // layout cells for now
  for (int xCoord = 0; xCoord < 6; xCoord++) {
    for (int yCoord = 0; yCoord < 6; yCoord++) {
      SKSpriteNode *blankCell = [SKSpriteNode spriteNodeWithImageNamed:@"blankSpace"];
      blankCell.name = @"blankCell";
      blankCell.zPosition = kZPositionBoardCell;
      _xOffset = 0.f; // for odd rows
        // TODO: continue to tweak these numbers
      _xPadding = 5.35f;
      _yPadding = _xPadding * .5f; // this is 2.59
      _nodePadding = 0.5f * _xPadding; // 0.5f is definitely correct
      
      if (yCoord % 2 == 0) {
        _xOffset = blankCell.size.width * 0.75f + _xPadding;
      }
      
      blankCell.position = CGPointMake(xCoord * (blankCell.size.width * 1.5f + 2.f * _xPadding) + _xOffset, yCoord * (blankCell.size.height / 2.f + _yPadding));
      blankCell.alpha = 0.1f;
      [self addChild:blankCell];
      
      [self addBoardNodesForThisCell:blankCell];
      
        // for testing purposes only
      if (xCoord == 2 && yCoord == 2) {
        self.testLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        self.testLabelNode.position = blankCell.position;
        self.testLabelNode.zPosition = kZPositionMessage;
        self.testLabelNode.text = @"C";
        self.testLabelNode.name = @"testLabel";
        self.testLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        [self addChild:self.testLabelNode];
      }
    }
  }
}

-(void)addBoardNodesForThisCell:(SKSpriteNode *)blankCell {
  
  SnapNode *boardNodeTwelveAndSix = [[SnapNode alloc] initWithSnapNodeType:kSnapNodeBoardTwelveAndSix];
  SnapNode *boardNodeTwoAndEight = [[SnapNode alloc] initWithSnapNodeType:kSnapNodeBoardTwoAndEight];
  SnapNode *boardNodeFourAndTen = [[SnapNode alloc] initWithSnapNodeType:kSnapNodeBoardFourAndTen];
  
  boardNodeTwelveAndSix.position = [self addThisPoint:blankCell.position
                                          toThisPoint:CGPointMake(0.f, 19.5f)];
  boardNodeTwoAndEight.position = [self addThisPoint:blankCell.position
                                         toThisPoint:CGPointMake(kBoardDiagonalX + _nodePadding, kBoardDiagonalY)];
  boardNodeFourAndTen.position = [self addThisPoint:blankCell.position
                                        toThisPoint:CGPointMake(-kBoardDiagonalX - _nodePadding, kBoardDiagonalY)];
  
  boardNodeTwelveAndSix.name = @"board 12-6";
  boardNodeTwoAndEight.name = @"board 2-8";
  boardNodeFourAndTen.name = @"board 4-10";
  
  [self.boardNodesTwelveAndSix addObject:boardNodeTwelveAndSix];
  [self.boardNodesTwoAndEight addObject:boardNodeTwoAndEight];
  [self.boardNodesFourAndTen addObject:boardNodeFourAndTen];
  [self addChild:boardNodeTwelveAndSix];
  [self addChild:boardNodeTwoAndEight];
  [self addChild:boardNodeFourAndTen];
}


@end
