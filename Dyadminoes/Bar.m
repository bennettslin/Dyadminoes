//
//  TopBar.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Bar.h"
#import "Button.h"
#import "Label.h"

@implementation Bar {
  NSUInteger _rotationFromDevice;
}

-(id)initWithColor:(UIColor *)color andSize:(CGSize)size
    andAnchorPoint:(CGPoint)anchorPoint
       andPosition:(CGPoint)position
      andZPosition:(CGFloat)zPosition {
  self = [super init];
  if (self) {
    self.color = color;
    self.size = size;
    self.anchorPoint = anchorPoint;
    self.position = position;
    self.zPosition = zPosition;
    _rotationFromDevice = 0;
  }
  return self;
}

#pragma mark - button methods

-(void)node:(SKNode *)node shouldBeEnabled:(BOOL)enabled {
  if (node) {
    if (enabled) {
      node.hidden = NO;
      node.zPosition = [node isKindOfClass:[Label class]] ? kZPositionTopBarLabel : node.zPosition;
      if (!node.parent) {
        [self addChild:node];
      }
    } else {
      node.hidden = YES;
      node.zPosition = [node isKindOfClass:[Label class]] ? -CGFLOAT_MAX : node.zPosition;
      if (node.parent) {
        [node removeFromParent];
      }
    }
  }
}

-(BOOL)rotateButtonsBasedOnDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
  
  NSUInteger rotation = _rotationFromDevice;
  switch (deviceOrientation) {
    case UIDeviceOrientationPortrait:
      rotation = 0;
      break;
    case UIDeviceOrientationLandscapeRight:
      rotation = 90;
      break;
    case UIDeviceOrientationPortraitUpsideDown:
      rotation = 180;
      break;
    case UIDeviceOrientationLandscapeLeft:
      rotation = 270;
      break;
    default:
      break;
  }
  
  if (rotation != _rotationFromDevice) {

    for (Button *button in self.allButtons) {
      button.zRotation = [self getRadiansFromDegree:rotation];
    }
    
    _rotationFromDevice = rotation;
    return YES;
  } else {
    return NO;
  }
}

#pragma mark - label view methods

-(void)updateLabel:(Label *)label withText:(NSString *)text andColour:(UIColor *)colour {
  
  if (label) {
      label.fontColor = colour ? colour : label.originalFontColour;
    
    if (!label.parent) {
      [self addChild:label];
    }
    label.text = text;
  }
}

-(void)flashLabel:(Label *)label withText:(NSString *)text andColour:(UIColor *)colour {

  if (label) {
    [label removeAllActions];
    if (!label.parent) {
      [self addChild:label];
    }

    label.fontColor = colour ? colour : label.originalFontColour;
    
    label.text = text;
    label.alpha = 0.f;

    SKAction *fadeIn = [SKAction fadeInWithDuration:.25f];
    SKAction *wait = [SKAction waitForDuration:1.75f];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:0.5f];
    
    SKAction *finishAnimation = [SKAction runBlock:^{
      label.text = @"";
      [label removeFromParent];
      label.alpha = 1.f;
      label.fontColor = label.originalFontColour;
    }];
    
    SKAction *sequence = [SKAction sequence:@[fadeIn, wait, fadeOut, finishAnimation]];
    [label runAction:sequence withKey:@"flash"];
  }
}

@end
