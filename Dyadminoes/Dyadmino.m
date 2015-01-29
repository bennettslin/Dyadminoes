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
#import "SKSpriteNode+Helper.h"

#define kActionMoveToPoint @"moveToPoint"
#define kActionShrinkPopIn @"shrinkPopIn"
#define kActionGrowPopIn @"growPopIn"
#define kActionFlip @"flip"
#define kActionRotate @"turn"
#define kActionEaseIntoNode @"easeIntoNode"
#define kActionSoundFace @"animateFace"
#define kActionHover @"hover"

@interface Dyadmino ()

@property (readwrite, nonatomic) BOOL isInTopBar;
@property (readwrite, nonatomic) BOOL belongsInSwap;
@property (readwrite, nonatomic) BOOL isRotating;
@property (readwrite, nonatomic) DyadminoHome home;

@end

@implementation Dyadmino {
  BOOL _alreadyAddedChildren;
  BOOL _isPivotAnimating;
  PivotOnPC _pivotOnPC;
  BOOL _movedDueToChangeInAnchorPoint;
}

@synthesize name = _name;
@synthesize pcMode = _pcMode;
@synthesize home = _home;

#pragma mark - init and layout methods

-(id)initWithPC1:(NSUInteger)pc1 andPC2:(NSUInteger)pc2 andPCMode:(PCMode)pcMode
  andRotationFrameArray:(NSArray *)rotationFrameArray
  andPC1LetterSprite:(Face *)pc1LetterSprite
  andPC2LetterSprite:(Face *)pc2LetterSprite
  andPC1NumberSprite:(Face *)pc1NumberSprite
  andPC2NumberSprite:(Face *)pc2NumberSprite {
  self = [super init];
  if (self) {
    self.color = (SKColor *)kNeutralYellow; // for color blend factor
    self.zPosition = kZPositionRackRestingDyadmino;
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
    [self selectAndPositionSpritesZRotation:0.f];
  }
  return self;
}

-(void)resetForNewMatch {
  _isPivotAnimating = NO;
  
    // reset these init values
  self.color = (SKColor *)kNeutralYellow;
  self.colorBlendFactor = 0.f;
  self.cellForPC1 = nil;
  self.cellForPC2 = nil;
  self.isInTopBar = NO;
  self.belongsInSwap = NO;
  self.canFlip = NO;
  self.isRotating = NO;
  self.isTouchThenHoverResized = NO;
  self.isZoomResized = NO;
  self.hoveringStatus = kDyadminoNoHoverStatus;
  self.zRotationCorrectedAfterPivot = NO;
  self.hidden = NO;
  self.shrunkForReplay = NO;
  [self removeFromParent];
  [self removeAllActions];
}

#pragma mark - texture methods

-(void)changeTexture:(TextureDyadmino)texture {
  
    // FIXME: change texture here
  
}

#pragma mark - orient, position, and size methods

-(void)establishSizeOfSprite:(SKSpriteNode *)sprite {
  
  CGFloat hoverRescaleFactor = self.isTouchThenHoverResized ? kDyadminoHoverResizeFactor : 1.f;
  CGFloat zoomRescaleFactor = self.isZoomResized ? kZoomResizeFactor : 1.f;

    // size is different if not vertical orientation
  CGFloat orientationFactor = (self.orientation == kPC1atTwelveOClock || self.orientation == kPC1atSixOClock) ? 4.f : 3.f;
  CGFloat pcRelativeSizeFactor = 10 / 7.f;
  
    // sprite is either dyadmino or pc
  CGFloat ySize = (sprite == self) ? kDyadminoFaceRadius * orientationFactor : kDyadminoFaceRadius * pcRelativeSizeFactor;
  
  CGFloat widthToHeightRatio = sprite.texture.size.width / sprite.texture.size.height;
  CGFloat xSize = widthToHeightRatio * ySize;
  
  sprite.size = CGSizeMake(xSize * hoverRescaleFactor * zoomRescaleFactor, ySize * hoverRescaleFactor * zoomRescaleFactor);
}

-(void)resize {
  [self establishSizeOfSprite:self];
  [self establishSizeOfSprite:self.pc1Sprite];
  [self establishSizeOfSprite:self.pc2Sprite];
}

