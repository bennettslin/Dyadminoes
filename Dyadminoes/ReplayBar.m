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

#define kLabelFontSize (kIsIPhone ? 28.f : 36.f)

@implementation ReplayBar

-(void)populateWithTopReplayLabels {
  
  NSMutableDictionary *tempDictionary = [NSMutableDictionary new];
  self.statusLabel = [[Label alloc] initWithName:@"status"
                                    andFontColor:[SKColor whiteColor]
                                     andFontSize:kLabelFontSize
                                     andPosition:CGPointMake(kButtonWidth * 2, kButtonYPosition * 2)
                                    andZPosition:kZPositionLogMessage
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.statusLabel forKey:self.statusLabel.name];
  self.allLabels = [NSDictionary dictionaryWithDictionary:tempDictionary];
}

-(void)populateWithBottomReplayButtons {
  
  NSMutableArray *tempButtons = [NSMutableArray new];
  
  NSArray *nameArray = @[@"return", @"first", @"previous", @"next", @"last"];
  NSArray *colourArray = @[[SKColor grayColor], [SKColor redColor], [SKColor orangeColor], [SKColor greenColor], [SKColor blueColor]];
    float xCoord[5] = {kButtonWidth, kButtonWidth * 3, kButtonWidth * 4, kButtonWidth * 5, kButtonWidth * 6};
  
  for (int i = 0; i < 5; i++) {
    Button *button = [[Button alloc] initWithName:nameArray[i] andColor:colourArray[i] andSize:kButtonSize andPosition:CGPointMake(xCoord[i], kButtonYPosition * 3) andZPosition:kZPositionTopBarButton];
    [tempButtons addObject:button];
  }
  
  self.returnOrStartButton = tempButtons[0];
  self.firstTurnButton = tempButtons[1];
  self.previousTurnButton = tempButtons[2];
  self.nextTurnButton = tempButtons[3];
  self.lastTurnButton = tempButtons[4];

  [self button:self.returnOrStartButton shouldBeEnabled:YES];
//  self.allButtons = [NSSet setWithArray:tempButtons];
}

@end
