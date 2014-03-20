//
//  TopBar.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "TopBar.h"
#import "Button.h"

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
  CGFloat buttonWidth = 45.f;
  CGSize buttonSize = CGSizeMake(buttonWidth, 45.f);
  CGFloat buttonYPosition = 30.f;
  
  self.togglePCModeButton = [[Button alloc] initWithColor:[UIColor orangeColor] size:buttonSize];
  self.togglePCModeButton.name = @"togglePCButton";
  self.togglePCModeButton.position = CGPointMake(buttonWidth, buttonYPosition);
  self.togglePCModeButton.zPosition = kZPositionTopBarButton;
  [self addChild:self.togglePCModeButton];
  [self.buttonNodes addObject:self.togglePCModeButton];
  [self enableButton:self.togglePCModeButton];
  
  self.swapButton = [[Button alloc] initWithColor:[UIColor yellowColor] size:buttonSize];
  self.swapButton.name = @"swapButton";
  self.swapButton.position = CGPointMake(buttonWidth * 2, buttonYPosition);
  self.swapButton.zPosition = kZPositionTopBarButton;
  [self addChild:self.swapButton];
  [self.buttonNodes addObject:self.swapButton];
  [self enableButton:self.swapButton];
  
  self.cancelButton = [[Button alloc] initWithColor:[UIColor redColor] size:buttonSize];
  self.cancelButton.name = @"cancelButton";
  self.cancelButton.position = CGPointMake(buttonWidth * 3, buttonYPosition);
  self.cancelButton.zPosition = kZPositionTopBarButton;
  [self addChild:self.cancelButton];
  [self.buttonNodes addObject:self.cancelButton];
  [self disableButton:_cancelButton];
  
    // play and done buttons are in same location, at least for now, as they are never shown together
  self.playDyadminoButton = [[Button alloc] initWithColor:[UIColor greenColor] size:buttonSize];
  self.playDyadminoButton.name = @"playDyadminoButton";
  self.playDyadminoButton.position = CGPointMake(buttonWidth * 4, buttonYPosition);
  self.playDyadminoButton.zPosition = kZPositionTopBarButton;
  [self addChild:self.playDyadminoButton];
  [self.buttonNodes addObject:self.playDyadminoButton];
  [self disableButton:_playDyadminoButton];
  
    // done turn button is also pass turn
  self.doneTurnButton = [[Button alloc] initWithColor:[UIColor blueColor] size:buttonSize];
  self.doneTurnButton.name = @"doneTurnButton";
  self.doneTurnButton.position = CGPointMake(buttonWidth * 5, buttonYPosition);
  self.doneTurnButton.zPosition = kZPositionTopBarButton;
  [self addChild:self.doneTurnButton];
  [self.buttonNodes addObject:self.doneTurnButton];
  [self enableButton:self.doneTurnButton];
  
  self.logButton = [[Button alloc] initWithColor:[UIColor blackColor] size:buttonSize];
  self.logButton.name = @"logButton";
  self.logButton.position = CGPointMake(buttonWidth * 6, buttonYPosition);
  self.logButton.zPosition = kZPositionTopBarButton;
  [self addChild:self.logButton];
  [_buttonNodes addObject:self.logButton];
  [self enableButton:self.logButton];
}

-(void)populateWithLabels {
  CGFloat labelYPosition = -5.f;
  
  self.pileCountLabel = [[SKLabelNode alloc] init];
  self.pileCountLabel.name = @"pileCountLabel";
  self.pileCountLabel.fontSize = 16.f;
  self.pileCountLabel.color = [UIColor whiteColor];
  self.pileCountLabel.position = CGPointMake(275, labelYPosition);
  self.pileCountLabel.zPosition = kZPositionTopBarLabel;
  [self addChild:self.pileCountLabel];
  
  self.messageLabel = [[SKLabelNode alloc] init];
  self.messageLabel.name = @"messageLabel";
  self.messageLabel.fontSize = 16.f;
  self.messageLabel.color = [UIColor whiteColor];
  self.messageLabel.position = CGPointMake(5.f, labelYPosition * 2);
  self.messageLabel.zPosition = kZPositionMessage;
  self.messageLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  [self addChild:self.messageLabel];
  
  self.logLabel = [[SKLabelNode alloc] init];
  self.logLabel.name = @"logLabel";
  self.logLabel.fontSize = 16.f;
  self.logLabel.color = [UIColor whiteColor];
  self.logLabel.position = CGPointMake(50, labelYPosition * 2);
  self.logLabel.zPosition = kZPositionMessage;
  [self addChild:self.logLabel];
}

-(void)enableButton:(Button *)button {
    // FIXME: make this better
  button.hidden = NO;
  button.enabled = YES;
}

-(void)disableButton:(Button *)button {
  button.hidden = YES;
  button.enabled = NO;
}

@end
