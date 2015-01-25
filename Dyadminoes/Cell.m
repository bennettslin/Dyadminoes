//
//  Cell.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/16/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Cell.h"

#define kPaddingBetweenCells (kIsIPhone ? 0.f : 0.f)

@interface Cell ()

@end

@implementation Cell {
  
  CGFloat _dominantPCArray[12];
  CGFloat _red, _green, _blue, _alpha;
}

-(id)initWithTexture:(SKTexture *)texture
         andHexCoord:(HexCoord)hexCoord
        andHexOrigin:(CGVector)hexOrigin
           andResize:(BOOL)resize {
  
  self = [super init];
  if (self) {
    
    self.cellNodeTexture = texture;
    [self reuseCellWithHexCoord:hexCoord andHexOrigin:hexOrigin forResize:resize];
  }
  return self;
}

-(void)reuseCellWithHexCoord:(HexCoord)hexCoord
                andHexOrigin:(CGVector)hexOrigin
                   forResize:(BOOL)resize {
  
  [self resetForReuse];
  
  self.hexCoord = hexCoord;
  self.name = [NSString stringWithFormat:@"cell %li, %li", (long)self.hexCoord.x, (long)self.hexCoord.y];
  
    // establish cell position in normal size
  CGPoint position = [Cell cellPositionWithHexOrigin:hexOrigin andHexCoord:self.hexCoord forResize:resize];
  CGSize cellSize = [Cell cellSizeForResize:resize];
  
  self.cellNode ?
      [self initCellNodeWithPosition:position andSize:cellSize] :
      [self instantiateCellNodeWithPosition:position andSize:cellSize];
}

-(void)resetForReuse {

  self.myDyadmino = nil;
  self.myPC = -1;
  self.hexCoord = [self hexCoordFromX:NSIntegerMax andY:NSIntegerMax];
  self.name = [NSString stringWithFormat:@"cell %li, %li", (long)self.hexCoord.x, (long)self.hexCoord.y];
  
    // reset colour
  _red = 0.2f;
  _green = 0.2f;
  _blue = 0.2f;
  _alpha = 0.2f;

  memset(_dominantPCArray, 0, sizeof(_dominantPCArray));
  
  if (self.cellNode) {
    [self renderColour];
  }
}

-(void)addColourValueForPC:(NSUInteger)pc atDistance:(NSUInteger)distance {

  _dominantPCArray[pc] += (kCellsAroundDyadmino - distance + 1);
  
    // alpha is full when next to a dyadmino, and 0.2f at furthest distance
  CGFloat tempAlpha = (1.f / kCellsAroundDyadmino) * (kCellsAroundDyadmino - distance + 1);
  if (tempAlpha > _alpha) {
    _alpha = tempAlpha;
  }
}

-(void)renderColour {
  
  NSInteger maxPC = 0;
  for (int i = 0; i < 12; i++) {
    if (_dominantPCArray[i] > 0 && _dominantPCArray[i] > _dominantPCArray[maxPC]) {
      maxPC = i;
    }
  }
  
  if (_dominantPCArray[maxPC] == 0) {
    maxPC = -1;
  }
  
  SKColor *pureColour = [self colourForPC:maxPC];
  SKColor *colourWithAlpha = [pureColour colorWithAlphaComponent:_alpha];
  self.cellNode.color = colourWithAlpha;
}

