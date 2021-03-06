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
@class Cell;
@class Face;

@protocol DyadminoDelegate <NSObject>

  // these must be delegate methods, because dyadmino does not know board's hex origin
-(CGPoint)homePositionForDyadmino:(Dyadmino *)dyadmino;
-(CGPoint)tempPositionForDyadmino:(Dyadmino *)dyadmino withHomeOrientation:(BOOL)homeOrientation;
-(CGPoint)rackPositionForDyadmino:(Dyadmino *)dyadmino;
-(BOOL)dyadminoShouldBeLocked:(Dyadmino *)dyadmino;

-(void)updateCellsForPlacedDyadmino:(Dyadmino *)dyadmino;
-(void)prepareForHoverThisDyadmino:(Dyadmino *)dyadmino;
-(void)postSoundNotification:(NotificationName)whichNotification;
-(BOOL)refreshRackFieldAndDyadminoesFromUndo:(BOOL)undo withAnimation:(BOOL)animation;
-(void)decrementDyadminoesInFluxWithLayoutLast:(BOOL)layoutLast;

@end

@protocol DyadminoSceneDelegate <NSObject>

@property (readonly, nonatomic) PCMode myPCMode;
-(SKTexture *)textureForTextureDyadmino:(TextureDyadmino)textureDyadmino;
-(SKTexture *)textureForPC:(NSInteger)pc;

@end

@interface Dyadmino : SKSpriteNode

@property (assign, nonatomic) NSUInteger myID;
@property (weak, nonatomic) id<DyadminoDelegate> delegate;
@property (weak, nonatomic) id<DyadminoSceneDelegate> sceneDelegate;

  // pcs
@property (assign, nonatomic) NSUInteger pc1;
@property (assign, nonatomic) NSUInteger pc2;
//@property (assign, nonatomic) PCMode pcMode;

  // cells
@property (strong, nonatomic) Cell *cellForPC1;
@property (strong, nonatomic) Cell *cellForPC2;

  // preserved positions
@property (assign, nonatomic) HexCoord homeHexCoord; // replaces homeNode
@property (assign, nonatomic) HexCoord tempHexCoord; // replaces tempBoardNode
@property (assign, nonatomic) NSInteger rackIndex; // replaces homeNode for rack

  // home
@property (readonly, nonatomic) DyadminoHome home;

  // orientations
@property (assign, nonatomic) DyadminoOrientation orientation;
@property (assign, nonatomic) DyadminoOrientation homeOrientation;

@property (strong, nonatomic) Face *pc1Sprite;
@property (strong, nonatomic) Face *pc2Sprite;

  // bools and states
@property (readonly, nonatomic) BOOL isInTopBar;
@property (readonly, nonatomic) BOOL belongsInSwap;
@property (assign, nonatomic) BOOL shrunkForReplay;

@property (nonatomic) BOOL canFlip;
@property (readonly, nonatomic) BOOL isRotating;
@property (nonatomic) BOOL isTouchThenHoverResized;
@property (nonatomic) BOOL isZoomResized;
@property (nonatomic) DyadminoHoveringStatus hoveringStatus;
@property (nonatomic) BOOL zRotationCorrectedAfterPivot;

  // pivot properties
@property (nonatomic) CGFloat initialPivotAngle;
@property (nonatomic) DyadminoOrientation prePivotDyadminoOrientation;
@property (nonatomic) CGPoint initialPivotPosition;
@property (nonatomic) CGPoint pivotAroundPoint;

  // replay properties will be set before each replay; they can be ignored otherwise
@property (assign, nonatomic) HexCoord preReplayHexCoord;
@property (assign, nonatomic) DyadminoOrientation preReplayOrientation;
@property (assign, nonatomic) DyadminoOrientation preReplayTempOrientation;

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

#pragma mark - init and layout methods

-(id)initWithPC1:(NSUInteger)pc1
          andPC2:(NSUInteger)pc2
andSceneDelegate:(id)sceneDelegate;

-(void)resetForNewMatch;

#pragma mark - orient, position, and size methods

-(void)selectAndPositionSpritesZRotation:(CGFloat)rotationAngle;

  // called by rack
-(CGPoint)addIfSwapToHomePosition:(CGPoint)homePosition;

  // called by scene in handle touch end of dyadmino
-(void)correctZRotationAfterHover;

#pragma mark - change status methods

-(void)startTouchThenHoverResize;
-(void)endTouchThenHoverResize;
-(void)unhighlightOutOfPlay;
-(void)changeHoveringStatus:(DyadminoHoveringStatus)hoveringStatus;
-(void)highlightBoardDyadminoWithColour:(UIColor *)colour;
-(void)adjustHighlightGivenDyadminoOffsetPosition:(CGPoint)dyadminoOffsetPosition;

#pragma mark - animate detailed placement methods

-(void)returnToRackByPoppingInForUndo:(BOOL)popInForUndo withResize:(BOOL)resize;
-(void)returnHomeToBoardWithLayout:(BOOL)layout andSound:(BOOL)sound withDecrement:(BOOL)decrement;

  // called by scene during replay and toggle board zoom
-(void)goToTempPositionWithLayout:(BOOL)layout andRescale:(BOOL)rescale andOrient:(BOOL)orient;

#pragma mark - animate basic placement methods

-(void)animateEaseIntoNodeAfterHover;
-(void)animateMoveToPointCalledFromRack:(CGPoint)point;

#pragma mark - animate rotation methods

-(void)orientWithAnimation:(BOOL)animate;
-(void)animateFlip;

#pragma mark - animate pop methods

-(void)animateGrowPopInWithCompletionBlock:(void(^)(void))completionBlock;

#pragma mark - unique animation methods

-(void)animateDyadminoesRecentlyPlayedWithColour:(UIColor *)colour;
-(void)animateFaceForSound:(SKSpriteNode *)face;
-(void)animateWiggleForHover:(BOOL)animate;
-(void)animateShrinkForReplayToShrink:(BOOL)shrink;

//#pragma mark - animation helper methods

//-(void)removeActionsAndEstablishNotRotatingIncludingMove:(BOOL)includingMove;

#pragma mark - pivot methods

-(void)zRotateToAngle:(CGFloat)angle;
-(BOOL)pivotBasedOnTouchLocation:(CGPoint)touchLocation andZRotationAngle:(CGFloat)angle andPivotOnPC:(PivotOnPC)pivotOnPC;

#pragma mark - bool methods

-(BOOL)isInRack;
-(BOOL)isOnBoard;
-(BOOL)isHovering;
-(BOOL)continuesToHover;
-(BOOL)isFinishedHovering;

#pragma mark - placement methods

-(void)placeInTopBar:(BOOL)inTopBar;
-(void)placeInBelongsInSwap:(BOOL)belongsInSwap;

#pragma mark - helper methods

-(CGPoint)determinePivotAroundPointBasedOnPivotOnPC:(PivotOnPC)pivotOnPC;
-(HexCoord)getHexCoordOfFace:(SKSpriteNode *)face;

#pragma mark - debugging methods

-(NSString *)logThisDyadmino;

@end
