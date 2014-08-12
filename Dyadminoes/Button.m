//
//  Button.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/17/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Button.h"

@implementation Button {
  SKLabelNode *_labelNode;
}

-(id)initWithName:(NSString *)name andColor:(UIColor *)color
          andSize:(CGSize)size andPosition:(CGPoint)position andZPosition:(CGFloat)zPosition {
  self = [super init];
  if (self) {
    self.name = name;
    self.color = color;
    self.size = size;
    self.position = position;
    self.zPosition = zPosition;
    
    _labelNode = [SKLabelNode new];
    _labelNode.text = self.name;
    _labelNode.name = [NSString stringWithFormat:@"%@ label", self.name];
    _labelNode.fontName = kFontHarmony;
    _labelNode.fontSize = kIsIPhone ? 20.f : 24.f;
    _labelNode.position = CGPointMake(0, -self.size.height * 0.5 + self.size.height / 8);
    [self addChild:_labelNode];
  }
  return self;
}

-(void)changeName {
  _labelNode.text = self.name;
}

-(SwapCancelOrUndoButton)confirmSwapCancelOrUndo {
  if ([self.name isEqualToString:@"swap"]) {
    return kSwapButton;
  } else if ([self.name isEqualToString:@"cancel"]) {
    return kCancelButton;
  } else if ([self.name isEqualToString:@"undo"]) {
    return kUndoButton;
  } else {
    return -1;
  }
}

-(PassPlayOrDoneButton)confirmPassPlayOrDone {
  if ([self.name isEqualToString:@"pass"]) {
    return kPassButton;
  } else if ([self.name isEqualToString:@"play"]) {
    return kPlayButton;
  } else if ([self.name isEqualToString:@"done"]) {
    return kDoneButton;
  } else {
    return -1;
  }
}

-(void)showSunkIn {
  self.alpha = 0.3f;
}

-(void)showLifted {
  self.alpha = 1.f;
}

@end
