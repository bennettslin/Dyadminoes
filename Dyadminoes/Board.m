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
  CGVector _hexCurrentOrigin;
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

    self.allCells = [NSMutableSet new];
      // not necessary to instantiate column of rows of cells, as it's recreated each time it's recalibrated
    
      // create new cells from get-go
    self.dequeuedCells = [NSMutableSet new];
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

-(void)instantiateDequeuedCells {

  NSUInteger times = 182; // number of initial cells with one dyadmino on board
  for (int i = 0; i < times; i++) {
    Cell *cell = [[Cell alloc] initWithTexture:self.cellTexture
                                   andHexCoord:[self hexCoordFromX:NSIntegerMax andY:NSIntegerMax]
                                  andHexOrigin:self.hexOrigin
                                     andResize:self.zoomedOut];
    
    [self.dequeuedCells addObject:cell];
  }
}

-(void)resetForNewMatch {
  
  NSSet *tempAllCells = [NSSet setWithSet:self.allCells];
  for (Cell *cell in tempAllCells) {
    [self ignoreCell:cell];
  }
  
//  [self ignoreAllCells];
  
  self.columnOfRowsOfAllCells = nil;

  self.zoomedOut = NO;
  self.zoomInBoardHomePositionDifference = CGPointZero;

//  [self zoomInBackgroundImage];
  
    // FIXME: this doesn't seem to be necessary
  [self removeAllActions];
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
  CGPoint newPoint = CGPointMake(self.origin.x + (self.hexOrigin.dx - _hexCurrentOrigin.dx) * kDyadminoFaceWideDiameter * factor,
                                 self.origin.y + (self.hexOrigin.dy - _hexCurrentOrigin.dy) * kDyadminoFaceDiameter * factor);
  
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
  CGFloat cellsTopmost = CGFLOAT_MIN;
  CGFloat cellsRightmost = CGFLOAT_MIN;
  CGFloat cellsBottommost = CGFLOAT_MAX;
  CGFloat cellsLeftmost = CGFLOAT_MAX;
  
  NSInteger cellsTopmostInteger = NSIntegerMin;
  NSInteger cellsRightmostInteger = NSIntegerMin;
  NSInteger cellsBottommostInteger = NSIntegerMax;
  NSInteger cellsLeftmostInteger = NSIntegerMax;
  
  for (Dyadmino *dyadmino in boardDyadminoes) {

    HexCoord bottomHexCoord = [self hexCoordFromX:dyadmino.tempHexCoord.x andY:dyadmino.tempHexCoord.y];
    HexCoord topHexCoord = [self retrieveTopHexCoordForBottomHexCoord:bottomHexCoord andOrientation:dyadmino.orientation];
    
    HexCoord hexCoord[2] = {bottomHexCoord, topHexCoord};
    
    for (int i = 0; i < 2; i++) {
      NSInteger xHex = hexCoord[i].x;
      NSInteger yHex = hexCoord[i].y;
      
        // check x span - this one is easy enough
      if (xHex > cellsRightmost) {
        cellsRightmost = xHex;
      }
      
      if (xHex < cellsLeftmost) {
        cellsLeftmost = xHex;
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
  
  NSLog(@"bounds is top %.1f, right %.1f, bottom %.1f, left %.1f", self.cellsTop, self.cellsRight, self.cellsBottom, self.cellsLeft);
  NSLog(@"raw bounds floats is top %.1f, right %.1f, bottom %.1f, left %.1f", cellsTopmost, cellsRightmost, cellsBottommost, cellsLeftmost);
  NSLog(@"raw bounds integers is top %i, right %i, bottom %i, left %i", (NSInteger)cellsTopmost, (NSInteger)cellsRightmost, (NSInteger)cellsBottommost, (NSInteger)cellsLeftmost);
  NSLog(@"cell bounds integers is top %i, right %i, bottom %i, left %i", self.cellsTopInteger, self.cellsRightInteger, self.cellsBottomInteger, self.cellsLeftInteger);
  
  CGVector returnVector = CGVectorMake(((CGFloat)(self.cellsRight - self.cellsLeft) / 2) + self.cellsLeft,
                                       ((CGFloat)(self.cellsTop - self.cellsBottom) / 2) + self.cellsBottom);
  
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

-(BOOL)layoutAndColourBoardCellsAndSnapPointsOfDyadminoes:(NSSet *)boardDyadminoes
                                            minusDyadmino:(Dyadmino *)minusDyadmino
                                             updateBounds:(BOOL)updateBounds {
  
//  NSLog(@"layout and colour board cells");
  
//  NSMutableArray *tempArray = [self arrayOfCellsFromBoardDyadminoes:boardDyadminoes
//                                                      minusDyadmino:minusDyadmino];
//  NSLog(@"temp array is\n%@", tempArray);
//  

  NSSet *finalBoardDyadminoes = [self boardDyadminoes:boardDyadminoes minusDyadmino:minusDyadmino];
  
    // regular hex origin is only set once per scene load, but zoom hex origin is set every time
  if (!_hexOriginSet) {
    self.hexOrigin = [self determineOutermostCellsBasedOnDyadminoes:finalBoardDyadminoes];
    _hexCurrentOrigin = self.hexOrigin;
    _hexOriginSet = YES;
  } else {
    _hexCurrentOrigin = [self determineOutermostCellsBasedOnDyadminoes:finalBoardDyadminoes];
  }
  
  NSLog(@"hex current is %.2f, %.2f", _hexCurrentOrigin.dx, _hexCurrentOrigin.dy);
  
  
  NSMutableSet *tempAddedCellSet = [NSMutableSet new];
  NSMutableSet *tempRemovedCellSet = [NSMutableSet setWithSet:self.allCells];

    // reset all cells
  for (Cell *cell in self.allCells) {
    [cell resetForReuse];
    [cell renderColour];
  }
  
//  void(^block)(Cell *) = ^void(Cell *cell) {
//    [cell resetForReuse];
//    [cell renderColour];
//  };
//  [self performBlockOnAllCells:block];
  
  for (Dyadmino *dyadmino in finalBoardDyadminoes) {

    HexCoord bottomHexCoord = [self hexCoordFromX:dyadmino.tempHexCoord.x andY:dyadmino.tempHexCoord.y];
    HexCoord topHexCoord = [self retrieveTopHexCoordForBottomHexCoord:bottomHexCoord andOrientation:dyadmino.orientation];
    
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
            Cell *addedCell = [self acknowledgeOrAddCellWithHexCoord:[self hexCoordFromX:newX andY:newY]];
            [tempAddedCellSet addObject:addedCell];
            [tempRemovedCellSet removeObject:addedCell];

            NSUInteger distance = [self distanceGivenHexXDifference:x andHexYDifference:y];
            if (dyadmino != minusDyadmino) {
              [addedCell addColourValueForPC:pc atDistance:distance];
            }
          }
        }
      }
    }
  }
  
    // dequeue all removed cells
  for (Cell *cell in tempRemovedCellSet) {
    [self ignoreCell:cell];
  }
  
    // colour all placed cells
  for (Cell *cell in tempAddedCellSet) {
    [cell renderColour];
  }
  
  self.allCells = tempAddedCellSet;
  
  
    // bounds is not updated with removal by touch, only with removal by cancel
  if (updateBounds) {
    [self determineOutermostCellsBasedOnDyadminoes:finalBoardDyadminoes];
    [self determineBoardPositionBounds];
  }
  return YES;
}

