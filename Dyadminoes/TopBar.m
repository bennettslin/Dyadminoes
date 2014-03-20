//
//  TopBar.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "TopBar.h"
#import "Button.h"
#import "Label.h"

#define kLabelYPosition 5.f
#define kButtonWidth 45.f
#define kButtonSize CGSizeMake(kButtonWidth, kButtonWidth)
#define kButtonYPosition 30.f

@implementation TopBar

-(id)initWithColor:(UIColor *)color andSize:(CGSize)size
    andAnchorPoint:(CGPoint)anchorPoint
       andPosition:(CGPoint)position
      andZPosition:(CGFloat)zPosition {
  self = [super init];
  if (self) {
    self.color = color;
    self.size = size;
    self.anchorPoint = anchorPoint;
    self.position = position;
    self.zPosition = zPosition;
    self.allButtons = [NSMutableSet new];
    self.allLabels = [NSMutableDictionary new];
  }
  return self;
}

-(void)populateWithButtons {
  self.togglePCModeButton = [[Button alloc] initWithName:@"toggle" andColor:[SKColor orangeColor]
                                                 andSize:kButtonSize
                                             andPosition:CGPointMake(kButtonWidth, kButtonYPosition)
                                            andZPosition:kZPositionTopBarButton];
  [self.allButtons addObject:self.togglePCModeButton];
  [self enableButton:self.togglePCModeButton];
  
  self.swapButton = [[Button alloc] initWithName:@"swap" andColor:[SKColor brownColor]
                                         andSize:kButtonSize
                                     andPosition:CGPointMake(kButtonWidth * 2, kButtonYPosition)
                                    andZPosition:kZPositionTopBarButton];
  [self.allButtons addObject:self.swapButton];
  [self enableButton:self.swapButton];
  
  self.cancelButton = [[Button alloc] initWithName:@"cancel" andColor:[SKColor redColor]
                                           andSize:kButtonSize
                                       andPosition:CGPointMake(kButtonWidth * 2, kButtonYPosition)
                                      andZPosition:kZPositionTopBarButton];
  [self.allButtons addObject:self.cancelButton];
  [self disableButton:_cancelButton];
  
  self.playDyadminoButton = [[Button alloc] initWithName:@"play" andColor:kDarkGreen
                                                 andSize:kButtonSize
                                             andPosition:CGPointMake(kButtonWidth * 3, kButtonYPosition)
                                            andZPosition:kZPositionTopBarButton];
  [self.allButtons addObject:self.playDyadminoButton];
  [self disableButton:_playDyadminoButton];
  
  self.doneTurnButton = [[Button alloc] initWithName:@"done" andColor:[SKColor blueColor]
                                             andSize:kButtonSize
                                         andPosition:CGPointMake(kButtonWidth * 3, kButtonYPosition)
                                        andZPosition:kZPositionTopBarButton];
  [self.allButtons addObject:self.doneTurnButton];
  [self enableButton:self.doneTurnButton];
  
  self.debugButton = [[Button alloc] initWithName:@"debug" andColor:[SKColor blackColor]
                                        andSize:kButtonSize
                                    andPosition:CGPointMake(kButtonWidth * 4, kButtonYPosition)
                                   andZPosition:kZPositionTopBarButton];
  [self.allButtons addObject:self.debugButton];
  [self enableButton:self.debugButton];
}

-(void)populateWithLabels {
  
  self.scoreLabel = [[Label alloc] initWithName:@"score"
                                   andFontColor:[SKColor whiteColor]
                                    andFontSize:14.f
                                    andPosition:CGPointMake(self.size.width - 5.f, 45.f)
                                   andZPosition:kZPositionTopBarLabel
                         andHorizontalAlignment:SKLabelHorizontalAlignmentModeRight];
  [self.allLabels setValue:self.scoreLabel forKey:self.scoreLabel.name];
  
  self.pileCountLabel = [[Label alloc] initWithName:@"pileCount"
                                       andFontColor:[SKColor whiteColor]
                                        andFontSize:14.f
                                        andPosition:CGPointMake(self.size.width - 5.f, 30.f)
                                       andZPosition:kZPositionTopBarLabel
                             andHorizontalAlignment:SKLabelHorizontalAlignmentModeRight];
  [self.allLabels setValue:self.pileCountLabel forKey:self.pileCountLabel.name];
  
  self.messageLabel = [[Label alloc] initWithName:@"message"
                                     andFontColor:kTestRed
                                      andFontSize:14.f
                                      andPosition:CGPointMake(5.f, -kLabelYPosition * 3)
                                     andZPosition:kZPositionMessage
                           andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [self.allLabels setValue:self.messageLabel forKey:self.messageLabel.name];
  
  self.logLabel = [[Label alloc] initWithName:@"log"
                                 andFontColor:[SKColor whiteColor]
                                  andFontSize:14.f
                                  andPosition:CGPointMake(self.size.width - 5.f, -kLabelYPosition * 3)
                                 andZPosition:kZPositionMessage
                       andHorizontalAlignment:SKLabelHorizontalAlignmentModeRight];
  [self.allLabels setValue:self.logLabel forKey:self.logLabel.name];
  
  self.chordLabel = [[Label alloc] initWithName:@"chord"
                                 andFontColor:[SKColor yellowColor]
                                  andFontSize:16.f
                                  andPosition:CGPointMake(self.size.width / 2, -kLabelYPosition * 6)
                                 andZPosition:kZPositionMessage
                       andHorizontalAlignment:SKLabelHorizontalAlignmentModeCenter];
  [self.allLabels setValue:self.chordLabel forKey:self.chordLabel.name];
}

#pragma mark - button methods

-(void)enableButton:(Button *)button {
  button.hidden = NO;
  if (!button.parent) {
    [self addChild:button];
  }
}

-(void)disableButton:(Button *)button {
  button.hidden = YES;
  if (button.parent) {
    [button removeFromParent];
  }
}

#pragma mark - label methods

-(void)updateLabelNamed:(NSString *)name withText:(NSString *)text {
  Label *label = [self.allLabels valueForKey:name];
  if (label) {
    if (!label.parent) {
      [self addChild:label];
    }
    label.text = text;
  }
}

-(void)flashLabelNamed:(NSString *)name withText:(NSString *)text {
  Label *label = [self.allLabels valueForKey:name];
  if (label) {
    [label removeAllActions];
    if (!label.parent) {
      [self addChild:label];
    }
    label.text = text;
    SKAction *wait = [SKAction waitForDuration:2.f];
    SKAction *fadeColor = [SKAction colorizeWithColor:[UIColor clearColor] colorBlendFactor:1.f duration:0.5f];
    SKAction *finishAnimation = [SKAction runBlock:^{
      label.text = @"";
      label.color = [SKColor whiteColor];
      [label removeFromParent];
    }];
    SKAction *sequence = [SKAction sequence:@[wait, fadeColor, finishAnimation]];
    [label runAction:sequence];
  }
}

@end
