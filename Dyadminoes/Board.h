//
//  Board.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+Helper.h"

@interface Board : SKSpriteNode

@property (strong, nonatomic) SKSpriteNode *boardCover;
@property (nonatomic) CGPoint homePosition;

@property (nonatomic) CGFloat boundsTop;
@property (nonatomic) CGFloat boundsRight;
@property (nonatomic) CGFloat boundsBottom;
@property (nonatomic) CGFloat boundsLeft;

@property (strong, nonatomic) NSMutableSet *snapPointsTwelveOClock;
@property (strong, nonatomic) NSMutableSet *snapPointsTwoOClock;
@property (strong, nonatomic) NSMutableSet *snapPointsTenOClock;

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

-(id)initWithColor:(UIColor *)color andSize:(CGSize)size
    andAnchorPoint:(CGPoint)anchorPoint
   andHomePosition:(CGPoint)homePosition
      andZPosition:(CGFloat)zPosition;

-(void)layoutBoardCellsAndSnapPointsWithCellsTop:(NSInteger)cellsTop
                                      cellsRight:(NSInteger)cellsRight
                                     cellsBottom:(NSInteger)cellsBottom
                                       cellsLeft:(NSInteger)cellsLeft;

-(CGPoint)getOffsetFromPoint:(CGPoint)point;
-(CGPoint)getOffsetForPoint:(CGPoint)point withTouchOffset:(CGPoint)touchOffset;

@end
