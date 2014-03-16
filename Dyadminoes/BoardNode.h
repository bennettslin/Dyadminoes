//
//  Board.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+Helper.h"

@interface BoardNode : SKSpriteNode

@property (strong, nonatomic) SKSpriteNode *boardCover;

@property (strong, nonatomic) NSMutableSet *boardNodesTwelveAndSix;
@property (strong, nonatomic) NSMutableSet *boardNodesTwoAndEight;
@property (strong, nonatomic) NSMutableSet *boardNodesFourAndTen;

@property (strong, nonatomic) SKLabelNode *testLabelNode;

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

-(id)initWithColor:(UIColor *)color andSize:(CGSize)size
    andAnchorPoint:(CGPoint)anchorPoint
       andPosition:(CGPoint)position
      andZPosition:(CGFloat)zPosition;

-(void)layoutBoardCellsAndNodes;

#pragma mark - board cover methods

-(void)revealBoardCover;

-(void)hideBoardCover;

@end
