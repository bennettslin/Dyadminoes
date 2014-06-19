//
//  Dyadmino.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Dyadmino.h"
#import "Board.h"

#define kActionMoveToPoint @"moveToPoint"
#define kActionPopIntoBoard @"popIntoBoard"
#define kActionPopIntoRack @"popIntoRack"
#define kActionFlip @"flip"
#define kActionEaseIntoNode @"easeIntoNode"
#define kActionShowRecentlyPlayed @"recentlyPlayed"
#define kActionSoundFace @"animateFace"

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
    self.color = kHighlightedDyadminoYellow; // for color blend factor
    self.zPosition = kZPositionRackRestingDyadmino;
    self.name = [NSString stringWithFormat:@"dyadmino %lu-%lu", (unsigned long)pc1, (unsigned long)pc2];
    self.pc1 = pc1;
    self.pc2 = pc2;
    self.pcMode = pcMode;
    self.rotationFrameArray = rotationFrameArray;
    self.pc1LetterSprite = pc1LetterSprite;
    self.pc1LetterSprite.zPosition = kZPositionDyadminoFace;
    self.pc2LetterSprite = pc2LetterSprite;
    self.pc2LetterSprite.zPosition = kZPositionDyadminoFace;
    self.pc1NumberSprite = pc1NumberSprite;
    self.pc1NumberSprite.zPosition = kZPositionDyadminoFace;
    self.pc2NumberSprite = pc2NumberSprite;
    self.pc2NumberSprite.zPosition = kZPositionDyadminoFace;
    self.hoveringStatus = kDyadminoNoHoverStatus;
    [self selectAndPositionSprites];
  }
  return self;
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
  
    // FIXME: actions conflict
//  SKAction *bounceScaleIn = [SKAction scaleTo:kDyadminoResizedFactor * 1.1f duration:0.125f];
//  SKAction *bounceScaleOut = [SKAction scaleTo:kDyadminoResizedFactor duration:0.25f];
//  SKAction *complete = [SKAction runBlock:^{
    self.isTouchThenHoverResized = YES;
    [self resizeBasedOnHoveringStatus];
    [self selectAndPositionSprites];
//  }];
//  SKAction *faceSequence = [SKAction sequence:@[bounceScaleIn, bounceScaleOut]];
//  SKAction *dyadminoSequence = [SKAction sequence:@[bounceScaleIn, bounceScaleOut, complete]];
//  [self runAction:dyadminoSequence];
//  [self.pc1Sprite runAction:faceSequence];
//  [self.pc2Sprite runAction:faceSequence];
}

-(void)endTouchThenHoverResize {
  self.isTouchThenHoverResized = NO;
  [self resizeBasedOnHoveringStatus];
  [self selectAndPositionSprites];
}

  // only update method sets to kDyadminoHovering
//-(void)startHovering {
//    // this is the only place where prePivot guide is made visible
//    // starting from no pivot guides
//  
////  NSLog(@"start hovering?!");
//  self.hoveringStatus = kDyadminoHovering;
//}

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

-(void)highlightBoardDyadmino {
  self.color = kPlayedDyadminoBlue;
  self.colorBlendFactor = kDyadminoColorBlendFactor;
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
//  NSLog(@"dyadmino's go home by popping in method called");
    // move these into a completion block for animation

  if (poppingIn) {
    [self animatePopBackIntoRackNode];
    
  } else {
    [self orientBySnapNode:self.homeNode];
    [self animateMoveToPoint:[self getHomeNodePosition]];
//    [self unhighlightOutOfPlay];
    self.zPosition = kZPositionRackMovedDyadmino;
  }
  
  self.tempBoardNode = nil;
  [self setToHomeZPosition];
  [self finishHovering];
}

-(void)removeActionsAndEstablishNotRotating {
  [self.pc1Sprite setScale:1.f];
  [self.pc2Sprite setScale:1.f];
  [self removeActionForKey:kActionMoveToPoint];
  [self removeActionForKey:kActionPopIntoRack];
  [self removeActionForKey:kActionFlip];
  [self removeActionForKey:kActionEaseIntoNode];
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
        
          // sound dyadmino click
        [self.delegate soundDyadminoPivotClick];
        
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
  [self runAction:moveAction withKey:kActionMoveToPoint];
}

-(void)animatePopBackIntoBoardNode {
//  NSLog(@"dyadmino's animate to board node method called");
  [self endTouchThenHoverResize];
  [self removeActionsAndEstablishNotRotating];
  SKAction *shrinkAction = [SKAction scaleTo:0.f duration:kConstantTime];
  SKAction *repositionAction = [SKAction runBlock:^{
    [self.delegate soundDyadminoSuck];
    if ([self belongsInRack]) {
      [self orientBySnapNode:self.tempBoardNode];
      self.position = self.tempBoardNode.position;
    } else {
//      NSLog(@"this is called because it's a board dyadmino");
      [self orientBySnapNode:self.homeNode];
      self.position = self.homeNode.position;
    }
    self.zPosition = kZPositionBoardRestingDyadmino;
    [self.delegate updateCellsForPlacedDyadmino:self];
  }];
  SKAction *growAction = [SKAction scaleTo:1.f duration:kConstantTime];
  SKAction *sequenceAction = [SKAction sequence:@[shrinkAction, repositionAction, growAction]];
  [self runAction:sequenceAction withKey:kActionPopIntoBoard];
}

