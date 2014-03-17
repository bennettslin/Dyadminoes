//
//  Dyadmino.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Dyadmino.h"
#import "Board.h"

@interface Dyadmino ()

@property (nonatomic) CGPoint pivotAroundPoint;

@end

@implementation Dyadmino {
  BOOL _alreadyAddedChildren;
  CGSize _touchSize;
  PivotOnPC _pivotOnPC;
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

#pragma mark - orient and position methods

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
  
  switch (self.orientation) {
    case kPC1atTwelveOClock:
      self.texture = self.rotationFrameArray[0];
      [self resizeDyadmino];
      self.pc1Sprite.position = CGPointMake(0, self.size.height / 4);
      self.pc2Sprite.position = CGPointMake(0, -self.size.height / 4);
      break;
    case kPC1atTwoOClock:
      self.texture = self.rotationFrameArray[1];
      [self resizeDyadmino];
      self.pc1Sprite.position = CGPointMake(self.size.width * 1.5f / 7, self.size.height / 6);
      self.pc2Sprite.position = CGPointMake(-self.size.width * 1.5f / 7, -self.size.height / 6);
      break;
    case kPC1atFourOClock:
      self.texture = self.rotationFrameArray[2];
      [self resizeDyadmino];
      self.pc1Sprite.position = CGPointMake(self.size.width * 1.5f / 7, -self.size.height / 6);
      self.pc2Sprite.position = CGPointMake(-self.size.width * 1.5f / 7, self.size.height / 6);
      break;
    case kPC1atSixOClock:
      self.texture = self.rotationFrameArray[0];
      [self resizeDyadmino];
      self.pc1Sprite.position = CGPointMake(0, -self.size.height / 4);
      self.pc2Sprite.position = CGPointMake(0, self.size.height / 4);
      break;
    case kPC1atEightOClock:
      self.texture = self.rotationFrameArray[1];
      [self resizeDyadmino];
      self.pc1Sprite.position = CGPointMake(-self.size.width * 1.5f / 7, -self.size.height / 6);
      self.pc2Sprite.position = CGPointMake(self.size.width * 1.5f / 7, self.size.height / 6);
      break;
    case kPC1atTenOClock:
      self.texture = self.rotationFrameArray[2];
      [self resizeDyadmino];
      self.pc1Sprite.position = CGPointMake(-self.size.width * 1.5f / 7, self.size.height / 6);
      self.pc2Sprite.position = CGPointMake(self.size.width * 1.5f / 7, -self.size.height / 6);
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

-(void)orientBasedOnSextantChange:(CGFloat)sextantChange {
  for (NSUInteger i = 0; i < 12; i++) {
    if (sextantChange >= 0.f + i && sextantChange < 1.f + i) {
      NSUInteger dyadminoOrientationShouldBe = (self.prePivotDyadminoOrientation + i) % 6;
      if (self.orientation == dyadminoOrientationShouldBe) {
        return;
      } else {
        self.orientation = dyadminoOrientationShouldBe;
        
          // or else put this in an animation
        [self selectAndPositionSprites];
        return;
      }
    }
  }
}

-(void)resizeDyadmino {
  if (self.isTouchThenHoverResized) {
    self.size = CGSizeMake(self.texture.size.width * kTouchedDyadminoSize, self.texture.size.height * kTouchedDyadminoSize);
    self.pc1Sprite.size = CGSizeMake(self.pc1Sprite.texture.size.width * kTouchedDyadminoSize, self.pc1Sprite.texture.size.height * kTouchedDyadminoSize);
    self.pc2Sprite.size = CGSizeMake(self.pc2Sprite.texture.size.width * kTouchedDyadminoSize, self.pc2Sprite.texture.size.height * kTouchedDyadminoSize);
  } else {
    self.size = self.texture.size;
    self.pc1Sprite.size = self.pc1Sprite.texture.size;
    self.pc2Sprite.size = self.pc2Sprite.texture.size;
  }
}

-(CGPoint)getHomeNodePosition {
  if (self.belongsInSwap) {
    return [self addThisPoint:self.homeNode.position
                  toThisPoint:CGPointMake(0.f, self.homeNode.position.y + (kRackHeight / 2))];
  } else {
    return self.homeNode.position;
  }
}

#pragma mark - change status methods

-(void)startTouchThenHoverResize {
  self.isTouchThenHoverResized = YES;
  [self resizeDyadmino];
  [self selectAndPositionSprites];
}

-(void)endTouchThenHoverResize {
  self.isTouchThenHoverResized = NO;
  [self resizeDyadmino];
  [self selectAndPositionSprites];
}

-(void)startHovering {
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
  [self unhighlightOutOfPlay];
  [self orientBySnapNode:self.homeNode];
  self.zPosition = kZPositionRackMovedDyadmino;
  if (poppingIn) {
    [self animatePopBackIntoRackNode];
  } else {
    [self animateConstantSpeedMoveDyadminoToPoint:[self getHomeNodePosition]];
  }
  self.tempBoardNode = nil;
  [self setToHomeZPosition];
  [self finishHovering];
}

-(void)goFromTopBarToTempBoardNode {
  [self animateConstantSpeedMoveDyadminoToPoint:self.tempBoardNode.position];
  [self endTouchThenHoverResize];
  [self orientBySnapNode:self.tempBoardNode];
}

-(void)removeActionsAndEstablishNotRotating {
  [self removeAllActions];
  self.isRotating = NO;
}

#pragma mark - pivot methods

-(void)pivotBasedOnLocation:(CGPoint)location {
  
  NSLog(@"from dyadmino's pivotBasedOnLocation, dyadmino parent is %@", self.parent.name);
  
    // there should be a method here that gets the pivotAroundPoint based on the location and the pivotOnPC

    // for now
  self.pivotAroundPoint = self.position;
  
  NSLog(@"dyadmino pivotAroundPoint is %.1f, %.1f", self.pivotAroundPoint.x, self.pivotAroundPoint.y);
  
  CGFloat thisAngle = [self findAngleInDegreesFromThisPoint:location toThisPoint:self.pivotAroundPoint];
  CGFloat sextant = [self getSextantFromThisAngle:thisAngle toThisAngle:self.initialPivotAngle];
  
  for (NSUInteger i = 0; i < 12; i++) {
    if (sextant >= 0.f + i + kAngleForSnapToPivot && sextant < 1.f + i - kAngleForSnapToPivot) {
      NSUInteger dyadminoOrientationShouldBe = (self.prePivotDyadminoOrientation + i) % 6;
      if (self.orientation == dyadminoOrientationShouldBe) {
        return;
      } else {
        self.orientation = dyadminoOrientationShouldBe;
        
          // if it pivots on center, just go straight to positioning sprites
        if (_pivotOnPC != kPivotCentre) {
          
            // eventually get these numbers from board nodes
          CGFloat xIncrement = 18.43f * kTouchedDyadminoSize;
          CGFloat yIncrement = 10.55f * kTouchedDyadminoSize;
          
          DyadminoOrientation pivotOrientation = dyadminoOrientationShouldBe;
          
          NSUInteger pivotOnPC2Offset = 0;
          if (_pivotOnPC == kPivotOnPC2) {
            pivotOrientation = 3 + pivotOrientation;
            pivotOnPC2Offset = 3;
          }
          
          pivotOrientation = pivotOrientation % 6;
          
          CGPoint tempPosition;
          
          switch ((self.prePivotDyadminoOrientation + pivotOnPC2Offset) % 6) {
            case 0:
              tempPosition = self.prePivotPosition;
              break;
            case 1:
              tempPosition = [self addThisPoint:self.prePivotPosition toThisPoint:CGPointMake(xIncrement, -yIncrement)];
              break;
            case 2:
              tempPosition = [self addThisPoint:self.prePivotPosition toThisPoint:CGPointMake(xIncrement, -yIncrement * 3.f)];
              break;
            case 3:
              tempPosition = [self addThisPoint:self.prePivotPosition toThisPoint:CGPointMake(0.f, -yIncrement * 4.f)];
              break;
            case 4:
              tempPosition = [self addThisPoint:self.prePivotPosition toThisPoint:CGPointMake(-xIncrement, -yIncrement * 3.f)];
              break;
            case 5:
              tempPosition = [self addThisPoint:self.prePivotPosition toThisPoint:CGPointMake(-xIncrement, -yIncrement)];
              break;
          }
          
          CGPoint position8oclock = [self addThisPoint:tempPosition toThisPoint:CGPointMake(-xIncrement, yIncrement)];
          CGPoint position10oclock = [self addThisPoint:tempPosition toThisPoint:CGPointMake(-xIncrement, yIncrement * 3.f)];
          CGPoint position12oclock = [self addThisPoint:tempPosition toThisPoint:CGPointMake(0.f, yIncrement * 4.f)];
          CGPoint position2oclock = [self addThisPoint:tempPosition toThisPoint:CGPointMake(xIncrement, yIncrement * 3.f)];
          CGPoint position4oclock = [self addThisPoint:tempPosition toThisPoint:CGPointMake(xIncrement, yIncrement)];
          CGPoint position6oclock = tempPosition;
          
          switch (pivotOrientation) {
            case 0:
              self.position = position6oclock;
              break;
            case 1:
              self.position = position8oclock;
              break;
            case 2:
              self.position = position10oclock;
              break;
            case 3:
              self.position = position12oclock;
              break;
            case 4:
              self.position = position2oclock;
              break;
            case 5:
              self.position = position4oclock;
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

-(void)animateConstantTimeMoveToPoint:(CGPoint)point {
  [self removeActionsAndEstablishNotRotating];
  SKAction *moveAction = [SKAction moveTo:point duration:kConstantTime];
  [self runAction:moveAction];
}

-(void)animateSlowerConstantTimeMoveToPoint:(CGPoint)point {
  [self removeActionsAndEstablishNotRotating];
  SKAction *moveAction = [SKAction moveTo:point duration:kSlowerConstantTime];
  [self runAction:moveAction];
}

-(void)animateConstantSpeedMoveDyadminoToPoint:(CGPoint)point{
  [self removeActionsAndEstablishNotRotating];
  CGFloat distance = [self getDistanceFromThisPoint:self.position toThisPoint:point];
  SKAction *moveAction = [SKAction moveTo:point duration:kConstantSpeed * distance];
  [self runAction:moveAction];
}

-(void)animatePopBackIntoRackNode {
  [self removeActionsAndEstablishNotRotating];
  SKAction *shrinkAction = [SKAction scaleTo:0.f duration:kConstantTime];
  SKAction *repositionAction = [SKAction runBlock:^{
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
      self.tempReturnOrientation = self.orientation;
      self.hoveringStatus = kDyadminoHovering;
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
    self.prePivotPosition = self.position;
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

-(PivotOnPC)determinePivotOnPC {
  CGFloat originOffset;
  switch (self.orientation) {
    case kPC1atTwelveOClock:
      originOffset = 0.f;
      break;
    case kPC1atTwoOClock:
      originOffset = 60.f;
      break;
    case kPC1atFourOClock:
      originOffset = 120.f;
      break;
    case kPC1atSixOClock:
      originOffset = 180.f;
      break;
    case kPC1atEightOClock:
      originOffset = 240.f;
      break;
    case kPC1atTenOClock:
      originOffset = 300.f;
      break;
  }
  CGFloat offsetAngle = self.initialPivotAngle + originOffset;
  if (offsetAngle > 360.f) {
    offsetAngle -= 360.f;
  }
  
  if (offsetAngle > 210.f && offsetAngle <= 330.f) {
    _pivotOnPC = kPivotOnPC1;
  } else if (offsetAngle >= 30.f && offsetAngle <= 150.f) {
    _pivotOnPC = kPivotOnPC2;
  } else {
    _pivotOnPC = kPivotCentre;
  }
  return _pivotOnPC;
}

-(CGFloat)getHeightFloatGivenGap:(CGFloat)gap andDyadminoPosition:(CGPoint)dyadminoOffsetPosition {
  
    // returns 0 at bottom, gradually reaches 1 at peak...
  if (dyadminoOffsetPosition.y < kRackHeight + (gap / 2) &&
      dyadminoOffsetPosition.y >= kRackHeight - (gap / 2)) {
    return (dyadminoOffsetPosition.y + (gap / 2) - kRackHeight) / gap;
    
      // then returns 1 thereafter
  } else if (dyadminoOffsetPosition.y > kRackHeight + (gap / 2)) {
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