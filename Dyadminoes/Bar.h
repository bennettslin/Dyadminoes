//
//  TopBar.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SKSpriteNode+Helper.h"
#import "NSObject+Helper.h"
#import "Button.h"
@class Label;

@protocol BarDelegate <NSObject>

-(void)postSoundNotification:(NotificationName)whichNotification;
-(void)handleButtonPressed:(Button *)button;

-(void)goBackToMainViewController;
-(BOOL)noActionsInProgress;

@end

@interface Bar : SKSpriteNode <ButtonDelegate>

@property (strong, nonatomic) NSSet *allButtons; // necessary for device orientation only
@property (strong, nonatomic) NSDictionary *allLabels;
@property (weak, nonatomic) id<BarDelegate> delegate;

@property (strong, nonatomic) Button *returnOrStartButton;

-(id)initWithColor:(UIColor *)color andSize:(CGSize)size
    andAnchorPoint:(CGPoint)anchorPoint
       andPosition:(CGPoint)position
      andZPosition:(CGFloat)zPosition;

#pragma mark - button methods

-(void)node:(SKNode *)node shouldBeEnabled:(BOOL)enabled;
//-(BOOL)rotateButtonsBasedOnDeviceOrientation:(UIDeviceOrientation)deviceOrientation;

@end
