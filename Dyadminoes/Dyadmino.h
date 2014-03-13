//
//  Dyadmino.h
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "NSObject+Helper.h"
#import "SnapNode.h"

@interface Dyadmino : SKSpriteNode

@property NSUInteger pc1;
@property NSUInteger pc2;
@property (nonatomic) PCMode pcMode;

@property (strong, nonatomic) SnapNode *homeNode;
@property (strong, nonatomic) SnapNode *tempBoardNode;
@property (strong, nonatomic) UITouch *myTouch;

@property (nonatomic) DyadminoOrientation orientation;
@property (nonatomic) DyadminoOrientation tempReturnOrientation;
@property (strong, nonatomic) NSArray *rotationFrameArray;
@property (strong, nonatomic) SKSpriteNode *pc1LetterSprite;
@property (strong, nonatomic) SKSpriteNode *pc2LetterSprite;
@property (strong, nonatomic) SKSpriteNode *pc1NumberSprite;
@property (strong, nonatomic) SKSpriteNode *pc2NumberSprite;
@property (strong, nonatomic) SKSpriteNode *pc1Sprite;
@property (strong, nonatomic) SKSpriteNode *pc2Sprite;

@property DyadminoWithinSection withinSection;
@property BOOL canFlip;
@property BOOL isRotating;
@property (nonatomic) DyadminoOrientation prePivotDyadminoOrientation;
@property (nonatomic) CGPoint prePivotPosition;

@property DyadminoHoveringStatus hoveringStatus;
@property BOOL isTouchThenHoverResized;

-(id)initWithPC1:(NSUInteger)pc1 andPC2:(NSUInteger)pc2 andPCMode:(PCMode)pcMode andRotationFrameArray:(NSArray *)rotationFrameArray andPC1LetterSprite:(SKSpriteNode *)pc1LetterSprite andPC2LetterSprite:(SKSpriteNode *)pc2LetterSprite andPC1NumberSprite:(SKSpriteNode *)pc1NumberSprite andPC2NumberSprite:(SKSpriteNode *)pc2NumberSprite;

-(void)selectAndPositionSprites;
-(void)randomiseRackOrientation;
-(void)orientBySnapNode:(SnapNode *)snapNode;
-(void)orientBasedOnSextantChange:(CGFloat)sextantChange;

-(void)startTouchThenHoverResize;
-(void)endTouchThenHoverResize;

-(void)startHovering;
-(void)keepHovering;
-(void)finishHovering;

-(void)adjustHighlightIntoPlay;
-(void)unhighlightOutOfPlay;

-(void)setToHomeZPosition;
-(void)setToTempZPosition;

-(void)goHome;
-(void)removeActionsAndEstablishNotRotating;

#pragma mark - bool methods
-(BOOL)belongsInRack;
-(BOOL)belongsOnBoard;
-(BOOL)isInRack;
-(BOOL)isOnBoard;
-(BOOL)isHovering;
-(BOOL)continuesToHover;
-(BOOL)isFinishedHovering;

#pragma mark - animation methods

-(void)animateConstantTimeMoveToPoint:(CGPoint)point;
-(void)animateSlowerConstantTimeMoveToPoint:(CGPoint)point;
-(void)animateConstantSpeedMoveDyadminoToPoint:(CGPoint)point;
-(void)animateFlip;
-(void)animateEaseIntoNodeAfterHover;

#pragma mark - debugging methods


  /// this is the first pc

/**
 initialises a dyadmino with pcs and orientation
 @see hello
 @param pc1, pc2, orientation
 @return itself
 **/
-(NSString *)logThisDyadmino;

@end
