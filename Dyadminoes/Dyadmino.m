//
//  Dyadmino.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Dyadmino.h"
#import "Board.h"

@implementation Dyadmino {
  BOOL _alreadyAddedChildren;
  CGSize _touchSize;
//  PivotOnPC _pivotOnPC;
}

#pragma mark - init and layout methods

-(id)initWithPC1:(NSUInteger)pc1 andPC2:(NSUInteger)pc2 andPCMode:(PCMode)pcMode
  andRotationFrameArray:(NSArray *)rotationFrameArray
  andPC1LetterSprite:(SKSpriteNode *)pc1LetterSprite
  andPC2LetterSprite:(SKSpriteNode *)pc2LetterSprite
  andPC1NumberSprite:(SKSpriteNode *)pc1NumberSprite
  andPC2NumberSprite:(SKSpriteNode *)pc2NumberSprite {
  self = [super init];
  if (self) {
      // constants
    self.color = [UIColor yellowColor]; // for color blend factor
    self.zPosition = kZPositionRackRestingDyadmino;
    self.name = [NSString stringWithFormat:@"dyadmino %lu-%lu", (unsigned long)pc1, (unsigned long)pc2];
    self.pc1 = pc1;
    self.pc2 = pc2;
    self.pcMode = pcMode;
    self.rotationFrameArray = rotationFrameArray;
    self.pc1LetterSprite = pc1LetterSprite;
    self.pc2LetterSprite = pc2LetterSprite;
    self.pc1NumberSprite = pc1NumberSprite;
    self.pc2NumberSprite = pc2NumberSprite;
    self.hoveringStatus = kDyadminoNoHoverStatus;
    [self randomiseRackOrientation];
    [self selectAndPositionSprites];
  }
  return self;
}

-(void)randomiseRackOrientation { // only gets called before sprite is reloaded
  NSUInteger zeroOrOne = [self randomValueUpTo:2]; // randomise rackOrientation
  if (zeroOrOne == 0) {
    self.orientation = kPC1atTwelveOClock;
  } else if (zeroOrOne == 1) {
    self.orientation = kPC1atSixOClock;
  }
  self.tempReturnOrientation = self.orientation;
}

#pragma mark - orient, position, and size methods

-(void)establishSizeOfSprite:(SKSpriteNode *)sprite {
  CGFloat resizeFactor;
  if (self.isTouchThenHoverResized) {
    resizeFactor = kDyadminoResizedFactor;
  } else {
    resizeFactor = 1.f;
  }

    // size is different if not vertical orientation
  CGFloat orientationFactor;
  if (self.orientation == kPC1atTwelveOClock || self.orientation == kPC1atSixOClock) {
    orientationFactor = 4.f;
  } else {
    orientationFactor = 3.f;
  }
  
  CGFloat pcRelativeSizeFactor = 10 / 7.f;
  
  CGFloat ySize;
  if (sprite == self) {
    ySize = kDyadminoFaceRadius * orientationFactor;
  } else { // sprite is a pc
    ySize = kDyadminoFaceRadius * pcRelativeSizeFactor;
  }
  
  CGFloat widthToHeightRatio = sprite.texture.size.width / sprite.texture.size.height;
  CGFloat xSize = widthToHeightRatio * ySize;
  sprite.size = CGSizeMake(xSize * resizeFactor, ySize * resizeFactor);
}

-(void)resizeBasedOnHoveringStatus {
  [self establishSizeOfSprite:self];
  [self establishSizeOfSprite:self.pc1Sprite];
  [self establishSizeOfSprite:self.pc2Sprite];
}

