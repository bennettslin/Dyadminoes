//
//  Board.h
//  Dyadminoes
//
//  Created by Bennett Lin on 3/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+Helper.h"
@class SnapPoint;
@class Cell;

@protocol BoardDelegate <NSObject>

-(BOOL)isFirstDyadmino:(Dyadmino *)dyadmino;
-(UIColor *)pivotColourForCurrentPlayerLight:(BOOL)light;

-(void)correctBoardForPositionAfterZoom;
-(NSSet *)allBoardDyadminoesPlusRecentRackDyadmino;
-(BOOL)actionSheetShown;

@end

@interface Board : SKSpriteNode
@property (weak, nonatomic) id<BoardDelegate> delegate;

@property (nonatomic) CGPoint homePosition;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGVector hexOrigin;

@property (nonatomic) BOOL zoomedOut;
@property (nonatomic) CGPoint postZoomPosition;
@property (assign, nonatomic) CGPoint zoomInBoardHomePositionDifference;

@property (nonatomic) CGFloat highestYPos;
@property (nonatomic) CGFloat highestXPos;
@property (nonatomic) CGFloat lowestYPos;
@property (nonatomic) CGFloat lowestXPos;

@property (strong, nonatomic) NSMutableSet *snapPointsTwelveOClock;
@property (strong, nonatomic) NSMutableSet *snapPointsTwoOClock;
@property (strong, nonatomic) NSMutableSet *snapPointsTenOClock;

@property (strong, nonatomic) NSMutableSet *allCells;

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

#pragma mark - background image methods

//-(void)initLoadBackgroundNodes;
//-(void)colourBackgroundForReplay;
//-(void)colourBackgroundForPnP;
//-(void)colourBackgroundForNormalPlay;

#pragma mark - zoom methods

-(CGPoint)repositionCellsForZoomWithSwap:(BOOL)swap;

#pragma mark - cell methods

-(BOOL)layoutAndColourBoardCellsAndSnapPointsOfDyadminoes:(NSSet *)boardDyadminoes minusDyadmino:(Dyadmino *)minusDyadmino;

-(void)updateCellsForDyadmino:(Dyadmino *)dyadmino placedOnBoardNode:(SnapPoint *)snapPoint;
-(void)updateCellsForDyadmino:(Dyadmino *)dyadmino removedFromBoardNode:(SnapPoint *)snapPoint;

#pragma mark - pivot guide methods

-(void)hidePivotGuideAndShowPrePivotGuideForDyadmino:(Dyadmino *)dyadmino;
-(void)hideAllPivotGuides;
-(void)handleUserWantsPivotGuides;

-(void)updatePositionsOfPivotGuidesForDyadminoPosition:(CGPoint)dyadminoPosition;

#pragma mark - pivot methods

-(PivotOnPC)determinePivotOnPCForDyadmino:(Dyadmino *)dyadmino;
-(void)rotatePivotGuidesBasedOnPivotAroundPoint:(CGPoint)pivotAroundPoint andTrueAngle:(CGFloat)trueAngle;

#pragma mark - board span methods

-(CGVector)determineOutermostCellsBasedOnDyadminoes:(NSSet *)boardDyadminoes; // called by scene's toggle board zoom method only
-(void)determineBoardPositionBounds;

#pragma mark - distance helper methods

-(CGPoint)getOffsetFromPoint:(CGPoint)point;
-(CGPoint)getOffsetForPoint:(CGPoint)point withTouchOffset:(CGPoint)touchOffset;

@end
