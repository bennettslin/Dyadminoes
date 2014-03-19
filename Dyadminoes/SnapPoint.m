//
//  SnapNode.m
//  Dyadminoes
//
//  Created by Bennett Lin on 2/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "SnapPoint.h"
#import "Dyadmino.h"

@implementation SnapPoint

-(id)initWithSnapPointType:(SnapPointType)snapPointType {
  self = [super init];
  if (self) {
    self.snapPointType = snapPointType;
  }
  return self;
}

-(BOOL)isBoardNode {
  if (self.snapPointType == kSnapPointBoardTwelveOClock ||
      self.snapPointType == kSnapPointBoardTwoOClock ||
      self.snapPointType == kSnapPointBoardTenOClock) {
    return YES;
  } else {
    return NO;
  }
}

@end
