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

@implementation TopBar

-(void)populateWithTopBarButtons {
  
  CGFloat topBarPadding = (self.frame.size.width - (kTopBarXEdgeBuffer * 2) - kTopBarPlayerLabelWidth - kTopBarScoreLabelWidth - (kButtonWidth * 5) - kTopBarTurnPileLabelsWidth) / 3;
  CGFloat topBarLeftOffset = kIsIPhone ?
      ((self.frame.size.width - (kButtonWidth * 5)) / 2) + (kButtonWidth / 2) :
      kTopBarXEdgeBuffer + kTopBarPlayerLabelWidth + kTopBarScoreLabelWidth + (topBarPadding * 2) + (kButtonWidth / 2);
  
  NSMutableArray *tempArray = [NSMutableArray new];
  CGFloat yPosition = kTopBarHeight / 2;
  
  NSArray *nameArray = @[@"games", @"replay", @"swap", @"pass", @"resign", @"debug"];
  NSArray *colourArray = @[[SKColor grayColor], [SKColor orangeColor], [SKColor redColor], [SKColor blueColor], [SKColor blackColor], [SKColor brownColor]];
  
  for (int i = 0; i < 6; i++) {
    Button *button = [[Button alloc] initWithName:nameArray[i] andColor:colourArray[i] andSize:kButtonSize andPosition:CGPointMake(kButtonWidth * i + topBarLeftOffset, yPosition) andZPosition:kZPositionTopBarButton];
    [tempArray addObject:button];
  }
  
  self.returnOrStartButton = tempArray[0];
  self.replayButton = tempArray[1];
  self.swapCancelOrUndoButton = tempArray[2];
  self.passPlayOrDoneButton = tempArray[3];
  self.resignButton = tempArray[4];
  self.debugButton = tempArray[5];

  [self node:self.debugButton shouldBeEnabled:YES];
//  self.allButtons = [NSSet setWithArray:tempArray];
}

