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
@property (strong, nonatomic) Button *resignButton;

@property (strong, nonatomic) NSArray *playerNameLabels;
@property (strong, nonatomic) NSArray *playerScoreLabels;

@property (strong, nonatomic) Label *turnLabel;
@property (strong, nonatomic) Label *pileCountLabel;
@property (strong, nonatomic) Label *messageLabel;
@property (strong, nonatomic) Label *chordLabel;

  // debugger labels and button
@property (strong, nonatomic) Button *debugButton;
@property (strong, nonatomic) NSArray *playerRackLabels;
@property (strong, nonatomic) Label *logLabel;
@property (strong, nonatomic) Label *pileDyadminoesLabel;
@property (strong, nonatomic) Label *boardDyadminoesLabel;
@property (strong, nonatomic) Label *holdingContainerLabel;
@property (strong, nonatomic) Label *swapContainerLabel;
@property (strong, nonatomic) Label *lastActionLabel;

-(void)populateWithTopBarButtons;
-(void)populateWithTopBarLabels;
-(void)populatePlayerLabels;

-(void)changeSwapCancelOrUndo:(SwapCancelOrUndoButton)swapCancelOrUndo;
-(void)changePassPlayOrDone:(PassPlayOrDoneButton)passPlayOrDone;

//-(void)afterPlayUpdateScoreLabel:(Label *)scoreLabel withText:(NSString *)scoreText;

@end
