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

@interface Board ()

@property (strong, nonatomic) SKSpriteNode *backgroundNode;
@property (strong, nonatomic) NSMutableSet *dequeuedCells;

@end

@implementation Board {
  
    // testing purposes
  NSInteger _cellCount;
  
  CGFloat _cellsInVertRange;
  CGFloat _cellsInHorzRange;
  BOOL _cellsTopXIsEven;
  BOOL _cellsBottomXIsEven;
  BOOL _hexOriginSet;
  CGVector _vectorOrigin;
  
  NSInteger _oldCellsTop;
  NSInteger _oldCellsBottom;
  NSInteger _oldCellsLeft;
  NSInteger _oldCellsRight;
}

-(id)initWithColor:(UIColor *)color andSize:(CGSize)size
    andAnchorPoint:(CGPoint)anchorPoint
   andHomePosition:(CGPoint)homePosition
         andOrigin:(CGPoint)origin
      andZPosition:(CGFloat)zPosition {
  self = [super init];
  if (self) {
    
    self.name = @"board";
    self.color = color;
    self.size = CGSizeMake(size.width * 2, size.height * 2);
    self.anchorPoint = anchorPoint;
    self.homePosition = homePosition;
    self.origin = origin;
    self.position = self.homePosition;
    self.zPosition = zPosition;
    self.backgroundNode = [[SKSpriteNode alloc] init];
    [self addChild:self.backgroundNode];

      // instantiate node and cell arrays to be searched
    self.snapPointsTwelveOClock = [NSMutableSet new];
    self.snapPointsTwoOClock = [NSMutableSet new];
    self.snapPointsTenOClock = [NSMutableSet new];
    self.occupiedCells = [NSMutableSet new];
    self.allCells = [NSMutableSet new];
    
      // create new cells from get-go
    self.dequeuedCells = [NSMutableSet new];
//    for (int i = 0; i < kIsIPhone ? 120 : 240; i++) {
//      Cell *cell = [[Cell alloc] initWithBoard:self
//                                    andTexture:[SKTexture textureWithImageNamed:@"blankSpace"]
//                                   andHexCoord:[self hexCoordFromX:0 andY:0]
//                               andVectorOrigin:_vectorOrigin];
//      [self.dequeuedCells addObject:cell];
//    }
    
      // testing
    _cellCount = 0;
    
      // these values are necessary for board movement
      // see determineBoardPositionBounds method for explanation
    _cellsInVertRange = ((self.origin.y - kRackHeight) / kDyadminoFaceDiameter);
    _cellsInHorzRange = (self.origin.x / kDyadminoFaceWideDiameter);
    
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
    
    _hexOriginSet = NO;
    
//    [self initLoadBackgroundImage];
  }
  return self;
}

#pragma mark - cell methods

-(void)repositionCellsAndDyadminoesForZoomOut:(BOOL)resize {
  
    // zoom out
  if (resize) {
    for (Cell *cell in self.allCells) {
//      if ([self.occupiedCells containsObject:cell]) {
        [cell resizeCell:YES withVectorOrigin:_vectorOrigin];
//      } else {
//        cell.cellNode.hidden = YES;
//      }
    }
    
      // zoom back in
  } else {
    for (Cell *cell in self.allCells) {
//      if ([self.occupiedCells containsObject:cell]) {
        [cell resizeCell:NO withVectorOrigin:_vectorOrigin];
//      } else {
//        cell.cellNode.hidden = NO;
//      }
    }
  }
}

