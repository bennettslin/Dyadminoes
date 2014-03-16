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
#import "SnapPoint.h"

@interface Dyadmino : SKSpriteNode

  // pcs
@property NSUInteger pc1;
@property NSUInteger pc2;
@property (nonatomic) PCMode pcMode;

  // nodes and touches
@property (strong, nonatomic) SnapPoint *homeNode;
@property (strong, nonatomic) SnapPoint *tempBoardNode;

  // orientations
@property (nonatomic) DyadminoOrientation orientation;
@property (nonatomic) DyadminoOrientation tempReturnOrientation;

  // sprites
@property (strong, nonatomic) NSArray *rotationFrameArray;
@property (strong, nonatomic) SKSpriteNode *pc1LetterSprite;
@property (strong, nonatomic) SKSpriteNode *pc2LetterSprite;
@property (strong, nonatomic) SKSpriteNode *pc1NumberSprite;
@property (strong, nonatomic) SKSpriteNode *pc2NumberSprite;
@property (strong, nonatomic) SKSpriteNode *pc1Sprite;
@property (strong, nonatomic) SKSpriteNode *pc2Sprite;
@property (strong, nonatomic) SKSpriteNode *pivotGuide;

  // bools and states
@property (nonatomic) BOOL isInTopBar;
@property (nonatomic) BOOL belongsInSwap;
@property (nonatomic) BOOL canFlip;
@property (nonatomic) BOOL isRotating;
@property (nonatomic) BOOL isTouchThenHoverResized;
@property (nonatomic) DyadminoHoveringStatus hoveringStatus;

  // pivot properties
@property (nonatomic) CGFloat initialPivotAngle;
@property (nonatomic) DyadminoOrientation prePivotDyadminoOrientation;
@property (nonatomic) CGPoint prePivotPosition;

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

#pragma mark - init and layout methods

-(id)initWithPC1:(NSUInteger)pc1 andPC2:(NSUInteger)pc2 andPCMode:(PCMode)pcMode
                  andRotationFrameArray:(NSArray *)rotationFrameArray
                     andPC1LetterSprite:(SKSpriteNode *)pc1LetterSprite
                     andPC2LetterSprite:(SKSpriteNode *)pc2LetterSprite
                     andPC1NumberSprite:(SKSpriteNode *)pc1NumberSprite
                     andPC2NumberSprite:(SKSpriteNode *)pc2NumberSprite;

-(void)randomiseRackOrientation;

#pragma mark - orient and position methods

-(void)selectAndPositionSprites;
-(void)orientBySnapNode:(SnapPoint *)snapNode;
-(void)orientBasedOnSextantChange:(CGFloat)sextantChange;
-(CGPoint)getHomeNodePosition;

#pragma mark - change status methods

-(void)startTouchThenHoverResize;
-(void)endTouchThenHoverResize;
-(void)startHovering;
-(void)keepHovering;
-(void)finishHovering;
-(void)adjustHighlightIntoPlay;
-(void)unhighlightOutOfPlay;

#pragma mark - change state methods

-(void)setToHomeZPosition;
-(void)goHomeByPoppingIn:(BOOL)poppingIn;
-(void)goFromTopBarToTempBoardNode;
-(void)removeActionsAndEstablishNotRotating;

#pragma mark - pivot methods

-(void)determinePivotOnPC;
-(void)pivotBasedOnLocation:(CGPoint)location;

#pragma mark - animation methods

-(void)animateConstantTimeMoveToPoint:(CGPoint)point;
-(void)animateSlowerConstantTimeMoveToPoint:(CGPoint)point;
-(void)animateConstantSpeedMoveDyadminoToPoint:(CGPoint)point;
-(void)animateFlip;
-(void)animateEaseIntoNodeAfterHover;

#pragma mark - bool methods

-(BOOL)belongsInRack;
-(BOOL)belongsOnBoard;

-(BOOL)isOrBelongsInSwap;
-(BOOL)isInRack;
-(BOOL)isOnBoard;
-(BOOL)isLocatedInTopBar;
-(BOOL)isHovering;
-(BOOL)continuesToHover;
-(BOOL)isFinishedHovering;

#pragma mark - helper methods

-(CGFloat)getHeightFloatGivenGap:(CGFloat)gap;

#pragma mark - debugging methods

-(NSString *)logThisDyadmino;

  /// this is the first pc

/**
 initialises a dyadmino with pcs and orientation
 @see hello
 @param pc1, pc2, orientation
 @return itself
 **/

@end
