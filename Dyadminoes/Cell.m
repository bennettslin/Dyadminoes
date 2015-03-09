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

@property (assign, nonatomic) NSUInteger minDistance;

@end

@implementation Cell {
  
  NSInteger _dominantPCArray[12];
  CGFloat _myRed, _myGreen, _myBlue, _myAlpha;
}

-(id)initWithTexture:(SKTexture *)texture
         andHexCoord:(HexCoord)hexCoord
        andHexOrigin:(CGVector)hexOrigin
           andResize:(BOOL)resize {
  
  self = [super init];
  if (self) {
    
    self.cellNodeTexture = texture;
    self.texture = self.cellNodeTexture;
    
    self.zPosition = kZPositionBoardCell;
//    self.colorBlendFactor = 0.9f;
    
//    [self createHexCoordLabel];
    [self updateHexCoordLabel];
//    [self createPCLabel];
    [self updatePCLabel];

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
  self.position = [Cell cellPositionWithHexOrigin:hexOrigin andHexCoord:self.hexCoord forResize:resize];
  self.size = [Cell cellSizeForResize:resize];
  [self updateHexCoordLabel];
  [self updatePCLabel];
}

-(void)resetForReuse {

  self.hidden = YES;
  [self setScale:0.f];
  self.myDyadmino = nil;
  self.myPC = -1;
  self.hexCoord = [self hexCoordFromX:NSIntegerMax andY:NSIntegerMax];
  self.name = [NSString stringWithFormat:@"cell %li, %li", (long)self.hexCoord.x, (long)self.hexCoord.y];
  
  [self resetColour];
  self.color = (SKColor *)[UIColor clearColor];
  
  [self renderColour];
  [self updateHexCoordLabel];
  [self updatePCLabel];
}

-(void)resetColour {
  
  self.minDistance = kCellsAroundDyadmino;

  _myRed = 0.f;
  _myGreen = 0.f;
  _myBlue = 0.f;
  _myAlpha = 0.f;
  
  memset(_dominantPCArray, 0, sizeof(_dominantPCArray));
}

-(void)addColourValueForPC:(NSUInteger)pc atDistance:(NSUInteger)distance {
  
  if (distance < self.minDistance) {
    self.minDistance = distance;
  }

  _dominantPCArray[pc] += (kCellsAroundDyadmino - distance + 1);
  
    // alpha is full when next to a dyadmino, and 0.2f at furthest distance
  CGFloat tempAlpha = 0.2 + 0.8 * (1.f / kCellsAroundDyadmino) * (kCellsAroundDyadmino - distance + 1);
  if (tempAlpha > _myAlpha) {
    _myAlpha = tempAlpha;
  }
}

-(void)renderColour {
  
  if (self.hidden) {
    [self fadeOut:NO completion:nil];
  }
  
    // first figure out the total number of values to compare
  NSUInteger total = 0;
  for (int i = 0; i < 12; i++) {
    total += _dominantPCArray[i];
  }
  
  if (total > 0) {
      // next, adjust colour of each pc based on values
    for (int i = 0; i < 12; i++) {
      NSUInteger valueForPC = _dominantPCArray[i];
      
      if (valueForPC > 0) {
        CGFloat multiplier = (CGFloat)valueForPC / (CGFloat)total;
        
        CGFloat red = 0.f, green = 0.f, blue = 0.f;
        UIColor *colourForPC = [self rawColourForPC:i];
        [colourForPC getRed:&red green:&green blue:&blue alpha:nil];
        
        _myRed += red * multiplier;
        _myBlue += blue * multiplier;
        _myGreen += green * multiplier;
      }
    }
    
    CGFloat duration = kConstantTime * (0.75f - (kCellsAroundDyadmino - self.minDistance) * 0.075f);
    
    [self removeActionForKey:@"colour"];
    SKColor *finalColour = (SKColor *)[UIColor colorWithRed:_myRed green:_myGreen blue:_myBlue alpha:_myAlpha];
    SKAction *colourAction = [SKAction colorizeWithColor:finalColour colorBlendFactor:self.colorBlendFactor duration:duration];
    SKAction *fadeAction = [SKAction fadeAlphaTo:_myAlpha duration:duration];
    SKAction *groupAction = [SKAction group:@[colourAction, fadeAction]];
    [self runAction:groupAction withKey:@"colour"];
  }
}

-(void)fadeOut:(BOOL)fadeOut completion:(void(^)(void))completion {
  
  CGFloat fadeAlpha = fadeOut ? 0.f : 1.f;
  CGFloat duration;
  
  if (fadeOut) {
    duration = kConstantTime * (0.75f - self.minDistance * (0.15f / kCellsAroundDyadmino));
  } else {
    self.hidden = NO;
    duration = kConstantTime * (0.75f - (kCellsAroundDyadmino - self.minDistance) * (0.15f / kCellsAroundDyadmino));
  }

  SKAction *shrinkAction = [SKAction scaleTo:fadeAlpha duration:duration];
  SKAction *completionAction = [SKAction runBlock:completion];
  SKAction *sequenceAction = [SKAction sequence:@[shrinkAction, completionAction]];
  [self runAction:sequenceAction withKey:@"cellFade"];
}

#pragma mark - cell view helper methods

-(void)animateResizeAndRepositionOfCell:(BOOL)resize withHexOrigin:(CGVector)hexOrigin andSize:(CGSize)cellSize {
  
  __weak typeof(self) weakSelf = self;
  CGFloat scaleTo = cellSize.height / self.size.height;
  
    // between .8 and .99
  CGFloat randomScaleFactor = ((arc4random() % 100) / 100.f * 0.19) + 0.8f;
  
    // 0.75f because zoom animation should be a little quicker than usual
  SKAction *scaleAction = [SKAction scaleTo:scaleTo duration:kConstantTime * 0.75f * randomScaleFactor];
  SKAction *completionAction = [SKAction runBlock:^{
    [weakSelf setScale:1.f];
    weakSelf.size = cellSize;
  }];
  SKAction *sequenceAction = [SKAction sequence:@[scaleAction, completionAction]];
  [self runAction:sequenceAction];
  
  CGPoint reposition = [Cell cellPositionWithHexOrigin:hexOrigin
                                     andHexCoord:self.hexCoord
                                       forResize:resize];
  
    // between .8 and .99
  CGFloat randomRepositionFactor = ((arc4random() % 100) / 100.f * 0.19) + 0.8f;
  
  SKAction *moveAction = [SKAction moveTo:reposition duration:kConstantTime * 0.75f * randomRepositionFactor];
  SKAction *moveCompletionAction = [SKAction runBlock:^{
    weakSelf.position = reposition;
  }];
  SKAction *moveSequenceAction = [SKAction sequence:@[moveAction, moveCompletionAction]];
  [self runAction:moveSequenceAction];
}

-(UIColor *)rawColourForPC:(NSInteger)pc {
  
    // this makes surrounding cells contrast against pc
    //  NSUInteger adjustedPC = (pc + 6) % 12;
  
    // this makes surrounding cells blend with pc
  NSUInteger adjustedPC = pc;
  
  switch (adjustedPC) {
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
      return [UIColor greenColor];
      break;
  }
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
  [self addChild:self.hexCoordLabel];
}

-(void)updateHexCoordLabel {
  
  NSString *boardXYString;
  if (self.hexCoord.x == NSIntegerMax && self.hexCoord.y == NSIntegerMax) {
    boardXYString = @"";
  } else {
    boardXYString = [NSString stringWithFormat:@"%li, %li", (long)self.hexCoord.x, (long)self.hexCoord.y];
  }
  
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
  [self addChild:self.pcLabel];
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
