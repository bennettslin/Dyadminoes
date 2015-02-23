//
//  Board.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Board.h"
#import "Cell.h"
#import "Dyadmino.h"
#import "Face.h"

#define kCellColourMultiplier .005f
#define kBackgroundFullAlpha 0.5f

@interface Board ()

@property (readwrite, nonatomic) CGPoint origin;
@property (readwrite, nonatomic) CGVector hexOrigin;

  /// these are the limits in terms of number of cells
@property (assign, nonatomic) CGFloat cellsTop;
@property (assign, nonatomic) CGFloat cellsRight;
@property (assign, nonatomic) CGFloat cellsBottom;
@property (assign, nonatomic) CGFloat cellsLeft;

  // properties for cell bounds
/*
  if cells are:
 
       1
    2     3
       4
    5     6
       7
 
  then array is:

    2  1
     
    5  4  3
     
       7  6
*/

@property (assign, nonatomic) NSInteger cellsTopInteger;
@property (assign, nonatomic) NSInteger cellsRightInteger;
@property (assign, nonatomic) NSInteger cellsBottomInteger;
@property (assign, nonatomic) NSInteger cellsLeftInteger;
@property (readwrite, nonatomic) NSMutableArray *columnOfRowsOfAllCells;

@property (strong, nonatomic) NSMutableSet *dequeuedCells;
@property (strong, nonatomic) SKTexture *cellTexture;
@property (nonatomic) BOOL userWantsPivotGuides;

@end

@implementation Board {

  BOOL _hexOriginSet;
  CGVector _hexCurrentOriginForCenteringBoard;
}

-(id)initWithColor:(UIColor *)color andSize:(CGSize)size andCellTexture:(SKTexture *)cellTexture {
  self = [super init];
  if (self) {
    
    self.name = @"board";
    self.color = color;
    self.size = size;
    self.cellTexture = cellTexture;
    self.anchorPoint = CGPointMake(0.5, 0.5);
    self.zPosition = kZPositionBoard;
    self.zoomedOut = NO;
    
    self.userWantsPivotGuides = YES;

      // create new cells from get-go
    [self instantiateDequeuedCells];
  }
  return self;
}

-(void)updatePivotGuidesForNewPlayer {
  SKNode *prePivotGuide = [self createPivotGuideNamed:@"prePivotGuide"];
  SKNode *pivotRotateGuide = [self createPivotGuideNamed:@"pivotRotateGuide"];
  SKNode *pivotAroundGuide = [self createPivotGuideNamed:@"pivotAroundGuide"];
  
    // assign pivot guides
  self.prePivotGuide = prePivotGuide;
  self.prePivotGuide.name = @"prePivotGuide";
  self.pivotRotateGuide = pivotRotateGuide;
  self.pivotRotateGuide.name = @"pivotRotateGuide";
  self.pivotAroundGuide = pivotAroundGuide;
  self.pivotAroundGuide.name = @"pivotAroundGuide";
}

-(void)resetForNewMatch {

  [self ignoreAllCells];
  
  self.columnOfRowsOfAllCells = nil;

  self.zoomedOut = NO;
  self.zoomInBoardHomePositionDifference = CGPointZero;

//  [self zoomInBackgroundImage];
  
    // FIXME: this doesn't seem to be necessary
  [self removeAllActions];
  [self removeAllChildren];
}

#pragma mark - board position methods

-(void)repositionBoardWithHomePosition:(CGPoint)homePosition
                             andOrigin:(CGPoint)origin {
  
  _hexOriginSet = NO;
  self.homePosition = homePosition;
  self.origin = origin;
  
  self.position = self.homePosition;
}

-(CGPoint)centerBoardOnDyadminoesAverageCenterWithSwap:(BOOL)swap {
  CGFloat factor = self.zoomedOut ? kZoomResizeFactor : 1.f;
  CGPoint newPoint = CGPointMake(self.origin.x + (self.hexOrigin.dx - _hexCurrentOriginForCenteringBoard.dx) * kDyadminoFaceWideDiameter * factor,
                                 self.origin.y + (self.hexOrigin.dy - _hexCurrentOriginForCenteringBoard.dy) * kDyadminoFaceDiameter * factor);
  
  CGPoint differenceInPosition = [self adjustedNewPositionFromBeganLocation:self.homePosition
                                                          toCurrentLocation:newPoint
                                                                   withSwap:swap
                                                           returnDifference:YES];
  self.homePosition = newPoint;
  return differenceInPosition;
}

#pragma mark - board span methods

-(CGPoint)adjustedNewPositionFromBeganLocation:(CGPoint)beganLocation
                             toCurrentLocation:(CGPoint)currentLocation
                                      withSwap:(BOOL)swap
                              returnDifference:(BOOL)returnDifference {
  
    // first get new board position, after applying touch offset
  CGPoint touchOffset = [self subtractFromThisPoint:beganLocation thisPoint:currentLocation];
  CGPoint newPosition = [self subtractFromThisPoint:self.homePosition thisPoint:touchOffset];
  
  CGFloat newX = newPosition.x;
  CGFloat newY = newPosition.y;
  
  CGFloat finalBuffer = swap ? kRackHeight : 0.f; // the height of the swap field

  if (newPosition.y < self.lowestYPos) {
    newY = self.lowestYPos;
  } else if (newPosition.y > (self.highestYPos + finalBuffer)) {
    newY = self.highestYPos + finalBuffer;
  }
  
  if (newPosition.x < self.lowestXPos) {
    newX = self.lowestXPos;
  } else if (newPosition.x > self.highestXPos) {
    newX = self.highestXPos;
  }
  
    // requested by scene for board move
  CGPoint adjustedNewPosition = CGPointMake(newX, newY);
  
    // requested by board itself for zoom
  CGPoint differenceInPosition = [self subtractFromThisPoint:self.position thisPoint:adjustedNewPosition];
  
  self.position = adjustedNewPosition;
  
    // move home position to board position, after applying touch offset
  self.homePosition = [self addToThisPoint:adjustedNewPosition thisPoint:touchOffset];
  
  return returnDifference ? differenceInPosition : adjustedNewPosition;
}

