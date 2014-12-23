//
//  TopBar.h
//  Dyadminoes
//
//  Created by Bennett Lin on 8/5/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Bar.h"

@interface TopBar : Bar

@property (strong, nonatomic) Button *swapCancelOrUndoButton;
@property (strong, nonatomic) Button *passPlayOrDoneButton;
@property (strong, nonatomic) Button *replayButton;
@property (strong, nonatomic) Button *optionsButton;
@property (strong, nonatomic) Button *debugButton;

@property (strong, nonatomic) NSArray *playerNameLabels;
@property (strong, nonatomic) NSArray *playerScoreLabels;

@property (strong, nonatomic) Label *messageLabel;
@property (strong, nonatomic) Label *chordLabel;

-(void)populateWithTopBarButtons;

-(void)changeSwapCancelOrUndo:(SwapCancelOrUndoButton)swapCancelOrUndo;
-(void)changePassPlayOrDone:(PassPlayOrDoneButton)passPlayOrDone;

@end
