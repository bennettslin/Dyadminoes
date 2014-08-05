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

-(void)enableButton:(Button *)button {
  button.hidden = NO;
  if (button && !button.parent) {
    [self addChild:button];
  }
}

-(void)disableButton:(Button *)button {
  button.hidden = YES;
  if (button && button.parent) {
    [button removeFromParent];
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

-(void)updateLabelNamed:(NSString *)name withText:(NSString *)text andColour:(UIColor *)colour {
  Label *label = [self.allLabels valueForKey:name];
  
  if (label) {
    
    if (!colour) {
      label.fontColor = label.originalFontColour;
    } else {
      label.fontColor = colour;
    }
    
    if (!label.parent) {
      [self addChild:label];
    }
    label.text = text;
  }
}

-(void)flashLabelNamed:(NSString *)name withText:(NSString *)text andColour:(UIColor *)colour {
  Label *label = [self.allLabels valueForKey:name];
  if (label) {
    [label removeAllActions];
    if (!label.parent) {
      [self addChild:label];
    }

    if (!colour) {
      label.fontColor = label.originalFontColour;
    } else {
      label.fontColor = colour;
    }
    
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
