//
//  Button.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/17/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Button.h"

@implementation Button {
  SKLabelNode *_labelNode;
  BOOL _isEnabled;
  BOOL _isSunkIn;
}

-(id)initWithName:(NSString *)name andColor:(UIColor *)color
          andSize:(CGSize)size andPosition:(CGPoint)position andZPosition:(CGFloat)zPosition {
  self = [super init];
  if (self) {
    self.userInteractionEnabled = YES;
    self.name = name;
    self.color = color;
    self.size = size;
    self.position = position;
    self.zPosition = zPosition;
    _isEnabled = NO;
    _isSunkIn = NO;
    
    _labelNode = [SKLabelNode new];
    _labelNode.text = self.name;
    _labelNode.name = [NSString stringWithFormat:@"%@ label", self.name];
    _labelNode.fontName = kFontHarmony;
    _labelNode.fontSize = kIsIPhone ? 20.f : 24.f;
    _labelNode.position = CGPointMake(0, -self.size.height * 0.5 + self.size.height / 8);
    [self addChild:_labelNode];
  }
  return self;
}

-(void)changeName {
  _labelNode.text = self.name;
  if ([self.name isEqualToString:@"play"] || [self.name isEqualToString:@"done"]) {
    [self glowOn:_isEnabled];
  } else {
    [self glowOn:NO];
  }
}

-(SwapCancelOrUndoButton)confirmSwapCancelOrUndo {
  if ([self.name isEqualToString:@"swap"]) {
    return kSwapButton;
  } else if ([self.name isEqualToString:@"reset"]) {
    return kResetButton;
  } else if ([self.name isEqualToString:@"cancel"]) {
    return kCancelButton;
  } else if ([self.name isEqualToString:@"undo"]) {
    return kUndoButton;
  } else if ([self.name isEqualToString:@"unlock"]) {
    return kUnlockButton;
  } else {
    return -1;
  }
}

-(PassPlayOrDoneButton)confirmPassPlayOrDone {
  if ([self.name isEqualToString:@"pass"]) {
    return kPassButton;
  } else if ([self.name isEqualToString:@"play"]) {
    return kPlayButton;
  } else if ([self.name isEqualToString:@"done"]) {
    return kDoneButton;
  } else {
    return -1;
  }
}

-(void)sinkInWithAnimation:(BOOL)animation andSound:(BOOL)sound {

  const CGFloat scaleTo = (1 / 1.1f);
    // FIXME: highlight button
  
  if (!animation) {
    _isSunkIn = YES;
    [self setScale:scaleTo];
    return;
  }
  
  if (!_isSunkIn && _isEnabled) {
    if (sound) {
      [self.delegate postSoundNotification:kNotificationButtonSunkIn];
    }
    _isSunkIn = YES; // establish right away so method can't be called again
    SKAction *moveAction = [SKAction scaleTo:scaleTo duration:kConstantTime * 0.075];
    moveAction.timingMode = SKActionTimingEaseOut;
    [self runAction:moveAction withKey:@"buttonSink"];
  }
}

-(void)liftWithAnimation:(BOOL)animation andSound:(BOOL)sound andCompletion:(void (^)(void))completion {
  
  if (!animation) {
    _isSunkIn = NO;
    [self setScale:1.f];
    return;
  }
  
  if (_isEnabled && _isSunkIn) {
    if (sound) {
      [self.delegate postSoundNotification:kNotificationButtonLifted];
    }
    _isSunkIn = NO; // establish right away so method can't be called again
    SKAction *liftAction = [SKAction scaleTo:1.f duration:kConstantTime * 0.075];
    SKAction *completionAction = [SKAction runBlock:completion];
    SKAction *sequence = [SKAction sequence:@[liftAction, completionAction]];
    [self runAction:sequence withKey:@"buttonLift"];
  }
}

-(void)glowOn:(BOOL)on {
  
    // remove any previous glow
  for (SKNode *node in self.children) {
    if ([node isKindOfClass:[SKShapeNode class]] && [node.name isEqualToString:@"glow"]) {
      
      NSArray *array = @[node];
      [self removeChildrenInArray:array];
    }
  }
  
  if (on) {
    SKShapeNode *shapeNode = [SKShapeNode new];
    CGMutablePathRef shapePath = CGPathCreateMutable();
    
      // line out
    CGPathMoveToPoint(shapePath, NULL, -self.size.width * 0.5f, -self.size.height * 0.5f);
    CGPathAddLineToPoint(shapePath, NULL, self.size.width * 0.5f, -self.size.height * 0.5f);
    CGPathAddLineToPoint(shapePath, NULL, self.size.width * 0.5f, self.size.height * 0.5f);
    CGPathAddLineToPoint(shapePath, NULL, -self.size.width * 0.5f, self.size.height * 0.5f);
      CGPathAddLineToPoint(shapePath, NULL, -self.size.width * 0.5f, -self.size.height * 0.5f);

    shapeNode.path = shapePath;
    CGPathRelease(shapePath);
    
    shapeNode.lineWidth = 1.f;
    shapeNode.glowWidth = self.size.width * 0.1f;
    shapeNode.alpha = 0.75f;
    shapeNode.strokeColor = kEndedMatchCellLightColour;
    shapeNode.fillColor = kEndedMatchCellLightColour;
    shapeNode.zPosition = - 1.f;
    shapeNode.name = @"glow";
    [self addChild:shapeNode];
    
    self.zPosition = kZPositionTopBarButton + 2.f;
    
  } else {
    self.zPosition = kZPositionTopBarButton;
  }
}

-(BOOL)isEnabled {
  return _isEnabled;
}

-(void)enable:(BOOL)isEnabled {
  
  if ([self.name isEqualToString:@"play"] || [self.name isEqualToString:@"done"] || [self.name isEqualToString:@"unlock"]) {
    [self glowOn:isEnabled];
  }
  _isEnabled = isEnabled;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if ([self isEnabled]) {
    BOOL frameContainsPoint = [self frameContainsTouchFromTouches:touches];
    if (frameContainsPoint && !_isSunkIn) {
      [self sinkInWithAnimation:YES andSound:YES];
    }
  }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if ([self isEnabled]) {
    BOOL frameContainsPoint = [self frameContainsTouchFromTouches:touches];
    if (frameContainsPoint && !_isSunkIn) {
      [self sinkInWithAnimation:YES andSound:NO];
    } else if (!frameContainsPoint && _isSunkIn) {
      [self liftWithAnimation:YES andSound:NO andCompletion:nil];
    }
  }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self touchesEnded:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if ([self isEnabled]) {

    void(^completion)(void);

    BOOL frameContainsPoint = [self frameContainsTouchFromTouches:touches];
      
    if (frameContainsPoint) {
      __weak typeof(self) weakSelf = self;
      completion = ^void(void) {
        [weakSelf.delegate handleButtonPressed:weakSelf];
      };
    } else {
      completion = nil;
    }
    
    [self liftWithAnimation:YES andSound:YES andCompletion:completion];
  }
}

#pragma mark - helper methods

-(BOOL)frameContainsTouchFromTouches:(NSSet *)touches {
  UITouch *touch = [touches anyObject];
  CGPoint location = [touch locationInNode:self.parent];
  BOOL frameContainsPoint = CGRectContainsPoint(self.frame, location);
  return frameContainsPoint;
}

@end
