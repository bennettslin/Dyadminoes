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

#define kPnPLabelFontSize (kIsIPhone ? 28.f : 54.f)

@implementation PnPBar

-(void)populateWithPnPButtonsAndLabel {
  
  CGFloat leftOffset = kLargeButtonWidth;

  self.returnOrStartButton = [[Button alloc] initWithName:@"start" andColor:[SKColor grayColor]
                                           andSize:kLargeButtonSize
                                       andPosition:CGPointMake(self.frame.size.width - (kLargeButtonWidth * 1.5), kRackHeight / 2)
                                      andZPosition:kZPositionTopBarButton];
  [self node:self.returnOrStartButton shouldBeEnabled:YES];
  
  self.waitingForPlayerLabel = [[Label alloc] initWithName:@"waitPlayer"
                                    andFontColor:kTestRed
                                     andFontSize:kPnPLabelFontSize
                                     andPosition:CGPointMake(leftOffset, kRackHeight / 2)
                                    andZPosition:kZPositionLogMessage
                          andHorizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
  
  self.allLabels = [NSDictionary dictionaryWithObject:self.waitingForPlayerLabel forKey:self.waitingForPlayerLabel.name];
}

@end
