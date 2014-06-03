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
  }
  return self;
}

-(void)populateWithButtons {

//  NSArray *tempNamesArray = @[@"games", @"toggle", @"swap", @"cancel", @"play", @"done", @"debug"];
//  NSArray *skColoursArray = @[[SKColor grayColor], [SKColor orangeColor], [SKColor brownColor], [SKColor redColor], kDarkGreen, [SKColor blueColor], [SKColor blackColor]];
//  int xMultiplier[7] = {1, 2, 3, 3, 4, 4, 5};
//  
//  for (int i = 0; i < self.allButtons.count; i++) {
//    Button *button = self.allButtons[i];
//    button = [[Button alloc] initWithName:tempNamesArray[i] andColor:skColoursArray[i] andSize:kButtonSize andPosition:CGPointMake(kButtonWidth * xMultiplier[i], kButtonYPosition) andZPosition:kZPositionTopBarButton];
//    [self enableButton:button];
//  }
 
  NSMutableSet *tempButtons = [NSMutableSet new];

  self.undoButton = [[Button alloc] initWithName:@"undo" andColor:[SKColor redColor]
                                          andSize:kButtonSize
                                      andPosition:CGPointMake(kButtonWidth, kButtonYPosition * 3)
                                     andZPosition:kZPositionTopBarButton];
  [tempButtons addObject:self.undoButton];
  [self enableButton:self.undoButton];
  self.redoButton = [[Button alloc] initWithName:@"redo" andColor:[SKColor greenColor]
                                         andSize:kButtonSize
                                     andPosition:CGPointMake(kButtonWidth * 2, kButtonYPosition * 3)
                                    andZPosition:kZPositionTopBarButton];
  [tempButtons addObject:self.redoButton];
  [self enableButton:self.redoButton];
  self.replayButton = [[Button alloc] initWithName:@"replay" andColor:[SKColor yellowColor]
                                         andSize:kButtonSize
                                     andPosition:CGPointMake(kButtonWidth * 3, kButtonYPosition * 3)
                                    andZPosition:kZPositionTopBarButton];
  [tempButtons addObject:self.replayButton];
  [self enableButton:self.replayButton];
  self.resignButton = [[Button alloc] initWithName:@"resign" andColor:[SKColor brownColor]
                                           andSize:kButtonSize
                                       andPosition:CGPointMake(kButtonWidth * 5, kButtonYPosition * 3)
                                      andZPosition:kZPositionTopBarButton];
  [tempButtons addObject:self.resignButton];
  [self enableButton:self.resignButton];
  
  self.gamesButton = [[Button alloc] initWithName:@"games" andColor:[SKColor grayColor]
                                                 andSize:kButtonSize
                                             andPosition:CGPointMake(kButtonWidth, kButtonYPosition)
                                            andZPosition:kZPositionTopBarButton];
  [tempButtons addObject:self.gamesButton];
  [self enableButton:self.gamesButton];
  
  self.togglePCModeButton = [[Button alloc] initWithName:@"toggle" andColor:[SKColor orangeColor]
                                                 andSize:kButtonSize
                                             andPosition:CGPointMake(kButtonWidth * 2, kButtonYPosition)
                                            andZPosition:kZPositionTopBarButton];
  [tempButtons addObject:self.togglePCModeButton];
  [self enableButton:self.togglePCModeButton];
  
  self.swapButton = [[Button alloc] initWithName:@"swap" andColor:[SKColor brownColor]
                                         andSize:kButtonSize
                                     andPosition:CGPointMake(kButtonWidth * 3, kButtonYPosition)
                                    andZPosition:kZPositionTopBarButton];
  [tempButtons addObject:self.swapButton];
  [self enableButton:self.swapButton];
  
  self.cancelButton = [[Button alloc] initWithName:@"cancel" andColor:[SKColor redColor]
                                           andSize:kButtonSize
                                       andPosition:CGPointMake(kButtonWidth * 3, kButtonYPosition)
                                      andZPosition:kZPositionTopBarButton];
  [tempButtons addObject:self.cancelButton];
  [self disableButton:_cancelButton];
  
  self.playDyadminoButton = [[Button alloc] initWithName:@"play" andColor:kDarkGreen
                                                 andSize:kButtonSize
                                             andPosition:CGPointMake(kButtonWidth * 4, kButtonYPosition)
                                            andZPosition:kZPositionTopBarButton];
  [tempButtons addObject:self.playDyadminoButton];
  [self disableButton:_playDyadminoButton];
  
  self.doneTurnButton = [[Button alloc] initWithName:@"done" andColor:[SKColor blueColor]
                                             andSize:kButtonSize
                                         andPosition:CGPointMake(kButtonWidth * 4, kButtonYPosition)
                                        andZPosition:kZPositionTopBarButton];
  [tempButtons addObject:self.doneTurnButton];
  [self enableButton:self.doneTurnButton];
  
  self.debugButton = [[Button alloc] initWithName:@"debug" andColor:[SKColor blackColor]
                                        andSize:kButtonSize
                                    andPosition:CGPointMake(kButtonWidth * 5, kButtonYPosition)
                                   andZPosition:kZPositionTopBarButton];
  [tempButtons addObject:self.debugButton];
  [self enableButton:self.debugButton];
  
  self.allButtons = [NSSet setWithSet:tempButtons];
}