-(CGVector)determineOutermostCellsBasedOnDyadminoes:(NSSet *)boardDyadminoes {
    // called directly by scene for replay and zoom
  
    // floats to allow for in-between values for y-coordinates
  CGFloat cellsTopmost = -CGFLOAT_MAX;
  CGFloat cellsRightmost = -CGFLOAT_MAX;
  CGFloat cellsBottommost = CGFLOAT_MAX;
  CGFloat cellsLeftmost = CGFLOAT_MAX;
  
  NSInteger cellsTopmostInteger = -NSIntegerMax;
  NSInteger cellsRightmostInteger = -NSIntegerMax;
  NSInteger cellsBottommostInteger = NSIntegerMax;
  NSInteger cellsLeftmostInteger = NSIntegerMax;
  
  for (Dyadmino *dyadmino in boardDyadminoes) {

    HexCoord bottomHexCoord = [self hexCoordFromX:dyadmino.tempHexCoord.x andY:dyadmino.tempHexCoord.y];
    HexCoord topHexCoord = [self retrieveTopHexCoordForBottomHexCoord:bottomHexCoord andOrientation:dyadmino.homeOrientation];
    
    HexCoord hexCoord[2] = {bottomHexCoord, topHexCoord};
    
    for (int i = 0; i < 2; i++) {
      NSInteger xHex = hexCoord[i].x;
      NSInteger yHex = hexCoord[i].y;
      
//      NSLog(@"hex is %i, %i for dyadmino %@", xHex, yHex, dyadmino.name);
      
        // check x span - this one is easy enough
      if (xHex > cellsRightmost) {
        cellsRightmost = (CGFloat)xHex;
      }
      
      if (xHex < cellsLeftmost) {
        cellsLeftmost = (CGFloat)xHex;
      }
      
      CGFloat trialTopmost = ((CGFloat)xHex + (2 * yHex)) / 2.f;
      if (trialTopmost > cellsTopmost) {
        cellsTopmost = trialTopmost;
      }
      
      CGFloat trialBottommost = ((CGFloat)xHex + (2 * yHex)) / 2.f;
      if (trialBottommost < cellsBottommost) {
        cellsBottommost = trialBottommost;
      }
      
        // for determining bounds of cells array
        // could be more DRY
      if (xHex > cellsRightmostInteger) {
        cellsRightmostInteger = xHex;
      }
      
      if (xHex < cellsLeftmostInteger) {
        cellsLeftmostInteger = xHex;
      }
      
      if (yHex > cellsTopmostInteger) {
        cellsTopmostInteger = yHex;
      }
      
      if (yHex < cellsBottommostInteger) {
        cellsBottommostInteger = yHex;
      }
    }
  }
  
  CGFloat cellsInHorizontalRange = [self cellsInHorizontalRange];
  CGFloat cellsInVerticalRange = [self cellsInVerticalRange];

      // buffer cells beyond outermost dyadmino (keep tweaking these numbers)
  CGFloat extraYCells = (((cellsInVerticalRange * 2) - (cellsTopmost - cellsBottommost + 1)) / 2.f) + 1.5f;
  if (extraYCells < 3.5) {
    extraYCells = 3.5;
  }
  
  CGFloat extraXCells = (((cellsInHorizontalRange * 2) - (cellsRightmost - cellsLeftmost + 1)) / 2.f) + 2.f;
  if (extraXCells < 4) {
    extraXCells = 4;
  }
  
  self.cellsTop = cellsTopmost + extraYCells;
  self.cellsRight = cellsRightmost + extraXCells;
  self.cellsBottom = cellsBottommost - extraYCells - 1.f;
  self.cellsLeft = cellsLeftmost - extraXCells;
  
  self.cellsTopInteger = cellsTopmostInteger + kCellsAroundDyadmino;
  self.cellsRightInteger = cellsRightmostInteger + kCellsAroundDyadmino;
  self.cellsBottomInteger = cellsBottommostInteger - kCellsAroundDyadmino;
  self.cellsLeftInteger = cellsLeftmostInteger - kCellsAroundDyadmino;
  
    // obviously, this is the only place that column of rows of all cells is recalibrated
    // since this is the only place where its bounds are set
  [self recalibrateColumnOfRowsOfAllCells];
  
//  NSLog(@"bounds is top %.1f, right %.1f, bottom %.1f, left %.1f", self.cellsTop, self.cellsRight, self.cellsBottom, self.cellsLeft);
//  NSLog(@"raw bounds floats is top %.1f, right %.1f, bottom %.1f, left %.1f", cellsTopmost, cellsRightmost, cellsBottommost, cellsLeftmost);
//  NSLog(@"raw bounds integers is top %i, right %i, bottom %i, left %i", (NSInteger)cellsTopmost, (NSInteger)cellsRightmost, (NSInteger)cellsBottommost, (NSInteger)cellsLeftmost);
//  NSLog(@"determine outermost, cell bounds integers is top %i, right %i, bottom %i, left %i", self.cellsTopInteger, self.cellsRightInteger, self.cellsBottomInteger, self.cellsLeftInteger);
  
  CGVector returnVector = CGVectorMake(((CGFloat)(self.cellsRight - self.cellsLeft) / 2.f) + self.cellsLeft,
                                       ((CGFloat)(self.cellsTop - self.cellsBottom) / 2.f) + self.cellsBottom);
  
  return returnVector;
}

-(void)determineBoardPositionBounds {
    // this should get called after every method that adds cells or removes them
  
  CGFloat cellsInHorizontalRange = [self cellsInHorizontalRange];
  CGFloat cellsInVerticalRange = [self cellsInVerticalRange];
  
  CGFloat factor = self.zoomedOut ? kZoomResizeFactor : 1.f;
  self.lowestYPos = self.origin.y - (self.cellsTop - cellsInVerticalRange - self.hexOrigin.dy) * kDyadminoFaceDiameter * factor;
  self.lowestXPos = self.origin.x - (self.cellsRight - cellsInHorizontalRange - self.hexOrigin.dx) * kDyadminoFaceAverageWideDiameter * factor;
  self.highestYPos = self.origin.y - (self.cellsBottom + cellsInVerticalRange - self.hexOrigin.dy) * kDyadminoFaceDiameter * factor;
  self.highestXPos = self.origin.x - (self.cellsLeft + cellsInHorizontalRange - self.hexOrigin.dx) * kDyadminoFaceAverageWideDiameter * factor;
}

#pragma mark - cell methods

-(void)establishHexOriginForCenteringBoardBasedOnBoardDyadminoes:(NSSet *)boardDyadminoes {
    // regular hex origin is only set once per scene load, but zoom hex origin is set every time
  
//  NSLog(@"establish hex origin based on board dyadminoes %@", boardDyadminoes);
  
  CGVector hexVector = [self determineOutermostCellsBasedOnDyadminoes:boardDyadminoes];
  
  if (!_hexOriginSet) {
    self.hexOrigin = hexVector;
    _hexCurrentOriginForCenteringBoard = self.hexOrigin;
    _hexOriginSet = YES;
    
  } else {
    _hexCurrentOriginForCenteringBoard = hexVector;
  }
  
//  NSLog(@"hex origin is %.2f, %.2f", hexVector.dx, hexVector.dy);
}

