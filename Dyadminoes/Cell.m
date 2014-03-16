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

@implementation Cell {
  CGFloat _snapPointPadding;
}

-(void)addSnapPointsToBoard:(Board *)board {
  
    // FIXME: 5.35 should not be hardCoded, get it from board xPadding
  _snapPointPadding = 0.5f * 5.35; // 0.5f is definitely correct constant for first number
  SnapPoint *boardSnapPointTwelveOClock = [[SnapPoint alloc] initWithSnapPointType:kSnapPointBoardTwelveOClock];
  SnapPoint *boardSnapPointTwoOClock = [[SnapPoint alloc] initWithSnapPointType:kSnapPointBoardTwoOClock];
  SnapPoint *boardSnapPointTenOClock = [[SnapPoint alloc] initWithSnapPointType:kSnapPointBoardTenOClock];
  
  boardSnapPointTwelveOClock.position = [self addThisPoint:self.position
                                          toThisPoint:CGPointMake(0.f, 19.5f)];
  
  boardSnapPointTwoOClock.position = [self addThisPoint:self.position
                                         toThisPoint:CGPointMake(kBoardDiagonalX + _snapPointPadding, kBoardDiagonalY)];
  
  boardSnapPointTenOClock.position = [self addThisPoint:self.position
                                        toThisPoint:CGPointMake(-kBoardDiagonalX - _snapPointPadding, kBoardDiagonalY)];
  
  boardSnapPointTwelveOClock.name = @"board 12-6";
  boardSnapPointTwoOClock.name = @"board 2-8";
  boardSnapPointTenOClock.name = @"board 4-10";
  [board.snapPointsTwelveOClock addObject:boardSnapPointTwelveOClock];
  [board.snapPointsTwoOClock addObject:boardSnapPointTwoOClock];
  [board.snapPointsTenOClock addObject:boardSnapPointTenOClock];
}

@end
