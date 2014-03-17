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

@implementation Cell

-(void)addSnapPointsToBoard:(Board *)board {
  
  CGFloat faceOffset = 19.5f;
  CGFloat faceOffsetX = faceOffset * 0.5f * kSquareRootOfThree;
  CGFloat faceOffsetY = faceOffset * 0.5f;
  
    // FIXME: 5.35 should not be hardCoded, get it from board padding? padding result should be around 1.5375046f;
  CGFloat snapPointPadding = 5.35 / 3.5f;
  SnapPoint *boardSnapPointTwelveOClock = [[SnapPoint alloc] initWithSnapPointType:kSnapPointBoardTwelveOClock];
  SnapPoint *boardSnapPointTwoOClock = [[SnapPoint alloc] initWithSnapPointType:kSnapPointBoardTwoOClock];
  SnapPoint *boardSnapPointTenOClock = [[SnapPoint alloc] initWithSnapPointType:kSnapPointBoardTenOClock];
  
  boardSnapPointTwelveOClock.position = [self addThisPoint:self.position
                                               toThisPoint:CGPointMake(0.f, faceOffset)];
  boardSnapPointTwoOClock.position = [self addThisPoint:self.position
                                            toThisPoint:CGPointMake(faceOffsetX + snapPointPadding, faceOffsetY)];
  boardSnapPointTenOClock.position = [self addThisPoint:self.position
                                            toThisPoint:CGPointMake(-faceOffsetX - snapPointPadding, faceOffsetY)];
  
  boardSnapPointTwelveOClock.name = @"snapPoint 12-6";
  boardSnapPointTwoOClock.name = @"snapPoint 2-8";
  boardSnapPointTenOClock.name = @"snapPoint 4-10";
  boardSnapPointTwelveOClock.myCell = self;
  boardSnapPointTwoOClock.myCell = self;
  boardSnapPointTenOClock.myCell = self;
  
  [board.snapPointsTwelveOClock addObject:boardSnapPointTwelveOClock];
  [board.snapPointsTwoOClock addObject:boardSnapPointTwoOClock];
  [board.snapPointsTenOClock addObject:boardSnapPointTenOClock];
}

@end
