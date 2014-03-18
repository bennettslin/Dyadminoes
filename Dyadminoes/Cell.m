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
  
  CGFloat faceOffset = kDyadminoFaceRadius;
  
    // based on a 30-60-90 degree triangle
  CGFloat faceOffsetX = faceOffset * 0.5 * kSquareRootOfThree;
  CGFloat faceOffsetY = faceOffset * 0.5;

  SnapPoint *boardSnapPointTwelveOClock = [[SnapPoint alloc] initWithSnapPointType:kSnapPointBoardTwelveOClock];
  SnapPoint *boardSnapPointTwoOClock = [[SnapPoint alloc] initWithSnapPointType:kSnapPointBoardTwoOClock];
  SnapPoint *boardSnapPointTenOClock = [[SnapPoint alloc] initWithSnapPointType:kSnapPointBoardTenOClock];
  
  boardSnapPointTwelveOClock.position = [self addToThisPoint:self.position
                                               thisPoint:CGPointMake(0.f, faceOffset)];
  boardSnapPointTwoOClock.position = [self addToThisPoint:self.position
                                            thisPoint:CGPointMake(faceOffsetX, faceOffsetY)];
  boardSnapPointTenOClock.position = [self addToThisPoint:self.position
                                            thisPoint:CGPointMake(-faceOffsetX, faceOffsetY)];
  
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
