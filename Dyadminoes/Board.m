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
#import "Dyadmino.h"
#import "Face.h"

#define kCellColourMultiplier .005f
#define kBackgroundFullAlpha 0.5f

@interface Board () <BoardCellDelegate>

  /// these are the limits in terms of number of cells
@property (nonatomic) CGFloat cellsTop;
@property (nonatomic) CGFloat cellsRight;
@property (nonatomic) CGFloat cellsBottom;
@property (nonatomic) CGFloat cellsLeft;

@property (strong, nonatomic) NSMutableSet *dequeuedCells;
@property (strong, nonatomic) SKTexture *cellTexture;
@property (nonatomic) BOOL userWantsPivotGuides;

@end

@implementation Board {
  
  CGFloat _cellsInVertRange;
  CGFloat _cellsInHorzRange;
  BOOL _cellsTopXIsEven;
  BOOL _cellsBottomXIsEven;
  BOOL _hexOriginSet;
  CGVector _hexCurrent;
  BOOL _cellsTopNeedsBuffer;
  BOOL _cellsBottomNeedsBuffer;
  
  CGFloat _oldCellsTop;
  CGFloat _oldCellsBottom;
  CGFloat _oldCellsLeft;
  CGFloat _oldCellsRight;  
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

      // instantiate node and cell arrays to be searched
    self.snapPointsTwelveOClock = [NSMutableSet new];
    self.snapPointsTwoOClock = [NSMutableSet new];
    self.snapPointsTenOClock = [NSMutableSet new];
    self.allCells = [NSMutableSet new];
    
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
                                   andHexCoord:[self hexCoordFromX:0 andY:0]
                                  andHexOrigin:self.hexOrigin
                                     andResize:self.zoomedOut
                                   andDelegate:self];
    
    [self.dequeuedCells addObject:cell];
  }
}

-(void)resetForNewMatch {
  
  NSSet *tempAllCells = [NSSet setWithSet:self.allCells];
  
  for (Cell *cell in tempAllCells) {
    [self ignoreCell:cell];
  }
  
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
  CGPoint newPoint = CGPointMake(self.origin.x + (self.hexOrigin.dx - _hexCurrent.dx) * kDyadminoFaceWideDiameter * factor,
                                 self.origin.y + (self.hexOrigin.dy - _hexCurrent.dy) * kDyadminoFaceDiameter * factor);
  
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
  
    // floats to allow for in-between values for y-coordinates
  CGFloat cellsTopmost = -CGFLOAT_MAX;
  CGFloat cellsRightmost = -CGFLOAT_MAX;
  CGFloat cellsBottommost = CGFLOAT_MAX;
  CGFloat cellsLeftmost = CGFLOAT_MAX;
  
  for (Dyadmino *dyadmino in boardDyadminoes) {

    HexCoord hexCoord1 = [self hexCoordFromX:dyadmino.myHexCoord.x andY:dyadmino.myHexCoord.y];
    HexCoord hexCoord2 = [self getHexCoordOfOtherCellGivenDyadmino:dyadmino andBoardNode:nil];
  
    HexCoord hexCoord[2] = {hexCoord1, hexCoord2};
    
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
        _cellsTopXIsEven = (ABS(xHex) % 2 == 0) ? YES : NO; // pretty sure not needed, but keep for my assurance for the time being
      }
      
      CGFloat trialBottommost = ((CGFloat)xHex + (2 * yHex)) / 2.f;
      if (trialBottommost < cellsBottommost) {
        cellsBottommost = trialBottommost;
        _cellsBottomXIsEven = (ABS(xHex) % 2 == 0) ? YES : NO; // ditto
      }
    }
  }

  CGFloat factor = self.zoomedOut ? kZoomResizeFactor : 1.f;
  
  _cellsInVertRange = ((self.origin.y - kRackHeight) / (kDyadminoFaceDiameter * factor));
  _cellsInHorzRange = (self.origin.x / (kDyadminoFaceAverageWideDiameter * factor));

      // buffer cells beyond outermost dyadmino (keep tweaking these numbers)
  CGFloat extraYCells = (((_cellsInVertRange * 2) - (cellsTopmost - cellsBottommost + 1)) / 2.f) + 1.5f;
  if (extraYCells < 3.5) {
    extraYCells = 3.5;
  }
  
  CGFloat extraXCells = (((_cellsInHorzRange * 2) - (cellsRightmost - cellsLeftmost + 1)) / 2.f) + 2.f;
  if (extraXCells < 4) {
    extraXCells = 4;
  }
  
  _oldCellsTop = self.cellsTop;
  _oldCellsBottom = self.cellsBottom;
  _oldCellsRight = self.cellsRight;
  _oldCellsLeft = self.cellsLeft;
  
  self.cellsTop = cellsTopmost + extraYCells;
  self.cellsRight = cellsRightmost + extraXCells;
  self.cellsBottom = cellsBottommost - extraYCells - 1.f;
  self.cellsLeft = cellsLeftmost - extraXCells;

  CGVector returnVector = CGVectorMake(((CGFloat)(self.cellsRight - self.cellsLeft) / 2) + self.cellsLeft, ((CGFloat)(self.cellsTop - self.cellsBottom) / 2) + self.cellsBottom);
  
  return returnVector;
}

