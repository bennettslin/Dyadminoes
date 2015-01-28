//
//  TopBar.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Bar.h"
#import "Button.h"

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
    
    if ([node isKindOfClass:[Button class]]) {
      Button *button = (Button *)node;
      [button enable:enabled];
    }
    
    CGFloat fadeAlpha = enabled ? 1.f : 0.2f;
    SKAction *alphaAction = [SKAction fadeAlphaTo:fadeAlpha duration:0.f];
    [node runAction:alphaAction];
  }
}

/*
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
 */

@end
