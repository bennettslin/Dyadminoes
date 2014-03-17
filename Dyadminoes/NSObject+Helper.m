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
  CGFloat angleDegrees = atan2f(point2.y - point1.y, point2.x - point1.x) * 180.f / M_PI + 180.f;
//  NSLog(@"angle is %f", angleDegrees);
  return angleDegrees;
}

-(CGFloat)getSextantFromThisAngle:(CGFloat)angle1 toThisAngle:(CGFloat)angle2 {
  CGFloat angle = 0.5f - ((angle1 - angle2) / 30);
  if (angle < 0.f) {
    angle += 12.f;
  }
  return angle;
}

-(CGFloat)getRadiansFromDegree:(CGFloat)degree {
  return (M_PI * degree) / 180;
}

-(BoardXY)boardXYFromX:(NSInteger)x andY:(NSInteger)y {
  BoardXY newBoardXY;
  newBoardXY.x = x;
  newBoardXY.y = y;
  return newBoardXY;
}

@end
