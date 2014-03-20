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

@interface TopBar : SKSpriteNode

@property (strong, nonatomic) NSMutableSet *allButtons;
@property (strong, nonatomic) NSMutableDictionary *allLabels;

@property (strong, nonatomic) Button *togglePCModeButton;
@property (strong, nonatomic) Button *swapButton;
@property (strong, nonatomic) Button *cancelButton;
@property (strong, nonatomic) Button *playDyadminoButton;
@property (strong, nonatomic) Button *doneTurnButton;
@property (strong, nonatomic) Button *debugButton;

@property (strong, nonatomic) Label *pileCountLabel;
@property (strong, nonatomic) Label *messageLabel;
@property (strong, nonatomic) Label *logLabel;

-(id)initWithColor:(UIColor *)color andSize:(CGSize)size
    andAnchorPoint:(CGPoint)anchorPoint
       andPosition:(CGPoint)position
      andZPosition:(CGFloat)zPosition;

-(void)populateWithButtons;
-(void)populateWithLabels;

#pragma mark - button methods

-(void)enableButton:(SKSpriteNode *)button;
-(void)disableButton:(SKSpriteNode *)button;

#pragma mark - label methods

-(void)updateLabelNamed:(NSString *)name withText:(NSString *)text;
-(void)flashLabelNamed:(NSString *)name withText:(NSString *)text;

@end
