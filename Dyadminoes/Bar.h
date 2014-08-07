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

@property (strong, nonatomic) Button *returnOrStartButton;

-(id)initWithColor:(UIColor *)color andSize:(CGSize)size
    andAnchorPoint:(CGPoint)anchorPoint
       andPosition:(CGPoint)position
      andZPosition:(CGFloat)zPosition;

#pragma mark - button methods

-(void)button:(SKSpriteNode *)button shouldBeEnabled:(BOOL)enabled;
//-(void)disableButton:(SKSpriteNode *)button;

-(BOOL)rotateButtonsBasedOnDeviceOrientation:(UIDeviceOrientation)deviceOrientation;

#pragma mark - label methods

-(void)updateLabelNamed:(NSString *)name withText:(NSString *)text andColour:(UIColor *)colour;
-(void)flashLabelNamed:(NSString *)name withText:(NSString *)text andColour:(UIColor *)colour;

@end