-(BOOL)layoutAndColourBoardCellsAndSnapPointsOfDyadminoes:(NSSet *)boardDyadminoes
                                            minusDyadmino:(Dyadmino *)minusDyadmino
                                             updateBounds:(BOOL)updateBounds {
  
  NSSet *finalBoardDyadminoes = [self boardDyadminoes:boardDyadminoes minusDyadmino:minusDyadmino];
  
  [self establishHexOriginForCenteringBoardBasedOnBoardDyadminoes:finalBoardDyadminoes];
  
//  NSLog(@"add all current called from layout");
  NSMutableSet *tempIgnoredCellsSet = [self placeholderContainerForIgnoredCells];
  
  void(^resetBlock)(Cell *) = ^void(Cell *cell) {
    [cell resetColour];
  };
  [self performBlockOnAllCells:resetBlock];
  
  for (Dyadmino *dyadmino in finalBoardDyadminoes) {

//    NSLog(@"layout for dyadmino %@ based on orientation %i", dyadmino.name, dyadmino.homeOrientation);
    HexCoord bottomHexCoord = [self hexCoordFromX:dyadmino.tempHexCoord.x andY:dyadmino.tempHexCoord.y];
    
      // was homeOrientation before
    
    DyadminoOrientation orientation = dyadmino.home == kRack ? dyadmino.orientation : dyadmino.homeOrientation;
    HexCoord topHexCoord = [self retrieveTopHexCoordForBottomHexCoord:bottomHexCoord andOrientation:orientation];
    
    HexCoord hexCoord[2] = {bottomHexCoord, topHexCoord};
    
    BOOL dyadminoRightSideUp = (dyadmino.orientation <= kPC1atTwoOClock || dyadmino.orientation >= kPC1atTenOClock);
    NSUInteger topPC = dyadminoRightSideUp ? dyadmino.pc1 : dyadmino.pc2;
    NSUInteger bottomPC = dyadminoRightSideUp ? dyadmino.pc2 : dyadmino.pc1;
    NSUInteger pcs[2] = {bottomPC, topPC};
    
    for (int i = 0; i < 2; i++) {
      NSInteger xHex = hexCoord[i].x;
      NSInteger yHex = hexCoord[i].y;
      NSUInteger pc = pcs[i];
      
      for (NSInteger x = -kCellsAroundDyadmino; x <= kCellsAroundDyadmino; x++) {
        for (NSInteger y = -kCellsAroundDyadmino; y <= kCellsAroundDyadmino; y++) {
          
          if (ABS(x + y) <= kCellsAroundDyadmino) {
            NSInteger newX = xHex + x;
            NSInteger newY = yHex + y;
            Cell *addedCell = [self recogniseCellWithHexCoord:[self hexCoordFromX:newX andY:newY]];

            NSUInteger distance = [self distanceGivenHexXDifference:x andHexYDifference:y];
//            NSLog(@"distance for cell %@ is %i", addedCell.name, distance);
            [addedCell addColourValueForPC:pc atDistance:distance];
            [tempIgnoredCellsSet removeObject:addedCell];
          }
        }
      }
    }
  }
  
  for (Cell *cell in tempIgnoredCellsSet) {
    [self ignoreCell:cell];
  }
  
  void(^renderBlock)(Cell *) = ^void(Cell *cell) {
    [cell renderColour];
  };
  [self performBlockOnAllCells:renderBlock];
 
    // bounds is not updated with removal by touch, only with removal by cancel
  if (updateBounds) {
    [self determineBoardPositionBounds];
  }
  return YES;
}

-(Cell *)recogniseCellWithHexCoord:(HexCoord)hexCoord {
  
    // first check to see if cell already exists
  Cell *cell = [self cellWithHexCoord:hexCoord];
  
    // if not, get one from queue
  if (!cell) {
    cell = [self popDequeuedCellWithHexCoord:hexCoord];
    [self addCellToColumnOfRowsOfCells:cell];
    [self fadeOut:NO cell:cell completion:nil];
  }
  
  return cell;
}

-(void)ignoreCell:(Cell *)cell {
  if (cell) {

    [self removeCellFromColumnOfRowsOfCells:cell];
    
    __weak typeof(self) weakSelf = self;
    void(^completion)(void) = ^void(void) {
      [cell resetForReuse];
      [weakSelf pushDequeuedCell:cell];
    };
    
    [self fadeOut:YES cell:cell completion:completion];
  }
}

-(void)fadeOut:(BOOL)fadeOut cell:(Cell *)cell completion:(void(^)(void))completion {
  CGFloat fadeAlpha = fadeOut ? 0.f : 1.f;
  
  CGFloat duration = fadeOut ? kConstantTime * 0.4f : kConstantTime * 0.8f;
  
  CGFloat wait;
  
  if (fadeOut) {
    wait = (kCellsAroundDyadmino - cell.minDistance) * 0.05f;
  } else {
    wait = cell.minDistance * 0.05f;
  }
  
  NSLog(@"wait for cell %@ is %.2f, with min distance %i", cell.name, wait, cell.minDistance);
  
  [cell removeActionForKey:@"cellFade"];
  SKAction *waitAction = [SKAction waitForDuration:wait];
  SKAction *fadeAction = [SKAction fadeAlphaTo:fadeAlpha duration:duration];
  SKAction *shrinkAction = [SKAction scaleTo:fadeAlpha duration:duration];
  SKAction *fadeShrinkGroup = [SKAction group:@[fadeAction, shrinkAction]];
  SKAction *completionAction = [SKAction runBlock:completion];
  SKAction *sequenceAction = [SKAction sequence:@[waitAction, fadeShrinkGroup, completionAction]];
//  [cell.cellNode runAction:sequenceAction];
  [cell runAction:sequenceAction withKey:@"cellFade"];

}

-(void)ignoreAllCells {
  
    // block to ignore each cell
  __weak typeof(self) weakSelf = self;
  void(^block)(Cell *) = ^void(Cell *cell) {
    [weakSelf ignoreCell:cell];
  };
  
  [self performBlockOnAllCells:block];
  self.columnOfRowsOfAllCells = nil;
}

#pragma mark - column of rows of all cells methods

-(BOOL)recalibrateColumnOfRowsOfAllCells {
  
//  NSLog(@"recalibrate column of rows of all cells");
  
    // remove cells that are not found in new array
  NSMutableSet *tempIgnoredCellsSet = [self placeholderContainerForIgnoredCells];
  
  NSMutableArray *tempColumnArray = [NSMutableArray new];
  for (NSInteger j = self.cellsBottomInteger - 2; j <= self.cellsTopInteger; j++) {
    
      // first value is x origin
    if (j == self.cellsBottomInteger - 2) {
      [tempColumnArray addObject:@(self.cellsLeftInteger)];
      
        // second value is y origin
    } else if (j == self.cellsBottomInteger - 1) {
      [tempColumnArray addObject:@(self.cellsBottomInteger)];
      
        // now add the rows
    } else {
      NSMutableArray *tempRowArray = [NSMutableArray new];
      for (NSInteger i = self.cellsLeftInteger; i <= self.cellsRightInteger; i++) {
        
          // add cell if there is a cell, otherwise add null
        Cell *addedCell = [self cellWithHexCoord:[self hexCoordFromX:i andY:j]];
        
        if (addedCell) {
          [tempRowArray addObject:addedCell];
          [tempIgnoredCellsSet removeObject:addedCell];
          
        } else {
          [tempRowArray addObject:[NSNull null]];
        }
      }
      
      [tempColumnArray addObject:tempRowArray];
    }
  }
  
  for (Cell *cell in tempIgnoredCellsSet) {
    [self ignoreCell:cell];
  }
  
  self.columnOfRowsOfAllCells = tempColumnArray;
  
    // check that array of arrays has right count
  NSArray *arbitraryRow = [self.columnOfRowsOfAllCells lastObject];
  return (self.columnOfRowsOfAllCells.count == self.cellsTopInteger - self.cellsBottomInteger + 1 + 2) &&
  (arbitraryRow.count == self.cellsRightInteger - self.cellsLeftInteger + 1);
}

