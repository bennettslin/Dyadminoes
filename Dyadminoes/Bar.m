//
//  TopBar.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Bar.h"
#import "Button.h"

@interface Bar ()

@end

@implementation Bar {
  NSUInteger _rotationFromDevice;
}

-(id)initWithColor:(UIColor *)color andSize:(CGSize)size andTop:(BOOL)top
    andAnchorPoint:(CGPoint)anchorPoint
       andPosition:(CGPoint)position
      andZPosition:(CGFloat)zPosition {
  self = [super init];
  if (self) {
    self.size = size;
    self.anchorPoint = anchorPoint;
    self.position = position;
    self.zPosition = zPosition;
    _rotationFromDevice = 0;
    [self addGradientBackgroundWithColour:color upsideDown:top];
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

#pragma mark - delegate methods

-(void)handleButtonPressed:(Button *)button {
  [self.delegate handleButtonPressed:button];
}

-(void)goBackToMainViewController {
  [self.delegate goBackToMainViewController];
}

-(void)postSoundNotification:(NotificationName)whichNotification {
  [self.delegate postSoundNotification:whichNotification];
}

#pragma mark - helper methods

-(void)addGradientBackgroundWithColour:(UIColor *)colour upsideDown:(BOOL)upsideDown {
  
//  const CGFloat bounceBuffer = 16.f / 15.f;
  
  UIGraphicsBeginImageContext(CGSizeMake(self.size.width, self.size.height));
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGGradientRef gradient;
  CGColorSpaceRef colorSpace;
  
  CGFloat location[] = {1};

  UIColor *colourTwo = [UIColor clearColor];
  
  NSArray *colours;
  CGGradientDrawingOptions option;
//  CGPoint endPoint;
  if (!upsideDown) {
    colours = @[(id)colour.CGColor, (id)colourTwo.CGColor];
    option = kCGGradientDrawsBeforeStartLocation;
  } else {
    colours = @[(id)colourTwo.CGColor, (id)colour.CGColor];
    option = kCGGradientDrawsAfterEndLocation;
  }
  
  colorSpace = CGColorSpaceCreateDeviceRGB();
  gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colours, location);
  
  CGPoint startPoint = CGPointMake(self.size.width / 2, 0);
  CGPoint endPoint = CGPointMake(self.size.width / 2, self.size.height);
  
  
  CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, option);
  
  CGColorSpaceRelease(colorSpace);
  CGGradientRelease(gradient);
  
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  SKTexture *newTexture = [SKTexture textureWithImage:newImage];
  newTexture.filteringMode = SKTextureFilteringNearest;
  
  SKSpriteNode *newNode = [SKSpriteNode spriteNodeWithTexture:newTexture];
  newNode.zPosition = -10;
  newNode.position = CGPointMake(self.size.width / 2, self.size.height / 2);
  
  [self addChild:newNode];
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
