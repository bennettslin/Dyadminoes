//
//  NSObject+Helper.m
//  Dyadminoes
//
//  Created by Bennett Lin on 2/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "NSObject+Helper.h"
#import "Dyadmino.h"

@implementation NSObject (Helper)

#pragma mark - math methods

-(NSUInteger)randomValueUpTo:(NSUInteger)high {
  NSUInteger randInteger = ((int) arc4random() % high);
  return randInteger;
}

-(CGFloat)getDistanceFromThisPoint:(CGPoint)point1 toThisPoint:(CGPoint)point2 {
  CGFloat xDistance = point1.x - point2.x;
  CGFloat yDistance = point1.y - point2.y;
  CGFloat distance = sqrtf((xDistance * xDistance) + (yDistance * yDistance));
  return distance;
}

-(CGPoint)addThisPoint:(CGPoint)point1 toThisPoint:(CGPoint)point2 {
  return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

-(CGPoint)fromThisPoint:(CGPoint)point1 subtractThisPoint:(CGPoint)point2 {
  return CGPointMake(point1.x - point2.x, point1.y - point2.y);
}

-(CGFloat)findAngleInDegreesFromThisPoint:(CGPoint)point1 toThisPoint:(CGPoint)point2 {
  CGFloat angleDegrees = atan2f(point2.y - point1.y, point2.x - point1.x) * 180 / M_PI;
//  NSLog(@"angle is %f", angleDegrees);
  return angleDegrees;
}

-(CGFloat)getSextantChangeFromThisAngle:(CGFloat)angle1 toThisAngle:(CGFloat)angle2 {
  CGFloat angle = 0.5f - ((angle1 - angle2) / 30);
  if (angle < 0.f) {
    angle += 12.f;
  }
  return angle;
}

#pragma mark - animation methods

-(void)animateConstantTimeMoveDyadmino:(Dyadmino *)dyadmino toThisPoint:(CGPoint)point {
  [dyadmino removeAllActions];
  SKAction *moveAction = [SKAction moveTo:point duration:kConstantTime];
  [dyadmino runAction:moveAction];
}

-(void)animateSlowerConstantTimeMoveDyadmino:(Dyadmino *)dyadmino toThisPoint:(CGPoint)point {
  [dyadmino removeAllActions];
  SKAction *snapAction = [SKAction moveTo:point duration:kSlowerConstantTime];
  [dyadmino runAction:snapAction];
}

-(void)animateConstantSpeedMoveDyadmino:(Dyadmino *)dyadmino toThisPoint:(CGPoint)point {
  [dyadmino removeAllActions];
  CGFloat distance = [self getDistanceFromThisPoint:dyadmino.position toThisPoint:point];
  SKAction *snapAction = [SKAction moveTo:point duration:kConstantSpeed * distance];
  [dyadmino runAction:snapAction];
}

-(void)animateRotateDyadmino:(Dyadmino *)dyadmino {
  [dyadmino removeAllActions];
  dyadmino.isRotating = YES;
  
  SKAction *nextFrame = [SKAction runBlock:^{
    dyadmino.orientation = (dyadmino.orientation + 1) % 6;
    [dyadmino selectAndPositionSprites];
  }];
  SKAction *waitTime = [SKAction waitForDuration:kRotateWait];
  SKAction *finishAction;
  SKAction *completeAction;
  
    // rotation
  if (dyadmino.withinSection == kDyadminoWithinRack) {
    finishAction = [SKAction runBlock:^{
      [dyadmino hoverUnhighlight];
      [dyadmino setToHomeZPosition];
      dyadmino.isRotating = NO;
    }];
    completeAction = [SKAction sequence:@[nextFrame, waitTime, nextFrame, waitTime, nextFrame, finishAction]];
    
      // just to ensure that dyadmino is back in its node position
    dyadmino.position = dyadmino.homeNode.position;
    
  } else if (dyadmino.withinSection == kDyadminoWithinBoard) {
    finishAction = [SKAction runBlock:^{
      [dyadmino selectAndPositionSprites];
      [dyadmino setToHomeZPosition];
      dyadmino.isRotating = NO;
      dyadmino.tempReturnOrientation = dyadmino.orientation;
    }];
    completeAction = [SKAction sequence:@[nextFrame, finishAction]];
  }
  [dyadmino runAction:completeAction];
}

-(void)animateHoverAndFinishedStatusOfDyadmino:(Dyadmino *)dyadmino {
  [dyadmino removeAllActions];
  SKAction *dyadminoHover = [SKAction waitForDuration:kAnimateHoverTime];
  SKAction *dyadminoFinishStatus = [SKAction runBlock:^{
    [dyadmino setToHomeZPosition];
    [dyadmino hoverUnhighlight];
    dyadmino.tempReturnOrientation = dyadmino.orientation;
  }];
  SKAction *actionSequence = [SKAction sequence:@[dyadminoHover, dyadminoFinishStatus]];
  [dyadmino runAction:actionSequence];
}

@end
