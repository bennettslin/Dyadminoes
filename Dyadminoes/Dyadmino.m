//
//  Dyadmino.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Dyadmino.h"

@implementation Dyadmino {
  BOOL _alreadyAddedChildren;
  CGSize _highlightedSize;
}

-(id)initWithPC1:(NSUInteger)pc1 andPC2:(NSUInteger)pc2 andPCMode:(PCMode)pcMode andRotationFrameArray:(NSArray *)rotationFrameArray andPC1LetterSprite:(SKSpriteNode *)pc1LetterSprite andPC2LetterSprite:(SKSpriteNode *)pc2LetterSprite andPC1NumberSprite:(SKSpriteNode *)pc1NumberSprite andPC2NumberSprite:(SKSpriteNode *)pc2NumberSprite {
  self = [super init];
  if (self) {
      // constants
    self.color = [UIColor purpleColor]; // for color blend factor
    self.zPosition = kZPositionRackRestingDyadmino;
    self.name = [NSString stringWithFormat:@"dyadmino %i-%i", pc1, pc2];
    self.pc1 = pc1;
    self.pc2 = pc2;
    self.pcMode = pcMode;
    self.rotationFrameArray = rotationFrameArray;
    self.pc1LetterSprite = pc1LetterSprite;
    self.pc2LetterSprite = pc2LetterSprite;
    self.pc1NumberSprite = pc1NumberSprite;
    self.pc2NumberSprite = pc2NumberSprite;
    self.withinSection = kDyadminoWithinRack;
    self.hoveringStatus = kDyadminoNoHoverStatus;
    [self randomiseRackOrientation];
    [self selectAndPositionSprites];
  }
  return self;
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
  
  switch (self.orientation) {
    case kPC1atTwelveOClock:
      self.texture = self.rotationFrameArray[0];
      [self resizeDyadmino];
      self.pc1Sprite.position = CGPointMake(0, -self.size.height / 4);
      self.pc2Sprite.position = CGPointMake(0, self.size.height / 4);
      break;
    case kPC1atTwoOClock:
      self.texture = self.rotationFrameArray[1];
      [self resizeDyadmino];
      self.pc1Sprite.position = CGPointMake(-self.size.width * 1.5f / 7, -self.size.height / 6);
      self.pc2Sprite.position = CGPointMake(self.size.width * 1.5f / 7, self.size.height / 6);
      break;
    case kPC1atFourOClock:
      self.texture = self.rotationFrameArray[2];
      [self resizeDyadmino];
      self.pc1Sprite.position = CGPointMake(-self.size.width * 1.5f / 7, self.size.height / 6);
      self.pc2Sprite.position = CGPointMake(self.size.width * 1.5f / 7, -self.size.height / 6);
      break;
    case kPC1atSixOClock:
      self.texture = self.rotationFrameArray[0];
      [self resizeDyadmino];
      self.pc1Sprite.position = CGPointMake(0, self.size.height / 4);
      self.pc2Sprite.position = CGPointMake(0, -self.size.height / 4);
      break;
    case kPC1atEightOClock:
      self.texture = self.rotationFrameArray[1];
      [self resizeDyadmino];
      self.pc1Sprite.position = CGPointMake(self.size.width * 1.5f / 7, self.size.height / 6);
      self.pc2Sprite.position = CGPointMake(-self.size.width * 1.5f / 7, -self.size.height / 6);
      break;
    case kPC1atTenOClock:
      self.texture = self.rotationFrameArray[2];
      [self resizeDyadmino];      
      self.pc1Sprite.position = CGPointMake(self.size.width * 1.5f / 7, -self.size.height / 6);
      self.pc2Sprite.position = CGPointMake(-self.size.width * 1.5f / 7, self.size.height / 6);
      break;
  }
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

-(void)resizeDyadmino {
  if (self.isHoverHighlighted) {
    self.size = CGSizeMake(self.texture.size.width * kHighlightedDyadminoSize, self.texture.size.height * kHighlightedDyadminoSize);
    self.pc1Sprite.size = CGSizeMake(self.pc1Sprite.texture.size.width * kHighlightedDyadminoSize, self.pc1Sprite.texture.size.height * kHighlightedDyadminoSize);
    self.pc2Sprite.size = CGSizeMake(self.pc2Sprite.texture.size.width * kHighlightedDyadminoSize, self.pc2Sprite.texture.size.height * kHighlightedDyadminoSize);
  } else {
    self.size = self.texture.size;
    self.pc1Sprite.size = self.pc1Sprite.texture.size;
    self.pc2Sprite.size = self.pc2Sprite.texture.size;
  }
}

-(void)hoverHighlight {
  self.isHoverHighlighted = YES;
  self.hoveringStatus = kDyadminoHovering;
    // for now, hovering just resizes
  [self resizeDyadmino];
  [self selectAndPositionSprites];
}

-(void)hoverUnhighlight {
  self.isHoverHighlighted = NO;
  self.hoveringStatus = kDyadminoFinishedHovering;
    // for now, hovering just resizes
  [self resizeDyadmino];
  [self selectAndPositionSprites];
}

-(void)inPlayHighlight {
  self.isInPlayHighlighted = YES;
  self.colorBlendFactor = 0.2f;
  [self selectAndPositionSprites];
}

-(void)inPlayUnhighlight {
  self.isInPlayHighlighted = NO;
  self.colorBlendFactor = 0.f;
  [self selectAndPositionSprites];
}

-(void)setToHomeZPosition {
  if (self.homeNode.snapNodeType == kSnapNodeRack) {
    self.zPosition = kZPositionRackRestingDyadmino;
  } else {
    self.zPosition = kZPositionBoardRestingDyadmino;
  }
}

-(void)setToTempZPosition {
  if (self.tempReturnNode.snapNodeType == kSnapNodeRack) {
    self.zPosition = kZPositionRackRestingDyadmino;
  } else {
    self.zPosition = kZPositionBoardRestingDyadmino;
  }
}

#pragma mark - animation methods

-(void)animateConstantTimeMoveToPoint:(CGPoint)point {
  [self removeAllActions];
  SKAction *moveAction = [SKAction moveTo:point duration:kConstantTime];
  [self runAction:moveAction];
}

-(void)animateSlowerConstantTimeMoveToPoint:(CGPoint)point {
  [self removeAllActions];
  SKAction *snapAction = [SKAction moveTo:point duration:kSlowerConstantTime];
  [self runAction:snapAction];
}

-(void)animateConstantSpeedMoveDyadminoToPoint:(CGPoint)point{
  [self removeAllActions];
  CGFloat distance = [self getDistanceFromThisPoint:self.position toThisPoint:point];
  SKAction *snapAction = [SKAction moveTo:point duration:kConstantSpeed * distance];
  [self runAction:snapAction];
}

-(void)animateRotate {
  [self removeAllActions];
  self.isRotating = YES;
  
  SKAction *nextFrame = [SKAction runBlock:^{
    self.orientation = (self.orientation + 1) % 6;
    [self selectAndPositionSprites];
  }];
  SKAction *waitTime = [SKAction waitForDuration:kRotateWait];
  SKAction *finishAction;
  
    // rotation
  if (self.withinSection == kDyadminoWithinRack) {
    finishAction = [SKAction runBlock:^{
      [self hoverUnhighlight];
      [self setToHomeZPosition];
      self.isRotating = NO;
    }];
      // just to ensure that dyadmino is back in its node position
    self.position = self.homeNode.position;
    
  } else if (self.withinSection == kDyadminoWithinBoard) {
    finishAction = [SKAction runBlock:^{
      [self selectAndPositionSprites];
      [self setToHomeZPosition];
      self.isRotating = NO;
      self.tempReturnOrientation = self.orientation;
    }];
  }
  
  SKAction *completeAction = [SKAction sequence:@[nextFrame, waitTime, nextFrame, waitTime, nextFrame, finishAction]];
  [self runAction:completeAction];
}

-(void)animateHoverAndFinishedStatus {
  [self removeAllActions];
  SKAction *dyadminoHover = [SKAction waitForDuration:kAnimateHoverTime];
  SKAction *dyadminoFinishStatus = [SKAction runBlock:^{
    [self setToHomeZPosition];
    [self hoverUnhighlight];
    self.tempReturnOrientation = self.orientation;
  }];
  SKAction *actionSequence = [SKAction sequence:@[dyadminoHover, dyadminoFinishStatus]];
  [self runAction:actionSequence];
}

@end