-(Cell *)cellWithHexCoord:(HexCoord)hexCoord {
  
  if (self.columnOfRowsOfAllCells.count > 2) {
    NSInteger xIndex = hexCoord.x - [self.columnOfRowsOfAllCells[0] unsignedIntegerValue];
    NSInteger yIndex = hexCoord.y - [self.columnOfRowsOfAllCells[1] unsignedIntegerValue];
    
    if (yIndex < self.columnOfRowsOfAllCells.count - 2) {
      NSMutableArray *rowArray = self.columnOfRowsOfAllCells[yIndex + 2];
      
      if (xIndex < rowArray.count) {
        id object = rowArray[xIndex];
        if ([object isKindOfClass:Cell.class]) {
          return object;
        }
      }
    }
  }
  
  return nil;
}

-(BOOL)addCellToColumnOfRowsOfCells:(Cell *)cell {
  
  if (self.columnOfRowsOfAllCells.count > 2) {

    NSInteger xIndex = cell.hexCoord.x - [self.columnOfRowsOfAllCells[0] unsignedIntegerValue];
    NSInteger yIndex = cell.hexCoord.y - [self.columnOfRowsOfAllCells[1] unsignedIntegerValue];
    
    if (yIndex >= 0 && yIndex < self.columnOfRowsOfAllCells.count - 2) {
      NSMutableArray *rowArray = self.columnOfRowsOfAllCells[yIndex + 2];
      
      if (xIndex >= 0 && xIndex < rowArray.count) {
    
          // only add if cell is not already contained
        if (rowArray[xIndex] == [NSNull null]) {
          [rowArray replaceObjectAtIndex:xIndex withObject:cell];
          return YES;
        }
      }
    }
  }
  return NO;
}

-(BOOL)removeCellFromColumnOfRowsOfCells:(Cell *)cell {

  if (self.columnOfRowsOfAllCells.count > 2) {

    NSInteger xIndex = cell.hexCoord.x - [self.columnOfRowsOfAllCells[0] unsignedIntegerValue];
    NSInteger yIndex = cell.hexCoord.y - [self.columnOfRowsOfAllCells[1] unsignedIntegerValue];
    
    if (yIndex >= 0 && yIndex < self.columnOfRowsOfAllCells.count - 2) {
      NSMutableArray *rowArray = self.columnOfRowsOfAllCells[yIndex + 2];
      if (xIndex >= 0 && xIndex < rowArray.count) {
        
          // only add if cell is already contained
        
        if ([rowArray[xIndex] isKindOfClass:Cell.class]) {
          [rowArray replaceObjectAtIndex:xIndex withObject:[NSNull null]];
          return YES;
        }
      }
    }
  }
  return NO;
}

-(void)performBlockOnAllCells:(void(^)(Cell *))block {
  
  if (self.columnOfRowsOfAllCells.count > 2) {
    for (int j = 0; j < self.columnOfRowsOfAllCells.count - 2; j++) {
      NSMutableArray *tempRowArray = self.columnOfRowsOfAllCells[j + 2];
      
      for (int i = 0; i < tempRowArray.count; i++) {
        id object = tempRowArray[i];
        
        if ([object isKindOfClass:Cell.class]) {
          Cell *cell = (Cell *)object;
          block(cell);
        }
      }
    }
  }
}

-(NSMutableSet *)placeholderContainerForIgnoredCells {

//  NSLog(@"all cells count is %i", self.allCells.count);
//  NSMutableSet *tempIgnoredCellsSet = [NSMutableSet setWithSet:self.allCells];
//  NSLog(@"temp children count is %i", tempIgnoredCellsSet.count);
//  return tempIgnoredCellsSet;
  
  NSMutableSet *tempIgnoredCellsSet = [NSMutableSet new];
  for (id child in self.children) {
    if ([child isKindOfClass:Cell.class]) {
      Cell *cell = (Cell *)child;
      [tempIgnoredCellsSet addObject:cell];
    }
  }
  
  if (self.columnOfRowsOfAllCells.count > 2) {
    for (int j = 0; j < self.columnOfRowsOfAllCells.count - 2; j++) {
      NSMutableArray *tempRowArray = self.columnOfRowsOfAllCells[j + 2];
      
      for (int i = 0; i < tempRowArray.count; i++) {
        id object = tempRowArray[i];
        
        if ([object isKindOfClass:Cell.class]) {
          Cell *cell = (Cell *)object;
          [tempIgnoredCellsSet addObject:cell];
        }
      }
    }
    
//    NSLog(@"added to temp array, count is %i", tempIgnoredCellsSet.count);
    return tempIgnoredCellsSet;
  }
  
  return nil;
}

#pragma mark - dequeued cell methods

-(void)instantiateDequeuedCells {
  
  if (!self.allCells) {
    self.allCells = [NSMutableSet new];
  }
  
  self.dequeuedCells = [NSMutableSet new];
  NSUInteger times = 182; // number of initial cells with one dyadmino on board
  for (int i = 0; i < times; i++) {
    Cell *cell = [[Cell alloc] initWithTexture:self.cellTexture
                                   andHexCoord:[self hexCoordFromX:NSIntegerMax andY:NSIntegerMax]
                                  andHexOrigin:self.hexOrigin
                                     andResize:self.zoomedOut];
    
    [self.dequeuedCells addObject:cell];
    [self.allCells addObject:cell];
  }
  
//  NSLog(@"all cells count is %i", self.allCells.count);

}

-(void)pushDequeuedCell:(Cell *)cell {
  cell.parent ? [cell removeFromParent] : nil;
//  cell.cellNode.parent ? [cell.cellNode removeFromParent] : nil;
  [self.dequeuedCells containsObject:cell] ? nil : [self.dequeuedCells addObject:cell];
  
//  NSLog(@"from pushing cell %@, dequeued cells count is %i", cell.name, self.dequeuedCells.count);

}

-(Cell *)popDequeuedCellWithHexCoord:(HexCoord)hexCoord {
  
  Cell *cell = [self.dequeuedCells anyObject];
  
    // there is a cell to dequeue
  if (cell) {
    [self.dequeuedCells removeObject:cell];
    [cell reuseCellWithHexCoord:hexCoord andHexOrigin:self.hexOrigin forResize:self.zoomedOut];
    
      // no cell to dequeue, so instantiate new one
  } else {
    
    if (!self.allCells) {
      self.allCells = [NSMutableSet new];
    }
    
    cell = [[Cell alloc] initWithTexture:self.cellTexture
                             andHexCoord:hexCoord
                            andHexOrigin:self.hexOrigin
                               andResize:self.zoomedOut];
    
    [self.allCells addObject:cell];
  }
  
//  NSLog(@"from popping %@, dequeued cells count is %i", cell.name, self.dequeuedCells.count);
  cell.parent ? nil : [self addChild:cell];
//  cell.cellNode.parent ? nil : [self addChild:cell.cellNode];
  
//  NSLog(@"all cells count is %i", self.allCells.count);

  return cell;
}

#pragma mark - cell zoom methods