-(void)selectAndPositionSpritesZRotation:(CGFloat)rotationAngle {
  NSLog(@"select and position sprites for %@", self.name);
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

  [self zRotateToAngle:rotationAngle];
  
  CGFloat hoverResizeFactor = self.isTouchThenHoverResized ? kDyadminoHoverResizeFactor : 1.f;
  CGFloat zoomResizeFactor = self.isZoomResized ? kZoomResizeFactor : 1.f;
  CGFloat yVertical = kDyadminoFaceRadius * hoverResizeFactor * zoomResizeFactor;
  CGFloat ySlant = kDyadminoFaceRadius * 0.5 * hoverResizeFactor * zoomResizeFactor;
  CGFloat xSlant = kDyadminoFaceRadius * 0.5 * kSquareRootOfThree * hoverResizeFactor * zoomResizeFactor;
  
  switch (self.orientation) {
    case kPC1atTwelveOClock:
      self.texture = self.rotationFrameArray[0];
      self.pc1Sprite.position = CGPointMake(0, yVertical);
      self.pc2Sprite.position = CGPointMake(0, -yVertical);
      break;
    case kPC1atTwoOClock:
      self.texture = self.rotationFrameArray[1];
      self.pc1Sprite.position = CGPointMake(xSlant, ySlant);
      self.pc2Sprite.position = CGPointMake(-xSlant, -ySlant);
      break;
    case kPC1atFourOClock:
      self.texture = self.rotationFrameArray[2];
      self.pc1Sprite.position = CGPointMake(xSlant, -ySlant);
      self.pc2Sprite.position = CGPointMake(-xSlant, ySlant);
      break;
    case kPC1atSixOClock:
      self.texture = self.rotationFrameArray[0];
      self.pc1Sprite.position = CGPointMake(0, -yVertical);
      self.pc2Sprite.position = CGPointMake(0, yVertical);
      break;
    case kPC1atEightOClock:
      self.texture = self.rotationFrameArray[1];
      self.pc1Sprite.position = CGPointMake(-xSlant, -ySlant);
      self.pc2Sprite.position = CGPointMake(xSlant, ySlant);
      break;
    case kPC1atTenOClock:
      self.texture = self.rotationFrameArray[2];
      self.pc1Sprite.position = CGPointMake(-xSlant, ySlant);
      self.pc2Sprite.position = CGPointMake(xSlant, -ySlant);
      break;
  }
  
  [self resize];
}

-(CGPoint)addIfSwapToHomePosition:(CGPoint)homePosition {

  CGFloat addedYValue = self.belongsInSwap ? (homePosition.y + kRackHeight * 0.5) : 0;
  return [self addToThisPoint:homePosition thisPoint:CGPointMake(0.f, addedYValue)];
}

-(void)correctZRotationAfterHover {
  
  __weak typeof(self) weakSelf = self;
  void(^completionBlock)(void) = ^void(void) {
    [weakSelf determineNewAnchorPointDuringPivot:NO];
    weakSelf.zRotationCorrectedAfterPivot = YES;
    [weakSelf.delegate prepareForHoverThisDyadmino:self];
  };
  
  if (self.zRotation != 0.f) {
    
    [self removeActionForKey:@"correctZRotation"];
    SKAction *zRotationAction = [SKAction rotateToAngle:0.f duration:kConstantTime / 4.f shortestUnitArc:YES];
    SKAction *zCompletion = [SKAction runBlock:completionBlock];
    SKAction *sequence = [SKAction sequence:@[zRotationAction, zCompletion]];
    [self runAction:sequence withKey:@"correctZRotation"];
    
    [self.pc1Sprite runAction:zRotationAction];
    [self.pc2Sprite runAction:zRotationAction];
    
  } else {
    
    completionBlock();
  }
}

#pragma mark - change status methods

-(void)startTouchThenHoverResize {
  self.isTouchThenHoverResized = YES;
  [self resize];
  [self selectAndPositionSpritesZRotation:0.f];
}

-(void)endTouchThenHoverResize {
  self.isTouchThenHoverResized = NO;
  [self resize];
  [self selectAndPositionSpritesZRotation:0.f];
}

-(void)changeHoveringStatus:(DyadminoHoveringStatus)hoveringStatus {
  self.hoveringStatus = hoveringStatus;
}

#pragma mark - change view methods

-(void)setToHomeZPosition {
  self.zPosition = (self.home == kRack) ?
      kZPositionRackRestingDyadmino : kZPositionBoardRestingDyadmino;
}

-(void)resetFaceScales {
  [self.pc1Sprite setScale:1.f];
  [self.pc2Sprite setScale:1.f];
}

#pragma mark - animate detailed placement methods

-(void)returnToRackByPoppingInForUndo:(BOOL)popInForUndo withResize:(BOOL)resize {

  CGPoint rackPosition = [self.delegate rackPositionForDyadmino:self];
  
  if (popInForUndo) {
    [self.delegate decrementDyadminoesInFluxWithLayoutLast:NO];
    [self animateShrinkPopIntoNodeWithResize:resize];
  } else {
    
    if (resize) {
      self.isZoomResized = NO;
      [self resize];
      [self selectAndPositionSpritesZRotation:0.f];
    }
    
    self.colorBlendFactor = 0.f;
    [self orientWithAnimation:YES];
    [self animateMoveToPoint:[self addIfSwapToHomePosition:rackPosition] withLayout:NO];
  }
  [self changeHoveringStatus:kDyadminoFinishedHovering];
}

-(void)returnHomeToBoardWithLayout:(BOOL)layout {
  [self orientWithAnimation:YES];
  [self animateMoveToPoint:[self.delegate homePositionForDyadmino:self] withLayout:layout];
  [self changeHoveringStatus:kDyadminoFinishedHovering];
}

