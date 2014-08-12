//
//  ReplayBar.m
//  Dyadminoes
//
//  Created by Bennett Lin on 8/5/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "ReplayBar.h"
#import "Button.h"
#import "Label.h"

#define kReplayLabelFontSize (kIsIPhone ? 28.f : 36.f)

@implementation ReplayBar

-(void)populateWithTopReplayLabels {
  
  NSMutableDictionary *tempDictionary = [NSMutableDictionary new];
  self.statusLabel = [[Label alloc] initWithName:@"status"
                                    andFontColor:[SKColor whiteColor]
                                     andFontSize:kReplayLabelFontSize
                                     andPosition:CGPointMake(kTopBarGeneralLeftOffset, kRackHeight / 2)
                                    andZPosition:kZPositionLogMessage
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.statusLabel forKey:self.statusLabel.name];
  self.allLabels = [NSDictionary dictionaryWithDictionary:tempDictionary];
}

-(void)populateWithBottomReplayButtons {
  
  CGFloat leftOffset = (kLargeButtonWidth / 2) + ((self.frame.size.width - kLargeButtonWidth * 5.5) / 2);
  
  NSMutableArray *tempButtons = [NSMutableArray new];
  
  NSArray *nameArray = @[@"first", @"previous", @"next", @"last", @"return"];
  NSArray *colourArray = @[[SKColor redColor], [SKColor orangeColor], [SKColor greenColor], [SKColor blueColor], [SKColor grayColor]];
    float xCoord[5] = {0, kLargeButtonWidth, kLargeButtonWidth * 2, kLargeButtonWidth * 3, kLargeButtonWidth * 4.5};
  
  for (int i = 0; i < 5; i++) {
    Button *button = [[Button alloc] initWithName:nameArray[i] andColor:colourArray[i] andSize:kLargeButtonSize andPosition:CGPointMake(leftOffset + xCoord[i], kRackHeight / 2) andZPosition:kZPositionTopBarButton];
    [tempButtons addObject:button];
  }
  
  self.firstTurnButton = tempButtons[0];
  self.previousTurnButton = tempButtons[1];
  self.nextTurnButton = tempButtons[2];
  self.lastTurnButton = tempButtons[3];
  self.returnOrStartButton = tempButtons[4];

  [self node:self.returnOrStartButton shouldBeEnabled:YES];
//  self.allButtons = [NSSet setWithArray:tempButtons];
}

@end
