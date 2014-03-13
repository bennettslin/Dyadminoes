//
//  SnapNode.m
//  Dyadminoes
//
//  Created by Bennett Lin on 2/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "SnapNode.h"
#import "Dyadmino.h"

@implementation SnapNode

-(id)initWithSnapNodeType:(SnapNodeType)snapNodeType {
  self = [super init];
  if (self) {
    self.snapNodeType = snapNodeType;
  }
  return self;
}

-(SnapNodeType)isType {
  return self.snapNodeType;
}

@end
