//
//  PnPBar.m
//  Dyadminoes
//
//  Created by Bennett Lin on 8/5/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "PnPBar.h"
#import "Button.h"
#import "Label.h"

#define kLabelFontSize (kIsIPhone ? 14.f : 18.f)

@implementation PnPBar

-(void)populateWithPnPButtonsAndLabel {
  
  self.returnOrStartButton = [[Button alloc] initWithName:@"start" andColor:[SKColor grayColor]
                                           andSize:kButtonSize
                                       andPosition:CGPointMake(kButtonWidth, kButtonYPosition * 2)
                                      andZPosition:kZPositionTopBarButton];
  [self button:self.returnOrStartButton shouldBeEnabled:YES];
  
  self.waitingForPlayerLabel = [[Label alloc] initWithName:@"waitPlayer"
                                    andFontColor:kTestRed
                                     andFontSize:kLabelFontSize
                                     andPosition:CGPointMake(5.f, kLabelYPosition)
                                    andZPosition:kZPositionLogMessage
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  
  self.allLabels = [NSDictionary dictionaryWithObject:self.waitingForPlayerLabel forKey:self.waitingForPlayerLabel.name];
}

@end
