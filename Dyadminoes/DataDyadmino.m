//
//  DataDyadmino.m
//  Dyadminoes
//
//  Created by Bennett Lin on 6/1/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "DataDyadmino.h"

@implementation DataDyadmino

-(id)initWithID:(NSUInteger)id {
  self = [super init];
  if (self) {
    self.myID = id;
    
      // set rack orientation
    int randNum = arc4random() % 2;
    self.myOrientation = (randNum == 0) ? kPC1atTwelveOClock : kPC1atSixOClock;
  }
  return self;
}

@end
