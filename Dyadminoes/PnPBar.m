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

@implementation PnPBar

-(void)populateWithPnPButtons {
  self.returnOrStartButton = [[Button alloc] initWithName:@"start" andColor:[SKColor grayColor]
                                           andSize:kButtonSize
                                       andPosition:CGPointMake(kButtonWidth, kButtonYPosition * 2)
                                      andZPosition:kZPositionTopBarButton];
  [self enableButton:self.returnOrStartButton];
}

@end
