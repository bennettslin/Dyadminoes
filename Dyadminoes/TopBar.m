//
//  TopBar.m
//  Dyadminoes
//
//  Created by Bennett Lin on 8/5/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "TopBar.h"
#import "Button.h"
#import "Label.h"

  // bar constants
#define kMinusForName 425.f
#define kMinusForScore 350.f
#define kPlayerLabelFontSize (kIsIPhone ? 20.f : 24.f)
#define kLabelFontSize (kIsIPhone ? 14.f : 18.f)

@implementation TopBar

-(void)populateWithTopBarButtons {
  
  NSMutableArray *tempArray = [NSMutableArray new];
  
  NSArray *nameArray = @[@"games", @"replay", @"swap", @"pass", @"resign", @"debug"];
  NSArray *colourArray = @[[SKColor grayColor], [SKColor orangeColor], [SKColor redColor], [SKColor blueColor], [SKColor blackColor], [SKColor brownColor]];
  float xCoord[6] = {kButtonWidth, kButtonWidth * 2, kButtonWidth * 3, kButtonWidth * 4, kButtonWidth * 5, kButtonWidth * 5};
  float yCoord[6] = {kButtonYPosition, kButtonYPosition, kButtonYPosition, kButtonYPosition, kButtonYPosition, kButtonYPosition * 3};
  
  for (int i = 0; i < 6; i++) {
    Button *button = [[Button alloc] initWithName:nameArray[i] andColor:colourArray[i] andSize:kButtonSize andPosition:CGPointMake(xCoord[i], yCoord[i])andZPosition:kZPositionTopBarButton];
    [tempArray addObject:button];
  }
  
  self.returnOrStartButton = tempArray[0];
  self.replayButton = tempArray[1];
  self.swapCancelOrUndoButton = tempArray[2];
  self.passPlayOrDoneButton = tempArray[3];
  self.resignButton = tempArray[4];
  self.debugButton = tempArray[5];

  [self button:self.debugButton shouldBeEnabled:YES];
  self.allButtons = [NSSet setWithArray:tempArray];
}

