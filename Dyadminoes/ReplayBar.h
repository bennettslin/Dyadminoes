//
//  ReplayBar.h
//  Dyadminoes
//
//  Created by Bennett Lin on 8/5/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Bar.h"

@interface ReplayBar : Bar

  // replay buttons
@property (strong, nonatomic) Button *firstTurnButton;
@property (strong, nonatomic) Button *previousTurnButton;
@property (strong, nonatomic) Button *nextTurnButton;
@property (strong, nonatomic) Button *lastTurnButton;

-(void)populateWithBottomReplayButtons;

@end