-(void)layoutBoardCellsAndSnapPointsOfDyadminoes:(NSSet *)boardDyadminoes {

    // hex origin is only set once
  if (!_hexOriginSet) {
    _vectorOrigin = [self determineOutermostCellsBasedOnDyadminoes:boardDyadminoes];
    _hexOriginSet = YES;
  } else {
    [self determineOutermostCellsBasedOnDyadminoes:boardDyadminoes];
  }
  
    // covers all cells in old range plus new range
  NSInteger maxCellsTop = _oldCellsTop > self.cellsTop ? _oldCellsTop : self.cellsTop;
  NSInteger minCellsBottom = _oldCellsBottom < self.cellsBottom ? _oldCellsBottom : self.cellsBottom;
  NSInteger maxCellsRight = _oldCellsRight > self.cellsRight ? _oldCellsRight : self.cellsRight;
  NSInteger minCellsLeft = _oldCellsLeft < self.cellsLeft ? _oldCellsLeft : self.cellsLeft;
//  NSLog(@"top %i, bottom %i, right %i, left %i", maxCellsTop, minCellsBottom, maxCellsRight, minCellsLeft);
  
    // formula is y <= cellsTop - (x / 2) and y >= cellsBottom - (x / 2)
    // use this to get the range to iterate over y, and to keep the board square
  for (NSInteger xHex = minCellsLeft; xHex <= maxCellsRight; xHex++) {
    for (NSInteger yHex = minCellsBottom - maxCellsRight / 2.f; yHex <= maxCellsTop - minCellsLeft / 2.f; yHex++) {
      
      if (xHex >= self.cellsLeft && xHex <= self.cellsRight &&
          yHex <= self.cellsTop - ((xHex - 1) / 2.f) && yHex >= self.cellsBottom - (xHex / 2.f)) {
        [self acknowledgeOrAddCellWithXHex:xHex andYHex:yHex];
        
      } else {
          //          NSLog(@"ignoring cell from layout board");
        [self ignoreCellWithXHex:xHex andYHex:yHex];
      }
    }
  }
  
//  NSLog(@"self.allCells count %i", self.allCells.count);
  [self determineBoardPositionBounds];
  
  NSLog(@"self.allCells %i, self.occupiedCells %i, self.dequeuedCells %i", self.allCells.count, self.occupiedCells.count, self.dequeuedCells.count);
  NSLog(@"board nodes %i, %i, %i", self.snapPointsTenOClock.count, self.snapPointsTwelveOClock.count, self.snapPointsTwoOClock.count);
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
      [cell initCellWithHexCoord:[self hexCoordFromX:xHex andY:yHex] andVectorOrigin:_vectorOrigin];
    } else {
      cell = [[Cell alloc] initWithBoard:self
                              andTexture:[SKTexture textureWithImageNamed:@"blankSpace"]
                             andHexCoord:[self hexCoordFromX:xHex andY:yHex]
                         andVectorOrigin:_vectorOrigin];
    }
///*
    if (!cell.cellNode) {
      [cell instantiateCellNode];
    } else {
      [cell initPositionCellNode];
    }
    
//    cell.cellNode.hidden = NO;
    if (!cell.cellNode.parent) {
      [self addChild:cell.cellNode];
    }
//*/
    
//    NSLog(@"cell %@ added, self.allCells count %i", cell.name, self.allCells.count);
    
    if (![self.allCells containsObject:cell]) {
      [self.allCells addObject:cell];
//      NSLog(@"now self.allCells count %i", self.allCells.count);
      [cell addSnapPointsToBoard];
    }
  }
  return cell;
}

-(void)ignoreCellWithXHex:(NSInteger)xHex andYHex:(NSInteger)yHex {
  Cell *cell = [self findCellWithXHex:xHex andYHex:yHex];
  if (cell) {
    if (cell.cellNode) {
//      cell.cellNode.hidden = YES;
      [cell.cellNode removeFromParent];
    }
//    NSLog(@"cell %@ removed, self.allCells count %i", cell.name, self.allCells.count);
    
    if ([self.allCells containsObject:cell]) {
      [self.allCells removeObject:cell];
//      NSLog(@"now self.allCells count %i", self.allCells.count);
      [cell removeSnapPointsFromBoard];
    }
    [self pushDequeuedCell:cell];
  }
}

-(void)pushDequeuedCell:(Cell *)cell {
  if (![self.dequeuedCells containsObject:cell]) {
    [self.dequeuedCells addObject:cell];
  }
//  NSLog(@"pushed cell %@, dequeued cells is %i", cell.name, self.dequeuedCells.count);
}

-(Cell *)popDequeuedCell {
  Cell *cell = [self.dequeuedCells anyObject];
  if ([cell isKindOfClass:[Cell class]]) {
    [self.dequeuedCells removeObject:cell];
  }
  return cell;
}

#pragma mark - board span methods

