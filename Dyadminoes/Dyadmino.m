//
//  Dyadmino.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Dyadmino.h"
#import "Board.h"
#import "Cell.h"
#import "Face.h"
//#import <CoreGraphics/CoreGraphics.h>
//#import <CoreImage/CoreImage.h>

#define kActionMoveToPoint @"moveToPoint"
#define kActionPopIntoBoard @"popIntoBoard"
#define kActionPopIntoRack @"popIntoRack"
#define kActionFlip @"flip"
#define kActionEaseIntoNode @"easeIntoNode"
#define kActionSoundFace @"animateFace"

@implementation Dyadmino {
  BOOL _alreadyAddedChildren;
}

#pragma mark - custom setters and getters

//-(void)setZRotation:(CGFloat)zRotation {
//  NSLog(@"set Z rotation of dyadmino %@", self.name);
//  [super setZRotation:zRotation];
//  self.pc1Sprite.zRotation = -zRotation;
//  self.pc2Sprite.zRotation = -zRotation;
//}

#pragma mark - init and layout methods

-(id)initWithPC1:(NSUInteger)pc1 andPC2:(NSUInteger)pc2 andPCMode:(PCMode)pcMode
  andRotationFrameArray:(NSArray *)rotationFrameArray
  andPC1LetterSprite:(Face *)pc1LetterSprite
  andPC2LetterSprite:(Face *)pc2LetterSprite
  andPC1NumberSprite:(Face *)pc1NumberSprite
  andPC2NumberSprite:(Face *)pc2NumberSprite {
  self = [super init];
  if (self) {
      // constants
    self.color = (SKColor *)kNeutralYellow; // for color blend factor
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

-(void)resetForNewMatch {

    // reset these init values
  self.color = (SKColor *)kNeutralYellow;
  self.colorBlendFactor = 0.f;
  self.cellForPC1 = nil;
  self.cellForPC2 = nil;
  self.homeNode = nil;
  self.tempBoardNode = nil;
  self.isInTopBar = NO;
  self.belongsInSwap = NO;
  self.canFlip = NO;
  self.isRotating = NO;
  self.isTouchThenHoverResized = NO;
  self.isZoomResized = NO;
  self.hoveringStatus = kDyadminoNoHoverStatus;
  self.hidden = NO;
  [self removeFromParent];
  [self removeAllActions];
}

#pragma mark - orient, position, and size methods

-(void)establishSizeOfSprite:(SKSpriteNode *)sprite {
  
  CGFloat hoverResizeFactor = (self.isTouchThenHoverResized) ? kDyadminoHoverResizeFactor : 1.f;
  CGFloat zoomResizeFactor = (self.isZoomResized) ? kZoomResizeFactor : 1.f;

    // size is different if not vertical orientation
  CGFloat orientationFactor = (self.orientation == kPC1atTwelveOClock || self.orientation == kPC1atSixOClock) ? 4.f : 3.f;
  CGFloat pcRelativeSizeFactor = 10 / 7.f;
  
    // sprite is either dyadmino or pc
  CGFloat ySize = (sprite == self) ? kDyadminoFaceRadius * orientationFactor : kDyadminoFaceRadius * pcRelativeSizeFactor;
  
  CGFloat widthToHeightRatio = sprite.texture.size.width / sprite.texture.size.height;
  CGFloat xSize = widthToHeightRatio * ySize;
  sprite.size = CGSizeMake(xSize * hoverResizeFactor * zoomResizeFactor, ySize * hoverResizeFactor * zoomResizeFactor);
}

-(void)resize {
  [self establishSizeOfSprite:self];
  [self establishSizeOfSprite:self.pc1Sprite];
  [self establishSizeOfSprite:self.pc2Sprite];
}

-(void)selectAndPositionFace:(Face *)face {
  
}

-(void)selectAndPositionDyadmino {
  
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
  
  self.zRotation = 0.f;
  self.pc1Sprite.zRotation = 0.f;
  self.pc2Sprite.zRotation = 0.f;
  
  CGFloat hoverResizeFactor = (self.isTouchThenHoverResized) ? kDyadminoHoverResizeFactor : 1.f;
  CGFloat zoomResizeFactor = (self.isZoomResized) ? kZoomResizeFactor : 1.f;
  CGFloat yVertical = kDyadminoFaceRadius * hoverResizeFactor * zoomResizeFactor;
  CGFloat ySlant = kDyadminoFaceRadius * 0.5 * hoverResizeFactor * zoomResizeFactor;
  CGFloat xSlant = kDyadminoFaceRadius * 0.5 * kSquareRootOfThree * hoverResizeFactor * zoomResizeFactor;
  
  switch (self.orientation) {
    case kPC1atTwelveOClock:
      self.texture = self.rotationFrameArray[0];
      [self resize];
      self.pc1Sprite.position = CGPointMake(0, yVertical);
      self.pc2Sprite.position = CGPointMake(0, -yVertical);
      break;
    case kPC1atTwoOClock:
      self.texture = self.rotationFrameArray[1];
      [self resize];
      self.pc1Sprite.position = CGPointMake(xSlant, ySlant);
      self.pc2Sprite.position = CGPointMake(-xSlant, -ySlant);
      break;
    case kPC1atFourOClock:
      self.texture = self.rotationFrameArray[2];
      [self resize];
      self.pc1Sprite.position = CGPointMake(xSlant, -ySlant);
      self.pc2Sprite.position = CGPointMake(-xSlant, ySlant);
      break;
    case kPC1atSixOClock:
      self.texture = self.rotationFrameArray[0];
      [self resize];
      self.pc1Sprite.position = CGPointMake(0, -yVertical);
      self.pc2Sprite.position = CGPointMake(0, yVertical);
      break;
    case kPC1atEightOClock:
      self.texture = self.rotationFrameArray[1];
      [self resize];
      self.pc1Sprite.position = CGPointMake(-xSlant, -ySlant);
      self.pc2Sprite.position = CGPointMake(xSlant, ySlant);
      break;
    case kPC1atTenOClock:
      self.texture = self.rotationFrameArray[2];
      [self resize];
      self.pc1Sprite.position = CGPointMake(-xSlant, ySlant);
      self.pc2Sprite.position = CGPointMake(xSlant, -ySlant);
      break;
  }
}

-(void)orientBySnapNode:(SnapPoint *)snapNode {
  
  switch (snapNode.snapPointType) {
    case kSnapPointRack:
      self.orientation = (self.orientation <= 1 || self.orientation >= 5) ? 0 : 3;
      break;
    default: // snapNode is on board
      self.orientation = self.tempReturnOrientation;
      break;
  }
  
  [self selectAndPositionSprites];
}

-(CGPoint)getHomeNodePosition {
  return (self.belongsInSwap) ?
      [self addToThisPoint:self.homeNode.position thisPoint:CGPointMake(0.f, self.homeNode.position.y + kRackHeight * 0.5)] :
      self.homeNode.position;
}

#pragma mark - change status methods

-(void)startTouchThenHoverResize {
    self.isTouchThenHoverResized = YES;
    [self resize];
    [self selectAndPositionSprites];
}

-(void)endTouchThenHoverResize {
  self.isTouchThenHoverResized = NO;
  [self resize];
  [self selectAndPositionSprites];
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

-(void)highlightBoardDyadminoWithColour:(UIColor *)colour {
  [self removeActionForKey:kActionShowRecentlyPlayed];
  self.color = (SKColor *)colour;
    // orange colour is dimmer, so increase colourBlendFactor to compensate
  self.colorBlendFactor = ([colour isEqual:kPlayerOrange]) ? kDyadminoColorBlendFactor * 1.5 : kDyadminoColorBlendFactor;
}

-(void)adjustHighlightGivenDyadminoOffsetPosition:(CGPoint)dyadminoOffsetPosition {
//  NSLog(@"adjust highlight given dyadmino offset");
  CGFloat inPlayFloat = [self getHeightFloatGivenGap:kGapForHighlight andDyadminoPosition:dyadminoOffsetPosition];
  self.colorBlendFactor = kDyadminoColorBlendFactor * inPlayFloat;
}

#pragma mark - change state methods

-(void)setToHomeZPositionAndSyncOrientation {
  self.zPosition = (self.homeNode.snapPointType == kSnapPointRack) ?
      kZPositionRackRestingDyadmino : kZPositionBoardRestingDyadmino;
  self.tempReturnOrientation = self.orientation;
}

-(void)goHomeToRackByPoppingIn:(BOOL)poppingIn andSounding:(BOOL)sounding fromUndo:(BOOL)undo withResize:(BOOL)resize {
//  NSLog(@"dyadmino's go home by popping in method called");
    // move these into a completion block for animation
  if (poppingIn) {
    [self animatePopBackIntoRackNodeFromUndo:undo withResize:resize];
  } else {
    [self orientBySnapNode:self.homeNode];
    [self animateMoveToPoint:[self getHomeNodePosition] andSounding:sounding];
//    [self setToHomeZPositionAndSyncOrientation];
  }
  self.tempBoardNode = nil;
  [self finishHovering];
}

  // this should be combined into one method with goHomeToRack
-(void)goHomeToBoardByPoppingIn:(BOOL)poppingIn andSounding:(BOOL)sounding {
  if (poppingIn) {
    [self animatePopBackIntoBoardNode];
  } else {
    [self orientBySnapNode:self.homeNode];
    [self animateMoveToPoint:[self getHomeNodePosition] andSounding:sounding];
  }
  [self finishHovering];
}

-(void)goToTempBoardNodeBySounding:(BOOL)sounding { // called after replay, perhaps will be used elsewhere
  SnapPoint *destinationNode = self.tempBoardNode ? self.tempBoardNode : self.homeNode;
  [self orientBySnapNode:destinationNode];
  [self animateMoveToPoint:destinationNode.position andSounding:sounding];
}

-(void)removeActionsAndEstablishNotRotatingIncludingMove:(BOOL)includingMove {
  
  if (includingMove) {
  [self removeActionForKey:kActionMoveToPoint];
  }
  
  [self resetFaceScales];
  [self removeActionForKey:kActionPopIntoRack];
  [self removeActionForKey:kActionFlip];
  [self removeActionForKey:kActionEaseIntoNode];
  self.isRotating = NO;
}

-(void)resetFaceScales {
  [self.pc1Sprite setScale:1.f];
  [self.pc2Sprite setScale:1.f];
}

#pragma mark - pivot methods

-(CGPoint)determinePivotAroundPointBasedOnPivotOnPC:(PivotOnPC)pivotOnPC {
  
    // if it's pivoting around center, then it's just the dyadmino position
  if (pivotOnPC == kPivotCentre) {
    self.pivotAroundPoint = self.position;
    
      // otherwise it's one of the pc faces
  } else {
    CGPoint pivotOffset;
    CGFloat yVertical = kDyadminoFaceRadius * kDyadminoHoverResizeFactor;
    CGFloat xSlant = kDyadminoFaceRadius * 0.5 * kSquareRootOfThree * kDyadminoHoverResizeFactor;
    CGFloat ySlant = kDyadminoFaceRadius * 0.5 * kDyadminoHoverResizeFactor;
    
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
        [self.delegate postSoundNotification:kNotificationPivotClick];
        
          // if it pivots on center, just go straight to positioning sprites
        if (pivotOnPC != kPivotCentre) {
          
          CGFloat xIncrement = kDyadminoFaceRadius * 0.5 * kSquareRootOfThree * kDyadminoHoverResizeFactor;
          CGFloat yIncrement = kDyadminoFaceRadius * 0.5 * kDyadminoHoverResizeFactor;
          
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
          CGPoint newPosition = CGPointZero;
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

-(void)animateMoveToPoint:(CGPoint)point andSounding:(BOOL)sounding {
//  NSLog(@"animateMoveToPoint called from dyadmino %@", self.name);
  [self removeActionsAndEstablishNotRotatingIncludingMove:YES];
  SKAction *moveAction = [SKAction moveTo:point duration:kConstantTime]; // was kConstantSpeed * distance
  moveAction.timingMode = SKActionTimingEaseIn;
  if (sounding) {
    SKAction *completeAction = [SKAction runBlock:^{
      [self.delegate postSoundNotification:kNotificationEaseIntoNode];
      [self setToHomeZPositionAndSyncOrientation];
    }];
    SKAction *sequence = [SKAction sequence:@[moveAction, completeAction]];
    [self runAction:sequence withKey:kActionMoveToPoint];
  } else {
    [self runAction:moveAction withKey:kActionMoveToPoint];
  }
}

-(void)animatePopBackIntoBoardNode {
//  NSLog(@"dyadmino's animate to board node method called");
  [self removeActionsAndEstablishNotRotatingIncludingMove:YES];
  SKAction *shrinkAction = [SKAction scaleTo:0.f duration:kConstantTime];
  SKAction *repositionAction = [SKAction runBlock:^{
    [self.delegate postSoundNotification:kNotificationPopIntoNode];
    [self setToHomeZPositionAndSyncOrientation];
    [self orientBySnapNode:([self belongsInRack] ? self.tempBoardNode : self.homeNode)];
    self.position = [self belongsInRack] ? self.tempBoardNode.position : self.homeNode.position;
    [self.delegate changeColoursAroundDyadmino:self withSign:+1];
  }];
  SKAction *growAction = [SKAction scaleTo:1.f duration:kConstantTime];
  SKAction *sequenceAction = [SKAction sequence:@[shrinkAction, repositionAction, growAction]];
  [self runAction:sequenceAction withKey:kActionPopIntoBoard];
}

-(void)animatePopBackIntoRackNodeFromUndo:(BOOL)undo withResize:(BOOL)resize {
  [self removeActionsAndEstablishNotRotatingIncludingMove:YES];
  SKAction *shrinkAction = [SKAction scaleTo:0.f duration:kConstantTime];
  SKAction *repositionAction = [SKAction runBlock:^{
    self.color = (SKColor *)kNeutralYellow;
    [self.delegate postSoundNotification:kNotificationPopIntoNode];
    [self setToHomeZPositionAndSyncOrientation];
    [self unhighlightOutOfPlay];
    [self orientBySnapNode:self.homeNode];
    
    if (resize) {
      self.isZoomResized = NO;
      [self resize];
      [self selectAndPositionSprites];
    }
    
    self.position = [self getHomeNodePosition];
    if (undo) {
      [self.delegate layoutOrRefreshRackFieldAndDyadminoesFromUndo:YES withAnimation:NO];
    }
  }];
  SKAction *growAction = [SKAction scaleTo:1.f duration:kConstantTime];
  SKAction *sequenceAction = undo ?
    [SKAction sequence:@[shrinkAction, repositionAction]] :
    [SKAction sequence:@[shrinkAction, repositionAction, growAction]];
  [self runAction:sequenceAction withKey:kActionPopIntoRack];
}

-(void)animateFlip {
  
  [self removeActionsAndEstablishNotRotatingIncludingMove:YES];
  self.isRotating = YES;
  [self animateOneThirdFlipClockwise:YES aroundAnchorPoint:self.anchorPoint times:3 withFullFlip:YES];
}

-(void)animateOneThirdFlipClockwise:(BOOL)clockwise aroundAnchorPoint:(CGPoint)anchorPoint times:(NSUInteger)times withFullFlip:(BOOL)fullFlip {
  
  self.anchorPoint = anchorPoint;
  
  CGFloat radians = [self getRadiansFromDegree:60] * (clockwise ? 1 : -1);
  __block NSUInteger counter = times;
  CGFloat duration = kConstantTime / 4.5;
  
  SKAction *turnDyadmino = [SKAction rotateByAngle:-radians duration:duration];
  SKAction *turnFace = [SKAction rotateByAngle:radians duration:duration];
  SKAction *turnAction = [SKAction runBlock:^{
    [self.pc1Sprite runAction:turnFace];
    [self.pc2Sprite runAction:turnFace];
    
    [self runAction:turnDyadmino completion:^{
      self.orientation = (self.orientation + 1) % 6;
      [self selectAndPositionSprites];
      counter--;
      if (counter > 0) {
        [self animateOneThirdFlipClockwise:clockwise aroundAnchorPoint:anchorPoint times:counter withFullFlip:fullFlip];
      } else {
        if (fullFlip) {
          [self animateCompletionOfFullFlip];
        }
      }
    }];
  }];
  
  [self runAction:turnAction];
  
    // reset anchorPoint after each and every time
  self.anchorPoint = CGPointMake(0.5f, 0.5f);
}

-(void)animateCompletionOfFullFlip {
  SKAction *finishAction;
  
    // rotation
  if ([self isInRack] || [self isOrBelongsInSwap]) {
    finishAction = [SKAction runBlock:^{
      [self finishHovering];
      [self setToHomeZPositionAndSyncOrientation];
      [self endTouchThenHoverResize];
      self.isRotating = NO;
      [self.delegate postSoundNotification:kNotificationPivotClick];
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
  } else {
    finishAction = [SKAction runBlock:^{
        // to ensure that finishAction is not nil
    }];
  }
  [self runAction:finishAction];
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
    [self setToHomeZPositionAndSyncOrientation];
    
    self.canFlip = NO;
    self.hoveringStatus = kDyadminoNoHoverStatus;
    self.initialPivotPosition = self.position;
    
    [self.delegate postSoundNotification:kNotificationEaseIntoNode];
    [self.delegate changeColoursAroundDyadmino:self withSign:+1];
  }];
  
  SKAction *sequence = [SKAction sequence:@[moveAction, finishAction]];
  [self runAction:sequence withKey:kActionEaseIntoNode];
}

-(void)animateDyadminoesRecentlyPlayedWithColour:(UIColor *)colour {
//  NSLog(@"animate dyadminoes recently played");
  [self removeActionsAndEstablishNotRotatingIncludingMove:NO];
  self.color = (SKColor *)colour;
  
  CGFloat colourBlendFactor = [colour isEqual:kPlayerOrange] ?
      (kDyadminoAnimatedColorBlendFactor * 1.5) : kDyadminoAnimatedColorBlendFactor;
  SKAction *highlightIn = [SKAction colorizeWithColorBlendFactor:colourBlendFactor * 1.333 duration:.5f];
  SKAction *wait = [SKAction waitForDuration:1.f];
  SKAction *highlightOut = [SKAction colorizeWithColorBlendFactor:0.f duration:0.5f];
  SKAction *sequence = [SKAction sequence:@[highlightIn, wait, highlightOut]];
  [self runAction:sequence withKey:kActionShowRecentlyPlayed];
}

-(void)animateFace:(SKSpriteNode *)face {
  if (face.parent == self) {
    [face removeAllActions];
    
    SKAction *begin = [SKAction runBlock:^{
      [self resetFaceScales];
    }];
    SKAction *scaleUp = [SKAction scaleTo:1.5f duration:0.05f];
    SKAction *scaleOvershootDown = [SKAction scaleTo:0.75f duration:0.1f];
    SKAction *scaleBounceBackUp = [SKAction scaleTo:1.f duration:0.025];
    SKAction *complete = [SKAction runBlock:^{
      [self establishSizeOfSprite:face];
    }];
    SKAction *sequence = [SKAction sequence:@[begin, scaleUp, scaleOvershootDown, scaleBounceBackUp, complete]];
    
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
  return (self.hoveringStatus == kDyadminoHovering) ? YES : NO;
}

-(BOOL)continuesToHover {
  return (self.hoveringStatus == kDyadminoContinuesHovering) ? YES : NO;
}

-(BOOL)isFinishedHovering {
  return (self.hoveringStatus == kDyadminoFinishedHovering) ? YES : NO;
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