-(void)selectAndPositionSprites {
  if (self.pcMode == kPCModeLetter) {
    if (!self.pc1Sprite || self.pc1Sprite == self.pc1NumberSprite) {
      _alreadyAddedChildren = YES;
      [self removeAllChildren];
      self.pc1Sprite = self.pc1LetterSprite;
      self.pc2Sprite = self.pc2LetterSprite;
      [self addChild:self.pc1Sprite];
      [self addChild:self.pc2Sprite];
    }
  } else if (self.pcMode == kPCModeNumber) {
    if (!self.pc1Sprite || self.pc1Sprite == self.pc1LetterSprite) {
      _alreadyAddedChildren = YES;
      [self removeAllChildren];
      self.pc1Sprite = self.pc1NumberSprite;
      self.pc2Sprite = self.pc2NumberSprite;
      [self addChild:self.pc1Sprite];
      [self addChild:self.pc2Sprite];
    }
  }
  
  CGFloat resizeFactor;
  if (self.isTouchThenHoverResized) {
    resizeFactor = kDyadminoResizedFactor;
  } else {
    resizeFactor = 1;
  }
  
  CGFloat yVertical = kDyadminoFaceRadius * resizeFactor;
  CGFloat ySlant = kDyadminoFaceRadius * 0.5 * resizeFactor;
  CGFloat xSlant = kDyadminoFaceRadius * 0.5 * kSquareRootOfThree * resizeFactor;
  
  switch (self.orientation) {
    case kPC1atTwelveOClock:
      self.texture = self.rotationFrameArray[0];
      [self resizeBasedOnHoveringStatus];
      self.pc1Sprite.position = CGPointMake(0, yVertical);
      self.pc2Sprite.position = CGPointMake(0, -yVertical);
      break;
    case kPC1atTwoOClock:
      self.texture = self.rotationFrameArray[1];
      [self resizeBasedOnHoveringStatus];
      self.pc1Sprite.position = CGPointMake(xSlant, ySlant);
      self.pc2Sprite.position = CGPointMake(-xSlant, -ySlant);
      break;
    case kPC1atFourOClock:
      self.texture = self.rotationFrameArray[2];
      [self resizeBasedOnHoveringStatus];
      self.pc1Sprite.position = CGPointMake(xSlant, -ySlant);
      self.pc2Sprite.position = CGPointMake(-xSlant, ySlant);
      break;
    case kPC1atSixOClock:
      self.texture = self.rotationFrameArray[0];
      [self resizeBasedOnHoveringStatus];
      self.pc1Sprite.position = CGPointMake(0, -yVertical);
      self.pc2Sprite.position = CGPointMake(0, yVertical);
      break;
    case kPC1atEightOClock:
      self.texture = self.rotationFrameArray[1];
      [self resizeBasedOnHoveringStatus];
      self.pc1Sprite.position = CGPointMake(-xSlant, -ySlant);
      self.pc2Sprite.position = CGPointMake(xSlant, ySlant);
      break;
    case kPC1atTenOClock:
      self.texture = self.rotationFrameArray[2];
      [self resizeBasedOnHoveringStatus];
      self.pc1Sprite.position = CGPointMake(-xSlant, ySlant);
      self.pc2Sprite.position = CGPointMake(xSlant, -ySlant);
      break;
  }
}

-(void)orientBySnapNode:(SnapPoint *)snapNode {
  switch (snapNode.snapPointType) {
    case kSnapPointRack:
      if (self.orientation <= 1 || self.orientation >= 5) {
        self.orientation = 0;
      } else {
        self.orientation = 3;
      }
      break;
    default: // snapNode is on board
      self.orientation = self.tempReturnOrientation;
      break;
  }
  [self selectAndPositionSprites];
}

-(CGPoint)getHomeNodePosition {
  if (self.belongsInSwap) {
    return [self addToThisPoint:self.homeNode.position
                  thisPoint:CGPointMake(0.f, self.homeNode.position.y + (kRackHeight / 2))];
  } else {
    return self.homeNode.position;
  }
}

#pragma mark - change status methods

-(void)startTouchThenHoverResize {
  self.isTouchThenHoverResized = YES;
  [self resizeBasedOnHoveringStatus];
  [self selectAndPositionSprites];
}

-(void)endTouchThenHoverResize {
  self.isTouchThenHoverResized = NO;
  [self resizeBasedOnHoveringStatus];
  [self selectAndPositionSprites];
}

-(void)startHovering {
    // this is the only place where prePivot guide is made visible
    // starting from no pivot guides
  
//  NSLog(@"start hovering?!");
  self.hoveringStatus = kDyadminoHovering;
}

-(void)keepHovering {
  self.hoveringStatus = kDyadminoContinuesHovering;
}

-(void)finishHovering {
  self.hoveringStatus = kDyadminoFinishedHovering;
}

-(void)unhighlightOutOfPlay {
// TODO: possibly some animation here
  self.colorBlendFactor = 0.f;
}

-(void)adjustHighlightGivenDyadminoOffsetPosition:(CGPoint)dyadminoOffsetPosition {
  CGFloat inPlayFloat = [self getHeightFloatGivenGap:kGapForHighlight andDyadminoPosition:dyadminoOffsetPosition];
  self.colorBlendFactor = kDyadminoColorBlendFactor * inPlayFloat;
}

