//
//  Board.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+Helper.h"
@class Cell;

@protocol BoardDelegate <NSObject>

-(UIColor *)pivotColourForCurrentPlayerLight:(BOOL)light;
-(Dyadmino *)touchDyadminoIfAny;
-(void)correctBoardForPositionAfterZoom;
-(NSSet *)allBoardDyadminoesPlusRecentRackDyadmino;
-(BOOL)actionSheetShown;
-(void)presentActionSheetAfterPivotGuidesHidden;
//-(BOOL)dyadminoesShouldBeLocked;

@end

@interface Board : SKSpriteNode
@property (weak, nonatomic) id<BoardDelegate> delegate;

@property (nonatomic) CGPoint homePosition;
@property (readonly, nonatomic) CGPoint origin;
@property (readonly, nonatomic) CGVector hexOrigin;

@property (nonatomic) BOOL zoomedOut;
@property (nonatomic) CGPoint postZoomPosition;
@property (assign, nonatomic) CGPoint zoomInBoardHomePositionDifference;

@property (nonatomic) CGFloat highestYPos;
@property (nonatomic) CGFloat highestXPos;
@property (nonatomic) CGFloat lowestYPos;
@property (nonatomic) CGFloat lowestXPos;

@property (strong, nonatomic) NSMutableSet *allCells;
@property (readonly, nonatomic) NSMutableArray *columnOfRowsOfAllCells;

  // pivot properties
@property (nonatomic) PivotOnPC pivotOnPC;
@property (strong, nonatomic) SKNode *prePivotGuide;
@property (strong, nonatomic) SKNode *pivotRotateGuide;
@property (strong, nonatomic) SKNode *pivotAroundGuide;

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

-(id)initWithColor:(UIColor *)color andSize:(CGSize)size andCellTexture:(SKTexture *)cellTexture;

-(void)updatePivotGuidesForNewPlayer;

-(void)repositionBoardWithHomePosition:(CGPoint)homePosition
                             andOrigin:(CGPoint)origin;

-(CGPoint)adjustedNewPositionFromBeganLocation:(CGPoint)beganLocation
                             toCurrentLocation:(CGPoint)currentLocation
                                      withSwap:(BOOL)swap
                              returnDifference:(BOOL)returnDifference;

-(void)resetForNewMatch;

#pragma mark - board position methods

-(CGPoint)centerBoardOnDyadminoesAverageCenterWithSwap:(BOOL)swap;

#pragma mark - board span methods

-(CGVector)determineOutermostCellsBasedOnDyadminoes:(NSSet *)boardDyadminoes; // called by scene's toggle board zoom method only
-(void)determineBoardPositionBounds;

#pragma mark - cell methods

-(void)establishHexOriginForCenteringBoardBasedOnBoardDyadminoes:(NSSet *)boardDyadminoes;

-(BOOL)layoutAndColourBoardCellsAndSnapPointsOfDyadminoes:(NSSet *)boardDyadminoes
                                            minusDyadmino:(Dyadmino *)minusDyadmino
                                             updateBounds:(BOOL)updateBounds;

-(void)updateCellsForDyadmino:(Dyadmino *)dyadmino placedOnBottomHexCoord:(HexCoord)bottomHexCoord;
-(void)updateCellsForDyadmino:(Dyadmino *)dyadmino removedFromBottomHexCoord:(HexCoord)bottomHexCoord;

#pragma mark - cell position query methods

-(HexCoord)findClosestHexCoordForDyadminoPosition:(CGPoint)dyadminoPosition
                                   andOrientation:(DyadminoOrientation)orientation;

#pragma mark - cell zoom methods

-(CGPoint)repositionCellsForZoomWithSwap:(BOOL)swap;
//-(void)changeAllCellsToFactor:(CGFloat)factor animated:(BOOL)animated;

#pragma mark - pivot guide methods

-(void)hidePivotGuideAndShowPrePivotGuideForDyadmino:(Dyadmino *)dyadmino;
-(void)hideAllPivotGuides;
-(void)hideAllPivotGuidesAndShowExtendedChordActionSheet;

-(void)updatePositionsOfPivotGuidesForDyadminoPosition:(CGPoint)dyadminoPosition;

#pragma mark - pivot methods

-(PivotOnPC)determinePivotOnPCForDyadmino:(Dyadmino *)dyadmino;
-(void)rotatePivotGuidesBasedOnPivotAroundPoint:(CGPoint)pivotAroundPoint andTrueAngle:(CGFloat)trueAngle;

#pragma mark - distance helper methods

-(CGPoint)getOffsetFromPoint:(CGPoint)point;
-(CGPoint)getOffsetForPoint:(CGPoint)point withTouchOffset:(CGPoint)touchOffset;

@end