-(CGPoint)repositionCellsForZoomWithSwap:(BOOL)swap {
  
  CGPoint differenceInPosition = CGPointZero;
  CGPoint zoomOutBoardHomePositionDifference = [self subtractFromThisPoint:self.position thisPoint:self.homePosition];
  
    // zoom out
  if (self.zoomedOut) {
    differenceInPosition = [self centerBoardOnDyadminoesAverageCenterWithSwap:swap];
      //    [self zoomOutBackgroundImage];
    
      // zoom back in
  } else {
    differenceInPosition = [self adjustedNewPositionFromBeganLocation:self.homePosition
                                                    toCurrentLocation:self.postZoomPosition
                                                             withSwap:swap
                                                     returnDifference:YES];
    
    [self.delegate correctBoardForPositionAfterZoom];
      //    [self zoomInBackgroundImage];
  }
  
    // animate all cells
  CGSize cellSize = [Cell cellSizeForResize:self.zoomedOut];
  __weak typeof(self) weakSelf = self;
  void(^block)(Cell *) = ^void(Cell *cell) {
    CGPoint tempNewPosition = [weakSelf addToThisPoint:cell.position thisPoint:differenceInPosition];
//    CGPoint tempNewPosition = [weakSelf addToThisPoint:cell.cellNode.position thisPoint:differenceInPosition];
    
    if (weakSelf.zoomedOut) {
      tempNewPosition = [self addToThisPoint:tempNewPosition thisPoint:zoomOutBoardHomePositionDifference];
    } else {
      tempNewPosition = [self addToThisPoint:tempNewPosition thisPoint:weakSelf.zoomInBoardHomePositionDifference];
    }
    
    cell.position = tempNewPosition;
//    cell.cellNode.position = tempNewPosition;

    [cell animateResizeAndRepositionOfCell:weakSelf.zoomedOut withHexOrigin:weakSelf.hexOrigin andSize:cellSize];
  };
  [self performBlockOnAllCells:block];
  
  return differenceInPosition;
    //  self.backgroundNodeZoomedIn.position = [self subtractFromThisPoint:self.origin thisPoint:self.position];
    //  self.backgroundNodeZoomedOut.position = [self subtractFromThisPoint:self.origin thisPoint:self.position];
}

-(void)changeAllCellsToAlpha:(CGFloat)desiredAlpha animated:(BOOL)animated {
  
  void(^block)(Cell *) = ^void(Cell *cell) {
    if (animated) {
      SKAction *changeAlphaAction = [SKAction fadeAlphaTo:desiredAlpha duration:kConstantTime];
      [cell runAction:changeAlphaAction withKey:@"fadeCellAlpha"];
//      [cell.cellNode runAction:changeAlphaAction withKey:@"fadeCellAlpha"];

    } else {
      [cell setMyAlpha:desiredAlpha];
//      [cell.cellNode setAlpha:desiredAlpha];
    }
  };

  [self performBlockOnAllCells:block];
}

#pragma mark - cell and data dyadmino methods

-(void)updateCellsForDyadmino:(Dyadmino *)dyadmino placedOnBottomHexCoord:(HexCoord)bottomHexCoord {
//  NSLog(@"update cells for dyadmino %@ placed on hexCoord %i, %i", dyadmino.name, bottomHexCoord.x, bottomHexCoord.y);
  
    // this assumes dyadmino is properly oriented for this boardNode
  NSArray *cells = [self topAndBottomCellsArrayForDyadmino:dyadmino
                                         andBottomHexCoord:bottomHexCoord];
  
  NSInteger pcs[2] = {dyadmino.pc1, dyadmino.pc2};
  
  for (int i = 0; i < cells.count; i++) {
    
    id object = cells[i];
    if ([object isKindOfClass:Cell.class]) {
      Cell *cell = (Cell *)object;
      
        // only assign if cell doesn't have a dyadmino recorded
      if (!cell.myDyadmino) {
        
        cell.myPC = (dyadmino.orientation <= kPC1atTwoOClock || dyadmino.orientation >= kPC1atTenOClock) ?
        pcs[i] : pcs[(i + 1) % 2];
        
          // ensures there's only one cell for each dyadmino pc, and vice versa
        [self mapOneCell:cell toOnePCForDyadmino:dyadmino];
      }
    }
  }
}

-(void)updateCellsForDyadmino:(Dyadmino *)dyadmino removedFromBottomHexCoord:(HexCoord)bottomHexCoord {

  NSArray *cells = [self topAndBottomCellsArrayForDyadmino:dyadmino
                                         andBottomHexCoord:bottomHexCoord];
  
  for (int i = 0; i < cells.count; i++) {
    id object = cells[i];
    if ([object isKindOfClass:Cell.class]) {
      Cell *cell = (Cell *)object;
      
        // only remove if cell dyadmino is dyadmino
      if (cell.myDyadmino == dyadmino) {
        [self removeDyadminoDataFromCell:cell];
      }
    }
  }
}

-(BOOL)mapOneCell:(Cell *)cell toOnePCForDyadmino:(Dyadmino *)dyadmino {
  
    // cell's new pc has just been assigned
  if (cell.myPC == dyadmino.pc1) {
    if (dyadmino.cellForPC1 && dyadmino.cellForPC1 != cell) { // remove dyadmino and its pc from previous cell
      [self removeDyadminoDataFromCell:dyadmino.cellForPC1];
    }
    dyadmino.cellForPC1 = cell;
    cell.myDyadmino = dyadmino;
    
      /// testing purposes
    [cell updatePCLabel];
    
    return YES;
    
  } else if (cell.myPC == dyadmino.pc2) {
    if (dyadmino.cellForPC2 && dyadmino.cellForPC2 != cell) { // remove dyadmino and its pc from previous cell
      [self removeDyadminoDataFromCell:dyadmino.cellForPC2];
    }
    dyadmino.cellForPC2 = cell;
    cell.myDyadmino = dyadmino;
    
      /// testing purposes
    [cell updatePCLabel];
    
    return YES;
  }
  
  return NO;
}

-(BOOL)removeDyadminoDataFromCell:(Cell *)cell {
  
  if (cell.myDyadmino.cellForPC1 == cell) {
    cell.myDyadmino.cellForPC1 = nil;
  }
  if (cell.myDyadmino.cellForPC2 == cell) {
    cell.myDyadmino.cellForPC2 = nil;
  }
  
  cell.myDyadmino = nil;
  cell.myPC = -1;
  
    // testing purposes
  [cell updatePCLabel];
  
  return YES;
}

-(NSArray *)topAndBottomCellsArrayForDyadmino:(Dyadmino *)dyadmino
                            andBottomHexCoord:(HexCoord)bottomHexCoord {

  HexCoord topHexCoord = [self retrieveTopHexCoordForBottomHexCoord:bottomHexCoord andOrientation:dyadmino.homeOrientation];
  
    // this will definitely get the cells
  Cell *topCell = [self cellWithHexCoord:topHexCoord];
  Cell *bottomCell = [self cellWithHexCoord:bottomHexCoord];
  
//  NSLog(@"top and bottom cells for dyadmino %@ placed on hexCoord %i, %i", dyadmino.name, bottomHexCoord.x, bottomHexCoord.y);
  
  NSMutableArray *tempCellsArray = [NSMutableArray new];
  if (topCell) {
    [tempCellsArray addObject:topCell];
  } else {
    [tempCellsArray addObject:[NSNull null]];
  }
  
  if (bottomCell) {
    [tempCellsArray addObject:bottomCell];
  } else {
    [tempCellsArray addObject:[NSNull null]];
  }
  
  NSArray *cellsArray = [NSArray arrayWithArray:tempCellsArray];
  return cellsArray;
}

