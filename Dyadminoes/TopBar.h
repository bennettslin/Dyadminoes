//
//  TopBar.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+Helper.h"

@interface TopBar : SKSpriteNode

@property (strong, nonatomic) NSMutableSet *buttonNodes;
@property (strong, nonatomic) SKSpriteNode *togglePCModeButton;
@property (strong, nonatomic) SKSpriteNode *swapButton;
@property (strong, nonatomic) SKSpriteNode *cancelButton;
@property (strong, nonatomic) SKSpriteNode *playDyadminoButton;
@property (strong, nonatomic) SKSpriteNode *doneTurnButton;
@property (strong, nonatomic) SKSpriteNode *logButton;

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