-(Cell *)getCellWithHexCoord:(HexCoord)hexCoord {
  for (Cell *cell in self.allCells) {
    if ([cell isKindOfClass:[Cell class]]) {
      if (cell.hexCoord.x == hexCoord.x && cell.hexCoord.y == hexCoord.y) {
        return cell;
      }
    }
  }
  return nil;
}

-(Cell *)acknowledgeOrAddCellWithHexCoord:(HexCoord)hexCoord {
    // first check to see if cell already exists
  Cell *cell = [self getCellWithHexCoord:hexCoord];
  
    // if cell does not exist, create and add it
  if (!cell) {
    Cell *poppedCell = [self popDequeuedCell];
    if (poppedCell) {
      cell = poppedCell;
      [cell reuseCellWithHexCoord:hexCoord andHexOrigin:self.hexOrigin forResize:self.zoomedOut];
    } else {
      cell = [[Cell alloc] initWithTexture:self.cellTexture
                               andHexCoord:hexCoord
                              andHexOrigin:self.hexOrigin
                                 andResize:self.zoomedOut];
    }
    
    cell.cellNode.parent ? nil : [self addChild:cell.cellNode];

    if (![self.allCells containsObject:cell]) {
      [self.allCells addObject:cell];
    }
    
//    [self addCellToColumnOfRowsOfCells:cell];
  }
  return cell;
}

-(void)ignoreCellWithHexCoord:(HexCoord)hexCoord {
  Cell *cell = [self getCellWithHexCoord:hexCoord];
  [self ignoreCell:cell];
}