#pragma mark - change state methods

-(void)setToHomeZPosition {
  if (self.homeNode.snapPointType == kSnapPointRack) {
    self.zPosition = kZPositionRackRestingDyadmino;
  } else {
    self.zPosition = kZPositionBoardRestingDyadmino;
  }
}

-(void)goHomeByPoppingIn:(BOOL)poppingIn {
    // move these into a completion block for animation

  if (poppingIn) {
    [self animatePopBackIntoRackNode];
    
  } else {
    [self orientBySnapNode:self.homeNode];
    [self animateMoveToPoint:[self getHomeNodePosition]];
    [self unhighlightOutOfPlay];
    self.zPosition = kZPositionRackMovedDyadmino;
  }
  
  self.tempBoardNode = nil;
  [self setToHomeZPosition];
  [self finishHovering];
}

-(void)goToBoardNode {
  [self endTouchThenHoverResize];
  if ([self belongsInRack]) {
    [self orientBySnapNode:self.tempBoardNode];
    [self animateMoveToPoint:self.tempBoardNode.position];
  } else {
    [self orientBySnapNode:self.homeNode];
    [self animateMoveToPoint:self.homeNode.position];
  }
}

-(void)removeActionsAndEstablishNotRotating {
  [self removeAllActions];
  self.isRotating = NO;
}

#pragma mark - pivot methods

-(CGPoint)determinePivotAroundPointBasedOnPivotOnPC:(PivotOnPC)pivotOnPC {
  
    // if it's pivoting around center, then it's just the dyadmino position
  if (pivotOnPC == kPivotCentre) {
    self.pivotAroundPoint = self.position;
    
      // otherwise it's one of the pc faces
  } else {
    CGPoint pivotOffset;
    CGFloat yVertical = kDyadminoFaceRadius * kDyadminoResizedFactor;
    CGFloat xSlant = kDyadminoFaceRadius * 0.5 * kSquareRootOfThree * kDyadminoResizedFactor;
    CGFloat ySlant = kDyadminoFaceRadius * 0.5 * kDyadminoResizedFactor;
    
      // if pc2, pivot orientation is offset
    DyadminoOrientation pivotOrientation = self.prePivotDyadminoOrientation;
    if (pivotOnPC == kPivotOnPC2) {
      pivotOrientation = 3 + pivotOrientation;
    }
    pivotOrientation = pivotOrientation % 6;
    
    switch (pivotOrientation) {
      case kPC1atTwelveOClock:
        pivotOffset = CGPointMake(0.f, yVertical);
        break;
      case kPC1atTwoOClock:
        pivotOffset = CGPointMake(xSlant, ySlant);
        break;
      case kPC1atFourOClock:
        pivotOffset = CGPointMake(xSlant, -ySlant);
        break;
      case kPC1atSixOClock:
        pivotOffset = CGPointMake(0, -yVertical);
        break;
      case kPC1atEightOClock:
        pivotOffset = CGPointMake(-xSlant, -ySlant);
        break;
      case kPC1atTenOClock:
        pivotOffset = CGPointMake(-xSlant, ySlant);
        break;
    }
    self.pivotAroundPoint = [self addToThisPoint:self.position thisPoint:pivotOffset];
  }
  return self.pivotAroundPoint;
}