-(void)goToTempPositionWithLayout:(BOOL)layout andRescale:(BOOL)rescale andOrient:(BOOL)orient {
    // this is only called by replay and zoom
  
    // replay has orient, zoom does not
  if (orient) {
    [self orientWithAnimation:YES];
  }
  
  self.zPosition = kZPositionBoardReplayAnimatedDyadmino;
  CGPoint reposition = [self.delegate tempPositionForDyadmino:self withHomeOrientation:YES];
  
  __weak typeof(self) weakSelf = self;
  void(^completion)(void) = ^void(void) {
    weakSelf.zPosition = kZPositionBoardRestingDyadmino;
    [weakSelf setScale:1.f];
    [weakSelf selectAndPositionSpritesZRotation:0.f];
    [weakSelf.delegate decrementDyadminoesInFluxWithLayoutLast:layout];
  };
  
  [self animateExcessivelyToPosition:reposition withRescale:rescale duration:kConstantTime withKey:@"replayAction" middleBlock:nil completion:completion];
}

-(void)animateEaseIntoNodeAfterHover {
  NSLog(@"animate ease into node after hover");
  
  CGPoint settledPosition = [self.delegate tempPositionForDyadmino:self withHomeOrientation:NO];

  __weak typeof(self) weakSelf = self;
  void (^completion)(void) = ^void(void) {
    
    [weakSelf endTouchThenHoverResize];
    [weakSelf setToHomeZPosition];
    
    weakSelf.canFlip = NO;
    [weakSelf changeHoveringStatus:kDyadminoNoHoverStatus];
    weakSelf.initialPivotPosition = self.position;
    
    [weakSelf.delegate postSoundNotification:kNotificationEaseIntoNode];
    
    if ([self isOnBoard]) {
      NSLog(@"update cells for placed dyadmino in animate ease");
      [weakSelf.delegate updateCellsForPlacedDyadmino:self];
      [weakSelf.delegate decrementDyadminoesInFluxWithLayoutLast:YES];
    }
  };

  [self animateEasilyToPosition:settledPosition
                       duration:kConstantTime
                     timingMode:SKActionTimingEaseOut
                        withKey:kActionEaseIntoNode
                     completion:completion];
}

#pragma mark - animate basic placement methods

-(void)animateMoveToPointCalledFromRack:(CGPoint)point {
  [self animateMoveToPoint:point withLayout:NO andCalledFromRack:YES];
}

-(void)animateMoveToPoint:(CGPoint)point withLayout:(BOOL)layout {
  [self animateMoveToPoint:point withLayout:layout andCalledFromRack:NO];
}

-(void)animateMoveToPoint:(CGPoint)point withLayout:(BOOL)layout andCalledFromRack:(BOOL)calledFromRack {
  
    // if called from rack, does not include orientation
    // otherwise it is called from self, and does include orientation animation
  __weak typeof(self) weakSelf = self;
  
  void(^completion)(void);
  if (!calledFromRack) {
    completion = ^void(void) {
      [self setToHomeZPosition];
      if ([self isOnBoard]) {
        NSLog(@"update cells for placed dyadmino in animate move to point");
        [weakSelf.delegate updateCellsForPlacedDyadmino:self];
        [weakSelf.delegate decrementDyadminoesInFluxWithLayoutLast:layout];
      }
    };
    
  } else {
    completion = nil;
  }
  
  if (calledFromRack) {
    [self animateEasilyToPosition:point duration:kConstantTime timingMode:SKActionTimingEaseOut withKey:kActionMoveToPoint completion:completion];
  } else {
    
    void(^middleBlock)(void) = ^void(void) {
        // will not sound if laying out
      if (weakSelf.home == kRack || layout) {
        [weakSelf.delegate postSoundNotification:kNotificationEaseIntoNode];
      }
    };
    
    [self animateExcessivelyToPosition:point withRescale:NO duration:kConstantTime withKey:kActionMoveToPoint middleBlock:middleBlock completion:completion];
  }
}

-(void)animateEasilyToPosition:(CGPoint)toPosition
                      duration:(CGFloat)duration
                    timingMode:(SKActionTimingMode)timingMode
                       withKey:(NSString *)key
                    completion:(void(^)(void))completion {
  
  SKAction *moveAction = [SKAction moveTo:toPosition duration:duration];
  moveAction.timingMode = timingMode;
  SKAction *completionAction = [SKAction runBlock:completion];
  SKAction *sequence = [SKAction sequence:@[moveAction, completionAction]];
  [self runAction:sequence withKey:key];
}

