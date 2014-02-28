//
//  NSObject+Helper.m
//  Dyadminoes
//
//  Created by Bennett Lin on 2/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "NSObject+Helper.h"

@implementation NSObject (Helper)

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

@end