-(void)pivotBasedOnTouchLocation:(CGPoint)touchLocation andPivotOnPC:(PivotOnPC)pivotOnPC {
    // initial pivotOnPC is dyadmino position
  
    // ensures that touch doesn't get too close to pivotAroundPoint
  if ([self getDistanceFromThisPoint:touchLocation toThisPoint:self.pivotAroundPoint] < kMinDistanceForPivot) {
    return;
  }
  
    // establish angles
  CGFloat touchAngle = [self findAngleInDegreesFromThisPoint:touchLocation toThisPoint:self.pivotAroundPoint];
  CGFloat changeInAngle = [self getChangeFromThisAngle:touchAngle toThisAngle:self.initialPivotAngle];
  
    //// Figure out if all of this would be easier if we just made the pivotAroundPoint the temporary dyadmino position
  for (NSUInteger i = 0; i < 12; i++) {
    if (changeInAngle >= i + kAngleForSnapToPivot &&
        changeInAngle < (i + 1) - kAngleForSnapToPivot) {
      
      NSUInteger newOrientation = (self.prePivotDyadminoOrientation + i) % 6;
      
        // if orientation hasn't changed, just return
      if (self.orientation != newOrientation) {
        self.orientation = newOrientation;
        
          // if it pivots on center, just go straight to positioning sprites
        if (pivotOnPC != kPivotCentre) {
          
          CGFloat xIncrement = kDyadminoFaceRadius * 0.5 * kSquareRootOfThree * kDyadminoResizedFactor;
          CGFloat yIncrement = kDyadminoFaceRadius * 0.5 * kDyadminoResizedFactor;
          
            // pivot orientation starts out as the dyadmino orientation
          DyadminoOrientation pivotOrientation = newOrientation;
          
            // if pc2, pivot orientation is offset
          NSUInteger pivotOnPC2Offset = 0;
          if (pivotOnPC == kPivotOnPC2) {
            pivotOrientation = 3 + pivotOrientation;
            pivotOnPC2Offset = 3;
          }
          pivotOrientation = pivotOrientation % 6;
          
            // when orientation changes, dyadmino will be in new position
          CGPoint newPosition;
          switch ((self.prePivotDyadminoOrientation + pivotOnPC2Offset) % 6) {
            case 0:
              newPosition = self.initialPivotPosition;
              break;
            case 1:
              newPosition = [self addToThisPoint:self.initialPivotPosition thisPoint:CGPointMake(xIncrement, -yIncrement)];
              break;
            case 2:
              newPosition = [self addToThisPoint:self.initialPivotPosition thisPoint:CGPointMake(xIncrement, -yIncrement * 3)];
              break;
            case 3:
              newPosition = [self addToThisPoint:self.initialPivotPosition thisPoint:CGPointMake(0, -yIncrement * 4)];
              break;
            case 4:
              newPosition = [self addToThisPoint:self.initialPivotPosition thisPoint:CGPointMake(-xIncrement, -yIncrement * 3)];
              break;
            case 5:
              newPosition = [self addToThisPoint:self.initialPivotPosition thisPoint:CGPointMake(-xIncrement, -yIncrement)];
              break;
          }
          
          switch (pivotOrientation) {
            case 0:
              self.position = newPosition;
              break;
            case 1:
              self.position = [self addToThisPoint:newPosition thisPoint:CGPointMake(-xIncrement, yIncrement)];
              break;
            case 2:
              self.position = [self addToThisPoint:newPosition thisPoint:CGPointMake(-xIncrement, yIncrement * 3)];
              break;
            case 3:
              self.position = [self addToThisPoint:newPosition thisPoint:CGPointMake(0, yIncrement * 4)];
              break;
            case 4:
              self.position = [self addToThisPoint:newPosition thisPoint:CGPointMake(xIncrement, yIncrement * 3)];
              break;
            case 5:
              self.position = [self addToThisPoint:newPosition thisPoint:CGPointMake(xIncrement, yIncrement)];
              break;
          }
        }
        
          // or else put this in an animation
        [self selectAndPositionSprites];
      }
    }
  }
}

#pragma mark - animation methods

-(void)animateMoveToPoint:(CGPoint)point{
  [self removeActionsAndEstablishNotRotating];
  CGFloat distance = [self getDistanceFromThisPoint:self.position toThisPoint:point];
  SKAction *moveAction = [SKAction moveTo:point duration:kConstantSpeed * distance];
  [self runAction:moveAction];
}

-(void)animatePopBackIntoRackNode {
  [self removeActionsAndEstablishNotRotating];
  SKAction *shrinkAction = [SKAction scaleTo:0.f duration:kConstantTime];
  SKAction *repositionAction = [SKAction runBlock:^{
    [self unhighlightOutOfPlay];
    [self orientBySnapNode:self.homeNode];
    self.zPosition = kZPositionRackMovedDyadmino;
    self.position = [self getHomeNodePosition];
  }];
  SKAction *growAction = [SKAction scaleTo:1.f duration:kConstantTime];
  SKAction *sequenceAction = [SKAction sequence:@[shrinkAction, repositionAction, growAction]];
  [self runAction:sequenceAction];
}

