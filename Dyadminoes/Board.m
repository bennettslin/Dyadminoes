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

@property (strong, nonatomic) SKSpriteNode *backgroundNode;

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
    self.size = size;
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
  }
  return self;
}

-(void)reloadBackgroundImage {
  
  NSLog(@"reload background image");
  UIImage *backgroundImage = [UIImage imageNamed:@"Bennett_Lin.jpg"];
  CGImageRef backgroundCGImage = backgroundImage.CGImage;
  CGRect textureSize = CGRectMake(self.position.x, self.position.y, backgroundImage.size.width, backgroundImage.size.height);
  
  UIGraphicsBeginImageContextWithOptions(self.size, YES, 2.f); // use WithOptions to set scale for retina display
  CGContextRef context = UIGraphicsGetCurrentContext();
    // Core Graphics coordinates are upside down from Sprite Kit's
  CGContextScaleCTM(context, 1.0, -1.0);
  CGContextDrawTiledImage(context, textureSize, backgroundCGImage);
  UIImage *tiledBackground = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  SKTexture *backgroundTexture = [SKTexture textureWithCGImage:tiledBackground.CGImage];
  self.backgroundNode.size = self.size;
  self.backgroundNode.texture = backgroundTexture;
  
  self.backgroundNode.position = [self subtractFromThisPoint:self.origin thisPoint:self.position];
}

-(void)layoutBoardCellsAndSnapPointsOfDyadminoes:(NSSet *)boardDyadminoes {
  
    // hex origin is only set once
  if (!_hexOriginSet) {
    _vectorOrigin = [self determineOutermostCellsBasedOnDyadminoes:boardDyadminoes];
    _hexOriginSet = YES;
  } else {
    [self determineOutermostCellsBasedOnDyadminoes:boardDyadminoes];
  }
  
    // formula is y <= cellsTop - (x / 2) and y >= cellsBottom - (x / 2)
    // use this to get the range to iterate over y, and to keep the board square
  for (NSInteger xHex = self.cellsLeft; xHex <= self.cellsRight; xHex++) {
    for (NSInteger yHex = self.cellsBottom - self.cellsRight / 2; yHex <= self.cellsTop - self.cellsLeft / 2; yHex++) {

      if (xHex >= self.cellsLeft && xHex <= self.cellsRight &&
          yHex <= self.cellsTop - ((xHex - 1) / 2.f) && yHex >= self.cellsBottom - (xHex / 2.f)) {
          // might be faster in the initial layout to add cells directly
          // without checking to see if they're already in allCells
        [self acknowledgeOrAddCellWithXHex:xHex andYHex:yHex];
//        _cellCount++;
      }
    }
  }
  [self determineBoardPositionBounds];
//  NSLog(@"cell count is %i", _cellCount);
  NSLog(@"would have called reload background image");
}

#pragma mark - cell methods

-(Cell *)findCellWithXHex:(NSInteger)xHex andYHex:(NSInteger)yHex {
  for (Cell *cell in self.allCells) {
    if (cell.hexCoord.x == xHex && cell.hexCoord.y == yHex) {
      return cell;
    }
  }
  return nil;
}

-(Cell *)acknowledgeOrAddCellWithXHex:(NSInteger)xHex andYHex:(NSInteger)yHex {
//  NSLog(@"acknowledge or add cell being called?!");
    // this method first checks to see if cell exists in allCells array
    // if not, it instantiates it

    // first check to see if cell already exists
  Cell *cell = [self findCellWithXHex:xHex andYHex:yHex];
  
    // if cell does not exist, create and add it
  if (!cell) {
    cell = [[Cell alloc] initWithBoard:self
                            andTexture:[SKTexture textureWithImageNamed:@"blankSpace"]
                           andHexCoord:[self hexCoordFromX:xHex andY:yHex]
                          andVectorOrigin:_vectorOrigin];
    
    cell.cellNode.hidden = NO;
    [self addChild:cell.cellNode];
    [self.allCells addObject:cell];
    [cell addSnapPointsToBoard];
  }
//  NSLog(@"cell %@ added", cell.name);
  return cell;
}

//-(Cell *)ignoreCell:(Cell *)cell {
//    // cells do *not* get deallocated or taken out of allCells array when ignored,
//    // they are only removed from parent
//    // not sure if this is the best approach, but do this for now...
//  
//  cell.hidden = YES;
//  [cell removeFromParent];
//  [cell removeSnapPointsFromBoard];
//  [self determineBoardPositionBounds];
//  return cell;
//}

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
  
  self.cellsTop = cellsTop + extraYCells;
  self.cellsRight = cellsRight + extraXCells;
  self.cellsBottom = cellsBottom - extraYCells;
  self.cellsLeft = cellsLeft - extraXCells;
  
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

-(void)updateCellsForDyadmino:(Dyadmino *)dyadmino placedOnBoardNode:(SnapPoint *)snapPoint {
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
        
          /// testing purposes
        [cell updatePCLabel];
      }
    }
//    NSLog(@"cells placed on board");
  }
}

-(void)updateCellsForDyadmino:(Dyadmino *)dyadmino removedFromBoardNode:(SnapPoint *)snapPoint {
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
        cell.myDyadmino = nil;
        cell.myPC = -1;
        
//        NSLog(@"cell.myDyadmino is %@", cell.myDyadmino.name);
        
        [self.occupiedCells removeObject:cell];
        
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

@end