-(void)ignoreCell:(Cell *)cell {
  if (cell) {
    
    cell.cellNode ? [cell.cellNode removeFromParent] : nil;
    
    if ([self.allCells containsObject:cell]) {
      [self.allCells removeObject:cell];
    }
    
//    [self removeCellFromColumnOfRowsOfCells:cell];
    [self pushDequeuedCell:cell];
  }
}

-(void)ignoreAllCells {
    // block to ignore each cell
  __weak typeof(self) weakSelf = self;
  void(^block)(Cell *) = ^void(Cell *cell) {
    cell.cellNode ? [cell.cellNode removeFromParent] : nil;
    [weakSelf pushDequeuedCell:cell];
  };
  
  [self performBlockOnAllCells:block];
  self.columnOfRowsOfAllCells = nil;
}

-(void)performBlockOnAllCells:(void(^)(Cell *))block {
  
  for (int j = self.cellsBottomInteger; j <= self.cellsTopInteger; j++) {
    NSMutableArray *tempRowArray = self.columnOfRowsOfAllCells[j];
    
    for (int i = self.cellsLeftInteger; i <= self.cellsRightInteger; i++) {
      id object = tempRowArray[i];
      
      if ([object isKindOfClass:Cell.class]) {
        Cell *cell = (Cell *)object;
        block(cell);
      }
    }
  }
}

-(void)pushDequeuedCell:(Cell *)cell {
  [self.dequeuedCells containsObject:cell] ? nil : [self.dequeuedCells addObject:cell];
}

-(Cell *)popDequeuedCell {
  Cell *cell = [self.dequeuedCells anyObject];
  [cell isKindOfClass:Cell.class] ? [self.dequeuedCells removeObject:cell] : nil;
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
  
  CGSize cellSize = [Cell cellSizeForResize:self.zoomedOut];
  
  for (Cell *cell in self.allCells) {
    
    CGPoint tempNewPosition = [self addToThisPoint:cell.cellNode.position thisPoint:differenceInPosition];
    
    if (self.zoomedOut) {
      tempNewPosition = [self addToThisPoint:tempNewPosition thisPoint:zoomOutBoardHomePositionDifference];
    } else {
      tempNewPosition = [self addToThisPoint:tempNewPosition thisPoint:self.zoomInBoardHomePositionDifference];
    }
    
    cell.cellNode.position = tempNewPosition;
    [cell animateResizeAndRepositionOfCell:self.zoomedOut withHexOrigin:self.hexOrigin andSize:cellSize];
  }
  
//  __weak typeof(self) weakSelf = self;
//  void(^block)(Cell *) = ^void(Cell *cell) {
//    CGPoint tempNewPosition = [weakSelf addToThisPoint:cell.cellNode.position thisPoint:differenceInPosition];
//    
//    if (weakSelf.zoomedOut) {
//      tempNewPosition = [self addToThisPoint:tempNewPosition thisPoint:zoomOutBoardHomePositionDifference];
//    } else {
//      tempNewPosition = [self addToThisPoint:tempNewPosition thisPoint:weakSelf.zoomInBoardHomePositionDifference];
//    }
//    
//    cell.cellNode.position = tempNewPosition;
//    [cell animateResizeAndRepositionOfCell:weakSelf.zoomedOut withHexOrigin:weakSelf.hexOrigin andSize:cellSize];
//  };
//  [self performBlockOnAllCells:block];
  
  return differenceInPosition;
    //  self.backgroundNodeZoomedIn.position = [self subtractFromThisPoint:self.origin thisPoint:self.position];
    //  self.backgroundNodeZoomedOut.position = [self subtractFromThisPoint:self.origin thisPoint:self.position];
}

#pragma mark - cell and data dyadmino methods

-(void)updateCellsForDyadmino:(Dyadmino *)dyadmino placedOnBottomHexCoord:(HexCoord)bottomHexCoord {
  
    // this assumes dyadmino is properly oriented for this boardNode
  NSArray *cells = [self topAndBottomCellsArrayForDyadmino:dyadmino
                                         andBottomHexCoord:bottomHexCoord];
  
  NSInteger pcs[2] = {dyadmino.pc1, dyadmino.pc2};
  
  for (int i = 0; i < cells.count; i++) {
    Cell *cell = cells[i];
    
      // only assign if cell doesn't have a dyadmino recorded
    if (!cell.myDyadmino) {
      
      cell.myPC = (dyadmino.orientation <= kPC1atTwoOClock || dyadmino.orientation >= kPC1atTenOClock) ?
          pcs[i] : pcs[(i + 1) % 2];
      
        // ensures there's only one cell for each dyadmino pc, and vice versa
      [self mapOneCell:cell toOnePCForDyadmino:dyadmino];
    }
  }
}