-(void)animateFlip {
  [self removeActionsAndEstablishNotRotating];
  self.isRotating = YES;
  
  SKAction *nextFrame = [SKAction runBlock:^{
    self.orientation = (self.orientation + 1) % 6;
    [self selectAndPositionSprites];
  }];
  SKAction *waitTime = [SKAction waitForDuration:kRotateWait];
  SKAction *finishAction;
  
    // rotation
  if ([self isInRack] || [self isOrBelongsInSwap]) {
    finishAction = [SKAction runBlock:^{
      [self finishHovering];
      [self setToHomeZPosition];
      [self endTouchThenHoverResize];
      self.isRotating = NO;
    }];
      // just to ensure that dyadmino is back in its node position
    self.position = [self getHomeNodePosition];
    
  } else if ([self isOnBoard]) {
    finishAction = [SKAction runBlock:^{
      self.isRotating = NO;
      [self keepHovering];
      NSLog(@"animate flip, now prepare for hover");
      NSLog(@"delegate is %@", self.delegate);
      [self.delegate prepareForHoverThisDyadmino:self];
      self.canFlip = NO;
    }];
  }
  
  SKAction *completeAction = [SKAction sequence:@[nextFrame, waitTime, nextFrame, waitTime, nextFrame, finishAction]];
  [self runAction:completeAction];
}

-(void)animateEaseIntoNodeAfterHover {
  
    // animate to homeNode as default, to tempBoardNode if it's a rack dyadmino
  CGPoint settledPosition = [self getHomeNodePosition];
  if ([self belongsInRack] && [self isOnBoard]) {
    settledPosition = self.tempBoardNode.position;
  }
  
  SKAction *moveAction = [SKAction moveTo:settledPosition duration:kConstantTime];
  SKAction *finishAction = [SKAction runBlock:^{
    [self endTouchThenHoverResize];
    [self setToHomeZPosition];
    
    self.canFlip = NO;
    self.hoveringStatus = kDyadminoNoHoverStatus;
    self.initialPivotPosition = self.position;
  }];
  SKAction *sequence = [SKAction sequence:@[moveAction, finishAction]];
  [self runAction:sequence];
}

#pragma mark - bool methods

-(BOOL)isOrBelongsInSwap {
  return self.belongsInSwap;
}

-(BOOL)belongsInRack {
  return (self.homeNode.snapPointType == kSnapPointRack);
}

-(BOOL)belongsOnBoard {
  return (self.homeNode.snapPointType == kSnapPointBoardTwelveOClock ||
          self.homeNode.snapPointType == kSnapPointBoardTwoOClock ||
          self.homeNode.snapPointType == kSnapPointBoardTenOClock);
}

-(BOOL)isInRack {
  return [self.parent.name isEqualToString:@"rack"];
}

-(BOOL)isOnBoard {
  return [self.parent.name isEqualToString:@"board"];
}

-(BOOL)isLocatedInTopBar {
  return self.isInTopBar;
}

-(BOOL)isHovering {
  if (self.hoveringStatus == kDyadminoHovering) {
    return YES;
  } else {
    return NO;
  }
}

-(BOOL)continuesToHover {
  if (self.hoveringStatus == kDyadminoContinuesHovering) {
    return YES;
  } else {
    return NO;
  }
}

-(BOOL)isFinishedHovering {
  if (self.hoveringStatus == kDyadminoFinishedHovering) {
    return YES;
  } else {
    return NO;
  }
}

#pragma mark - helper methods

-(CGFloat)getHeightFloatGivenGap:(CGFloat)gap andDyadminoPosition:(CGPoint)dyadminoOffsetPosition {
  
    // returns 0 at bottom, gradually reaches 1 at peak...
  if (dyadminoOffsetPosition.y < kRackHeight + (gap * 0.5) &&
      dyadminoOffsetPosition.y >= kRackHeight - (gap * 0.5)) {
    return (dyadminoOffsetPosition.y + (gap * 0.5) - kRackHeight) / gap;
    
      // then returns 1 thereafter
  } else if (dyadminoOffsetPosition.y > kRackHeight + (gap * 0.5)) {
    return 1.f;
  } else {
    return 0.f;
  }
}

#pragma mark - debugging methods

-(NSString *)logThisDyadmino {
  if (self) {
    NSString *tempString = [NSString stringWithFormat:@"%@ is in swap mode %i", self.name, self.belongsInSwap];
    return tempString;
  } else {
    return @"dyadmino doesn't exist";
  }
}

@end