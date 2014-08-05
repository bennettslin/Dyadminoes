//
//  TopBar.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+Helper.h"
@class Button;
@class Label;

@interface Bar : SKSpriteNode

@property (strong, nonatomic) NSSet *allButtons;
@property (strong, nonatomic) NSDictionary *allLabels;
@property (strong, nonatomic) NSArray *playerNameLabels;
@property (strong, nonatomic) NSArray *playerScoreLabels;

@property (strong, nonatomic) Button *returnButton;
@property (strong, nonatomic) Button *swapCancelOrUndoButton;
@property (strong, nonatomic) Button *passPlayOrDoneButton;
@property (strong, nonatomic) Button *debugButton;

@property (strong, nonatomic) Button *replayButton;
@property (strong, nonatomic) Button *resignButton;

@property (strong, nonatomic) Label *turnLabel;
@property (strong, nonatomic) Label *pileCountLabel;
@property (strong, nonatomic) Label *messageLabel;
@property (strong, nonatomic) Label *chordLabel;

@property (strong, nonatomic) Label *player1Name;
@property (strong, nonatomic) Label *player2Name;
@property (strong, nonatomic) Label *player3Name;
@property (strong, nonatomic) Label *player4Name;

@property (strong, nonatomic) Label *player1Score;
@property (strong, nonatomic) Label *player2Score;
@property (strong, nonatomic) Label *player3Score;
@property (strong, nonatomic) Label *player4Score;

@property (strong, nonatomic) Label *player1Rack;
@property (strong, nonatomic) Label *player2Rack;
@property (strong, nonatomic) Label *player3Rack;
@property (strong, nonatomic) Label *player4Rack;

  // replay buttons
@property (strong, nonatomic) Button *firstTurnButton;
@property (strong, nonatomic) Button *previousTurnButton;
@property (strong, nonatomic) Button *nextTurnButton;
@property (strong, nonatomic) Button *lastTurnButton;

  // replay labels
@property (strong, nonatomic) Label *playedDyadminoesLabel;

  // debugger labels
@property (strong, nonatomic) Label *logLabel;
@property (strong, nonatomic) NSArray *playerRackLabels;
@property (strong, nonatomic) Label *pileDyadminoesLabel;
@property (strong, nonatomic) Label *boardDyadminoesLabel;
@property (strong, nonatomic) Label *holdingContainerLabel;
@property (strong, nonatomic) Label *swapContainerLabel;
@property (strong, nonatomic) Label *lastActionLabel;
@property (strong, nonatomic) Label *statusLabel;

-(id)initWithColor:(UIColor *)color andSize:(CGSize)size
    andAnchorPoint:(CGPoint)anchorPoint
       andPosition:(CGPoint)position
      andZPosition:(CGFloat)zPosition;

-(void)populateWithTopBarButtons;
-(void)populateWithTopBarLabels;

-(void)populateWithTopReplayButtonsAndLabels;
-(void)populateWithBottomReplayButtons;

//-(void)populateWithTopPnPButtons;
-(void)populateWithBottomPnPButtons;

#pragma mark - button methods

-(void)enableButton:(SKSpriteNode *)button;
-(void)disableButton:(SKSpriteNode *)button;
-(void)changeSwapCancelOrUndo:(SwapCancelOrUndoButton)swapCancelOrUndo;
-(void)changePassPlayOrDone:(PassPlayOrDoneButton)passPlayOrDone;

-(BOOL)rotateButtonsBasedOnDeviceOrientation:(UIDeviceOrientation)deviceOrientation;

#pragma mark - label methods

-(void)updateLabelNamed:(NSString *)name withText:(NSString *)text andColour:(UIColor *)colour;
-(void)flashLabelNamed:(NSString *)name withText:(NSString *)text andColour:(UIColor *)colour;
-(void)afterPlayUpdateScoreLabel:(Label *)scoreLabel withText:(NSString *)scoreText;

@end
