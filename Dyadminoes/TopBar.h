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

@interface TopBar : SKSpriteNode

@property (strong, nonatomic) NSMutableSet *buttonNodes;
@property (strong, nonatomic) Button *togglePCModeButton;
@property (strong, nonatomic) Button *swapButton;
@property (strong, nonatomic) Button *cancelButton;
@property (strong, nonatomic) Button *playDyadminoButton;
@property (strong, nonatomic) Button *doneTurnButton;
@property (strong, nonatomic) Button *logButton;

@property (strong, nonatomic) SKLabelNode *pileCountLabel;
@property (strong, nonatomic) SKLabelNode *messageLabel;
@property (strong, nonatomic) SKLabelNode *logLabel;

-(id)initWithColor:(UIColor *)color andSize:(CGSize)size
    andAnchorPoint:(CGPoint)anchorPoint
       andPosition:(CGPoint)position
      andZPosition:(CGFloat)zPosition;

-(void)populateWithButtons;
-(void)populateWithLabels;

-(void)enableButton:(SKSpriteNode *)button;
-(void)disableButton:(SKSpriteNode *)button;

@end