-(void)animateExcessivelyToPosition:(CGPoint)reposition
                        withRescale:(BOOL)rescale
                           duration:(CGFloat)duration
                            withKey:(NSString *)key
                        middleBlock:(void(^)(void))middleBlock
                         completion:(void(^)(void))completion {
  
  SKAction *repositionAndMaybeResizeAction;
  
    // between .6 and .99
  CGFloat randomRepositionFactor = ((arc4random() % 100) / 100.f * 0.39) + 0.6f;
  
  CGPoint positionDifference = [self subtractFromThisPoint:reposition thisPoint:self.position];
  const CGFloat excessFactor = 1.1f;
  
  CGPoint excessPosition = CGPointMake(positionDifference.x * excessFactor, positionDifference.y * excessFactor);
  CGPoint excessReposition = [self addToThisPoint:self.position thisPoint:excessPosition];
  
  SKAction *excessRepositionAction = [SKAction moveTo:excessReposition duration:duration * randomRepositionFactor * 0.7];
  excessRepositionAction.timingMode = SKActionTimingEaseIn;
  
  SKAction *middleBlockAction = [SKAction runBlock:middleBlock];
  
  SKAction *bounceBackAction = [SKAction moveTo:reposition duration:duration * randomRepositionFactor * 0.3f];
  SKAction *repositionSequence = [SKAction sequence:@[excessRepositionAction, middleBlockAction, bounceBackAction]];
  
  if (rescale) {
      // between .6 and .99
    CGFloat randomResizeFactor = ((arc4random() % 100) / 100.f * 0.39) + 0.6f;
    CGFloat scaleTo = self.isZoomResized ? kZoomResizeFactor : 1 / kZoomResizeFactor;
    SKAction *resizeAction = [SKAction scaleTo:scaleTo duration:duration * randomResizeFactor];
    resizeAction.timingMode = SKActionTimingEaseIn;
    repositionAndMaybeResizeAction = [SKAction group:@[repositionSequence, resizeAction]];
    
  } else {
    repositionAndMaybeResizeAction = repositionSequence;
  }
  
  SKAction *completeAction = [SKAction runBlock:completion];
  SKAction *sequenceAction = [SKAction sequence:@[repositionAndMaybeResizeAction, completeAction]];
  
  [self runAction:sequenceAction withKey:key];
}

#pragma mark - animate rotation methods

-(void)orientWithAnimation:(BOOL)animate {
  NSLog(@"%@ orient with animate %i", self.name, animate);
  
  NSInteger currentOrientation = self.orientation;
  DyadminoOrientation shouldBeOrientation;
  
  if (self.home == kRack) {
    shouldBeOrientation = (currentOrientation <= 1 || currentOrientation >= 5) ? 0 : 3;
  } else {
    shouldBeOrientation = self.homeOrientation;
  }
  
  if (animate) {
    if (self.orientation != shouldBeOrientation) {
      CGFloat difference = ((shouldBeOrientation - self.orientation + 6) % 6);
      
      if (difference <= 3) {
        [self animateOneThirdFlipClockwise:YES times:difference withFullFlip:NO];
      } else {
        [self animateOneThirdFlipClockwise:NO times:(6 - difference) withFullFlip:NO];
      }
    }
    
  } else {
    self.orientation = shouldBeOrientation;
    [self selectAndPositionSpritesZRotation:0.f];
  }
}

-(void)animateFlip {
  [self removeActionsAndEstablishNotRotatingIncludingMove:YES];
  self.isRotating = YES;
  [self animateOneThirdFlipClockwise:YES times:3 withFullFlip:YES];
}

-(void)animateOneThirdFlipClockwise:(BOOL)clockwise times:(NSUInteger)times withFullFlip:(BOOL)fullFlip {

  if (!_isPivotAnimating) {
    CGFloat radians = [self getRadiansFromDegree:60] * (clockwise ? 1 : -1);
    __block NSUInteger counter = times;
    CGFloat duration = fullFlip ? kConstantTime / 4.5f : kConstantTime / 4.5f; // was 4.5;
    
    SKAction *turnDyadmino = [SKAction rotateByAngle:-radians duration:duration];
    SKAction *turnFace = [SKAction rotateByAngle:radians duration:duration];
    
    __weak typeof(self) weakSelf = self;
    SKAction *turnAction = [SKAction runBlock:^{
      
      [weakSelf.pc1Sprite runAction:turnFace];
      [weakSelf.pc2Sprite runAction:turnFace];
      
      [weakSelf runAction:turnDyadmino completion:^{
        weakSelf.orientation = (weakSelf.orientation + (clockwise ? 1 : 5)) % 6;
        [weakSelf selectAndPositionSpritesZRotation:0.f];
        counter--;
        _isPivotAnimating = NO;
        if (counter > 0) {
          [weakSelf animateOneThirdFlipClockwise:clockwise times:counter withFullFlip:fullFlip];
        } else {

          if (fullFlip) {
            [weakSelf completionAfterAnimatingFullFlip];
          }
        }
      }];
    }];
    
    _isPivotAnimating = YES;
    [self runAction:turnAction withKey:kActionRotate];
    
      // reset anchorPoint after each and every time
    self.anchorPoint = CGPointMake(0.5f, 0.5f);
    
      // if already animating, just add to orientation.
  } else {
    self.orientation = (self.orientation + (clockwise ? 1 : 5)) % 6;
  }
}

-(void)completionAfterAnimatingFullFlip {
  
    // rotation
  if ([self isInRack] || self.belongsInSwap) {
    [self changeHoveringStatus:kDyadminoFinishedHovering];
    [self setToHomeZPosition];
    [self endTouchThenHoverResize];
    self.isRotating = NO;
    [self.delegate postSoundNotification:kNotificationPivotClick];
    
  } else if ([self isOnBoard]) {
    self.isRotating = NO;
    [self changeHoveringStatus:kDyadminoContinuesHovering];
    [self.delegate prepareForHoverThisDyadmino:self];
    self.canFlip = NO;
  }
}