-(void)animatePopBackIntoRackNode {
  [self removeActionsAndEstablishNotRotating];
  SKAction *shrinkAction = [SKAction scaleTo:0.f duration:kConstantTime];
  SKAction *repositionAction = [SKAction runBlock:^{
    [self.delegate soundDyadminoSuck];
    [self unhighlightOutOfPlay];
    [self orientBySnapNode:self.homeNode];
    self.zPosition = kZPositionRackMovedDyadmino;
    self.position = [self getHomeNodePosition];
  }];
  SKAction *growAction = [SKAction scaleTo:1.f duration:kConstantTime];
  SKAction *sequenceAction = [SKAction sequence:@[shrinkAction, repositionAction, growAction]];
  [self runAction:sequenceAction withKey:kActionPopIntoRack];
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
      [self.delegate soundDyadminoSettleClick];
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
      [self.delegate prepareForHoverThisDyadmino:self];
      self.canFlip = NO;
    }];
  }
  
  SKAction *completeAction = [SKAction sequence:@[nextFrame, waitTime, nextFrame, waitTime, nextFrame, finishAction]];
  [self runAction:completeAction withKey:kActionFlip];
}

-(void)animateEaseIntoNodeAfterHover {
  
    // animate to homeNode as default, to tempBoardNode if it's a rack dyadmino
  CGPoint settledPosition = [self getHomeNodePosition];
  if ([self belongsInRack] && [self isOnBoard]) {
    settledPosition = self.tempBoardNode.position;
  }
  
  SKAction *moveAction = [SKAction moveTo:settledPosition duration:kConstantTime];
  SKAction *finishAction = [SKAction runBlock:^{
    
    [self.delegate soundDyadminoSettleClick];
    [self endTouchThenHoverResize];
    [self setToHomeZPosition];
    
    self.canFlip = NO;
    self.hoveringStatus = kDyadminoNoHoverStatus;
    self.initialPivotPosition = self.position;
  }];
  SKAction *sequence = [SKAction sequence:@[moveAction, finishAction]];
  [self runAction:sequence withKey:kActionEaseIntoNode];
}

-(void)animateDyadminoesRecentlyPlayed:(BOOL)playedByMyPlayer {
  
  self.color = playedByMyPlayer ? kPlayedDyadminoBlue : kEnemyDyadminoRed;
  SKAction *highlightIn = [SKAction colorizeWithColorBlendFactor:kDyadminoColorBlendFactor * 1.333 duration:.75f];
  SKAction *highlightOut = [SKAction colorizeWithColorBlendFactor:0.f duration:1.5f];
  SKAction *sequence = [SKAction sequence:@[highlightIn, highlightOut]];
  [self runAction:sequence withKey:kActionShowRecentlyPlayed];
}

-(void)animateFace:(SKSpriteNode *)face {
  if (face.parent == self) {
    SKAction *scaleIn = [SKAction scaleTo:1.5f duration:.05f];
    SKAction *scaleOut = [SKAction scaleTo:1.f duration:.125f];
    SKAction *sequence = [SKAction sequence:@[scaleIn, scaleOut]];
    [face runAction:sequence withKey:kActionSoundFace];
  }
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

-(HexCoord)getHexCoordOfFace:(SKSpriteNode *)face {
  BOOL faceIsPC1 = [face.name integerValue] == self.pc1 ? YES : NO;
  
  if (face.parent == self) {
    switch (self.orientation) {
      case kPC1atTwelveOClock:
        return faceIsPC1 ? [self hexCoordFromX:self.myHexCoord.x andY:self.myHexCoord.y + 1] : self.myHexCoord;
        break;
      case kPC1atTwoOClock:
        return faceIsPC1 ? [self hexCoordFromX:self.myHexCoord.x + 1 andY:self.myHexCoord.y] : self.myHexCoord;
        break;
      case kPC1atFourOClock:
        return faceIsPC1 ? self.myHexCoord : [self hexCoordFromX:self.myHexCoord.x - 1 andY:self.myHexCoord.y + 1];
        break;
      case kPC1atSixOClock:
        return faceIsPC1 ? self.myHexCoord : [self hexCoordFromX:self.myHexCoord.x andY:self.myHexCoord.y + 1];
        break;
      case kPC1atEightOClock:
        return faceIsPC1 ? self.myHexCoord : [self hexCoordFromX:self.myHexCoord.x + 1 andY:self.myHexCoord.y];
        break;
      case kPC1atTenOClock:
        return faceIsPC1 ? [self hexCoordFromX:self.myHexCoord.x - 1 andY:self.myHexCoord.y + 1] : self.myHexCoord;
        break;
    }
  }
  return self.myHexCoord;
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