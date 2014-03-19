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

@interface Board ()

@property (strong, nonatomic) NSMutableSet *occupiedCells;

@end

@implementation Board

-(id)initWithColor:(UIColor *)color andSize:(CGSize)size
    andAnchorPoint:(CGPoint)anchorPoint
   andHomePosition:(CGPoint)homePosition
      andZPosition:(CGFloat)zPosition {
  self = [super init];
  if (self) {
    
    self.name = @"board";
    self.color = color;
    self.size = size;
    self.anchorPoint = anchorPoint;
    self.homePosition = homePosition;
    self.position = self.homePosition;
    self.zPosition = zPosition;

      // instantiate node and cell arrays to be searched
    self.snapPointsTwelveOClock = [NSMutableSet new];
    self.snapPointsTwoOClock = [NSMutableSet new];
    self.snapPointsTenOClock = [NSMutableSet new];
    self.occupiedCells = [NSMutableSet new];
  }
  return self;
}

-(void)layoutBoardCellsAndSnapPointsOfDyadminoes:(NSMutableSet *)boardDyadminoes {

  [self determineOutermostCellsBasedOnDyadminoes:boardDyadminoes];
  
    // formula is y <= cellsTop - (x / 2) and y >= cellsBottom - (x / 2)
    // use this to get the range to iterate over y, and to keep the board square
  
  for (NSInteger xHex = self.cellsLeft; xHex <= self.cellsRight; xHex++) {
    for (NSInteger yHex = self.cellsBottom - self.cellsRight / 2; yHex <= self.cellsTop - self.cellsLeft / 2; yHex++) {

      if (xHex >= self.cellsLeft && xHex <= self.cellsRight &&
          yHex <= self.cellsTop - (xHex / 2.f) && yHex >= self.cellsBottom - (xHex / 2.f)) {
        [self addCellWithXHex:xHex andYHex:yHex];
      }
    }
  }
  [self determineBoardBounds];
}

#pragma mark - cell methods

-(Cell *)addCellWithXHex:(NSInteger)xHex andYHex:(NSInteger)yHex {
    // to save time, initial layout adds cells directly,
    // without checking to see if they're already in allCells
  
  Cell *cell = [[Cell alloc] initWithBoard:self
                                     andTexture:[SKTexture textureWithImageNamed:@"blankSpace"]
                                    andHexCoord:[self hexCoordFromX:xHex andY:yHex]];
  cell.color = [SKColor orangeColor];
  cell.colorBlendFactor = 0.5f;
  cell.hidden = NO;
  [self addChild:cell];
  [cell addSnapPointsToBoard];
  return cell;
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
    // this method only gets called during play, after initial layout
    // it first checks to see if cell exists in allCells array
    // if not, it instantiates it

    // first check to see if cell already exists
  Cell *cell = [self findCellWithXHex:xHex andYHex:yHex];
  
    // if cell does not exist, create and add it
  if (!cell) {
    cell = [[Cell alloc] initWithBoard:self
                                    andTexture:[SKTexture textureWithImageNamed:@"blankSpace"]
                                   andHexCoord:[self hexCoordFromX:xHex andY:yHex]];
  }
    //// do stuff here to officially acknowledge cell
  
  cell.hidden = NO;
  [self addChild:cell];
  [cell addSnapPointsToBoard];
  [self determineBoardBounds];
  return cell;
}

-(Cell *)ignoreCell:(Cell *)cell {
    // cells do *not* get deallocated or taken out of allCells array when ignored,
    // they are only removed from parent

    //// do stuff here to officially remove cell
  
  cell.hidden = YES;
  [cell removeFromParent];
  [cell removeSnapPointsFromBoard];
  [self determineBoardBounds];
  return cell;
}

#pragma mark - board span methods

-(void)determineOutermostCellsBasedOnDyadminoes:(NSMutableSet *)boardDyadminoes {
  for (Dyadmino *dyadmino in boardDyadminoes) {
    [self determineOutermostCellsBasedOnDyadmino:dyadmino];
  }
  
    // hard coded for now, will change, obviously
//  self.cellsTop = 5;
//  self.cellsRight = 4;
//  self.cellsBottom = -5;
//  self.cellsLeft = -4;
  
//  NSLog(@"board cells range is top %i, right %i, bottom %i, left %i", self.cellsTop, self.cellsRight, self.cellsBottom, self.cellsLeft);
}

-(void)determineOutermostCellsBasedOnDyadmino:(Dyadmino *)dyadmino {
    /// test this
  
  NSInteger cellsTop = 0;
  NSInteger cellsRight = 0;
  NSInteger cellsBottom = 0;
  NSInteger cellsLeft = 0;
  
    // check hexCoords of both cells of dyadmino
  HexCoord hexCoord[2] = {dyadmino.homeNode.myCell.hexCoord,
    [self getHexCoordOfOtherCellGivenDyadmino:dyadmino andBoardNode:dyadmino.homeNode]};
  
  for (int i = 0; i < 2; i++) {
    NSInteger xHex = hexCoord[i].x;
    NSInteger yHex = hexCoord[i].y;
    
      // check x span
    if (xHex > cellsRight) {
      cellsRight = xHex;
    } else if (xHex < cellsLeft) {
      cellsLeft = xHex;
    }
    
      // check y span
    if (yHex > cellsTop - (xHex / 2.f)) {
      cellsTop = yHex;
    } else if (yHex < cellsBottom - (xHex / 2.f)) {
      cellsBottom = yHex;
    }
  }
  
    // this creates four cells plus one buffer cell beyond outermost dyadmino
  self.cellsTop = cellsTop + 5;
  self.cellsRight = cellsRight + 5;
  self.cellsBottom = cellsBottom - 5;
  self.cellsLeft = cellsLeft - 5;
}