#pragma mark - animate pop methods

-(void)animateShrinkPopIntoNodeWithResize:(BOOL)resize {
  
  [self removeActionsAndEstablishNotRotatingIncludingMove:YES];
  
  __weak typeof(self) weakSelf = self;
  
  SKAction *shrinkAction = [SKAction scaleTo:0.f duration:kConstantTime];
  
  void (^repositionBetweenShrinkAndGrowBlock)(void) = ^void(void) {
    [weakSelf.delegate postSoundNotification:kNotificationPopIntoNode];
    [weakSelf setToHomeZPosition];
    
    weakSelf.color = (SKColor *)kNeutralYellow;
    [weakSelf unhighlightOutOfPlay];
    [weakSelf orientWithAnimation:NO];
    
    if (resize) {
      weakSelf.isZoomResized = NO;
      [weakSelf resize];
      [weakSelf selectAndPositionSpritesZRotation:0.f];
    }
    weakSelf.position = [weakSelf.delegate rackPositionForDyadmino:self];
  };
  SKAction *repositionAction = [SKAction runBlock:repositionBetweenShrinkAndGrowBlock];
  
    // dyadmino will enter as rack nodes are being repositioned
    // so grow action will be called by rack
    SKAction *refreshAction = [SKAction runBlock:^{
      [weakSelf.delegate refreshRackFieldAndDyadminoesFromUndo:YES withAnimation:YES];
    }];
  
    SKAction *sequenceAction = [SKAction sequence:@[shrinkAction, repositionAction, refreshAction]];

  [self runAction:sequenceAction withKey:kActionShrinkPopIn];
}

-(void)animateGrowPopInWithCompletionBlock:(void(^)(void))completionBlock {
  SKAction *excessGrowAction = [SKAction scaleTo:kDyadminoHoverResizeFactor duration:kConstantTime * 0.7f];
  excessGrowAction.timingMode = SKActionTimingEaseOut;
  SKAction *settleBackAction = [SKAction scaleTo:1.f duration:kConstantTime * 0.3f];
  settleBackAction.timingMode = SKActionTimingEaseIn;
  SKAction *completionAction = [SKAction runBlock:completionBlock];
  SKAction *sequence = [SKAction sequence:@[excessGrowAction, settleBackAction, completionAction]];
  [self runAction:sequence withKey:kActionGrowPopIn];
}

#pragma mark - unique animation methods

