//
//  Label.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/19/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Label.h"

@implementation Label

-(id)initWithName:(NSString *)name
         andColor:(UIColor *)color
      andFontSize:(CGFloat)fontSize
      andPosition:(CGPoint)position
     andZPosition:(CGFloat)zPosition
    andHorizontalAlignment:(SKLabelHorizontalAlignmentMode)horizontalAlignment {
  
  self = [super init];
  if (self) {
    self.name = name;
    self.color = color;
    self.fontSize = fontSize;
    self.position = position;
    self.zPosition = zPosition;
    self.horizontalAlignmentMode = horizontalAlignment;
  }
  return self;
}

@end