-(UIColor *)colourForPC:(NSInteger)pc {
  switch (pc) {
    case 0:
      return [UIColor colorWithRed:100/100.f green:0/100.f blue:0/100.f alpha:100/100.f];
      break;
    case 1:
      return [UIColor colorWithRed:0/100.f green:70/100.f blue:55/100.f alpha:100/100.f];
      break;
    case 2:
      return [UIColor colorWithRed:86/100.f green:0/100.f blue:88/100.f alpha:100/100.f];
      break;
    case 3:
      return [UIColor colorWithRed:67/100.f green:91/100.f blue:0/100.f alpha:100/100.f];
      break;
    case 4:
      return [UIColor colorWithRed:32/100.f green:25/100.f blue:100/100.f alpha:100/100.f];
      break;
    case 5:
      return [UIColor colorWithRed:100/100.f green:53/100.f blue:10/100.f alpha:100/100.f];
      break;
    case 6:
      return [UIColor colorWithRed:0/100.f green:65/100.f blue:82/100.f alpha:100/100.f];
      break;
    case 7:
      return [UIColor colorWithRed:100/100.f green:0/100.f blue:51/100.f alpha:100/100.f];
      break;
    case 8:
      return [UIColor colorWithRed:9/100.f green:61/100.f blue:0/100.f alpha:100/100.f];
      break;
    case 9:
      return [UIColor colorWithRed:57/100.f green:17/100.f blue:95/100.f alpha:100/100.f];
      break;
    case 10:
      return [UIColor colorWithRed:94/100.f green:86/100.f blue:0/100.f alpha:100/100.f];
      break;
    case 11:
      return [UIColor colorWithRed:5/100.f green:40/100.f blue:94/100.f alpha:100/100.f];
      break;
    default:
      return [UIColor darkGrayColor];
      break;
  }
}

#pragma mark - cell node methods

-(void)instantiateCellNodeWithPosition:(CGPoint)position andSize:(CGSize)cellSize {
  
  self.cellNode = [[SKSpriteNode alloc] init];
  self.cellNode.name = @"cellNode";
  self.cellNode.texture = self.cellNodeTexture;
  self.cellNode.zPosition = kZPositionBoardCell;
  self.cellNode.colorBlendFactor = .9f;
  self.cellNode.size = cellSize;
  [self initCellNodeWithPosition:position andSize:cellSize];
  
    //// for testing purposes
  if (self.cellNode) {
    [self createHexCoordLabel];
    [self updateHexCoordLabel];
    [self createPCLabel];
    [self updatePCLabel];
  }
}

-(void)initCellNodeWithPosition:(CGPoint)position andSize:(CGSize)cellSize {
  self.cellNode.position = position;
  self.cellNode.size = cellSize;
  [self updateHexCoordLabel];
  [self updatePCLabel];
}

#pragma mark - cell view helper methods

-(void)animateResizeAndRepositionOfCell:(BOOL)resize withHexOrigin:(CGVector)hexOrigin andSize:(CGSize)cellSize {
  
  __weak typeof(self) weakSelf = self;
  CGFloat scaleTo = cellSize.height / self.cellNode.size.height;
  
    // between .6 and .99
  CGFloat randomScaleFactor = ((arc4random() % 100) / 100.f * 0.39) + 0.6f;
  
  SKAction *scaleAction = [SKAction scaleTo:scaleTo duration:kConstantTime * randomScaleFactor];
  SKAction *completionAction = [SKAction runBlock:^{
    [weakSelf.cellNode setScale:1.f];
    weakSelf.cellNode.size = cellSize;
  }];
  SKAction *sequenceAction = [SKAction sequence:@[scaleAction, completionAction]];
  [self.cellNode runAction:sequenceAction];
  
  CGPoint reposition = [Cell cellPositionWithHexOrigin:hexOrigin
                                     andHexCoord:self.hexCoord
                                       forResize:resize];
  
    // between .6 and .99
  CGFloat randomRepositionFactor = ((arc4random() % 100) / 100.f * 0.39) + 0.6f;
  
  SKAction *moveAction = [SKAction moveTo:reposition duration:kConstantTime * randomRepositionFactor];
  SKAction *moveCompletionAction = [SKAction runBlock:^{
    weakSelf.cellNode.position = reposition;
  }];
  SKAction *moveSequenceAction = [SKAction sequence:@[moveAction, moveCompletionAction]];
  [self.cellNode runAction:moveSequenceAction];
}

#pragma mark - cell size and position helper methods

+(CGSize)cellSizeForResize:(BOOL)resize {
  
  CGFloat factor = resize ? kZoomResizeFactor : 1.f;
  CGFloat ySize = (kDyadminoFaceRadius * 2 - kPaddingBetweenCells) * factor;
  CGFloat widthToHeightRatio = kTwoOverSquareRootOfThree;
  CGFloat xSize = widthToHeightRatio * ySize;
  return CGSizeMake(xSize, ySize);
}