-(void)updateCellsForDyadmino:(Dyadmino *)dyadmino removedFromBottomHexCoord:(HexCoord)bottomHexCoord {

  NSArray *cells = [self topAndBottomCellsArrayForDyadmino:dyadmino
                                         andBottomHexCoord:bottomHexCoord];
  
  for (int i = 0; i < cells.count; i++) {
    Cell *cell = cells[i];
    
      // only remove if cell dyadmino is dyadmino
    if (cell.myDyadmino == dyadmino) {
      [self removeDyadminoDataFromCell:cell];
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

  HexCoord topHexCoord = [self retrieveTopHexCoordForBottomHexCoord:bottomHexCoord andOrientation:dyadmino.orientation];
  
    // this will definitely get the cells
  Cell *topCell = [self acknowledgeOrAddCellWithHexCoord:topHexCoord];
  Cell *bottomCell = [self acknowledgeOrAddCellWithHexCoord:bottomHexCoord];
  
  NSMutableArray *tempCellsArray = [NSMutableArray new];
  if (topCell) {
    [tempCellsArray addObject:topCell];
  }
  
  if (bottomCell) {
    [tempCellsArray addObject:bottomCell];
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
  NSLog(@"closest hex coord is %i, %i", returnHexCoord.x, returnHexCoord.y);
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

#pragma mark - column of rows of all cells methods

-(BOOL)recalibrateColumnOfRowsOfAllCells {
  
  NSMutableArray *tempColumnArray = [NSMutableArray new];
  for (int j = self.cellsBottomInteger; j <= self.cellsTopInteger; j++) {
    
    NSMutableArray *tempRowArray = [NSMutableArray new];
    for (int i = self.cellsLeftInteger; i <= self.cellsRightInteger; i++) {
      
        // add cell if there is a cell, otherwise add null
      Cell *addedCell = [self getCellWithHexCoord:[self hexCoordFromX:i andY:j]];
      [tempRowArray addObject:(addedCell ? addedCell : [NSNull null])];
    }
    
    [tempColumnArray addObject:tempRowArray];
  }
  
  self.columnOfRowsOfAllCells = tempColumnArray;
  
    // check that array of arrays has right count
  NSArray *arbitraryRow = [self.columnOfRowsOfAllCells lastObject];
  return (self.columnOfRowsOfAllCells.count == self.cellsTopInteger - self.cellsBottomInteger + 1) &&
  (arbitraryRow.count == self.cellsRightInteger - self.cellsLeftInteger + 1);
}

-(Cell *)cellWithHexCoord:(HexCoord)hexCoord {
  NSInteger xIndex = hexCoord.x - self.cellsLeftInteger;
  NSInteger yIndex = hexCoord.y - self.cellsBottomInteger;
  
  if (yIndex < self.columnOfRowsOfAllCells.count) {
    NSMutableArray *rowArray = self.columnOfRowsOfAllCells[yIndex];
    
    if (xIndex < rowArray.count) {
      id object = rowArray[xIndex];
      if ([object isKindOfClass:Cell.class]) {
        return object;
      }
    }
  }
  
  return nil;
}

-(BOOL)addCellToColumnOfRowsOfCells:(Cell *)cell {
  NSInteger xIndex = cell.hexCoord.x - self.cellsLeftInteger;
  NSInteger yIndex = cell.hexCoord.y - self.cellsBottomInteger;
  
  NSMutableArray *rowArray = self.columnOfRowsOfAllCells[yIndex];
  
  if (rowArray[xIndex] == [NSNull null]) {
    [rowArray replaceObjectAtIndex:xIndex withObject:cell];
    return YES;
    
      // do not add if column of rows already contains cell
  } else {
    return NO;
  }
}

-(BOOL)removeCellFromColumnOfRowsOfCells:(Cell *)cell {
  
  NSInteger xIndex = cell.hexCoord.x - self.cellsLeftInteger;
  NSInteger yIndex = cell.hexCoord.y - self.cellsBottomInteger;
  NSMutableArray *rowArray = self.columnOfRowsOfAllCells[yIndex];
  
  if (rowArray[xIndex] == cell) {
    [rowArray replaceObjectAtIndex:xIndex withObject:[NSNull null]];
    return YES;
    
      // do not remove if column of rows does not contain cell
  } else {
    return NO;
  }
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