-(void)populateWithTopBarLabels {
  
  NSMutableDictionary *tempDictionary = [NSMutableDictionary new];
  
  self.turnLabel = [[Label alloc] initWithName:@"turnCount"
                                  andFontColor:[SKColor whiteColor]
                                   andFontSize:kLabelFontSize
                                   andPosition:CGPointMake(self.size.width - 5.f, 60.f)
                                  andZPosition:kZPositionTopBarLabel
                        andHorizontalAlignment:SKLabelHorizontalAlignmentModeRight];
  [tempDictionary setValue:self.turnLabel forKey:self.turnLabel.name];
  self.pileCountLabel = [[Label alloc] initWithName:@"pileCount"
                                       andFontColor:[SKColor whiteColor]
                                        andFontSize:kLabelFontSize
                                        andPosition:CGPointMake(self.size.width - 5.f, 30.f)
                                       andZPosition:kZPositionTopBarLabel
                             andHorizontalAlignment:SKLabelHorizontalAlignmentModeRight];
  [tempDictionary setValue:self.pileCountLabel forKey:self.pileCountLabel.name];
  
    // debugger labels
  CGFloat xMinusForPlayerRack = 275.f;
  self.player1Rack = [[Label alloc] initWithName:@"player1Rack"
                                    andFontColor:[SKColor whiteColor]
                                     andFontSize:kLabelFontSize
                                     andPosition:CGPointMake(self.size.width - xMinusForPlayerRack, kLabelYPosition * 10)
                                    andZPosition:kZPositionTopBarLabel
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player1Rack forKey:self.player1Rack.name];
  self.player2Rack = [[Label alloc] initWithName:@"player2Rack"
                                    andFontColor:[SKColor whiteColor]
                                     andFontSize:kLabelFontSize
                                     andPosition:CGPointMake(self.size.width - xMinusForPlayerRack, kLabelYPosition * 7)
                                    andZPosition:kZPositionTopBarLabel
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player2Rack forKey:self.player2Rack.name];
  self.player3Rack = [[Label alloc] initWithName:@"player3Rack"
                                    andFontColor:[SKColor whiteColor]
                                     andFontSize:kLabelFontSize
                                     andPosition:CGPointMake(self.size.width - xMinusForPlayerRack, kLabelYPosition * 4)
                                    andZPosition:kZPositionTopBarLabel
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player3Rack forKey:self.player3Rack.name];
  self.player4Rack = [[Label alloc] initWithName:@"player4Rack"
                                    andFontColor:[SKColor whiteColor]
                                     andFontSize:kLabelFontSize
                                     andPosition:CGPointMake(self.size.width - xMinusForPlayerRack, kLabelYPosition * 1)
                                    andZPosition:kZPositionTopBarLabel
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player4Rack forKey:self.player4Rack.name];
  self.playerRackLabels = @[self.player1Rack, self.player2Rack, self.player3Rack, self.player4Rack];
  
  self.holdingContainerLabel = [[Label alloc] initWithName:@"holdingContainer"
                                              andFontColor:[SKColor whiteColor]
                                               andFontSize:kLabelFontSize * 0.8f
                                               andPosition:CGPointMake(self.size.width / 2, -kLabelYPosition)
                                              andZPosition:kZPositionTopBarLabel
                                    andHorizontalAlignment:SKLabelHorizontalAlignmentModeCenter];
  [tempDictionary setValue:self.holdingContainerLabel forKey:self.holdingContainerLabel.name];
  self.swapContainerLabel = [[Label alloc] initWithName:@"swapContainer"
                                           andFontColor:[SKColor whiteColor]
                                            andFontSize:kLabelFontSize * 0.8f
                                            andPosition:CGPointMake(self.size.width / 2, -kLabelYPosition * 4)
                                           andZPosition:kZPositionTopBarLabel
                                 andHorizontalAlignment:SKLabelHorizontalAlignmentModeCenter];
  [tempDictionary setValue:self.swapContainerLabel forKey:self.swapContainerLabel.name];
  self.boardDyadminoesLabel = [[Label alloc] initWithName:@"boardDyadminoes"
                                             andFontColor:[SKColor whiteColor]
                                              andFontSize:kLabelFontSize * 0.8f
                                              andPosition:CGPointMake(self.size.width / 2, -kLabelYPosition * 7)
                                             andZPosition:kZPositionTopBarLabel
                                   andHorizontalAlignment:SKLabelHorizontalAlignmentModeCenter];
  [tempDictionary setValue:self.boardDyadminoesLabel forKey:self.boardDyadminoesLabel.name];
  self.pileDyadminoesLabel = [[Label alloc] initWithName:@"pileDyadminoes"
                                            andFontColor:[SKColor whiteColor]
                                             andFontSize:kLabelFontSize / 2
                                             andPosition:CGPointMake(self.size.width / 2, -kLabelYPosition * 10)
                                            andZPosition:kZPositionTopBarLabel
                                  andHorizontalAlignment:SKLabelHorizontalAlignmentModeCenter];
  [tempDictionary setValue:self.pileDyadminoesLabel forKey:self.pileDyadminoesLabel.name];
  
    // message labels
  
  self.messageLabel = [[Label alloc] initWithName:@"message"
                                     andFontColor:kTestRed
                                      andFontSize:kLabelFontSize
                                      andPosition:CGPointMake(5.f, -kLabelYPosition * 3)
                                     andZPosition:kZPositionLogMessage
                           andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.messageLabel forKey:self.messageLabel.name];
  self.logLabel = [[Label alloc] initWithName:@"log"
                                 andFontColor:[SKColor whiteColor]
                                  andFontSize:kLabelFontSize
                                  andPosition:CGPointMake(self.size.width - 5.f, -kLabelYPosition * 3)
                                 andZPosition:kZPositionLogMessage
                       andHorizontalAlignment:SKLabelHorizontalAlignmentModeRight];
  [tempDictionary setValue:self.logLabel forKey:self.logLabel.name];
  self.chordLabel = [[Label alloc] initWithName:@"gameAvatar"
                                   andFontColor:[SKColor yellowColor]
                                    andFontSize:kLabelFontSize
                                    andPosition:CGPointMake(self.size.width / 2, -kLabelYPosition * 6)
                                   andZPosition:kZPositionLogMessage
                         andHorizontalAlignment:SKLabelHorizontalAlignmentModeCenter];
  [tempDictionary setValue:self.chordLabel forKey:self.chordLabel.name];
  
  self.allLabels = [NSDictionary dictionaryWithDictionary:tempDictionary];
  
  [self populatePlayerLabels];
}

