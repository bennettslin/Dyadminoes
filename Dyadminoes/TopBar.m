//
//  TopBar.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "TopBar.h"
#import "Button.h"

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
    self.buttonNodes = [NSMutableSet new];
  }
  return self;
}

-(void)populateWithButtons {
  self.togglePCModeButton = [[Button alloc] initWithName:@"toggle" andColor:[UIColor orangeColor]
                                                 andSize:kButtonSize
                                             andPosition:CGPointMake(kButtonWidth, kButtonYPosition)
                                            andZPosition:kZPositionTopBarButton];
  [self.buttonNodes addObject:self.togglePCModeButton];
  [self enableButton:self.togglePCModeButton];
  
  self.swapButton = [[Button alloc] initWithName:@"swap" andColor:[UIColor yellowColor]
                                         andSize:kButtonSize
                                     andPosition:CGPointMake(kButtonWidth * 2, kButtonYPosition)
                                    andZPosition:kZPositionTopBarButton];
  [self.buttonNodes addObject:self.swapButton];
  [self enableButton:self.swapButton];
  
  self.cancelButton = [[Button alloc] initWithName:@"cancel" andColor:[UIColor redColor]
                                           andSize:kButtonSize
                                       andPosition:CGPointMake(kButtonWidth * 2, kButtonYPosition)
                                      andZPosition:kZPositionTopBarButton];
  [self.buttonNodes addObject:self.cancelButton];
  [self disableButton:_cancelButton];
  
  self.playDyadminoButton = [[Button alloc] initWithName:@"play" andColor:[UIColor greenColor]
                                                 andSize:kButtonSize
                                             andPosition:CGPointMake(kButtonWidth * 3, kButtonYPosition)
                                            andZPosition:kZPositionTopBarButton];
  [self.buttonNodes addObject:self.playDyadminoButton];
  [self disableButton:_playDyadminoButton];
  
  self.doneTurnButton = [[Button alloc] initWithName:@"done" andColor:[UIColor blueColor]
                                             andSize:kButtonSize
                                         andPosition:CGPointMake(kButtonWidth * 3, kButtonYPosition)
                                        andZPosition:kZPositionTopBarButton];
  [self.buttonNodes addObject:self.doneTurnButton];
  [self enableButton:self.doneTurnButton];
  
  self.logButton = [[Button alloc] initWithName:@"log" andColor:[UIColor brownColor]
                                        andSize:kButtonSize
                                    andPosition:CGPointMake(kButtonWidth * 4, kButtonYPosition)
                                   andZPosition:kZPositionTopBarButton];
  [_buttonNodes addObject:self.logButton];
  [self enableButton:self.logButton];
}

-(void)populateWithLabels {
  
  self.pileCountLabel = [[SKLabelNode alloc] init];
  self.pileCountLabel.name = @"pileCountLabel";
  self.pileCountLabel.fontSize = 14.f;
  self.pileCountLabel.color = [UIColor whiteColor];
  self.pileCountLabel.position = CGPointMake(self.size.width - 5.f, kButtonYPosition);
  self.pileCountLabel.zPosition = kZPositionTopBarLabel;
  self.pileCountLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
  [self addChild:self.pileCountLabel];
  
  self.messageLabel = [[SKLabelNode alloc] init];
  self.messageLabel.name = @"messageLabel";
  self.messageLabel.fontSize = 14.f;
  self.messageLabel.color = [UIColor whiteColor];
  self.messageLabel.position = CGPointMake(5.f, -kLabelYPosition * 3);
  self.messageLabel.zPosition = kZPositionMessage;
  self.messageLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  [self addChild:self.messageLabel];
  
  self.logLabel = [[SKLabelNode alloc] init];
  self.logLabel.name = @"logLabel";
  self.logLabel.fontSize = 14.f;
  self.logLabel.color = [UIColor whiteColor];
  self.logLabel.position = CGPointMake(self.size.width - 5.f, -kLabelYPosition * 3);
  self.logLabel.zPosition = kZPositionMessage;
  self.logLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
  [self addChild:self.logLabel];
}

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

@end