-(void)populateWithLabels {
  
  NSMutableDictionary *tempDictionary = [NSMutableDictionary new];
  CGFloat labelFontSize = kIsIPhone ? 14.f : 18.f;

  self.pileCountLabel = [[Label alloc] initWithName:@"pileCount"
                                       andFontColor:[SKColor whiteColor]
                                        andFontSize:labelFontSize
                                        andPosition:CGPointMake(self.size.width - 5.f, 30.f)
                                       andZPosition:kZPositionTopBarLabel
                             andHorizontalAlignment:SKLabelHorizontalAlignmentModeRight];
  [tempDictionary setValue:self.pileCountLabel forKey:self.pileCountLabel.name];
  
  CGFloat xMinusForName = 425.f;
  self.player1Name = [[Label alloc] initWithName:@"player1Name"
                                     andFontColor:[SKColor whiteColor]
                                      andFontSize:labelFontSize
                                      andPosition:CGPointMake(self.size.width - xMinusForName, kLabelYPosition * 10)
                                     andZPosition:kZPositionTopBarLabel
                           andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player1Name forKey:self.player1Name.name];
  self.player2Name = [[Label alloc] initWithName:@"player2Name"
                                    andFontColor:[SKColor whiteColor]
                                     andFontSize:labelFontSize
                                     andPosition:CGPointMake(self.size.width - xMinusForName, kLabelYPosition * 7)
                                    andZPosition:kZPositionTopBarLabel
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player2Name forKey:self.player2Name.name];
  self.player3Name = [[Label alloc] initWithName:@"player3Name"
                                    andFontColor:[SKColor whiteColor]
                                     andFontSize:labelFontSize
                                     andPosition:CGPointMake(self.size.width - xMinusForName, kLabelYPosition * 4)
                                    andZPosition:kZPositionTopBarLabel
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player3Name forKey:self.player3Name.name];
  self.player4Name = [[Label alloc] initWithName:@"player4Name"
                                    andFontColor:[SKColor whiteColor]
                                     andFontSize:labelFontSize
                                     andPosition:CGPointMake(self.size.width - xMinusForName, kLabelYPosition * 1)
                                    andZPosition:kZPositionTopBarLabel
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player4Name forKey:self.player4Name.name];
  self.playerNameLabels = @[self.player1Name, self.player2Name, self.player3Name, self.player4Name];
  
  CGFloat xMinusForScore = 350.f;
  self.player1Score = [[Label alloc] initWithName:@"player1Score"
                                    andFontColor:[SKColor whiteColor]
                                     andFontSize:labelFontSize
                                     andPosition:CGPointMake(self.size.width - xMinusForScore, kLabelYPosition * 10)
                                    andZPosition:kZPositionTopBarLabel
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player1Score forKey:self.player1Score.name];
  self.player2Score = [[Label alloc] initWithName:@"player2Score"
                                     andFontColor:[SKColor whiteColor]
                                      andFontSize:labelFontSize
                                      andPosition:CGPointMake(self.size.width - xMinusForScore, kLabelYPosition * 7)
                                     andZPosition:kZPositionTopBarLabel
                           andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player2Score forKey:self.player2Score.name];
  self.player3Score = [[Label alloc] initWithName:@"player3Score"
                                     andFontColor:[SKColor whiteColor]
                                      andFontSize:labelFontSize
                                      andPosition:CGPointMake(self.size.width - xMinusForScore, kLabelYPosition * 4)
                                     andZPosition:kZPositionTopBarLabel
                           andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player3Score forKey:self.player3Score.name];
  self.player4Score = [[Label alloc] initWithName:@"player4Score"
                                     andFontColor:[SKColor whiteColor]
                                      andFontSize:labelFontSize
                                      andPosition:CGPointMake(self.size.width - xMinusForScore, kLabelYPosition * 1)
                                     andZPosition:kZPositionTopBarLabel
                           andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player4Score forKey:self.player4Score.name];
  self.playerScoreLabels = @[self.player1Score, self.player2Score, self.player3Score, self.player4Score];
  
    // debugger labels
  CGFloat xMinusForPlayerRack = 275.f;
  self.player1Rack = [[Label alloc] initWithName:@"player1Rack"
                                     andFontColor:[SKColor whiteColor]
                                      andFontSize:labelFontSize
                                      andPosition:CGPointMake(self.size.width - xMinusForPlayerRack, kLabelYPosition * 10)
                                     andZPosition:kZPositionTopBarLabel
                           andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player1Rack forKey:self.player1Rack.name];
  self.player2Rack = [[Label alloc] initWithName:@"player2Rack"
                                    andFontColor:[SKColor whiteColor]
                                     andFontSize:labelFontSize
                                     andPosition:CGPointMake(self.size.width - xMinusForPlayerRack, kLabelYPosition * 7)
                                    andZPosition:kZPositionTopBarLabel
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player2Rack forKey:self.player2Rack.name];
  self.player3Rack = [[Label alloc] initWithName:@"player3Rack"
                                    andFontColor:[SKColor whiteColor]
                                     andFontSize:labelFontSize
                                     andPosition:CGPointMake(self.size.width - xMinusForPlayerRack, kLabelYPosition * 4)
                                    andZPosition:kZPositionTopBarLabel
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player3Rack forKey:self.player3Rack.name];
  self.player4Rack = [[Label alloc] initWithName:@"player4Rack"
                                    andFontColor:[SKColor whiteColor]
                                     andFontSize:labelFontSize
                                     andPosition:CGPointMake(self.size.width - xMinusForPlayerRack, kLabelYPosition * 1)
                                    andZPosition:kZPositionTopBarLabel
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player4Rack forKey:self.player4Rack.name];
  self.playerRackLabels = @[self.player1Rack, self.player2Rack, self.player3Rack, self.player4Rack];
  
  
  self.holdingContainerLabel = [[Label alloc] initWithName:@"holdingContainer"
                                              andFontColor:[SKColor whiteColor]
                                               andFontSize:labelFontSize
                                               andPosition:CGPointMake(self.size.width / 2, -kLabelYPosition * 10)
                                              andZPosition:kZPositionTopBarLabel
                                    andHorizontalAlignment:SKLabelHorizontalAlignmentModeCenter];
  [tempDictionary setValue:self.holdingContainerLabel forKey:self.holdingContainerLabel.name];
  self.boardDyadminoesLabel = [[Label alloc] initWithName:@"boardDyadminoes"
                                   andFontColor:[SKColor whiteColor]
                                    andFontSize:labelFontSize
                                    andPosition:CGPointMake(self.size.width / 2, -kLabelYPosition * 20)
                                   andZPosition:kZPositionTopBarLabel
                         andHorizontalAlignment:SKLabelHorizontalAlignmentModeCenter];
  [tempDictionary setValue:self.boardDyadminoesLabel forKey:self.boardDyadminoesLabel.name];
  self.pileDyadminoesLabel = [[Label alloc] initWithName:@"pileDyadminoes"
                                  andFontColor:[SKColor whiteColor]
                                   andFontSize:labelFontSize
                                   andPosition:CGPointMake(self.size.width / 2, -kLabelYPosition * 30)
                                  andZPosition:kZPositionTopBarLabel
                        andHorizontalAlignment:SKLabelHorizontalAlignmentModeCenter];
  [tempDictionary setValue:self.pileDyadminoesLabel forKey:self.pileDyadminoesLabel.name];
  
    // message labels
  
  self.messageLabel = [[Label alloc] initWithName:@"message"
                                     andFontColor:kTestRed
                                      andFontSize:labelFontSize
                                      andPosition:CGPointMake(5.f, -kLabelYPosition * 3)
                                     andZPosition:kZPositionLogMessage
                           andHorizontalAlignment:SKLabelHorizontalAlignmentModeRight];
  [tempDictionary setValue:self.messageLabel forKey:self.messageLabel.name];
  self.logLabel = [[Label alloc] initWithName:@"log"
                                 andFontColor:[SKColor whiteColor]
                                  andFontSize:labelFontSize
                                  andPosition:CGPointMake(self.size.width - 5.f, -kLabelYPosition * 3)
                                 andZPosition:kZPositionLogMessage
                       andHorizontalAlignment:SKLabelHorizontalAlignmentModeRight];
  [tempDictionary setValue:self.logLabel forKey:self.logLabel.name];
  self.chordLabel = [[Label alloc] initWithName:@"chord"
                                 andFontColor:[SKColor yellowColor]
                                  andFontSize:labelFontSize
                                  andPosition:CGPointMake(self.size.width / 2, -kLabelYPosition * 6)
                                 andZPosition:kZPositionLogMessage
                       andHorizontalAlignment:SKLabelHorizontalAlignmentModeCenter];
  [tempDictionary setValue:self.chordLabel forKey:self.chordLabel.name];
  
  self.allLabels = [NSDictionary dictionaryWithDictionary:tempDictionary];
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
