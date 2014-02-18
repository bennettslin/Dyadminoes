//
//  Dyadmino.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Dyadmino.h"

@implementation Dyadmino

-(id)initWithPC1:(NSUInteger)pc1 andPC2:(NSUInteger)pc2 andOrientation:(NSUInteger)orientation {
  self = [super init];
  if (self) {
    self.pc1 = pc1;
    self.pc2 = pc2;
    self.rackOrientation = orientation;
  }
  return self;
}

@end