-(void)determineBoardPositionBounds {
    // this should get called after every method that adds cells or removes them
  
  CGFloat factor = self.zoomedOut ? kZoomResizeFactor : 1.f;
  self.lowestYPos = self.origin.y - (self.cellsTop - _cellsInVertRange - self.hexOrigin.dy) * kDyadminoFaceDiameter * factor;
  self.lowestXPos = self.origin.x - (self.cellsRight - _cellsInHorzRange - self.hexOrigin.dx) * kDyadminoFaceAverageWideDiameter * factor;
  self.highestYPos = self.origin.y - (self.cellsBottom + _cellsInVertRange - self.hexOrigin.dy) * kDyadminoFaceDiameter * factor;
  self.highestXPos = self.origin.x - (self.cellsLeft + _cellsInHorzRange - self.hexOrigin.dx) * kDyadminoFaceAverageWideDiameter * factor;
}

#pragma mark - cell methods

-(BOOL)layoutAndColourBoardCellsAndSnapPointsOfDyadminoes:(NSSet *)boardDyadminoes minusDyadmino:(Dyadmino *)minusDyadmino {
  
    // regular hex origin is only set once per scene load, but zoom hex origin is set every time
  if (!_hexOriginSet) {
    self.hexOrigin = [self determineOutermostCellsBasedOnDyadminoes:boardDyadminoes];
    _hexCurrent = self.hexOrigin;
    _hexOriginSet = YES;
  } else {
    _hexCurrent = [self determineOutermostCellsBasedOnDyadminoes:boardDyadminoes];
  }
  
  NSMutableSet *tempAddedCellSet = [NSMutableSet new];
  NSMutableSet *tempRemovedCellSet = [NSMutableSet setWithSet:self.allCells];

    // reset all cells
  for (Cell *cell in self.allCells) {
    [cell resetForReuse];
    [cell renderColour];
  }
  
  for (Dyadmino *dyadmino in boardDyadminoes) {
      
    HexCoord bottomHexCoord = [self hexCoordFromX:dyadmino.tempBoardNode.myCell.hexCoord.x
                                        andY:dyadmino.tempBoardNode.myCell.hexCoord.y];
    HexCoord topHexCoord = [self getHexCoordOfOtherCellGivenDyadmino:dyadmino andBoardNode:dyadmino.tempBoardNode];
    
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
            Cell *addedCell = [self acknowledgeOrAddCellWithXHex:newX andYHex:newY];
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
  [self determineBoardPositionBounds];
  return YES;
}

-(Cell *)findCellWithXHex:(NSInteger)xHex andYHex:(NSInteger)yHex {
  for (Cell *cell in self.allCells) {
    if (cell.hexCoord.x == xHex && cell.hexCoord.y == yHex) {
      return cell;
    }
  }
  return nil;
}

-(Cell *)acknowledgeOrAddCellWithXHex:(NSInteger)xHex andYHex:(NSInteger)yHex {
    // first check to see if cell already exists
  Cell *cell = [self findCellWithXHex:xHex andYHex:yHex];
  
    // if cell does not exist, create and add it
  if (!cell) {
    Cell *poppedCell = [self popDequeuedCell];
    if (poppedCell) {
      cell = poppedCell;
      [cell reuseCellWithHexCoord:[self hexCoordFromX:xHex andY:yHex] andHexOrigin:self.hexOrigin forResize:self.zoomedOut];
    } else {
      cell = [[Cell alloc] initWithTexture:self.cellTexture
                               andHexCoord:[self hexCoordFromX:xHex andY:yHex]
                              andHexOrigin:self.hexOrigin
                                 andResize:self.zoomedOut
                               andDelegate:self];
    }
    
    cell.cellNode.parent ? nil : [self addChild:cell.cellNode];

    if (![self.allCells containsObject:cell]) {
      [self.allCells addObject:cell];
      [cell addSnapPointsToBoardAndResize:self.zoomedOut];
    }
  }
  return cell;
}

-(void)ignoreCellWithXHex:(NSInteger)xHex andYHex:(NSInteger)yHex {
  Cell *cell = [self findCellWithXHex:xHex andYHex:yHex];
  [self ignoreCell:cell];
}

-(void)ignoreCell:(Cell *)cell {
  if (cell) {
    
    [cell resetForReuse];
    cell.cellNode ? [cell.cellNode removeFromParent] : nil;
    
    if ([self.allCells containsObject:cell]) {
      [self.allCells removeObject:cell];
      [cell removeSnapPointsFromBoard];
    }
    [self pushDequeuedCell:cell];
  }
}

-(void)pushDequeuedCell:(Cell *)cell {
  [self.dequeuedCells containsObject:cell] ? nil : [self.dequeuedCells addObject:cell];
}

-(Cell *)popDequeuedCell {
  Cell *cell = [self.dequeuedCells anyObject];
  [cell isKindOfClass:[Cell class]] ? [self.dequeuedCells removeObject:cell] : nil;
  return cell;
}

#pragma mark - zoom methods

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
  
  CGSize cellSize = [Cell establishCellSizeForResize:self.zoomedOut];
  for (Cell *cell in self.allCells) {
    
    CGPoint tempNewPosition = [self addToThisPoint:cell.cellNode.position thisPoint:differenceInPosition];
    
    if (self.zoomedOut) {
      tempNewPosition = [self addToThisPoint:tempNewPosition thisPoint:zoomOutBoardHomePositionDifference];
    } else {
      tempNewPosition = [self addToThisPoint:tempNewPosition thisPoint:self.zoomInBoardHomePositionDifference];
    }
    
    
    cell.cellNode.position = tempNewPosition;
    
    
    
    [cell resizeAndRepositionCell:self.zoomedOut withHexOrigin:self.hexOrigin andSize:cellSize];
  }
  
  return differenceInPosition;
    //  self.backgroundNodeZoomedIn.position = [self subtractFromThisPoint:self.origin thisPoint:self.position];
    //  self.backgroundNodeZoomedOut.position = [self subtractFromThisPoint:self.origin thisPoint:self.position];
}