-(void)determineBoardBounds {
    // this gets called after every method that adds cells or removes them
  
    //// this will determine bounds
  
//  hardcode just to test
  self.boundsBottom = 280.f;
  self.boundsRight = 180.f;
  self.boundsLeft = 140.f;
  self.boundsTop  = 320.f;

//  NSLog(@"board size is %.1f, %.1f", self.size.width, self.size.height);
  CGFloat tempTop = self.cellsTop * kDyadminoFaceRadius * 2;
  CGFloat tempRight = self.cellsRight * kDyadminoFaceRadius * 2;
  CGFloat tempBottom = -self.cellsBottom * kDyadminoFaceRadius * 2;
  CGFloat tempLeft = -self.cellsLeft * kDyadminoFaceRadius * 2;
  
//  NSLog(@"bounds by cell size is top %.1f, right %.1f, bottom %.1f, left %.1f",
//        tempTop, tempRight, tempBottom, tempLeft);
  
  if (tempTop < self.size.height * 0.5) {
    tempTop = self.size.height * 0.5;
  }
  if (tempRight < self.size.width * 0.5) {
    tempRight = self.size.width * 0.5;
  }
  if (tempBottom < self.size.height * 0.5) {
    tempBottom = self.size.height * 0.5;
  }
  if (tempLeft < self.size.width * 0.5) {
    tempLeft = self.size.width * 0.5;
  }
  
//  self.boundsTop = tempTop;
//  self.boundsRight = tempRight;
//  self.boundsBottom = tempBottom;
//  self.boundsLeft = tempLeft;
  
//  NSLog(@"bounds must be top %.1f, right %.1f, bottom %.1f, left %.1f", self.boundsTop, self.boundsRight, self.boundsBottom, self.boundsLeft);
}

#pragma mark - distance methods

-(CGPoint)getOffsetFromPoint:(CGPoint)point {
  return [self subtractFromThisPoint:point thisPoint:self.position];
}

-(CGPoint)getOffsetForPoint:(CGPoint)point withTouchOffset:(CGPoint)touchOffset {
  CGPoint offsetPoint = [self subtractFromThisPoint:point thisPoint:touchOffset];
  return [self subtractFromThisPoint:offsetPoint thisPoint:self.position];
}

#pragma mark - cell methods

-(BOOL)updateCellsForDyadmino:(Dyadmino *)dyadmino placedOnBoardNode:(SnapPoint *)snapPoint {
    // this assumes dyadmino is properly oriented for this boardNode
  
  Cell *bottomCell = snapPoint.myCell;
  HexCoord topCellHexCoord = [self getHexCoordOfOtherCellGivenDyadmino:dyadmino andBoardNode:snapPoint];
  Cell *topCell = [self getCellWithHexCoord:topCellHexCoord];
  
    // if either cell is occupied, move is illegal, so return
  if (bottomCell.myDyadmino || topCell.myDyadmino) {
    return NO;
  }
  
    // assign dyadmino to cells
  bottomCell.myDyadmino = dyadmino;
  topCell.myDyadmino = dyadmino;
  
    // assign pc to cell based on dyadmino orientation
  switch (dyadmino.orientation) {
    case kPC1atTwelveOClock:
    case kPC1atTwoOClock:
    case kPC1atFourOClock:
      bottomCell.myPC = dyadmino.pc2;
      topCell.myPC = dyadmino.pc1;
      break;
    case kPC1atSixOClock:
    case kPC1atEightOClock:
    case kPC1atTenOClock:
      bottomCell.myPC = dyadmino.pc1;
      topCell.myPC = dyadmino.pc2;
      break;
  }
  
  [self.occupiedCells addObject:bottomCell];
  [self.occupiedCells addObject:topCell];

    /// testing purposes
  [bottomCell updatePCLabel];
  [topCell updatePCLabel];
  
  return YES;
}

-(BOOL)updateCellsForDyadmino:(Dyadmino *)dyadmino removedFromBoardNode:(SnapPoint *)snapPoint {
  
    // dyadmino is not placed on boardNode, so return
  if (snapPoint != dyadmino.tempBoardNode || snapPoint != dyadmino.homeNode) {
    return NO;
  }
  
  Cell *bottomCell = snapPoint.myCell;
  HexCoord topCellHexCoord = [self getHexCoordOfOtherCellGivenDyadmino:dyadmino andBoardNode:snapPoint];
  Cell *topCell = [self getCellWithHexCoord:topCellHexCoord];
  
    // if either cell doesn't have dyadmino as its dyadmino, return
  if (bottomCell.myDyadmino != dyadmino || topCell.myDyadmino != dyadmino) {
    return NO;
  }
  
    // dyadmino still knows its boardNode or homeNode in case it needs to return
    // this just clears the board for legal-chord-checking purposes
  
  bottomCell.myDyadmino = nil;
  topCell.myDyadmino = nil;
  bottomCell.myPC = -1;
  topCell.myPC = -1;
  
  [self.occupiedCells removeObject:bottomCell];
  [self.occupiedCells removeObject:topCell];
  
    /// testing purposes
  [bottomCell updatePCLabel];
  [topCell updatePCLabel];
  
  return YES;
}

-(HexCoord)getHexCoordOfOtherCellGivenDyadmino:(Dyadmino *)dyadmino andBoardNode:(SnapPoint *)snapPoint {
  NSInteger xHex = snapPoint.myCell.hexCoord.x;
  NSInteger yHex = snapPoint.myCell.hexCoord.y;
  
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
  for (Cell *cell in self.children) {
    if (cell.hexCoord.x == hexCoord.x && cell.hexCoord.y == hexCoord.y) {
      return cell;
    }
  }
  return nil;
}

@end