-(CGVector)determineOutermostCellsBasedOnDyadminoes:(NSSet *)boardDyadminoes {
  
    // ridiculously high numbers arbitrarily chosen to force limits
    // not sure if this is the best approach...
  NSInteger cellsTop = -99999999;
  NSInteger cellsRight = -99999999;
  NSInteger cellsBottom = 99999999;
  NSInteger cellsLeft = 99999999;
  
  for (Dyadmino *dyadmino in boardDyadminoes) {

    HexCoord hexCoord1;
    HexCoord hexCoord2;

    if (dyadmino.homeNode) {
      SnapPoint *boardNode;
      
        // different board nodes, depending on whether dyadmino belongs in rack
      if ([dyadmino belongsInRack]) {
        boardNode = dyadmino.tempBoardNode;
      } else {
        boardNode = dyadmino.homeNode;
      }
      struct HexCoord tempHexCoord1 = boardNode.myCell.hexCoord;
      struct HexCoord tempHexCoord2 = [self getHexCoordOfOtherCellGivenDyadmino:dyadmino andBoardNode:boardNode];
      hexCoord1 = tempHexCoord1;
      hexCoord2 = tempHexCoord2;
    
        // if instantiating, dyadmino does not have boardNode
    } else {
//      NSLog(@"dyadmino %i does not have board node", dyadmino.myID);
      struct HexCoord tempHexCoord1 = dyadmino.myHexCoord;
      struct HexCoord tempHexCoord2 = [self getHexCoordOfOtherCellGivenDyadmino:dyadmino andBoardNode:nil];
      hexCoord1 = tempHexCoord1;
      hexCoord2 = tempHexCoord2;
    }
    
    HexCoord hexCoord[2] = {hexCoord1, hexCoord2};
    
    for (int i = 0; i < 2; i++) {
      NSInteger xHex = hexCoord[i].x;
      NSInteger yHex = hexCoord[i].y;
      
        // check x span - this one is easy enough
      if (xHex > cellsRight) {
        cellsRight = xHex;
      }
      if (xHex < cellsLeft) {
        cellsLeft = xHex;
      }
      
        // now check y span, which means...
        // next, subtract cell when x is negative to compensate for rounding down
        // and yes, it has to be in this order!
      NSInteger workingXHex = xHex;
      if (xHex < 0) {
        workingXHex = xHex - 1;
      }
      
        // this compensates for the fact that when x is odd, y is offset by half a cell
      CGFloat workingYHex = yHex;
      if (abs(xHex) % 2 == 1) {
        workingYHex = yHex + 0.5;
      }
      
      if (workingYHex > cellsTop - workingXHex / 2) {
        cellsTop = yHex + workingXHex / 2;
          // board y-coord bounds will be different depending on whether x is odd or even
        if (abs(xHex) % 2 == 0) {
          _cellsTopXIsEven = YES;
        } else {
          _cellsTopXIsEven = NO;
        }
      }
      
      if (workingYHex < cellsBottom - workingXHex / 2) {
        cellsBottom = yHex + workingXHex / 2;
        if (abs(xHex) % 2 == 0) {
          _cellsBottomXIsEven = YES;
        } else {
          _cellsBottomXIsEven = NO;
        }
      }
        //  NSLog(@"yHex is %i, this value is %.1f", yHex, cellsTop - (xHex / 2.f));
        //  NSLog(@"yHex %i, cellsTop %i, xHex / 2 is %.1f", yHex, cellsTop, xHex / 2.f);
        //  NSLog(@"xHex is %i, yHex is %i", xHex, yHex);
    }
  }
      // buffer cells beyond outermost dyadmino
  NSInteger extraYCells;
  switch (cellsTop - cellsBottom) {
    case 0:
    case 1:
    case 2:
      extraYCells = kIsIPhone? 5 : 7;
      break;
    case 3:
    case 4:
      extraYCells = kIsIPhone? 4 : 6;
      break;
    default:
      extraYCells = kIsIPhone? 4 : 5;
      break;
  }
 
  NSInteger extraXCells;
  switch (cellsRight - cellsLeft) {
    case 0:
    case 1:
      extraXCells = kIsIPhone? 5 : 8;
      break;
    case 2:
    case 3:
      extraXCells = kIsIPhone? 4 : 7;
      break;
    case 4:
    case 5:
      extraXCells = kIsIPhone? 4 : 6;
      break;
    case 6:
    case 7:
      extraXCells = kIsIPhone? 4 : 5;
      break;
    default:
      extraXCells = kIsIPhone? 4 : 4;
      break;
  }
  
  _oldCellsTop = self.cellsTop;
  _oldCellsBottom = self.cellsBottom;
  _oldCellsRight = self.cellsRight;
  _oldCellsLeft = self.cellsLeft;

  self.cellsTop = cellsTop + extraYCells;
  self.cellsRight = cellsRight + extraXCells;
  self.cellsBottom = cellsBottom - extraYCells;
  self.cellsLeft = cellsLeft - extraXCells;
  
//  NSLog(@"top %i, right %i, bottom %i, left %i", self.cellsTop, self.cellsRight, self.cellsBottom, self.cellsLeft);
  
    // returns general center
  return CGVectorMake(((self.cellsRight - self.cellsLeft) / 2) + self.cellsLeft, ((self.cellsTop - self.cellsBottom - 1) / 2) + self.cellsBottom);
}

