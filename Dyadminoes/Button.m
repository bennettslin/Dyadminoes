//
//  Button.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/17/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Button.h"

@implementation Button

-(id)initWithName:(NSString *)name andColor:(UIColor *)color
          andSize:(CGSize)size andPosition:(CGPoint)position andZPosition:(CGFloat)zPosition {
  self = [super init];
  if (self) {
    self.name = name;
    self.color = color;
    self.size = size;
    self.position = position;
    self.zPosition = zPosition;
    
    SKLabelNode *labelNode = [SKLabelNode new];
    labelNode.text = self.name;
    labelNode.fontSize = 10.f;
    labelNode.position = CGPointMake(0, -self.size.height * 0.5);
    [self addChild:labelNode];
  }
  return self;
}

@end