+(CGPoint)cellPositionWithHexOrigin:(CGVector)hexOrigin andHexCoord:(HexCoord)hexCoord forResize:(BOOL)resize {
  
    // to make node between two faces the center
  CGFloat factor = resize ? kZoomResizeFactor : 1.f;
  CGFloat yOffset = kDyadminoFaceRadius * factor;
  CGFloat padding = kPaddingBetweenCells * factor;
  
  CGSize thisCellSize = [Cell cellSizeForResize:resize];
  
  CGFloat cellWidth = thisCellSize.width;
  CGFloat cellHeight = thisCellSize.height;
  CGFloat newX = (hexCoord.x - hexOrigin.dx) * (0.75 * cellWidth + padding);
  CGFloat newY = (hexCoord.y - hexOrigin.dy + hexCoord.x * 0.5) * (cellHeight + padding) - yOffset;
  
  return CGPointMake(newX, newY);
}

+(CGPoint)snapPositionForHexCoord:(HexCoord)hexCoord
                      orientation:(DyadminoOrientation)orientation
                        andResize:(BOOL)resize
                   givenHexOrigin:(CGVector)hexOrigin {
  
  CGPoint cellNodePosition = [Cell cellPositionWithHexOrigin:hexOrigin andHexCoord:hexCoord forResize:resize];
  CGFloat faceOffset = resize ? kDyadminoFaceRadius * kZoomResizeFactor : kDyadminoFaceRadius;
  
    // based on a 30-60-90 degree triangle
  CGFloat faceOffsetX = faceOffset * 0.5 * kSquareRootOfThree;
  CGFloat faceOffsetY = faceOffset * 0.5;
  
  switch (orientation) {
    case kPC1atTwoOClock:
    case kPC1atEightOClock:
      return [self addToThisPoint:cellNodePosition thisPoint:CGPointMake(faceOffsetX, faceOffsetY)];
      break;
    case kPC1atFourOClock:
    case kPC1atTenOClock:
      return [self addToThisPoint:cellNodePosition thisPoint:CGPointMake(-faceOffsetX, faceOffsetY)];
      break;
    case kPC1atTwelveOClock:
    case kPC1atSixOClock:
    default:
      return [self addToThisPoint:cellNodePosition thisPoint:CGPointMake(0.f, faceOffset)];
      break;
  }
}

#pragma mark - testing methods

-(void)createHexCoordLabel {
  self.hexCoordLabel = [[SKLabelNode alloc] init];
  self.hexCoordLabel.fontSize = 12.f;
  self.hexCoordLabel.alpha = 1.f;
  self.hexCoordLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
  self.hexCoordLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
  self.hexCoordLabel.position = CGPointMake(0, 5.f);
//  self.hexCoordLabel.hidden = YES;
  [self.cellNode addChild:self.hexCoordLabel];
}

-(void)updateHexCoordLabel {
  NSString *boardXYString = [NSString stringWithFormat:@"%li, %li", (long)self.hexCoord.x, (long)self.hexCoord.y];
  self.hexCoordLabel.name = boardXYString;
  self.hexCoordLabel.text = boardXYString;
  
    // determine font colour
  self.hexCoordLabel.fontColor = [SKColor whiteColor];
  if (self.hexCoord.x == 0 || self.hexCoord.y == 0 || self.hexCoord.x + self.hexCoord.y == 0)
    self.hexCoordLabel.fontColor = [SKColor yellowColor];
  if (self.hexCoord.x == 0 && (self.hexCoord.y == 0 || self.hexCoord.y == 1))
    self.hexCoordLabel.fontColor = [SKColor greenColor];
}

-(void)createPCLabel {
  self.pcLabel = [[SKLabelNode alloc] init];
  self.pcLabel.fontColor = kTestRed;
  self.pcLabel.fontSize = 14.f;
  self.pcLabel.alpha = 1.f;
  self.pcLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
  self.pcLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
  self.pcLabel.position = CGPointMake(0, -9.f);
//  self.pcLabel.hidden = YES;
  [self.cellNode addChild:self.pcLabel];
}

-(void)updatePCLabel {
  NSString *pcString;
  if (self.myPC == -1) {
    pcString = @"";
  } else {
    pcString = [NSString stringWithFormat:@"%li", (long)self.myPC];
  }
  self.pcLabel.name = pcString;
  self.pcLabel.text = pcString;
}

@end
