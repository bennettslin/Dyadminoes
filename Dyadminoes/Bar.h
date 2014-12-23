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

@property (strong, nonatomic) NSSet *allButtons; // necessary for device orientation only
@property (strong, nonatomic) NSDictionary *allLabels;

@property (strong, nonatomic) Button *returnOrStartButton;

-(id)initWithColor:(UIColor *)color andSize:(CGSize)size
    andAnchorPoint:(CGPoint)anchorPoint
       andPosition:(CGPoint)position
      andZPosition:(CGFloat)zPosition;

#pragma mark - button methods

  // for both buttons and labels
-(void)node:(SKNode *)node shouldBeEnabled:(BOOL)enabled;

-(BOOL)rotateButtonsBasedOnDeviceOrientation:(UIDeviceOrientation)deviceOrientation;

#pragma mark - label methods

//-(void)updateLabel:(Label *)label withText:(NSString *)text andColour:(UIColor *)colour;
//-(void)flashLabel:(Label *)label withText:(NSString *)text andColour:(UIColor *)colour;

@end
