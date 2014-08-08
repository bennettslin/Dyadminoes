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

#define kLabelFontSize (kIsIPhone ? 14.f : 18.f)

@implementation ReplayBar

-(void)populateWithTopReplayButtonsAndLabels {
  
  NSMutableSet *tempButtons = [NSMutableSet new];
  self.returnOrStartButton = [[Button alloc] initWithName:@"return" andColor:[SKColor grayColor]
                                           andSize:kButtonSize
                                       andPosition:CGPointMake(kButtonWidth, kButtonYPosition * 2)
                                      andZPosition:kZPositionTopBarButton];
  [tempButtons addObject:self.returnOrStartButton];
  [self button:self.returnOrStartButton shouldBeEnabled:YES];
  
  self.allButtons = [NSSet setWithSet:tempButtons];
  
  NSMutableDictionary *tempDictionary = [NSMutableDictionary new];
  self.statusLabel = [[Label alloc] initWithName:@"status"
                                    andFontColor:kTestRed
                                     andFontSize:kLabelFontSize
                                     andPosition:CGPointMake(5.f, kLabelYPosition)
                                    andZPosition:kZPositionLogMessage
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  [tempDictionary setValue:self.statusLabel forKey:self.statusLabel.name];
  self.allLabels = [NSDictionary dictionaryWithDictionary:tempDictionary];
}

-(void)populateWithBottomReplayButtons {
  
  NSMutableSet *tempButtons = [NSMutableSet new];
  
  self.firstTurnButton = [[Button alloc] initWithName:@"first" andColor:[SKColor redColor]
                                              andSize:kButtonSize
                                          andPosition:CGPointMake(kButtonWidth, kButtonYPosition * 3)
                                         andZPosition:kZPositionTopBarButton];
  [tempButtons addObject:self.firstTurnButton];
//  [self enableButton:self.firstTurnButton];
  
  self.previousTurnButton = [[Button alloc] initWithName:@"previous" andColor:[SKColor orangeColor]
                                                 andSize:kButtonSize
                                             andPosition:CGPointMake(kButtonWidth * 2, kButtonYPosition * 3)
                                            andZPosition:kZPositionTopBarButton];
  [tempButtons addObject:self.previousTurnButton];
//  [self enableButton:self.previousTurnButton];
  
  self.nextTurnButton = [[Button alloc] initWithName:@"next" andColor:[SKColor greenColor]
                                             andSize:kButtonSize
                                         andPosition:CGPointMake(kButtonWidth * 3, kButtonYPosition * 3)
                                        andZPosition:kZPositionTopBarButton];
  [tempButtons addObject:self.nextTurnButton];
//  [self enableButton:self.nextTurnButton];
  
  self.lastTurnButton = [[Button alloc] initWithName:@"last" andColor:[SKColor blueColor]
                                             andSize:kButtonSize
                                         andPosition:CGPointMake(kButtonWidth * 4, kButtonYPosition * 3)
                                        andZPosition:kZPositionTopBarButton];
  [tempButtons addObject:self.lastTurnButton];
//  [self enableButton:self.lastTurnButton];
  
  self.allButtons = [NSSet setWithSet:tempButtons];
}

@end