-(void)determineBoardPositionBounds {
    // this should get called after every method that adds cells or removes them
  
    // board y-coord bounds will be different depending on whether x is odd or even
  if (_cellsTopXIsEven) {
    CGFloat lowYBufferValue = -_vectorOrigin.dy + (kIsIPhone ? -0.5 : -1.5);
    self.lowestYPos = self.origin.y - (self.cellsTop - _cellsInVertRange + lowYBufferValue) * kDyadminoFaceDiameter;
  } else {
    CGFloat lowYBufferValue = -_vectorOrigin.dy + (kIsIPhone ? 0 : -1.0);
    self.lowestYPos = self.origin.y - (self.cellsTop - _cellsInVertRange + lowYBufferValue) * kDyadminoFaceDiameter;
  }
  CGFloat lowXBufferValue = -_vectorOrigin.dx + (kIsIPhone ? 0.25 : -.25);
  self.lowestXPos = self.origin.x - (self.cellsRight - _cellsInHorzRange + lowXBufferValue) * kDyadminoFaceWideDiameter;
  
  if (_cellsBottomXIsEven) {
    CGFloat highYBufferValue = -_vectorOrigin.dy + (kIsIPhone ? -0.5 : 0.5);
    self.highestYPos = self.origin.y - (self.cellsBottom + _cellsInVertRange + highYBufferValue) * kDyadminoFaceDiameter;
  } else {
    CGFloat highYBufferValue = -_vectorOrigin.dy + (kIsIPhone ? 0: 1.0);
    self.highestYPos = self.origin.y - (self.cellsBottom + _cellsInVertRange + highYBufferValue) * kDyadminoFaceDiameter;
  }
  CGFloat highXBufferValue = -_vectorOrigin.dx + (kIsIPhone ? -0.25 : 0.25);
  self.highestXPos = self.origin.x - (self.cellsLeft + _cellsInHorzRange + highXBufferValue) * kDyadminoFaceWideDiameter;
  
  /*
    cellsTop determines lowest Y position
    cellsBottom determines highest Y position
    cellsRight determines lowest X position
    cellsLeft determines highest X position
  
    cellsInVertRange and cellsInHorzRange is the number of cells
    that span one half-height or half-width of screen

    so that number gets subtracted from the actual number of cells
    in, let's say, the top half, then multiplied by the cell diameter
    (which is different horizontally), then subtracted from the origin
    to indicate how far away from the origin the board position is allowed to be
   
    furthest cell seen from outermost vertical cell is 4.5 cells away
    furthest cell seen from outermost horizontal cell is 4.5 cells away
    that half cell is not seen after it snaps back
   
    of course, on iPad, these numbers may be different
    origin on iPhone 4-inch is 160, 298
   */
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
        
        // assign dyadmino to cell
        cell.myDyadmino = dyadmino;
        
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
          // add to board's array of occupied cells to search
        [self.occupiedCells addObject:cell];
        
        if (colour) {
          [self changeColoursAroundCell:cell withSign:1];
        }
        
          /// testing purposes
        [cell updatePCLabel];
      }
    }
  }
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

//      NSLog(@"cell.myDyadmino is %@", cell.myDyadmino.name);
      
        // only remove if cell dyadmino is dyadmino
      if (cell.myDyadmino == dyadmino) {
        
//        NSLog(@"cell.myDyadmino is %@", cell.myDyadmino.name);
        
        [self.occupiedCells removeObject:cell];
       
        if (colour) {
          [self changeColoursAroundCell:cell withSign:-1];
        }
        
        cell.myDyadmino = nil;
        cell.myPC = -1;
          /// testing purposes
        [cell updatePCLabel];
      }
    }
