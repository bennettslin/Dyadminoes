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

@protocol DyadminoDelegate <NSObject>

-(void)updateCellsForPlacedDyadmino:(Dyadmino *)dyadmino andColour:(BOOL)colour;
-(void)prepareForHoverThisDyadmino:(Dyadmino *)dyadmino;
-(void)soundDyadminoSettleClick;
-(void)soundDyadminoPivotClick;
-(void)soundDyadminoSuck;

-(void)layoutOrRefreshRackFieldAndDyadminoesFromUndo:(BOOL)undo withAnimation:(BOOL)animation;
-(void)changeColoursAroundDyadmino:(Dyadmino *)dyadmino withSign:(NSInteger)sign;

@end

@interface Dyadmino : SKSpriteNode

@property (nonatomic) NSUInteger myID;
@property (weak, nonatomic) id<DyadminoDelegate> delegate;

  // pcs
@property NSUInteger pc1;
@property NSUInteger pc2;
@property (nonatomic) PCMode pcMode;

  // cells
@property (strong, nonatomic) Cell *cellForPC1;
@property (strong, nonatomic) Cell *cellForPC2;

  // nodes and touches
@property (strong, nonatomic) SnapPoint *homeNode;
@property (strong, nonatomic) SnapPoint *tempBoardNode;
@property (nonatomic) HexCoord myHexCoord;
@property (nonatomic) NSInteger myRackOrder;

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

  // bools and states
@property (nonatomic) BOOL isInTopBar;
@property (nonatomic) BOOL belongsInSwap;
@property (nonatomic) BOOL canFlip;
@property (nonatomic) BOOL isRotating;
@property (nonatomic) BOOL isTouchThenHoverResized;
@property (nonatomic) BOOL isZoomResized;
@property (nonatomic) DyadminoHoveringStatus hoveringStatus;

  // pivot properties
@property (nonatomic) CGFloat initialPivotAngle;
@property (nonatomic) DyadminoOrientation prePivotDyadminoOrientation;
@property (nonatomic) CGPoint initialPivotPosition;
@property (nonatomic) CGPoint pivotAroundPoint;

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

#pragma mark - init and layout methods

-(id)initWithPC1:(NSUInteger)pc1 andPC2:(NSUInteger)pc2 andPCMode:(PCMode)pcMode
                  andRotationFrameArray:(NSArray *)rotationFrameArray
                     andPC1LetterSprite:(SKSpriteNode *)pc1LetterSprite
                     andPC2LetterSprite:(SKSpriteNode *)pc2LetterSprite
                     andPC1NumberSprite:(SKSpriteNode *)pc1NumberSprite
                     andPC2NumberSprite:(SKSpriteNode *)pc2NumberSprite;

//-(void)randomiseRackOrientation;

#pragma mark - orient, position, and size methods

-(void)selectAndPositionSprites;
-(void)orientBySnapNode:(SnapPoint *)snapNode;
-(CGPoint)getHomeNodePosition;

#pragma mark - change status methods

-(void)startTouchThenHoverResize;
-(void)endTouchThenHoverResize;
//-(void)startHovering;
-(void)keepHovering;
-(void)finishHovering;
//-(void)unhighlightOutOfPlay;
-(void)highlightBoardDyadmino;
-(void)adjustHighlightGivenDyadminoOffsetPosition:(CGPoint)dyadminoOffsetPosition;

#pragma mark - change state methods

-(void)setToHomeZPosition;
-(void)goHomeToRackByPoppingIn:(BOOL)poppingIn fromUndo:(BOOL)undo;
-(void)goHomeToBoardByPoppingIn:(BOOL)poppingIn;
-(void)animatePopBackIntoBoardNode;
-(void)removeActionsAndEstablishNotRotating;

#pragma mark - pivot methods

-(void)pivotBasedOnTouchLocation:(CGPoint)touchLocation andPivotOnPC:(PivotOnPC)pivotOnPC;

#pragma mark - animation methods

-(void)animateMoveToPoint:(CGPoint)point;
-(void)animateFlip;
-(void)animateEaseIntoNodeAfterHover;
-(void)animateDyadminoesRecentlyPlayed:(BOOL)playedByMyPlayer;
-(void)animateFace:(SKSpriteNode *)face;
//-(void)animateInitialTouch;

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

-(CGPoint)determinePivotAroundPointBasedOnPivotOnPC:(PivotOnPC)pivotOnPC;
-(HexCoord)getHexCoordOfFace:(SKSpriteNode *)face;

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