-(void)populateWithTopBarLabels {
  
  NSMutableDictionary *tempDictionary = [NSMutableDictionary new];
  
    // debugger player rack
  CGFloat xMinusForPlayerRack = 275.f;
  NSMutableArray *tempPlayerRackArray = [NSMutableArray new];
  NSArray *debuggerPlayerRackNameArray = @[@"player1Rack", @"player2Rack", @"player3Rack", @"player4Rack"];
  float debuggerPlayerRackYCoord[4] = {kLabelYPosition * 10, kLabelYPosition * 7, kLabelYPosition * 4, kLabelYPosition * 1};
  
  for (int i = 0; i < 4; i++) {
    Label *label = [[Label alloc] initWithName:debuggerPlayerRackNameArray[i] andFontColor:[SKColor whiteColor] andFontSize:kSceneLabelFontSize andPosition:CGPointMake(self.size.width - xMinusForPlayerRack, debuggerPlayerRackYCoord[i]) andZPosition:kZPositionTopBarLabel andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
    [tempPlayerRackArray addObject:label];
    [tempDictionary setValue:label forKey:label.name];
  }

  self.playerRackLabels = [NSArray arrayWithArray: tempPlayerRackArray];
  
    // debugger labels
  NSMutableArray *tempDebuggerArray = [NSMutableArray new];
  
  NSArray *debuggerNameArray = @[@"holdingContainer", @"swapContainer", @"boardDyadminoes", @"pileDyadminoes"];
  float debuggerYCoord[4] = {-kLabelYPosition, -kLabelYPosition * 4, -kLabelYPosition * 7, -kLabelYPosition * 10};
  for (int i = 0; i < 4; i++) {
    Label *label = [[Label alloc] initWithName:debuggerNameArray[i] andFontColor:[SKColor whiteColor] andFontSize:kSceneLabelFontSize * 0.8f andPosition:CGPointMake(self.size.width / 2, debuggerYCoord[i]) andZPosition:-CGFLOAT_MAX andHorizontalAlignment:SKLabelHorizontalAlignmentModeCenter];
    [tempDebuggerArray addObject:label];
    [tempDictionary setValue:label forKey:label.name];
  }
  
  self.holdingContainerLabel = tempDebuggerArray[0];
  self.swapContainerLabel = tempDebuggerArray[1];
  self.boardDyadminoesLabel = tempDebuggerArray[2];
  self.pileDyadminoesLabel = tempDebuggerArray[3];
  
    // permanent labels  
//  self.turnLabel = [[Label alloc] initWithName:@"turnCount"
//                                  andFontColor:[SKColor whiteColor]
//                                   andFontSize:kSceneLabelFontSize * 1.25
//                                   andPosition:CGPointMake(self.frame.size.width - kTopBarXEdgeBuffer, kTopBarHeight - kTopBarPlayerLabelHeight * 1.25)
//                                  andZPosition:kZPositionTopBarLabel
//                        andHorizontalAlignment:SKLabelHorizontalAlignmentModeRight];
//  self.turnLabel.fontName = kFontHarmony;
//  [tempDictionary setValue:self.turnLabel forKey:self.turnLabel.name];
//  self.pileCountLabel = [[Label alloc] initWithName:@"pileCount"
//                                       andFontColor:[SKColor whiteColor]
//                                        andFontSize:kSceneLabelFontSize
//                                        andPosition:CGPointMake(self.frame.size.width - kTopBarXEdgeBuffer, kTopBarHeight - kTopBarPlayerLabelHeight * 2.25)
//                                       andZPosition:kZPositionTopBarLabel
//                             andHorizontalAlignment:SKLabelHorizontalAlignmentModeRight];
//  self.pileCountLabel.fontName = kFontHarmony;
//  [tempDictionary setValue:self.pileCountLabel forKey:self.pileCountLabel.name];
  
    // message labels
  
  self.messageLabel = [[Label alloc] initWithName:@"message"
                                     andFontColor:kTestRed
                                      andFontSize:kSceneLabelFontSize
                                      andPosition:CGPointMake(5.f, -kLabelYPosition * 3)
                                     andZPosition:kZPositionLogMessage
                           andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.messageLabel forKey:self.messageLabel.name];
  self.chordLabel = [[Label alloc] initWithName:@"playedChord"
                                   andFontColor:[SKColor yellowColor]
                                    andFontSize:kSceneLabelFontSize
                                    andPosition:CGPointMake(self.size.width / 2, -kLabelYPosition * 6)
                                   andZPosition:kZPositionLogMessage
                         andHorizontalAlignment:SKLabelHorizontalAlignmentModeCenter];
  [tempDictionary setValue:self.chordLabel forKey:self.chordLabel.name];
  self.logLabel = [[Label alloc] initWithName:@"log"
                                 andFontColor:[SKColor whiteColor]
                                  andFontSize:kSceneLabelFontSize
                                  andPosition:CGPointMake(self.size.width - 5.f, -kLabelYPosition * 3)
                                 andZPosition:kZPositionLogMessage
                       andHorizontalAlignment:SKLabelHorizontalAlignmentModeRight];
  [tempDictionary setValue:self.logLabel forKey:self.logLabel.name];
  
  self.allLabels = [NSDictionary dictionaryWithDictionary:tempDictionary];
}

//-(void)populatePlayerLabels {
//  
//  NSMutableDictionary *tempDictionary = [NSMutableDictionary new];
//  NSMutableArray *tempPlayerNames = [NSMutableArray new];
//  
//  NSArray *playerNames = @[@"player1Name", @"player2Name", @"player3Name", @"player4Name"];
//  float yCoord[4] = {kLabelYPosition * 10, kLabelYPosition * 7, kLabelYPosition * 4, kLabelYPosition * 1};
//  
//  for (int i = 0; i < 4; i++) {
//    Label *label = [[Label alloc] initWithName:playerNames[i] andFontColor:[SKColor whiteColor] andFontSize:kScenePlayerLabelFontSize andPosition:CGPointMake(kTopBarGeneralLeftOffset, yCoord[i]) andZPosition:kZPositionTopBarLabel andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
//    label.fontName = kFontModern;
//    [tempDictionary setValue:label forKey:label.name];
//    [tempPlayerNames addObject:label];
//  }
//
//  self.playerNameLabels = [NSArray arrayWithArray:tempPlayerNames];
//  
//  NSMutableArray *tempPlayerScores = [NSMutableArray new];
//  NSArray *playerScores = @[@"player1Score", @"player2Score", @"player3Score", @"player4Score"];
//  
//  for (int i = 0; i < 4; i++) {
//    Label *label = [[Label alloc] initWithName:playerScores[i] andFontColor:[SKColor whiteColor] andFontSize:kScenePlayerLabelFontSize * 0.8f andPosition:CGPointMake(kTopBarGeneralLeftOffset + 125, yCoord[i]) andZPosition:kZPositionTopBarLabel andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
//    label.fontName = kFontModern;
//    [tempDictionary setValue:label forKey:label.name];
//    [tempPlayerScores addObject:label];
//  }
//  
//  self.playerScoreLabels = [NSArray arrayWithArray:tempPlayerScores];
//  
//  [tempDictionary addEntriesFromDictionary:self.allLabels];
//  self.allLabels = [NSDictionary dictionaryWithDictionary:tempDictionary];
//}

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

//-(void)afterPlayUpdateScoreLabel:(Label *)scoreLabel withText:(NSString *)scoreText {
//  
//  NSLog(@"afterPlayUpdateScoreLabel called");
//  if (scoreLabel) {
//    scoreLabel.text = scoreText;
//    SKAction *brightenColour = [SKAction runBlock:^{
//      scoreLabel.fontColor = [SKColor yellowColor];
//    }];
//      // make own constants
//    
//      // keeps score centred
//    CGPoint positionPoint = CGPointMake(scoreLabel.position.x - scoreLabel.frame.size.width * 0.5f, scoreLabel.position.y - scoreLabel.frame.size.height * 0.35f);
//    
//    SKAction *scaleIn = [SKAction scaleTo:kScoreScaleFactor duration:kScoreScaleInTime];
//    SKAction *positionIn = [SKAction moveTo:positionPoint duration:kScoreScaleInTime];
//    SKAction *inGroup = [SKAction group:@[scaleIn, positionIn]];
//    
//    SKAction *scaleOut = [SKAction scaleTo:1.f duration:kScoreScaleOutTime];
//    SKAction *positionOut = [SKAction moveTo:scoreLabel.position duration:kScoreScaleOutTime];
//    SKAction *outGroup = [SKAction group:@[scaleOut, positionOut]];
//    
//    SKAction *finishAnimation = [SKAction runBlock:^{
//      scoreLabel.fontColor = [SKColor whiteColor];
//    }];
//    
//    SKAction *sequence = [SKAction sequence:@[brightenColour, inGroup, outGroup, finishAnimation]];
//    [scoreLabel runAction:sequence withKey:@"score"];
//  }
//}

@end