#pragma mark - pivot guide methods

-(SKNode *)createPivotGuideNamed:(NSString *)name {
  
    // first four are prePivot, next is pivotRotate, next two are pivotAround
  float startAngle[9] = {212.5, 32.5, 212.5, 32.5, // prePivot around
                         332.5, 152.5, // prePivot rotate
                         300, // rotate
                         300, 300}; // around
  float endAngle[9] = {327.5, 147.5, 327.5, 147.5,
                       27.5, 207.5,
                       60, 60, 60};
  
  BOOL colourArray[9] = {NO, NO, NO, NO, YES, YES, YES, NO, NO};
  
  NSArray *colours = @[[self.delegate pivotColourForCurrentPlayerLight:YES], [self.delegate pivotColourForCurrentPlayerLight:NO]];
  
  CGFloat outerMin = kMaxDistanceForPivot + 5.f;
  CGFloat outerMax = kMaxDistanceForPivot + kMaxDistanceForPivot - kMinDistanceForPivot;
  
    // hard-coded values for second pivotAround guide, needs to change
  float minDistance[9] = {kMinDistanceForPivot, kMinDistanceForPivot, outerMin, outerMin, // prePivot around
                          kMinDistanceForPivot, kMinDistanceForPivot, // prePivot rotate
                          kMinDistanceForPivot, // rotate
                          kMinDistanceForPivot + kDyadminoFaceRadius, outerMin + kDyadminoFaceRadius}; // around
  
  float maxDistance[9] = {kMaxDistanceForPivot, kMaxDistanceForPivot, outerMax, outerMax, // prePivot around
                          kMaxDistanceForPivot, kMaxDistanceForPivot, // prePivot rotate
                          kMaxDistanceForPivot, // rotate
                          kMaxDistanceForPivot + kDyadminoFaceRadius, outerMax + kDyadminoFaceRadius}; // around
  
  SKNode *pivotGuide = [SKNode new];
  pivotGuide.hidden = YES;
  pivotGuide.name = name;
  pivotGuide.zPosition = kZPositionPivotGuide; // for now
  
    // this will have to change substantially...
  NSUInteger initialNumber;
  NSUInteger conditionalNumber;
  CGFloat pivotYOffset = 0.f;
  if ([pivotGuide.name isEqualToString:@"prePivotGuide"]) {
    initialNumber = 0;
    conditionalNumber = 6;
  } else if ([pivotGuide.name isEqualToString:@"pivotRotateGuide"]) {
    initialNumber = 6;
    conditionalNumber = 7;
  } else if ([pivotGuide.name isEqualToString:@"pivotAroundGuide"]) {
    initialNumber = 7;
    conditionalNumber = 8; // for now, leave out second, double-speed pivotAround guide
  } else {
    return nil;
  }
  
  for (NSUInteger i = initialNumber; i < conditionalNumber; i++) {
    if (i != 2 && i != 3) { // for now, leave out second, double-speed guide
      SKShapeNode *shapeNode = [SKShapeNode new];
      CGMutablePathRef shapePath = CGPathCreateMutable();
      
      CGFloat startAngleInRadians = [self getRadiansFromDegree:startAngle[i]];
      CGFloat endAngleInRadians = [self getRadiansFromDegree:endAngle[i]];
    
        // line out
      CGPathMoveToPoint(shapePath, NULL, maxDistance[i] * cosf(startAngleInRadians) * 0.5,
                        maxDistance[i] * sinf(startAngleInRadians) * 0.5);
      
      CGPathAddLineToPoint(shapePath, NULL, maxDistance[i] * cosf(startAngleInRadians),
                           maxDistance[i] * sinf(startAngleInRadians));
      
        // outer arc
      CGPathAddArc(shapePath, NULL, 0.f, 0.f + pivotYOffset, maxDistance[i], startAngleInRadians,
                   endAngleInRadians, NO);
        // line in
      CGPathAddLineToPoint(shapePath, NULL, minDistance[i] * cosf(endAngleInRadians),
                           minDistance[i] * sinf(endAngleInRadians));
        // inner arc
      CGPathAddArc(shapePath, NULL, 0.f, 0.f + pivotYOffset, minDistance[i], endAngleInRadians,
                   startAngleInRadians, YES);
        // line out
      CGPathAddLineToPoint(shapePath, NULL, maxDistance[i] * cosf(startAngleInRadians) * 0.5,
                           maxDistance[i] * sinf(startAngleInRadians) * 0.5);
      
      shapeNode.path = shapePath;
      CGPathRelease(shapePath);
      
      shapeNode.lineWidth = 0.05;
      shapeNode.glowWidth = 4.f;
      shapeNode.alpha = kPivotGuideAlpha;
      shapeNode.strokeColor = colours[colourArray[i]];
      shapeNode.fillColor = colours[colourArray[i]];
      [pivotGuide addChild:shapeNode];
    }
  }
  return pivotGuide;
}

-(void)handleUserWantsPivotGuides {
    // called before scene appears
  self.userWantsPivotGuides = [[NSUserDefaults standardUserDefaults] boolForKey:@"pivotGuide"];
}

-(void)updatePositionsOfPivotGuidesForDyadminoPosition:(CGPoint)dyadminoPosition {
    
  if (!self.prePivotGuide.hidden) {
    self.prePivotGuide.position = dyadminoPosition;
  }
  if (!self.pivotAroundGuide.hidden) {
    self.pivotAroundGuide.position = dyadminoPosition;
  }
  if (!self.pivotRotateGuide.hidden) {
    self.pivotRotateGuide.position = dyadminoPosition;
  }
}

-(void)showPivotGuide:(SKNode *)pivotGuide forDyadmino:(Dyadmino *)dyadmino {
  if (self.userWantsPivotGuides && !pivotGuide.parent && ![self.delegate actionSheetShown]) {
    pivotGuide.position = (pivotGuide == self.prePivotGuide || pivotGuide == self.pivotRotateGuide) ?
        dyadmino.position : dyadmino.pivotAroundPoint;
    
    CGFloat degree = (dyadmino.orientation) * -60.f;
    while (degree > 360.f) {
      degree -= 360.f;
    }

    pivotGuide.zRotation = [self getRadiansFromDegree:degree];
    
    [self addChild:pivotGuide];
    [self animatePivotGuide:pivotGuide toShow:YES completion:nil];
  }
}