-(void)populatePlayerLabels {
  
  NSMutableDictionary *tempDictionary = [NSMutableDictionary new];
  
  self.player1Name = [[Label alloc] initWithName:@"player1Name"
                                    andFontColor:[SKColor whiteColor]
                                     andFontSize:kPlayerLabelFontSize
                                     andPosition:CGPointMake(self.size.width - kMinusForName, kLabelYPosition * 10)
                                    andZPosition:kZPositionTopBarLabel
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player1Name forKey:self.player1Name.name];
  self.player2Name = [[Label alloc] initWithName:@"player2Name"
                                    andFontColor:[SKColor whiteColor]
                                     andFontSize:kPlayerLabelFontSize
                                     andPosition:CGPointMake(self.size.width - kMinusForName, kLabelYPosition * 7)
                                    andZPosition:kZPositionTopBarLabel
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player2Name forKey:self.player2Name.name];
  self.player3Name = [[Label alloc] initWithName:@"player3Name"
                                    andFontColor:[SKColor whiteColor]
                                     andFontSize:kPlayerLabelFontSize
                                     andPosition:CGPointMake(self.size.width - kMinusForName, kLabelYPosition * 4)
                                    andZPosition:kZPositionTopBarLabel
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player3Name forKey:self.player3Name.name];
  self.player4Name = [[Label alloc] initWithName:@"player4Name"
                                    andFontColor:[SKColor whiteColor]
                                     andFontSize:kPlayerLabelFontSize
                                     andPosition:CGPointMake(self.size.width - kMinusForName, kLabelYPosition * 1)
                                    andZPosition:kZPositionTopBarLabel
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player4Name forKey:self.player4Name.name];
  self.playerNameLabels = @[self.player1Name, self.player2Name, self.player3Name, self.player4Name];
  
  for (Label *label in self.playerNameLabels) {
    label.fontName = kPlayerNameFont;
  }
  
  self.player1Score = [[Label alloc] initWithName:@"player1Score"
                                     andFontColor:[SKColor whiteColor]
                                      andFontSize:kLabelFontSize
                                      andPosition:CGPointMake(self.size.width - kMinusForScore, kLabelYPosition * 10)
                                     andZPosition:kZPositionTopBarLabel
                           andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player1Score forKey:self.player1Score.name];
  self.player2Score = [[Label alloc] initWithName:@"player2Score"
                                     andFontColor:[SKColor whiteColor]
                                      andFontSize:kLabelFontSize
                                      andPosition:CGPointMake(self.size.width - kMinusForScore, kLabelYPosition * 7)
                                     andZPosition:kZPositionTopBarLabel
                           andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player2Score forKey:self.player2Score.name];
  self.player3Score = [[Label alloc] initWithName:@"player3Score"
                                     andFontColor:[SKColor whiteColor]
                                      andFontSize:kLabelFontSize
                                      andPosition:CGPointMake(self.size.width - kMinusForScore, kLabelYPosition * 4)
                                     andZPosition:kZPositionTopBarLabel
                           andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player3Score forKey:self.player3Score.name];
  self.player4Score = [[Label alloc] initWithName:@"player4Score"
                                     andFontColor:[SKColor whiteColor]
                                      andFontSize:kLabelFontSize
                                      andPosition:CGPointMake(self.size.width - kMinusForScore, kLabelYPosition * 1)
                                     andZPosition:kZPositionTopBarLabel
                           andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.player4Score forKey:self.player4Score.name];
  self.playerScoreLabels = @[self.player1Score, self.player2Score, self.player3Score, self.player4Score];
  
  [tempDictionary addEntriesFromDictionary:self.allLabels];
  self.allLabels = [NSDictionary dictionaryWithDictionary:tempDictionary];
}

-(void)changePassPlayOrDone:(PassPlayOrDoneButton)passPlayOrDone {
  switch (passPlayOrDone) {
    case kPassButton:
      self.passPlayOrDoneButton.color = [SKColor purpleColor];
      self.passPlayOrDoneButton.name = @"pass";
      break;
    case kPlayButton:
      self.passPlayOrDoneButton.color = [SKColor greenColor];
      self.passPlayOrDoneButton.name = @"play";
      break;
    case kDoneButton:
      self.passPlayOrDoneButton.color = [SKColor blueColor];
      self.passPlayOrDoneButton.name = @"done";
      break;
  }
  [self.passPlayOrDoneButton changeName];
}

-(void)changeSwapCancelOrUndo:(SwapCancelOrUndoButton)swapCancelOrUndo {
  switch (swapCancelOrUndo) {
    case kSwapButton:
      self.swapCancelOrUndoButton.color = [SKColor brownColor];
      self.swapCancelOrUndoButton.name = @"swap";
      break;
    case kCancelButton:
      self.swapCancelOrUndoButton.color = [SKColor redColor];
      self.swapCancelOrUndoButton.name = @"cancel";
      break;
    case kUndoButton:
      self.swapCancelOrUndoButton.color = [SKColor yellowColor];
      self.swapCancelOrUndoButton.name = @"undo";
      break;
  }
  [self.swapCancelOrUndoButton changeName];
}

-(void)afterPlayUpdateScoreLabel:(Label *)scoreLabel withText:(NSString *)scoreText {
  
  NSLog(@"afterPlayUpdateScoreLabel called");
  if (scoreLabel) {
    scoreLabel.text = scoreText;
    SKAction *brightenColour = [SKAction runBlock:^{
      scoreLabel.fontColor = [SKColor yellowColor];
    }];
      // make own constants
    
      // keeps score centred
    CGPoint positionPoint = CGPointMake(scoreLabel.position.x - scoreLabel.frame.size.width * 0.5f, scoreLabel.position.y - scoreLabel.frame.size.height * 0.35f);
    
    SKAction *scaleIn = [SKAction scaleTo:kScoreScaleFactor duration:kScoreScaleInTime];
    SKAction *positionIn = [SKAction moveTo:positionPoint duration:kScoreScaleInTime];
    SKAction *inGroup = [SKAction group:@[scaleIn, positionIn]];
    
    SKAction *scaleOut = [SKAction scaleTo:1.f duration:kScoreScaleOutTime];
    SKAction *positionOut = [SKAction moveTo:scoreLabel.position duration:kScoreScaleOutTime];
    SKAction *outGroup = [SKAction group:@[scaleOut, positionOut]];
    
    SKAction *finishAnimation = [SKAction runBlock:^{
      scoreLabel.fontColor = [SKColor whiteColor];
    }];
    
    SKAction *sequence = [SKAction sequence:@[brightenColour, inGroup, outGroup, finishAnimation]];
    [scoreLabel runAction:sequence withKey:@"score"];
  }
}

@end