//    NSLog(@"cells removed from board");
  }
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
    
    NSInteger range = 8;
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
  if (pc != -1) {

//    CGFloat colourFactor = (factor >= 2) ? factor - 2 : 0;
    CGFloat colourFactor = factor * 0.5f;
    
    NSInteger redMult, greenMult, blueMult;
    CGFloat redVal, greenVal, blueVal, alphaVal;
    
//    if (colourFactor > 0) {
      // returns the opposite colour. So for example, pc 0 returns red 0, green 4, blue 4
      redMult = 6 - abs(6 - pc);
      redMult = redMult >= 4 ? 4 : redMult;
      greenMult = 6 - abs(6 - ((pc + 4) % 12));
      greenMult = greenMult >= 4 ? 4 : greenMult;
      blueMult = 6 - abs(6 - ((pc + 8) % 12));
      blueMult = blueMult >= 4 ? 4 : blueMult;
//    } else {
//      redMult = 0;
//      greenMult = 0;
//      blueMult = 0;
//    }
  
//      NSLog(@"for pc %i, redMult %i, greenMult %i, blueMult %i", pc, redMult, greenMult, blueMult);
//    colourFactor;
    redVal = (sign * colourFactor * redMult * kCellColourMultiplier);
    greenVal = (sign * colourFactor * greenMult * kCellColourMultiplier);
    blueVal = (sign * colourFactor * blueMult * kCellColourMultiplier);
    alphaVal = (sign * factor * 7 * kCellColourMultiplier);
//      NSLog(@"for pc %i, redVal %.2f, greenVal %.2f, blueVal %.2f", pc, redVal, greenVal, blueVal);
    
    [cellToColour addColourWithRed:redVal green:greenVal blue:blueVal alpha:alphaVal];
  }
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
  
    // if it's the first dyadmino
  if ([self.delegate isFirstDyadmino:dyadmino]) {
//    NSLog(@"first dyadmino!");
    return kNoError;
  } else {
    // otherwise, it's a lone dyadmino
    return kErrorLoneDyadmino;
  }
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
  NSArray *colourArray = @[kPivotOrange, kPivotOrange, kPivotOrange, kPivotOrange,
                           kYellow, kYellow,
                           kYellow, kPivotOrange, kPivotOrange];
  
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
      shapeNode.lineWidth = 0.75;
      shapeNode.alpha = kPivotGuideAlpha;
      shapeNode.strokeColor = colourArray[i];
      shapeNode.fillColor = colourArray[i];
      [pivotGuide addChild:shapeNode];
    }
  }
  return pivotGuide;
}

-(void)showPivotGuide:(SKNode *)pivotGuide forDyadmino:(Dyadmino *)dyadmino {
  if (!pivotGuide.parent) {
    if (pivotGuide == self.prePivotGuide || pivotGuide == self.pivotRotateGuide) {
      pivotGuide.position = dyadmino.position;
    } else {
      pivotGuide.position = dyadmino.pivotAroundPoint;
    }
    
    CGFloat degree = (dyadmino.orientation) * -60.f;
    while (degree > 360.f) {
      degree -= 360.f;
    }

    pivotGuide.zRotation = [self getRadiansFromDegree:degree];
    
    [self addChild:pivotGuide];
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
  if (pivotGuide.parent) {
    [pivotGuide removeFromParent];
    pivotGuide.hidden = YES;
  }
}

-(void)hidePivotGuideAndShowPrePivotGuideForDyadmino:(Dyadmino *)dyadmino {
  NSLog(@"hide pivot guide and show prepivot guide");
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
//  CGFloat changeInAngle = [self getChangeFromThisAngle:touchAngle toThisAngle:dyadmino.initialPivotAngle];
  
    //// pivot guide positions and rotations should be established in determinePivotOnPC methods
    //// Here, they are adjusted. This should change, obviously
  self.pivotAroundGuide.position = dyadmino.pivotAroundPoint;
  self.pivotRotateGuide.position = dyadmino.pivotAroundPoint;
  self.pivotAroundGuide.zRotation = [self getRadiansFromDegree:touchAngle];
  self.pivotRotateGuide.zRotation = [self getRadiansFromDegree:touchAngle];
}

  // these might be used for replay mode
#pragma mark - background image methods

-(void)initLoadBackgroundImage {
  UIImage *backgroundImage = [UIImage imageNamed:@"MaryFloral.jpeg"];
  CGImageRef backgroundCGImage = backgroundImage.CGImage;
  CGRect textureSize = CGRectMake(self.position.x, self.position.y, backgroundImage.size.width / 2, backgroundImage.size.height / 2);
  
  UIGraphicsBeginImageContextWithOptions(self.size, YES, 2.f); // use WithOptions to set scale for retina display
  CGContextRef context = UIGraphicsGetCurrentContext();
    // Core Graphics coordinates are upside down from Sprite Kit's
  CGContextScaleCTM(context, 1.0, -1.0);
  CGContextDrawTiledImage(context, textureSize, backgroundCGImage);
  UIImage *tiledBackground = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  SKTexture *backgroundTexture = [SKTexture textureWithCGImage:tiledBackground.CGImage];
  self.backgroundNode.texture = backgroundTexture;
}

-(void)reloadBackgroundImage {
    //  dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_queue_t aQueue = dispatch_queue_create("whatever", NULL);
  dispatch_async(aQueue, ^{
    self.backgroundNode.size = self.size;
    self.backgroundNode.position = [self subtractFromThisPoint:self.origin thisPoint:self.position];
  });
}

@end
