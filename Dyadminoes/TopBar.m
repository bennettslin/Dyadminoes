//
//  TopBar.m
//  Dyadminoes
//
//  Created by Bennett Lin on 3/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "TopBar.h"

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
  CGSize buttonSize = CGSizeMake(buttonWidth, 50.f);
  CGFloat buttonYPosition = 30.f;
  
  self.togglePCModeButton = [[SKSpriteNode alloc] initWithColor:[UIColor orangeColor] size:buttonSize];
  self.togglePCModeButton.name = @"togglePCButton";
  self.togglePCModeButton.position = CGPointMake(buttonWidth, buttonYPosition);
  self.togglePCModeButton.zPosition = kZPositionTopBarButton;
  [self addChild:self.togglePCModeButton];
  [self.buttonNodes addObject:self.togglePCModeButton];
  
  self.swapButton = [[SKSpriteNode alloc] initWithColor:[UIColor yellowColor] size:buttonSize];
  self.swapButton.name = @"swapButton";
  self.swapButton.position = CGPointMake(buttonWidth * 2, buttonYPosition);
  self.swapButton.zPosition = kZPositionTopBarButton;
  [self addChild:self.swapButton];
  [self.buttonNodes addObject:self.swapButton];
  
  self.cancelButton = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:buttonSize];
  self.cancelButton.name = @"cancelButton";
  self.cancelButton.position = CGPointMake(buttonWidth * 3, buttonYPosition);
  self.cancelButton.zPosition = kZPositionTopBarButton;
  [self addChild:self.cancelButton];
  [self.buttonNodes addObject:self.cancelButton];
  [self disableButton:_cancelButton];
  
    // play and done buttons are in same location, at least for now, as they are never shown together
  self.playDyadminoButton = [[SKSpriteNode alloc] initWithColor:[UIColor greenColor] size:buttonSize];
  self.playDyadminoButton.name = @"playDyadminoButton";
  self.playDyadminoButton.position = CGPointMake(buttonWidth * 4, buttonYPosition);
  self.playDyadminoButton.zPosition = kZPositionTopBarButton;
  [self addChild:self.playDyadminoButton];
  [self.buttonNodes addObject:self.playDyadminoButton];
  [self disableButton:_playDyadminoButton];
  
    // done turn button is also pass turn
  self.doneTurnButton = [[SKSpriteNode alloc] initWithColor:[UIColor blueColor] size:buttonSize];
  self.doneTurnButton.name = @"doneTurnButton";
  self.doneTurnButton.position = CGPointMake(buttonWidth * 5, buttonYPosition);
  self.doneTurnButton.zPosition = kZPositionTopBarButton;
  [self addChild:self.doneTurnButton];
  [self.buttonNodes addObject:self.doneTurnButton];
  
  self.logButton = [[SKSpriteNode alloc] initWithColor:[UIColor blackColor] size:buttonSize];
  self.logButton.name = @"logButton";
  self.logButton.position = CGPointMake(buttonWidth * 6, buttonYPosition);
  self.logButton.zPosition = kZPositionTopBarButton;
  [self addChild:self.logButton];
  [_buttonNodes addObject:self.logButton];
}

-(void)populateWithLabels {
  CGFloat labelYPosition = -30.f;
  
  self.pileCountLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Neue"];
  self.pileCountLabel.name = @"pileCountLabel";
  self.pileCountLabel.fontSize = 14.f;
  self.pileCountLabel.color = [UIColor whiteColor];
  self.pileCountLabel.position = CGPointMake(275, labelYPosition);
  self.pileCountLabel.zPosition = kZPositionTopBarLabel;
  [self addChild:self.pileCountLabel];
  
  self.messageLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Neue"];
  self.messageLabel.name = @"messageLabel";
  self.messageLabel.fontSize = 14.f;
  self.messageLabel.color = [UIColor whiteColor];
  self.messageLabel.position = CGPointMake(50, labelYPosition);
  self.messageLabel.zPosition = kZPositionMessage;
  [self addChild:self.messageLabel];
  
  self.logLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Neue"];
  self.logLabel.name = @"logLabel";
  self.logLabel.fontSize = 14.f;
  self.logLabel.color = [UIColor whiteColor];
  self.logLabel.position = CGPointMake(50, labelYPosition * 2);
  self.logLabel.zPosition = kZPositionMessage;
  [self addChild:self.logLabel];
}

-(void)enableButton:(SKSpriteNode *)button {
    // FIXME: make this better
  button.hidden = NO;
}

-(void)disableButton:(SKSpriteNode *)button {
  button.hidden = YES;
}

@end