-(void)animatePivotGuide:(SKNode *)pivotGuide toShow:(BOOL)toShow completion:(void(^)(void))completion {
  
  if (toShow && ![pivotGuide actionForKey:@"pivotGuideScaleUp"]) {
    [pivotGuide removeActionForKey:@"pivotGuideScaleDown"];
    [pivotGuide setScale:0.f];
    pivotGuide.hidden = NO;
    SKAction *scaleExcessUp = [SKAction scaleTo:kDyadminoHoverResizeFactor duration:.105f];
    scaleExcessUp.timingMode = SKActionTimingEaseOut;
    SKAction *scaleDown = [SKAction scaleTo:1.f duration:0.035f];
    scaleDown.timingMode = SKActionTimingEaseIn;
    SKAction *completionAction = [SKAction runBlock:completion];
    SKAction *sequence = [SKAction sequence:@[scaleExcessUp, scaleDown, completionAction]];
    [pivotGuide runAction:sequence withKey:@"pivotGuideScaleUp"];
    
    pivotGuide.alpha = 0.f;
    [pivotGuide removeActionForKey:@"pivotGuideFadeOut"];
    SKAction *fadeInAction = [SKAction fadeInWithDuration:.1f];
    [pivotGuide runAction:fadeInAction withKey:@"pivotGuideFadeIn"];
    
  } else if (!toShow && ![pivotGuide actionForKey:@"pivotGuideScaleDown"]) {
    [pivotGuide removeActionForKey:@"pivotGuideScaleUp"];
    SKAction *scaleDown = [SKAction scaleTo:0.f duration:0.14f];
    scaleDown.timingMode = SKActionTimingEaseIn;
    SKAction *hideAction = [SKAction runBlock:^{
      pivotGuide.hidden = YES;
    }];
    SKAction *completionAction = [SKAction runBlock:completion];
    SKAction *sequence = [SKAction sequence:@[scaleDown, completionAction, hideAction]];
    [pivotGuide runAction:sequence withKey:@"pivotGuideScaleDown"];
    
    pivotGuide.alpha = 1.f;
    [pivotGuide removeActionForKey:@"pivotGuideFadeIn"];
    SKAction *fadeOutAction = [SKAction fadeOutWithDuration:.1f];
    [pivotGuide runAction:fadeOutAction withKey:@"pivotGuideFadeOut"];
  }

}

-(void)hidePivotGuide:(SKNode *)pivotGuide {
  if (self.userWantsPivotGuides && pivotGuide.parent) {
    [self animatePivotGuide:pivotGuide toShow:NO completion:^{
      [pivotGuide removeFromParent];
    }];
  }
}

-(void)hidePivotGuideAndShowPrePivotGuideForDyadmino:(Dyadmino *)dyadmino {
  [self showPivotGuide:self.prePivotGuide forDyadmino:dyadmino];
  [self hidePivotGuide:self.pivotRotateGuide];
  [self hidePivotGuide:self.pivotAroundGuide];
}

-(void)hideAllPivotGuides {
  [self hidePivotGuide:self.prePivotGuide];
  [self hidePivotGuide:self.pivotAroundGuide];
  [self hidePivotGuide:self.pivotRotateGuide];
}

#pragma mark - pivot helper methods

-(PivotOnPC)determinePivotOnPCForDyadmino:(Dyadmino *)dyadmino {
  
  CGFloat originOffset = dyadmino.orientation * 60;
  CGFloat offsetAngle = dyadmino.initialPivotAngle + originOffset;
  while (offsetAngle > 360) {
    offsetAngle -= 360;
  }
  
    // this is the only place where prePivotGuide is hidden
    // and pivotAround or pivotRotate guides are then made visible
  [self hideAllPivotGuides];
  
  if (offsetAngle > 210 && offsetAngle <= 330) {
    [self showPivotGuide:self.pivotAroundGuide forDyadmino:dyadmino];
    self.pivotOnPC = kPivotOnPC1;
  } else if (offsetAngle >= 30 && offsetAngle <= 150) {
    [self showPivotGuide:self.pivotAroundGuide forDyadmino:dyadmino];
    self.pivotOnPC = kPivotOnPC2;
  } else {
    [self showPivotGuide:self.pivotRotateGuide forDyadmino:dyadmino];
    self.pivotOnPC = kPivotCentre;
  }
  return self.pivotOnPC;
}

-(void)rotatePivotGuidesBasedOnPivotAroundPoint:(CGPoint)pivotAroundPoint andTrueAngle:(CGFloat)trueAngle {
  
  self.pivotAroundGuide.position = pivotAroundPoint;
  self.pivotRotateGuide.position = pivotAroundPoint;
  self.pivotAroundGuide.zRotation = [self getRadiansFromDegree:trueAngle];
  self.pivotRotateGuide.zRotation = [self getRadiansFromDegree:trueAngle];
}

#pragma mark - position query methods

-(HexCoord)findClosestHexCoordForDyadminoPosition:(CGPoint)dyadminoPosition
                                   andOrientation:(DyadminoOrientation)orientation {
  
    // find closest hex coord for hex origin, and get the snap point for that orientation
  HexCoord homeHexCoord = [self hexCoordFromX:(NSInteger)self.hexOrigin.dx andY:(NSInteger)self.hexOrigin.dy];
  
  CGPoint homeSnapPosition = [Cell snapPositionForHexCoord:homeHexCoord
                                               orientation:orientation
                                                 andResize:self.zoomedOut
                                            givenHexOrigin:self.hexOrigin];
  CGFloat degrees = [self findAngleInDegreesFromThisPoint:homeSnapPosition toThisPoint:dyadminoPosition];
  
  while (fabsf([self getDistanceFromThisPoint:homeSnapPosition toThisPoint:dyadminoPosition]) > kDyadminoFaceDiameter) {
    
    if (degrees >= 0 && degrees <= 60) {
      homeHexCoord = [self hexCoordFromX:homeHexCoord.x - 1 andY:homeHexCoord.y];
      
    } else if (degrees > 60 && degrees <= 120) {
      homeHexCoord = [self hexCoordFromX:homeHexCoord.x andY:homeHexCoord.y - 1];
      
    } else if (degrees > 120 && degrees <= 180) {
      homeHexCoord = [self hexCoordFromX:homeHexCoord.x + 1 andY:homeHexCoord.y - 1];
      
    } else if (degrees > 180 && degrees <= 240) {
      homeHexCoord = [self hexCoordFromX:homeHexCoord.x + 1 andY:homeHexCoord.y];
      
    } else if (degrees > 240 && degrees <= 300) {
      homeHexCoord = [self hexCoordFromX:homeHexCoord.x andY:homeHexCoord.y + 1];
      
    } else if (degrees > 300 && degrees <= 360) {
      homeHexCoord = [self hexCoordFromX:homeHexCoord.x - 1 andY:homeHexCoord.y + 1];
    }
    
    homeSnapPosition = [Cell snapPositionForHexCoord:homeHexCoord
                                         orientation:orientation
                                           andResize:self.zoomedOut
                                      givenHexOrigin:self.hexOrigin];
    
    degrees = [self findAngleInDegreesFromThisPoint:homeSnapPosition toThisPoint:dyadminoPosition];
  }
  
  HexCoord hexCoordsToCheck[7] = {homeHexCoord,
    [self hexCoordFromX:homeHexCoord.x - 1 andY:homeHexCoord.y],
    [self hexCoordFromX:homeHexCoord.x andY:homeHexCoord.y - 1],
    [self hexCoordFromX:homeHexCoord.x + 1 andY:homeHexCoord.y - 1],
    [self hexCoordFromX:homeHexCoord.x + 1 andY:homeHexCoord.y],
    [self hexCoordFromX:homeHexCoord.x andY:homeHexCoord.y + 1],
    [self hexCoordFromX:homeHexCoord.x - 1 andY:homeHexCoord.y + 1]};
  
  NSUInteger minDistanceIndex;
  CGFloat minDistance = CGFLOAT_MAX;
  for (int i = 0; i < 7; i++) {
    HexCoord hexCoordToCheck = hexCoordsToCheck[i];
    CGPoint snapPointToCheck = [Cell snapPositionForHexCoord:hexCoordToCheck
                                                 orientation:orientation
                                                   andResize:self.zoomedOut
                                              givenHexOrigin:self.hexOrigin];
    CGFloat thisDistance = fabsf([self getDistanceFromThisPoint:snapPointToCheck toThisPoint:dyadminoPosition]);
    
    if (thisDistance < minDistance) {
      minDistance = thisDistance;
      minDistanceIndex = i;
    }
  }
  
  HexCoord returnHexCoord = hexCoordsToCheck[minDistanceIndex];
//  NSLog(@"closest hex coord is %li, %li", (long)returnHexCoord.x, (long)returnHexCoord.y);
  return returnHexCoord;
}

