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

#define kCellColourMultiplier .005f

#define kBackgroundFullAlpha 0.5f

@interface Board ()

@property (strong, nonatomic) SKSpriteNode *backgroundNodeZoomedIn;
@property (strong, nonatomic) SKSpriteNode *backgroundNodeZoomedOut;

@property (strong, nonatomic) NSMutableSet *dequeuedCells;
@property (strong, nonatomic) SKTexture *cellTexture;
@property (nonatomic) BOOL userWantsPivotGuides;

@end

@implementation Board {

  CGSize _cellSize;
  
  CGFloat _cellsInVertRange;
  CGFloat _cellsInHorzRange;
  BOOL _cellsTopXIsEven;
  BOOL _cellsBottomXIsEven;
  BOOL _hexOriginSet;
  CGVector _hexCurrent;
  BOOL _cellsTopNeedsBuffer;
  BOOL _cellsBottomNeedsBuffer;
  BOOL _redoLayoutAfterZoom;
  
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
    
    self.userWantsPivotGuides = YES;

      // instantiate node and cell arrays to be searched
    self.snapPointsTwelveOClock = [NSMutableSet new];
    self.snapPointsTwoOClock = [NSMutableSet new];
    self.snapPointsTenOClock = [NSMutableSet new];
    self.occupiedCells = [NSMutableSet new];
    self.allCells = [NSMutableSet new];
    
    _cellSize = [Cell establishCellSizeForResize:NO];
    
      // create new cells from get-go
    self.dequeuedCells = [NSMutableSet new];
    [self instantiateDequeuedCells];
    
      // these values are necessary for board movement
      // see determineBoardPositionBounds method for explanation
    
      // create pivot guides
      // TODO: refactor into one method?
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
  return self;
}

-(void)instantiateDequeuedCells {

  NSUInteger times = kIsIPhone ? 125 : 250;
  for (int i = 0; i < times; i++) {
    Cell *cell = [[Cell alloc] initWithBoard:self
                                  andTexture:self.cellTexture
                                 andHexCoord:[self hexCoordFromX:0 andY:0]
                                andHexOrigin:self.hexOrigin
                                     andSize:_cellSize];
    [self.dequeuedCells addObject:cell];
  }
}

-(void)resetForNewMatch {
  
  NSSet *tempAllCells = [NSSet setWithSet:self.allCells];
  [self.occupiedCells removeAllObjects];
  
  for (Cell *cell in tempAllCells) {
    [self ignoreCell:cell];
    [cell resetForNewMatch];
  }
//  NSLog(@"self.all cells count is %lu, dequeued cells is %lu", (unsigned long)self.allCells.count, (unsigned long)self.dequeuedCells.count);
//  NSLog(@"self snappoints count is %lu, %lu, %lu", (unsigned long)self.snapPointsTenOClock.count, (unsigned long)self.snapPointsTwelveOClock.count, (unsigned long)self.snapPointsTwoOClock.count);
  
  self.zoomedOut = NO;
  [self zoomInBackgroundImage];
}

#pragma mark - board position methods

-(void)repositionBoardWithHomePosition:(CGPoint)homePosition
                             andOrigin:(CGPoint)origin {
  _hexOriginSet = NO;
  self.homePosition = homePosition;
  self.origin = origin;
  self.position = self.homePosition;
}

-(void)centerBoardOnDyadminoesAverageCenterWithSwap:(BOOL)swap andGameEnded:(BOOL)gameEnded {
  CGFloat factor = self.zoomedOut ? kZoomResizeFactor : 1.f;
  CGPoint newPoint = CGPointMake(self.origin.x + (self.hexOrigin.dx - _hexCurrent.dx) * kDyadminoFaceWideDiameter * factor,
                                 self.origin.y + (self.hexOrigin.dy - _hexCurrent.dy) * kDyadminoFaceDiameter * factor);
  
  [self adjustToNewPositionFromBeganLocation:self.homePosition toCurrentLocation:newPoint withSwap:swap andGameEnded:gameEnded];
  self.homePosition = newPoint;
}

//-(void)centerBoardOnLocation:(CGPoint)location withSwap:(BOOL)swap andGameEnded:(BOOL)gameEnded {
//  [self adjustToNewPositionFromBeganLocation:self.homePosition toCurrentLocation:location withSwap:swap andGameEnded:gameEnded];
//  self.homePosition = location;
//}

