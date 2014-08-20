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

  self.returnOrStartButton = [[Button alloc] initWithName:@"start" andColor:[SKColor grayColor]
                                           andSize:kLargeButtonSize
                                       andPosition:CGPointMake(self.frame.size.width - (kLargeButtonWidth * 0.5) - kPnPXEdgeBuffer, kRackHeight / 2)
                                      andZPosition:kZPositionTopBarButton];
  [self addChild:self.returnOrStartButton];
  [self node:self.returnOrStartButton shouldBeEnabled:YES];
}

@end