#pragma mark - cell and data dyadmino methods

-(void)updateCellsForDyadmino:(Dyadmino *)dyadmino placedOnBoardNode:(SnapPoint *)snapPoint {
  
    // this assumes dyadmino is properly oriented for this boardNode
  if ([snapPoint isBoardNode]) {
    
    NSArray *cells = [self topAndBottomCellsArrayForDyadmino:dyadmino andBoardNode:snapPoint];
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
}

-(void)updateCellsForDyadmino:(Dyadmino *)dyadmino removedFromBoardNode:(SnapPoint *)snapPoint {
  
    // don't call if it's a rack node
  if ([snapPoint isBoardNode]) {

    NSArray *cells = [self topAndBottomCellsArrayForDyadmino:dyadmino andBoardNode:snapPoint];
    
    for (int i = 0; i < cells.count; i++) {
      Cell *cell = cells[i];
      
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

-(HexCoord)getHexCoordOfOtherCellGivenDyadmino:(Dyadmino *)dyadmino andBoardNode:(SnapPoint *)snapPoint {
  
    // method needs board node
    // there are situations where it cannot get hexCoord from dyadmino alone
  
  NSInteger xHex;
  NSInteger yHex;
  if (snapPoint) {
    xHex = snapPoint.myCell.hexCoord.x;
    yHex = snapPoint.myCell.hexCoord.y;
  } else {
    xHex = dyadmino.myHexCoord.x;
    yHex = dyadmino.myHexCoord.y;
  }
  
  switch (dyadmino.orientation) {
    case kPC1atTwelveOClock:
    case kPC1atSixOClock:
      yHex++;
      break;
    case kPC1atTwoOClock:
    case kPC1atEightOClock:
      xHex++;
      break;
    case kPC1atFourOClock:
    case kPC1atTenOClock:
      xHex--;
      yHex++;
      break;
  }
  return [self hexCoordFromX:xHex andY:yHex];
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

-(NSArray *)topAndBottomCellsArrayForDyadmino:(Dyadmino *)dyadmino andBoardNode:(SnapPoint *)snapPoint {
  Cell *bottomCell = snapPoint.myCell;
  HexCoord topCellHexCoord = [self getHexCoordOfOtherCellGivenDyadmino:dyadmino andBoardNode:snapPoint];
  Cell *topCell = [self getCellWithHexCoord:topCellHexCoord];
  return topCell ? @[topCell, bottomCell] : @[bottomCell];
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

#pragma mark - legality methods

-(PhysicalPlacementResult)validatePhysicallyPlacingDyadmino:(Dyadmino *)dyadmino onBoardNode:(SnapPoint *)snapPoint {
    // if it's the first dyadmino, placement anywhere is fine
  
    // this gets the cells based on dyadmino orientation and board node
  Cell *bottomCell = snapPoint.myCell;
  HexCoord topCellHexCoord = [self getHexCoordOfOtherCellGivenDyadmino:dyadmino andBoardNode:snapPoint];
  Cell *topCell = [self getCellWithHexCoord:topCellHexCoord];
  
    // if either cell has a dyadmino, then it's not legal
  if ((topCell.myDyadmino && topCell.myDyadmino != dyadmino) ||
      (bottomCell.myDyadmino && bottomCell.myDyadmino != dyadmino)) {
    return kErrorStackedDyadminoes;
  }
  
    //--------------------------------------------------------------------------
  
    // now this checks if either cell has a neighbour cell occupied by another dyadmino
  NSArray *cells = @[topCell, bottomCell];
  for (Cell *dyadminoCell in cells) {
    if ([self cell:dyadminoCell hasNeighbourCellNotOccupiedByDyadmino:dyadmino]) {
      return kNoError;
    };
  }
  
    // if lone dyadmino, no error only if it's the first dyadmino
  return [self.delegate isFirstDyadmino:dyadmino] ? kNoError : kErrorLoneDyadmino;
}

-(BOOL)cell:(Cell *)dyadminoCell hasNeighbourCellNotOccupiedByDyadmino:(Dyadmino *)dyadmino {
  NSInteger xHex = dyadminoCell.hexCoord.x;
  NSInteger yHex = dyadminoCell.hexCoord.y;
    // this includes cell and its eight surrounding cells (thinking in terms of square grid)
  for (NSInteger i = xHex - 1; i <= xHex + 1; i++) {
    for (NSInteger j = yHex - 1; j <= yHex + 1; j++) {
        // this excludes cell itself and the two far cells
      if (!(i == xHex && j == yHex) &&
          !(i == xHex - 1 && j == yHex - 1) &&
          !(i == xHex + 1 && j == yHex + 1)) {
        
        Cell *neighbourCell = [self getCellWithHexCoord:[self hexCoordFromX:i andY:j]];
        if (neighbourCell.myDyadmino && neighbourCell.myDyadmino != dyadmino) {
          return YES;
        }
      }
    }
  }
  return NO;
}

#pragma mark - distance helper methods

-(CGPoint)getOffsetFromPoint:(CGPoint)point {
  return [self subtractFromThisPoint:point thisPoint:self.position];
}

-(CGPoint)getOffsetForPoint:(CGPoint)point withTouchOffset:(CGPoint)touchOffset {
  CGPoint offsetPoint = [self subtractFromThisPoint:point thisPoint:touchOffset];
  return [self subtractFromThisPoint:offsetPoint thisPoint:self.position];
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