#pragma mark - board span methods

-(CGPoint)adjustToNewPositionFromBeganLocation:(CGPoint)beganLocation toCurrentLocation:(CGPoint)currentLocation withSwap:(BOOL)swap andGameEnded:(BOOL)gameEnded {
    // first get new board position, after applying touch offset
  CGPoint touchOffset = [self subtractFromThisPoint:beganLocation thisPoint:currentLocation];
  CGPoint newPosition = [self subtractFromThisPoint:self.homePosition thisPoint:touchOffset];
  
  CGFloat newX = newPosition.x;
  CGFloat newY = newPosition.y;
  
  CGFloat finalBuffer = swap ? kRackHeight : 0.f; // the height of the swap field
//  CGFloat endGameBuffer = gameEnded ? finalBuffer - kRackHeight : finalBuffer;

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
  
  CGPoint adjustedNewPosition = CGPointMake(newX, newY);
  self.position = adjustedNewPosition;
  
    // move home position to board position, after applying touch offset
  self.homePosition = [self addToThisPoint:adjustedNewPosition thisPoint:touchOffset];
  
  return adjustedNewPosition;
}

-(CGVector)determineOutermostCellsBasedOnDyadminoes:(NSSet *)boardDyadminoes withGameEnded:(BOOL)gameEnded {
  
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
        _cellsTopXIsEven = (abs(xHex) % 2 == 0) ? YES : NO; // pretty sure not needed, but keep for my assurance for the time being
      }
      
      CGFloat trialBottommost = ((CGFloat)xHex + (2 * yHex)) / 2.f;
      if (trialBottommost < cellsBottommost) {
        cellsBottommost = trialBottommost;
        _cellsBottomXIsEven = (abs(xHex) % 2 == 0) ? YES : NO; // ditto
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

  return CGVectorMake(((CGFloat)(self.cellsRight - self.cellsLeft) / 2) + self.cellsLeft, ((CGFloat)(self.cellsTop - self.cellsBottom) / 2) + self.cellsBottom);
}

-(void)determineBoardPositionBounds {
  NSLog(@"determineBoardPositionBounds");
    // this should get called after every method that adds cells or removes them
  
  CGFloat factor = self.zoomedOut ? kZoomResizeFactor : 1.f;
  self.lowestYPos = self.origin.y - (self.cellsTop - _cellsInVertRange - self.hexOrigin.dy) * kDyadminoFaceDiameter * factor;
  self.lowestXPos = self.origin.x - (self.cellsRight - _cellsInHorzRange - self.hexOrigin.dx) * kDyadminoFaceAverageWideDiameter * factor;
  self.highestYPos = self.origin.y - (self.cellsBottom + _cellsInVertRange - self.hexOrigin.dy) * kDyadminoFaceDiameter * factor;
  self.highestXPos = self.origin.x - (self.cellsLeft + _cellsInHorzRange - self.hexOrigin.dx) * kDyadminoFaceAverageWideDiameter * factor;
  
//  NSLog(@"lowest y is %.2f, highest y is %.2f", self.lowestYPos, self.highestYPos);
//  NSLog(@"determine board position bounds, for zoom? %i", self.zoomedOut);
//  NSLog(@"board bounds range %.2f, %.2f", self.highestXPos - self.lowestXPos, self.highestYPos - self.lowestYPos);
}

#pragma mark - zoom methods

-(void)repositionCellsForZoomWithSwap:(BOOL)swap andGameEnded:(BOOL)gameEnded {

  CGSize cellSize = [Cell establishCellSizeForResize:self.zoomedOut];
  for (Cell *cell in self.allCells) {
    [cell resizeCell:self.zoomedOut withHexOrigin:self.hexOrigin andSize:cellSize];
  }
  
    // zoom out
  if (self.zoomedOut) {

    [self centerBoardOnDyadminoesAverageCenterWithSwap:swap andGameEnded:gameEnded];
    [self zoomOutBackgroundImage];
    
      // zoom back in
  } else {
    
    [self adjustToNewPositionFromBeganLocation:self.homePosition toCurrentLocation:self.postZoomPosition withSwap:swap andGameEnded:gameEnded];
    if (_redoLayoutAfterZoom) {
      [self layoutBoardCellsAndSnapPointsOfDyadminoes:[self.delegate allBoardDyadminoesPlusRecentRackDyadmino] withGameEnded:gameEnded];
      _redoLayoutAfterZoom = NO;
    }
    
    [self.delegate correctBoardForPositionAfterZoom];
    [self zoomInBackgroundImage];
  }

  self.backgroundNodeZoomedIn.position = [self subtractFromThisPoint:self.origin thisPoint:self.position];
  self.backgroundNodeZoomedOut.position = [self subtractFromThisPoint:self.origin thisPoint:self.position];
}

