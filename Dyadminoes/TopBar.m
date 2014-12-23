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
  
  NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:6];
  CGFloat yPosition = kTopBarHeight / 2;
  
  NSArray *nameArray = @[@"games", @"replay", @"swap", @"pass", @"options", @"debug"];
  NSArray *colourArray = @[[SKColor grayColor], [SKColor orangeColor], [SKColor redColor], [SKColor blueColor], [SKColor blackColor], [SKColor brownColor]];
  
  for (int i = 0; i < 6; i++) {
    
      // divide padding in half here, just for aesthetic reasons
      // so that buttons are closer to turn and pile count labels
    
    CGFloat xIPhoneSidePadding = (self.frame.size.width - (kButtonWidth * 5)) / 2;
    CGFloat xPosition = kIsIPhone ?
        xIPhoneSidePadding + (kButtonWidth * (i + 0.5)) :
        self.frame.size.width - kTopBarXEdgeBuffer - kTopBarTurnPileLabelsWidth -
        (kTopBarPaddingBetweenStuff / 2) - kButtonWidth * (4.5 - i);
    Button *button = [[Button alloc] initWithName:nameArray[i] andColor:colourArray[i] andSize:kButtonSize andPosition:CGPointMake(xPosition, yPosition) andZPosition:kZPositionTopBarButton];
    [self addChild:button];
    [tempArray addObject:button];
  }
  self.allButtons = [NSSet setWithArray:tempArray];
  
  self.returnOrStartButton = tempArray[0];
  self.replayButton = tempArray[1];
  self.swapCancelOrUndoButton = tempArray[2];
  self.passPlayOrDoneButton = tempArray[3];
  self.optionsButton = tempArray[4];
  self.debugButton = tempArray[5];

  [self node:self.debugButton shouldBeEnabled:YES];
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

@end
