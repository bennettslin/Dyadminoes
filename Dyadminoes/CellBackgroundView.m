//
//  BackgroundView.m
//  Dyadminoes
//
//  Created by Bennett Lin on 7/21/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "CellBackgroundView.h"

@implementation CellBackgroundView

-(void)setBackgroundColor:(UIColor *)backgroundColor {
  if (self.backgroundColourCanBeChanged) {
    [super setBackgroundColor:backgroundColor];
    self.backgroundColourCanBeChanged = NO;
  }
}

@end