-(void)toggleBackgroundAlphaZeroed:(BOOL)zeroed animated:(BOOL)animated {
  
  CGFloat desiredAlpha = zeroed ? 0.f : kBackgroundFullAlpha;
  SKAction *fadeAlpha = [SKAction fadeAlphaTo:desiredAlpha duration:kConstantTime * 0.9f]; // a little faster than field move
  
  if (animated) {
    [self.backgroundNodeZoomedIn runAction:fadeAlpha];
  } else {
    self.backgroundNodeZoomedIn.alpha = desiredAlpha;
  }
}

#pragma mark - cell methods

-(void)layoutBoardCellsAndSnapPointsOfDyadminoes:(NSSet *)boardDyadminoes withGameEnded:(BOOL)gameEnded {

    // regular hex origin is only set once per scene load, but zoom hex origin is set every time
  if (!_hexOriginSet) {
    self.hexOrigin = [self determineOutermostCellsBasedOnDyadminoes:boardDyadminoes withGameEnded:gameEnded];
    _hexCurrent = self.hexOrigin;
    _hexOriginSet = YES;
  } else {
    _hexCurrent = [self determineOutermostCellsBasedOnDyadminoes:boardDyadminoes withGameEnded:gameEnded];
  }
  
    // covers all cells in old range plus new range
  CGFloat maxCellsTop = _oldCellsTop > self.cellsTop ? _oldCellsTop : self.cellsTop;
  CGFloat minCellsBottom = _oldCellsBottom < self.cellsBottom ? _oldCellsBottom : self.cellsBottom;
  CGFloat maxCellsRight = _oldCellsRight > self.cellsRight ? _oldCellsRight : self.cellsRight;
  CGFloat minCellsLeft = _oldCellsLeft < self.cellsLeft ? _oldCellsLeft : self.cellsLeft;
    //  NSLog(@"top %i, bottom %i, right %i, left %i", maxCellsTop, minCellsBottom, maxCellsRight, minCellsLeft);
  
    // formula is y <= cellsTop - (x / 2) and y >= cellsBottom - (x / 2)
    // use this to get the range to iterate over y, and to keep the board square
  
  NSMutableSet *tempAddedCellSet = [NSMutableSet new];

    // FIXME: (maybe) these extra + or - and 1 or 2 constants ensures that no empty slots show when dyadmino is moved or removed
    // and board bounds are corrected as a result. Seems fine for now, but *might* want to fix later
  for (NSInteger xHex = minCellsLeft - 2; xHex <= maxCellsRight + 2; xHex++) {
    for (NSInteger yHex = minCellsBottom - 1 - maxCellsRight / 2.f; yHex <= maxCellsTop + 2 - minCellsLeft / 2.f; yHex++) {
      
      if (xHex >= self.cellsLeft - 2 && xHex <= self.cellsRight + 2 &&
          yHex <= self.cellsTop + 2 - ((xHex - 1) / 2.f) && yHex >= self.cellsBottom - 1 - (xHex / 2.f)) {

          // this method gets called if dyadmino is cancelled or undone while board is zoomed out
          // so this is a kludge way of ensuring that board doesn't add cells when this happens
          // redoLayoutAfterZoom bool is set to yes to ensure that cells are properly laid out *after* zoom
        if (!self.zoomedOut) {
          Cell *addedCell = [self acknowledgeOrAddCellWithXHex:xHex andYHex:yHex];
          [tempAddedCellSet addObject:addedCell];
        }
        
      } else {
        [self ignoreCellWithXHex:xHex andYHex:yHex];
      }
    }
  }
  
    // this block tries to add only cells surrounding dyadminoes
    // unfortunately, getting cell from dyadmino's myHexCoord is not a good way to do it
  /*
  for (Dyadmino *dyadmino in boardDyadminoes) {
    if (!self.zoomedOut) {
      Cell *addedCell = [self acknowledgeOrAddCellWithXHex:dyadmino.myHexCoord.x andYHex:dyadmino.myHexCoord.y];
      HexCoord otherCellHexCoord = [self getHexCoordOfOtherCellGivenDyadmino:dyadmino andBoardNode:(dyadmino.tempBoardNode ? dyadmino.tempBoardNode : dyadmino.homeNode)];
      Cell *otherCell = [self acknowledgeOrAddCellWithXHex:otherCellHexCoord.x andYHex:otherCellHexCoord.y];
      [tempAddedCellSet addObject:addedCell];
      [tempAddedCellSet addObject:otherCell];
    }
  }
  
  self.allCells = [NSMutableSet setWithSet:tempAddedCellSet];
  */
  
    // ensures there's no straggler cells
  if (!self.zoomedOut) {
    NSMutableSet *tempAllCellsSet = [NSMutableSet setWithSet:self.allCells];
    for (Cell *cell in tempAllCellsSet) {
      [tempAddedCellSet containsObject:cell] ? nil : [self ignoreCell:cell];
    }
  } else {
    _redoLayoutAfterZoom = YES;
  }
  
  [self determineBoardPositionBounds];
  
//  NSLog(@"self.allCells %i, self.occupiedCells %i, self.dequeuedCells %i", self.allCells.count, self.occupiedCells.count, self.dequeuedCells.count);
//  NSLog(@"board nodes %i, %i, %i", self.snapPointsTenOClock.count, self.snapPointsTwelveOClock.count, self.snapPointsTwoOClock.count);
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
      [cell reuseCellWithHexCoord:[self hexCoordFromX:xHex andY:yHex] andHexOrigin:self.hexOrigin andSize:_cellSize];
    } else {
      cell = [[Cell alloc] initWithBoard:self
                              andTexture:self.cellTexture
                             andHexCoord:[self hexCoordFromX:xHex andY:yHex]
                            andHexOrigin:self.hexOrigin
                                 andSize:_cellSize];
    }
    
    cell.cellNode.parent ? nil : [self addChild:cell.cellNode];

    if (![self.allCells containsObject:cell]) {
      [self.allCells addObject:cell];
      [cell addSnapPointsToBoard];
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

#pragma mark - cell and data dyadmino methods

-(void)updateCellsForDyadmino:(Dyadmino *)dyadmino placedOnBoardNode:(SnapPoint *)snapPoint andColour:(BOOL)colour {
    // this assumes dyadmino is properly oriented for this boardNode
  if ([snapPoint isBoardNode]) {
    
      // this gets the cells based on dyadmino orientation and board node
    Cell *bottomCell = snapPoint.myCell;
    
    HexCoord topCellHexCoord = [self getHexCoordOfOtherCellGivenDyadmino:dyadmino andBoardNode:snapPoint];
    Cell *topCell = [self getCellWithHexCoord:topCellHexCoord];

    NSArray *cells = @[topCell, bottomCell];
    NSInteger pcs[2] = {dyadmino.pc1, dyadmino.pc2};
    
    for (int i = 0; i < 2; i++) {
      Cell *cell = cells[i];
      
        // only assign if cell doesn't have a dyadmino recorded
      if (!cell.myDyadmino) {
        
        // assign pc to cell based on dyadmino orientation
        switch (dyadmino.orientation) {
          case kPC1atTwelveOClock:
          case kPC1atTwoOClock:
          case kPC1atTenOClock:
            cell.myPC = pcs[i];
            break;
          case kPC1atSixOClock:
          case kPC1atEightOClock:
          case kPC1atFourOClock:
            cell.myPC = pcs[(i + 1) % 2];
            break;
        }
        
          // ensures there's only one cell for each dyadmino pc, and vice versa
        [self mapOneCell:cell toOnePCForDyadmino:dyadmino];
        
        colour ? [self changeColoursAroundCell:cell withSign:1] : nil;
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
    
      // add to board's array of occupied cells to search
    if (![self.occupiedCells containsObject:cell]) {
      [self.occupiedCells addObject:cell];
    }
    return YES;
    
  } else if (cell.myPC == dyadmino.pc2) {
    if (dyadmino.cellForPC2 && dyadmino.cellForPC2 != cell) { // remove dyadmino and its pc from previous cell
      [self removeDyadminoDataFromCell:dyadmino.cellForPC2];
    }
    dyadmino.cellForPC2 = cell;
    cell.myDyadmino = dyadmino;
    
      /// testing purposes
    [cell updatePCLabel];
    
      // add to board's array of occupied cells to search
    if (![self.occupiedCells containsObject:cell]) {
      [self.occupiedCells addObject:cell];
    }
    return YES;
  }
  return NO;
}

-(void)updateCellsForDyadmino:(Dyadmino *)dyadmino removedFromBoardNode:(SnapPoint *)snapPoint andColour:(BOOL)colour {
    // don't call if it's a rack node
  if ([snapPoint isBoardNode]) {
    
      // this gets the cells based on dyadmino orientation and board node
    Cell *bottomCell = snapPoint.myCell;
    HexCoord topCellHexCoord = [self getHexCoordOfOtherCellGivenDyadmino:dyadmino andBoardNode:snapPoint];
    Cell *topCell = [self getCellWithHexCoord:topCellHexCoord];
    
    NSArray *cells = @[topCell, bottomCell];
    
    for (int i = 0; i < 2; i++) {
      Cell *cell = cells[i];
      
        // only remove if cell dyadmino is dyadmino
      if (cell.myDyadmino == dyadmino) {
       
        if (colour) {
          [self changeColoursAroundCell:cell withSign:-1];
        }
        
        [self removeDyadminoDataFromCell:cell];
      }
    }
  }
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
  
  if ([self.occupiedCells containsObject:cell]) {
    [self.occupiedCells removeObject:cell];
  }
  
    // testing purposes
  [cell updatePCLabel];
  
  return YES;
}

-(HexCoord)getHexCoordOfOtherCellGivenDyadmino:(Dyadmino *)dyadmino andBoardNode:(SnapPoint *)snapPoint {
  
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

#pragma mark - cell colour methods
  // five places that call cell colour methods:
  // add: scene's populateBoard, dyadmino's animatePopBackIntoBoardNode, animateEaseIntoNode
  // remove: scene's beginTouchOfDyadmino (for touched board dyadmino) and touchesMoved (for removing rack dyadmino)

-(void)changeColoursAroundDyadmino:(Dyadmino *)dyadmino withSign:(NSInteger)sign {
  
  SnapPoint *snapPoint = dyadmino.tempBoardNode ? dyadmino.tempBoardNode : dyadmino.homeNode;
  
  Cell *bottomCell = snapPoint.myCell;
  HexCoord topCellHexCoord = [self getHexCoordOfOtherCellGivenDyadmino:dyadmino andBoardNode:snapPoint];
  Cell *topCell = [self getCellWithHexCoord:topCellHexCoord];
  NSArray *cells = @[topCell, bottomCell];
  for (Cell *cell in cells) {
    [self changeColoursAroundCell:cell withSign:sign];
  }
}

  // cell knows pc
-(void)changeColoursAroundCell:(Cell *)cell withSign:(NSInteger)sign {
  
  if ((sign == -1 && cell.currentlyColouringNeighbouringCells) || (sign == 1 && !cell.currentlyColouringNeighbouringCells)) {
    cell.currentlyColouringNeighbouringCells = cell.currentlyColouringNeighbouringCells == YES ? NO : YES;
    
    NSInteger xHex;
    NSInteger yHex;
    
      // each iteration goes around the cell
    
    NSInteger range = 7; // was 8; when tweaking, also change colourFactor in colourCell method
    
      // start with self
    [self colourCellWithXHex:cell.hexCoord.x andYHex:cell.hexCoord.y andFactor:range andSign:sign andPC:cell.myPC];
    
    for (int i = 1; i < range; i++) {
      xHex = cell.hexCoord.x;
      yHex = cell.hexCoord.y + i;
      
        // start with cell at 12 o'clock
      [self colourCellWithXHex:xHex andYHex:yHex andFactor:range - i andSign:sign andPC:cell.myPC];
      
        // going from 12 to 2...
      do {
        yHex--;
        xHex++;
        [self colourCellWithXHex:xHex andYHex:yHex andFactor:range - i andSign:sign andPC:cell.myPC];
      } while (yHex > cell.hexCoord.y);
      
        // now 2 to 4...
      do {
        yHex--;
        [self colourCellWithXHex:xHex andYHex:yHex andFactor:range - i andSign:sign andPC:cell.myPC];
      } while (yHex > cell.hexCoord.y - i);
      
        // now 4 to 6...
      do {
        xHex--;
        [self colourCellWithXHex:xHex andYHex:yHex andFactor:range - i andSign:sign andPC:cell.myPC];
      } while (xHex > cell.hexCoord.x);
      
        // now 6 to 8...
      do {
        xHex--;
        yHex++;
        [self colourCellWithXHex:xHex andYHex:yHex andFactor:range - i andSign:sign andPC:cell.myPC];
      } while (yHex < cell.hexCoord.y);
      
        // now 8 to 10...
      do {
        yHex++;
        [self colourCellWithXHex:xHex andYHex:yHex andFactor:range - i andSign:sign andPC:cell.myPC];
      } while (yHex < cell.hexCoord.y + i);
      
        // now 10 to 12, but stop *before* the very top cell
      while (xHex < cell.hexCoord.x - 1) {
        xHex++;
        [self colourCellWithXHex:xHex andYHex:yHex andFactor:range - i andSign:sign andPC:cell.myPC];
      };
    }
  }
}

-(void)colourCellWithXHex:(NSInteger)xHex andYHex:(NSInteger)yHex andFactor:(NSInteger)factor andSign:(NSInteger)sign andPC:(NSInteger)pc {

  Cell *cellToColour = [self getCellWithHexCoord:[self hexCoordFromX:xHex andY:yHex]];
  
    // if cell doesn't currently exist, add it so that colours don't get screwed up when bounds change
  if (!cellToColour) {
    cellToColour = [self acknowledgeOrAddCellWithXHex:xHex andYHex:yHex];
  }
  
  if (pc != -1) {
    CGFloat colourFactor = factor * 0.38f;
    
    NSInteger redMult, greenMult, blueMult;
    CGFloat redVal, greenVal, blueVal, alphaVal;

      // returns the opposite colour. So for example, pc 0 returns red 0, green 4, blue 4
    redMult = 6 - abs(6 - pc);
    redMult = redMult >= 4 ? 4 : redMult;
    greenMult = 6 - abs(6 - ((pc + 4) % 12));
    greenMult = greenMult >= 4 ? 4 : greenMult;
    blueMult = 6 - abs(6 - ((pc + 8) % 12));
    blueMult = blueMult >= 4 ? 4 : blueMult;

    redVal = (sign * colourFactor * redMult * kCellColourMultiplier);
    greenVal = (sign * colourFactor * greenMult * kCellColourMultiplier);
    blueVal = (sign * colourFactor * blueMult * kCellColourMultiplier);
    alphaVal = (sign * factor * 7 * kCellColourMultiplier);
    
    [cellToColour addColourWithRed:redVal green:greenVal blue:blueVal alpha:alphaVal];
    if (sign) {
      cellToColour.colouredByNeighbouringCells += 1;
    } else {
      cellToColour.colouredByNeighbouringCells -= 1;
    }
  }
}

#pragma mark - pivot guide methods

  // useful for testing purposes, not really needed otherwise
-(SKNode *)determineCurrentPivotGuide {
  SKNode *pivotGuide;
  if (self.prePivotGuide.parent == self) {
    pivotGuide = self.prePivotGuide;
  } else if (self.pivotRotateGuide.parent == self) {
    pivotGuide = self.pivotRotateGuide;
  } else if (self.pivotAroundGuide.parent == self) {
    pivotGuide = self.pivotAroundGuide;
  }
  return pivotGuide;
}

-(SKNode *)createPivotGuideNamed:(NSString *)name {
  
    // first four are prePivot, next is pivotRotate, next two are pivotAround
  float startAngle[9] = {212.5, 32.5, 212.5, 32.5, // prePivot around
                         332.5, 152.5, // prePivot rotate
                         300, // rotate
                         300, 300}; // around
  float endAngle[9] = {327.5, 147.5, 327.5, 147.5,
                       27.5, 207.5,
                       60, 60, 60};
  
  NSArray *colourArray = @[kEndedMatchCellDarkColour,
                           kEndedMatchCellDarkColour,
                           kEndedMatchCellDarkColour,
                           kEndedMatchCellDarkColour,
                           kEndedMatchCellLightColour,
                           kEndedMatchCellLightColour,
                           kEndedMatchCellLightColour,
                           kEndedMatchCellDarkColour,
                           kEndedMatchCellDarkColour];
  
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
  
  for (int i = initialNumber; i < conditionalNumber; i++) {
    if (i != 2 && i != 3) { // for now, leave out second, double-speed guide
      SKShapeNode *shapeNode = [SKShapeNode new];
      CGMutablePathRef shapePath = CGPathCreateMutable();
    
        // outer arc
      CGPathAddArc(shapePath, NULL, 0.f, 0.f + pivotYOffset, maxDistance[i], [self getRadiansFromDegree:startAngle[i]],
                   [self getRadiansFromDegree:endAngle[i]], NO);
        // line in
      CGPathAddLineToPoint(shapePath, NULL, minDistance[i] * cosf([self getRadiansFromDegree:endAngle[i]]),
                           minDistance[i] * sinf([self getRadiansFromDegree:endAngle[i]]));
        // inner arc
      CGPathAddArc(shapePath, NULL, 0.f, 0.f + pivotYOffset, minDistance[i], [self getRadiansFromDegree:endAngle[i]],
                   [self getRadiansFromDegree:startAngle[i]], YES);
        // line out
      CGPathAddLineToPoint(shapePath, NULL, maxDistance[i] * cosf([self getRadiansFromDegree:startAngle[i]]),
                           maxDistance[i] * sinf([self getRadiansFromDegree:startAngle[i]]));
      
      shapeNode.path = shapePath;
      CGPathRelease(shapePath);
      
      shapeNode.lineWidth = 0.75;
      shapeNode.alpha = kPivotGuideAlpha;
      shapeNode.strokeColor = colourArray[i];
      shapeNode.fillColor = colourArray[i];
      [pivotGuide addChild:shapeNode];
    }
  }
  return pivotGuide;
}

-(void)handleUserWantsPivotGuides {
    // called before scene appears
  self.userWantsPivotGuides = [[NSUserDefaults standardUserDefaults] boolForKey:@"pivotGuide"];
}

-(void)showPivotGuide:(SKNode *)pivotGuide forDyadmino:(Dyadmino *)dyadmino {
  if (self.userWantsPivotGuides && !pivotGuide.parent) {
    pivotGuide.position = (pivotGuide == self.prePivotGuide || pivotGuide == self.pivotRotateGuide) ?
        dyadmino.position : dyadmino.pivotAroundPoint;
    
    CGFloat degree = (dyadmino.orientation) * -60.f;
    while (degree > 360.f) {
      degree -= 360.f;
    }

    pivotGuide.zRotation = [self getRadiansFromDegree:degree];
    
    [self addChild:pivotGuide];
    [pivotGuide removeActionForKey:@"pivotGuideScale"];
    SKAction *scaleStart = [SKAction scaleTo:0.f duration:0.f];
    SKAction *unhide = [SKAction runBlock:^{
      pivotGuide.hidden = NO;
    }];
    SKAction *scaleUp = [SKAction scaleTo:1.f duration:.08f];
    SKAction *sequence = [SKAction sequence:@[scaleStart, unhide, scaleUp]];
    NSLog(@"pivot guide scaling now");
    [pivotGuide runAction:sequence withKey:@"pivotGuideScale"];
  }
}

-(void)hidePivotGuide:(SKNode *)pivotGuide {
  if (self.userWantsPivotGuides && pivotGuide.parent) {
    [pivotGuide removeFromParent];
    pivotGuide.hidden = YES;
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

#pragma mark - pivot methods

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

-(void)pivotGuidesBasedOnTouchLocation:(CGPoint)touchLocation forDyadmino:(Dyadmino *)dyadmino {

    // establish angles
  CGFloat touchAngle = [self findAngleInDegreesFromThisPoint:touchLocation toThisPoint:dyadmino.pivotAroundPoint];
  
    //// pivot guide positions and rotations should be established in determinePivotOnPC methods
    //// Here, they are adjusted. This should change, obviously
  self.pivotAroundGuide.position = dyadmino.pivotAroundPoint;
  self.pivotRotateGuide.position = dyadmino.pivotAroundPoint;
  self.pivotAroundGuide.zRotation = [self getRadiansFromDegree:touchAngle];
  self.pivotRotateGuide.zRotation = [self getRadiansFromDegree:touchAngle];
}

  // these might be used for replay mode
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

#pragma mark - legality methods

-(PhysicalPlacementResult)validatePlacingDyadmino:(Dyadmino *)dyadmino onBoardNode:(SnapPoint *)snapPoint {
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
