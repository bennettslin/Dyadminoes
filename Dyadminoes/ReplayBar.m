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

-(void)populateWithTopReplayButtonsAndLabels {
  
  NSMutableSet *tempButtons = [NSMutableSet new];
  self.returnOrStartButton = [[Button alloc] initWithName:@"return" andColor:[SKColor grayColor]
                                           andSize:kButtonSize
                                       andPosition:CGPointMake(kButtonWidth, kButtonYPosition * 2)
                                      andZPosition:kZPositionTopBarButton];
  [tempButtons addObject:self.returnOrStartButton];
  [self button:self.returnOrStartButton shouldBeEnabled:YES];
  
//  self.allButtons = [NSSet setWithSet:tempButtons];
  
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
  
  NSArray *nameArray = @[@"first", @"previous", @"next", @"last"];
  NSArray *colourArray = @[[SKColor redColor], [SKColor orangeColor], [SKColor greenColor], [SKColor blueColor]];
    float xCoord[4] = {kButtonWidth, kButtonWidth * 2, kButtonWidth * 3, kButtonWidth * 4};
  
  for (int i = 0; i < 4; i++) {
    Button *button = [[Button alloc] initWithName:nameArray[i] andColor:colourArray[i] andSize:kButtonSize andPosition:CGPointMake(xCoord[i], kButtonYPosition * 3) andZPosition:kZPositionTopBarButton];
    [tempButtons addObject:button];
  }
  
  self.firstTurnButton = tempButtons[0];
  self.previousTurnButton = tempButtons[1];
  self.nextTurnButton = tempButtons[2];
  self.lastTurnButton = tempButtons[3];

  [tempButtons addObject:self.firstTurnButton];
//  self.allButtons = [NSSet setWithArray:tempButtons];
}

@end