-(void)animateDyadminoesRecentlyPlayedWithColour:(UIColor *)colour {
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

-(void)animateFaceForSound:(SKSpriteNode *)face {
  if (face.parent == self) {
    __weak typeof(self) weakSelf = self;
    [face removeAnimationForKey:kActionSoundFace withCompletion:^{
      [weakSelf resetFaceScales];
    }];
    
    SKAction *scaleUp = [SKAction scaleTo:1.4f duration:0.05f];
    SKAction *scaleOvershootDown = [SKAction scaleTo:0.75f duration:0.1f];
    SKAction *scaleBounceBackUp = [SKAction scaleTo:1.f duration:0.025];
    
    SKAction *complete = [SKAction runBlock:^{
      [weakSelf establishSizeOfSprite:face];
    }];
    SKAction *sequence = [SKAction sequence:@[scaleUp, scaleOvershootDown, scaleBounceBackUp, complete]];
    
    [face runAction:sequence withKey:kActionSoundFace];
  }
}

-(void)animateWiggleForHover:(BOOL)animate {
  if (animate) {
    if (![self actionForKey:kActionHover]) {
      
        // experiment with different values for these two
      const CGFloat degrees = 2.f;
      const CGFloat timeDivisor = 4.f;
      
      SKAction *leftAction = [SKAction rotateToAngle:[self getRadiansFromDegree:degrees] duration:kAnimateHoverTime / timeDivisor];
      SKAction *rightAction = [SKAction rotateToAngle:[self getRadiansFromDegree:-degrees] duration:kAnimateHoverTime / timeDivisor];
      leftAction.timingMode = SKActionTimingEaseOut;
      rightAction.timingMode = SKActionTimingEaseOut;
      
      SKAction *sequenceAction = [SKAction sequence:@[leftAction, rightAction]];
      SKAction *repeatAction = [SKAction repeatActionForever:sequenceAction];
      [self runAction:repeatAction withKey:kActionHover];
    }
  } else {
    [self removeActionForKey:kActionHover];
    [self resize];
    [self selectAndPositionSpritesZRotation:0.f];
  }
}

-(void)animateShrinkForReplayToShrink:(BOOL)shrink {
    // no animation if dyadmino is already at the desired scale
  
  if (shrink && !self.shrunkForReplay) {
    self.shrunkForReplay = YES;
    SKAction *shrinkAction = [SKAction scaleTo:0.5f duration:kConstantTime * 0.99f];
    shrinkAction.timingMode = SKActionTimingEaseIn;
    SKAction *fadeOutAction = [SKAction fadeAlphaTo:0.f duration:kConstantTime * 0.99f];
    fadeOutAction.timingMode = SKActionTimingEaseIn;
    SKAction *shrinkFadeOutGroup = [SKAction group:@[shrinkAction, fadeOutAction]];
    
    SKAction *hideAction = [SKAction runBlock:^{
      self.hidden = YES;
      [self setScale:1.f];
      [self resize];
      self.zPosition = kZPositionBoardRestingDyadmino;
    }];
    SKAction *sequence = [SKAction sequence:@[shrinkFadeOutGroup, hideAction]];
    self.zPosition = kZPositionBoardReplayAnimatedDyadmino;
    [self runAction:sequence withKey:@"replayShrink"];
    
  } else if (!shrink && self.shrunkForReplay) {
    self.shrunkForReplay = NO;
    self.hidden = NO;
    [self setScale:0.5f];
    self.alpha = 0.f;
    SKAction *excessGrowAction = [SKAction scaleTo:1.1f duration:kConstantTime * 0.69f];
    excessGrowAction.timingMode = SKActionTimingEaseOut;
    SKAction *bounceBackAction = [SKAction scaleTo:1.f duration:kConstantTime * 0.29f];
    bounceBackAction.timingMode = SKActionTimingEaseIn;
    SKAction *growSequence = [SKAction sequence:@[excessGrowAction, bounceBackAction]];
    
    SKAction *fadeInAction = [SKAction fadeAlphaTo:1.f duration:kConstantTime * 0.99f];
    fadeInAction.timingMode = SKActionTimingEaseIn;
    SKAction *growFadeInGroup = [SKAction group:@[growSequence, fadeInAction]];
    
    SKAction *completeAction = [SKAction runBlock:^{
      self.zPosition = kZPositionBoardRestingDyadmino;
      [self setScale:1.f];
      [self resize];
    }];
    SKAction *sequence = [SKAction sequence:@[growFadeInGroup, completeAction]];
    self.zPosition = kZPositionBoardReplayAnimatedDyadmino;
    [self runAction:sequence withKey:@"replayGrow"];
  }
}

#pragma mark - animation helper methods

-(void)removeMoveAction {
  
}

-(void)removeScaleAction {
  
}

-(void)removeRotateAction {
  
}

-(void)removeActionsAndEstablishNotRotatingIncludingMove:(BOOL)includingMove {
  
  if (includingMove) {
    [self removeActionForKey:kActionMoveToPoint];
  }
  
  [self resetFaceScales];
  [self removeActionForKey:kActionShrinkPopIn];
  [self removeActionForKey:kActionGrowPopIn];
//  [self removeActionForKey:kActionFlip];
  [self removeActionForKey:kActionEaseIntoNode];
  self.isRotating = NO;
}

#pragma mark - pivot methods

-(CGPoint)determinePivotAroundPointBasedOnPivotOnPC:(PivotOnPC)pivotOnPC {
  
  _pivotOnPC = pivotOnPC;
  
    // if it's pivoting around center, then it's just the dyadmino position
  if (_pivotOnPC == kPivotCentre) {
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
  
  [self determineNewAnchorPointDuringPivot:YES];
  return self.pivotAroundPoint;
}

-(BOOL)pivotBasedOnTouchLocation:(CGPoint)touchLocation
               andZRotationAngle:(CGFloat)dyadminoAngle
                    andPivotOnPC:(PivotOnPC)pivotOnPC {
  
    // initial pivotOnPC is dyadmino position
  _pivotOnPC = pivotOnPC; // not sure why, but pivotOnPC needs to be set again here, even after being set in determinePivot
  
    // establish angles
  CGFloat touchAngle = [self findAngleInDegreesFromThisPoint:touchLocation toThisPoint:self.pivotAroundPoint];
  CGFloat changeInAngle = [self getChangeFromThisAngle:touchAngle toThisAngle:self.initialPivotAngle];
  
    //// Figure out if all of this would be easier if we just made the pivotAroundPoint the temporary dyadmino position
  for (NSUInteger i = 0; i < 12; i++) {
    if (changeInAngle >= i + kAngleForSnapToPivot &&
        changeInAngle < (i + 1) - kAngleForSnapToPivot) {
      
      uint newOrientation = (self.prePivotDyadminoOrientation + i) % 6;
      
        // if orientation hasn't changed, just return
      if (self.orientation != newOrientation) {
        
          // sound dyadmino click
        [self.delegate postSoundNotification:kNotificationPivotClick];
        
          // if it pivots on center, just go straight to positioning sprites
        if (_pivotOnPC != kPivotCentre) {
          
          CGFloat xIncrement = kDyadminoFaceRadius * 0.5 * kSquareRootOfThree * kDyadminoHoverResizeFactor;
          CGFloat yIncrement = kDyadminoFaceRadius * 0.5 * kDyadminoHoverResizeFactor;
          
            // pivot orientation starts out as the dyadmino orientation
          DyadminoOrientation pivotOrientation = newOrientation;
          
            // if pc2, pivot orientation is offset
          NSUInteger pivotOnPC2Offset = 0;
          if (_pivotOnPC == kPivotOnPC2) {
            pivotOrientation = 3 + pivotOrientation;
            pivotOnPC2Offset = 3;
          }
          pivotOrientation = pivotOrientation % 6;
          
            // when orientation changes, dyadmino will be in new position
          CGPoint newPosition = CGPointZero;
          
            //------------------------------------------------------------------
          
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
            //------------------------------------------------------------------
        }
        
        CGFloat difference = ((newOrientation - self.orientation + 6) % 6) * 60;
        self.orientation = newOrientation;
        [self selectAndPositionSpritesZRotation:dyadminoAngle + difference];
        [self determineNewAnchorPointDuringPivot:YES];
        return YES;
      }
    }
  }
  return NO;
}

-(void)zRotateToAngle:(CGFloat)angleForZRotation {
  
  self.zRotation = [self getRadiansFromDegree:angleForZRotation];
  self.pc1Sprite.zRotation = -[self getRadiansFromDegree:angleForZRotation];
  self.pc2Sprite.zRotation = -[self getRadiansFromDegree:angleForZRotation];
}

-(void)determineNewAnchorPointDuringPivot:(BOOL)during {
  
  if (_pivotOnPC == kPivotCentre) {
    self.anchorPoint = CGPointMake(0.5, 0.5);
    return;
  }
  
  CGPoint newAnchorPoint = CGPointZero;
  CGPoint originalPosition = self.position;
  CGPoint originalPC1Position = self.pc1Sprite.position;
  CGPoint originalPC2Position = self.pc2Sprite.position;
  
  CGPoint positionOffset;
  
  switch (self.orientation) {
    case kPC1atTwelveOClock:
      newAnchorPoint = (_pivotOnPC == kPivotOnPC1) ? CGPointMake(0.5, 0.75) : CGPointMake(0.5, 0.25);
      positionOffset = (_pivotOnPC == kPivotOnPC1) ? CGPointMake(0, kDyadminoFaceRadius) : CGPointMake(0, -kDyadminoFaceRadius);
      break;
    case kPC1atTwoOClock:
      newAnchorPoint = (_pivotOnPC == kPivotOnPC1) ? CGPointMake(5/7.f, 2/3.f) : CGPointMake(2/7.f, 1/3.f);
      positionOffset = (_pivotOnPC == kPivotOnPC1) ? CGPointMake(0.75 * kDyadminoFaceWideRadius, 0.5 * kDyadminoFaceRadius) : CGPointMake(-0.75 * kDyadminoFaceWideRadius, -0.5 * kDyadminoFaceRadius);
      break;
    case kPC1atFourOClock:
      newAnchorPoint = (_pivotOnPC == kPivotOnPC1) ? CGPointMake(5/7.f, 1/3.f) : CGPointMake(2/7.f, 2/3.f);
      positionOffset = (_pivotOnPC == kPivotOnPC1) ? CGPointMake(0.75 * kDyadminoFaceWideRadius, -0.5 * kDyadminoFaceRadius) : CGPointMake(-0.75 * kDyadminoFaceWideRadius, 0.5 * kDyadminoFaceRadius);
      break;
    case kPC1atSixOClock:
      newAnchorPoint = (_pivotOnPC == kPivotOnPC1) ? CGPointMake(0.5, 0.25) : CGPointMake(0.5, 0.75);
      positionOffset = (_pivotOnPC == kPivotOnPC1) ? CGPointMake(0, -kDyadminoFaceRadius) : CGPointMake(0, kDyadminoFaceRadius);
      break;
    case kPC1atEightOClock:
      newAnchorPoint = (_pivotOnPC == kPivotOnPC1) ? CGPointMake(2/7.f, 1/3.f) : CGPointMake(5/7.f, 2/3.f);
      positionOffset = (_pivotOnPC == kPivotOnPC1) ? CGPointMake(-0.75 * kDyadminoFaceWideRadius, -0.5 * kDyadminoFaceRadius) : CGPointMake(0.75 * kDyadminoFaceWideRadius, 0.5 * kDyadminoFaceRadius);
      break;
    case kPC1atTenOClock:
      newAnchorPoint = (_pivotOnPC == kPivotOnPC1) ? CGPointMake(2/7.f, 2/3.f) : CGPointMake(5/7.f, 1/3.f);
      positionOffset = (_pivotOnPC == kPivotOnPC1) ? CGPointMake(-0.75 * kDyadminoFaceWideRadius, 0.5 * kDyadminoFaceRadius) : CGPointMake(0.75 * kDyadminoFaceWideRadius, -0.5 * kDyadminoFaceRadius);
      break;
  }
  
  positionOffset = CGPointMake(positionOffset.x * kDyadminoHoverResizeFactor,
                               positionOffset.y * kDyadminoHoverResizeFactor);
  
  if (during) {
    self.anchorPoint = newAnchorPoint;
    _movedDueToChangeInAnchorPoint = YES;
    self.position = [self addToThisPoint:originalPosition thisPoint:positionOffset];
    self.pc1Sprite.position = [self subtractFromThisPoint:originalPC1Position thisPoint:positionOffset];
    self.pc2Sprite.position = [self subtractFromThisPoint:originalPC2Position thisPoint:positionOffset];
    
  } else {
    if (_movedDueToChangeInAnchorPoint) {
      self.position = [self subtractFromThisPoint:originalPosition thisPoint:positionOffset];
      self.pc1Sprite.position = [self addToThisPoint:originalPC1Position thisPoint:positionOffset];
      self.pc2Sprite.position = [self addToThisPoint:originalPC2Position thisPoint:positionOffset];
      _movedDueToChangeInAnchorPoint = NO;
    }
    self.anchorPoint = CGPointMake(0.5, 0.5);
  }
}

#pragma mark - query methods

-(BOOL)isInRack {
  return [self.parent.name isEqualToString:@"rack"];
}

-(BOOL)isOnBoard {
  return [self.parent.name isEqualToString:@"board"];
}

-(BOOL)isHovering {
  return self.hoveringStatus == kDyadminoHovering;
}

-(BOOL)continuesToHover {
  return self.hoveringStatus == kDyadminoContinuesHovering;
}

-(BOOL)isFinishedHovering {
  return self.hoveringStatus == kDyadminoFinishedHovering;
}

#pragma mark - placement methods

-(void)placeInTopBar:(BOOL)inTopBar {
  self.isInTopBar = inTopBar;
}

-(void)placeInBelongsInSwap:(BOOL)belongsInSwap {
  self.belongsInSwap = belongsInSwap;
}

#pragma mark - highlight metjods

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
  CGFloat inPlayFloat = [self getHeightFloatGivenGap:kGapForHighlight andDyadminoPosition:dyadminoOffsetPosition];
  self.colorBlendFactor = kDyadminoColorBlendFactor * inPlayFloat;
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
  BOOL faceIsPC1 = [face.name integerValue] == self.pc1;
  
  if (face.parent == self) {
    switch (self.orientation) {
      case kPC1atTwelveOClock:
        return faceIsPC1 ? [self hexCoordFromX:self.tempHexCoord.x andY:self.tempHexCoord.y + 1] : self.tempHexCoord;
        break;
      case kPC1atTwoOClock:
        return faceIsPC1 ? [self hexCoordFromX:self.tempHexCoord.x + 1 andY:self.tempHexCoord.y] : self.tempHexCoord;
        break;
      case kPC1atFourOClock:
        return faceIsPC1 ? self.tempHexCoord : [self hexCoordFromX:self.tempHexCoord.x - 1 andY:self.tempHexCoord.y + 1];
        break;
      case kPC1atSixOClock:
        return faceIsPC1 ? self.tempHexCoord : [self hexCoordFromX:self.tempHexCoord.x andY:self.tempHexCoord.y + 1];
        break;
      case kPC1atEightOClock:
        return faceIsPC1 ? self.tempHexCoord : [self hexCoordFromX:self.tempHexCoord.x + 1 andY:self.tempHexCoord.y];
        break;
      case kPC1atTenOClock:
        return faceIsPC1 ? [self hexCoordFromX:self.tempHexCoord.x - 1 andY:self.tempHexCoord.y + 1] : self.tempHexCoord;
        break;
    }
  }
  return self.tempHexCoord;
}

#pragma mark - custom accessor methods

-(PCMode)pcMode {
  if (!_pcMode) {
    _pcMode = kPCModeLetter;
  }
  return _pcMode;
}

-(void)setPcMode:(PCMode)pcMode {
  _pcMode = pcMode;
  self.name = [self updateName];
}

-(NSString *)name {
  if (!_name) {
    _name = [self updateName];
  }
  return _name;
}

-(void)setName:(NSString *)name {
  _name = name;
}

-(DyadminoHome)home {
  return (self.rackIndex == -1) ? kBoard : kRack;
}

-(void)setHome:(DyadminoHome)home {
  _home = home;
}

#pragma mark - name helper methods

-(NSString *)updateName {

    // Unicode u2011 is non-breaking hyphen, u2013 is N-dash, u2014 is M-dash
    // u2022 is bullet
  switch (self.pcMode) {
    case kPCModeLetter:
      return [NSString stringWithFormat:@"%@\u2013%@", [self stringForPC:self.pc1], [self stringForPC:self.pc2]];
      break;
    case kPCModeNumber:
      return [NSString stringWithFormat:@"%lu\u2013%lu", (unsigned long)self.pc1, (unsigned long)self.pc2];
      break;
  }
}

-(NSString *)stringForPC:(NSUInteger)pc {
  
    // Unicode u266d is flat, u00b7 is small bullet, u266f is sharp
  
  switch (pc) {
    case 0:
      return @"C";
      break;
    case 1:
      return @"C\u266f/D\u266d";
      break;
    case 2:
      return @"D";
      break;
    case 3:
      return @"D\u266f/E\u266d";
      break;
    case 4:
      return @"E";
      break;
    case 5:
      return @"F";
      break;
    case 6:
      return @"F\u266f/G\u266d";
      break;
    case 7:
      return @"G";
      break;
    case 8:
      return @"G\u266f/A\u266d";
      break;
    case 9:
      return @"A";
      break;
    case 10:
      return @"A\u266f/B\u266d";
      break;
    case 11:
      return @"B";
      break;
    default:
      return @"";
      break;
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