#pragma mark - distance helper methods

-(CGPoint)getOffsetFromPoint:(CGPoint)point {
  return [self subtractFromThisPoint:point thisPoint:self.position];
}

-(CGPoint)getOffsetForPoint:(CGPoint)point withTouchOffset:(CGPoint)touchOffset {
  CGPoint offsetPoint = [self subtractFromThisPoint:point thisPoint:touchOffset];
  return [self subtractFromThisPoint:offsetPoint thisPoint:self.position];
}

-(CGFloat)cellsInHorizontalRange {
  CGFloat factor = self.zoomedOut ? kZoomResizeFactor : 1.f;
  return (self.origin.x / (kDyadminoFaceAverageWideDiameter * factor));
}

-(CGFloat)cellsInVerticalRange {
  CGFloat factor = self.zoomedOut ? kZoomResizeFactor : 1.f;
  return ((self.origin.y - kRackHeight) / (kDyadminoFaceDiameter * factor));
}

#pragma mark - dyadmino helper methods

-(NSSet *)boardDyadminoes:(NSSet *)boardDyadminoes minusDyadmino:(Dyadmino *)minusDyadmino {
  
  NSSet *finalBoardDyadminoes;
  
  if (minusDyadmino) {
    NSMutableSet *tempFinalBoardDyadminoes = [NSMutableSet setWithSet:boardDyadminoes];
    [tempFinalBoardDyadminoes removeObject:minusDyadmino];
    finalBoardDyadminoes = [NSSet setWithSet:tempFinalBoardDyadminoes];
    
  } else {
    finalBoardDyadminoes = boardDyadminoes;
  }
  
  return finalBoardDyadminoes;
}

@end

/*
 
 these might be used for replay mode
 #pragma mark - background image methods
 
 -(void)colourBackgroundForReplay {
 self.backgroundNodeZoomedIn.color = kGold;
 self.backgroundNodeZoomedOut.color = kGold;
 }
 
 -(void)colourBackgroundForPnP {
 self.backgroundNodeZoomedIn.color = kSkyBlue;
 self.backgroundNodeZoomedOut.color = kSkyBlue;
 }
 
 -(void)colourBackgroundForNormalPlay {
 self.backgroundNodeZoomedIn.color = kBackgroundBoardColour;
 self.backgroundNodeZoomedOut.color = kBackgroundBoardColour;
 }
 
 -(void)showBackgroundNode:(SKSpriteNode *)backgroundNode {
 backgroundNode.hidden = NO;
 if (!backgroundNode.parent) {
 [self addChild:backgroundNode];
 }
 }
 
 -(void)hideBackgroundNode:(SKSpriteNode *)backgroundNode {
 backgroundNode.hidden = YES;
 if (backgroundNode.parent) {
 [backgroundNode removeFromParent];
 }
 }
 
 -(void)zoomInBackgroundImage {
 [self showBackgroundNode:self.backgroundNodeZoomedIn];
 [self hideBackgroundNode:self.backgroundNodeZoomedOut];
 }
 
 -(void)zoomOutBackgroundImage {
 [self showBackgroundNode:self.backgroundNodeZoomedOut];
 [self hideBackgroundNode:self.backgroundNodeZoomedIn];
 }
 
 -(void)initLoadBackgroundNodes {
 UIImage *backgroundImage = [UIImage imageNamed:@"BachMassBackgroundCropped"];
 CGImageRef backgroundCGImage = backgroundImage.CGImage;
 
 CGRect textureSizeZoomedIn = CGRectMake(self.position.x, self.position.y, backgroundImage.size.width, backgroundImage.size.height);
 UIGraphicsBeginImageContextWithOptions(self.size, YES, 2.f); // use WithOptions to set scale for retina display
 CGContextRef contextZoomedIn = UIGraphicsGetCurrentContext();
 // Core Graphics coordinates are upside down from Sprite Kit's
 CGContextScaleCTM(contextZoomedIn, 1.0, -1.0);
 CGContextDrawTiledImage(contextZoomedIn, textureSizeZoomedIn, backgroundCGImage);
 UIImage *tiledBackgroundZoomedIn = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 
 SKTexture *backgroundTextureZoomedIn = [SKTexture textureWithCGImage:tiledBackgroundZoomedIn.CGImage];
 self.backgroundNodeZoomedIn = [[SKSpriteNode alloc] initWithTexture:backgroundTextureZoomedIn];
 self.backgroundNodeZoomedIn.color = kBackgroundBoardColour;
 self.backgroundNodeZoomedIn.colorBlendFactor = 0.5f;
 self.backgroundNodeZoomedIn.alpha = kBackgroundFullAlpha;
 self.backgroundNodeZoomedIn.texture = backgroundTextureZoomedIn;
 self.backgroundNodeZoomedIn.zPosition = kZPositionBackgroundNode;
 
 CGRect textureSizeZoomedOut = CGRectMake(self.position.x + self.size.width / 2, self.position.y - self.size.height / 2, backgroundImage.size.width, backgroundImage.size.height);
 UIGraphicsBeginImageContextWithOptions(self.size, YES, 2.f); // use WithOptions to set scale for retina display
 CGContextRef contextZoomedOut = UIGraphicsGetCurrentContext();
 // Core Graphics coordinates are upside down from Sprite Kit's
 CGContextScaleCTM(contextZoomedOut, 0.5, -0.5);
 CGContextDrawTiledImage(contextZoomedOut, textureSizeZoomedOut, backgroundCGImage);
 UIImage *tiledBackgroundZoomedOut = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 
 SKTexture *backgroundTextureZoomedOut = [SKTexture textureWithCGImage:tiledBackgroundZoomedOut.CGImage];
 self.backgroundNodeZoomedOut = [[SKSpriteNode alloc] initWithTexture:backgroundTextureZoomedOut];
 self.backgroundNodeZoomedOut.color = kBackgroundBoardColour;
 self.backgroundNodeZoomedOut.colorBlendFactor = 0.5f;
 self.backgroundNodeZoomedOut.alpha = kBackgroundFullAlpha;
 self.backgroundNodeZoomedOut.texture = backgroundTextureZoomedOut;
 self.backgroundNodeZoomedOut.zPosition = kZPositionBackgroundNode;
 
 // zoom background node is always there
 [self zoomInBackgroundImage];
 }
 
 */
