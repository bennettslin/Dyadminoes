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
-(void)correctBoardForPositionAfterZoom;
-(NSSet *)allBoardDyadminoesPlusRecentRackDyadmino;

@end

@interface Board : SKSpriteNode
@property (weak, nonatomic) id<BoardDelegate> delegate;

@property (nonatomic) CGPoint homePosition;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGVector hexOrigin;

@property (nonatomic) BOOL zoomedOut;
@property (nonatomic) CGPoint postZoomPosition;

@property (nonatomic) CGFloat highestYPos;
@property (nonatomic) CGFloat highestXPos;
@property (nonatomic) CGFloat lowestYPos;
@property (nonatomic) CGFloat lowestXPos;

  /// these are the limits in terms of number of cells
@property (nonatomic) CGFloat cellsTop;
@property (nonatomic) CGFloat cellsRight;
@property (nonatomic) CGFloat cellsBottom;
@property (nonatomic) CGFloat cellsLeft;

@property (strong, nonatomic) NSMutableSet *snapPointsTwelveOClock;
@property (strong, nonatomic) NSMutableSet *snapPointsTwoOClock;
@property (strong, nonatomic) NSMutableSet *snapPointsTenOClock;

@property (strong, nonatomic) NSMutableSet *allCells;
@property (strong, nonatomic) NSMutableSet *occupiedCells;

  // pivot properties

@property (nonatomic) PivotOnPC pivotOnPC;
@property (strong, nonatomic) SKNode *prePivotGuide;
@property (strong, nonatomic) SKNode *pivotRotateGuide;
@property (strong, nonatomic) SKNode *pivotAroundGuide;

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

-(id)initWithColor:(UIColor *)color andSize:(CGSize)size andCellTexture:(SKTexture *)cellTexture;

-(void)repositionBoardWithHomePosition:(CGPoint)homePosition
                             andOrigin:(CGPoint)origin;

-(CGPoint)adjustToNewPositionFromBeganLocation:(CGPoint)beganLocation
                             toCurrentLocation:(CGPoint)currentLocation
                                      withSwap:(BOOL)swap;

-(void)resetForNewMatch;

#pragma mark - board position methods

-(void)centerBoardOnDyadminoesAverageCenterWithSwap:(BOOL)swap;
//-(void)centerBoardOnLocation:(CGPoint)location withSwap:(BOOL)swap andGameEnded:(BOOL)gameEnded;

#pragma mark - background image methods

//-(void)initLoadBackgroundNodes;
//-(void)colourBackgroundForReplay;
//-(void)colourBackgroundForPnP;
//-(void)colourBackgroundForNormalPlay;

#pragma mark - zoom methods

-(void)repositionCellsForZoomWithSwap:(BOOL)swap;
//-(void)toggleBackgroundAlphaZeroed:(BOOL)zeroed animated:(BOOL)animated;

#pragma mark - cell methods

-(void)layoutBoardCellsAndSnapPointsOfDyadminoes:(NSSet *)boardDyadminoes;
-(Cell *)acknowledgeOrAddCellWithXHex:(NSInteger)xHex andYHex:(NSInteger)yHex; // called by scene's replay methods
-(void)updateCellsForDyadmino:(Dyadmino *)dyadmino placedOnBoardNode:(SnapPoint *)snapPoint andColour:(BOOL)colour;
-(void)updateCellsForDyadmino:(Dyadmino *)dyadmino removedFromBoardNode:(SnapPoint *)snapPoint andColour:(BOOL)colour;

#pragma mark - cell colour methods

-(void)changeColoursAroundDyadmino:(Dyadmino *)dyadmino withSign:(NSInteger)sign;

#pragma mark - pivot guide methods

-(void)hidePivotGuideAndShowPrePivotGuideForDyadmino:(Dyadmino *)dyadmino;
-(void)hideAllPivotGuides;
-(void)handleUserWantsPivotGuides;

#pragma mark - pivot methods

-(PivotOnPC)determinePivotOnPCForDyadmino:(Dyadmino *)dyadmino;
-(void)pivotGuidesBasedOnTouchLocation:(CGPoint)touchLocation forDyadmino:(Dyadmino *)dyadmino firstTime:(BOOL)firstTime;

#pragma mark - board span methods

-(CGVector)determineOutermostCellsBasedOnDyadminoes:(NSSet *)boardDyadminoes; // called by scene's toggle board zoom method only
-(void)determineBoardPositionBounds;

#pragma mark - legality methods

-(PhysicalPlacementResult)validatePlacingDyadmino:(Dyadmino *)dyadmino onBoardNode:(SnapPoint *)snapPoint;
-(void)validateChordsForPlacingDyadmino:(Dyadmino *)dyadmino onBoardNode:(SnapPoint *)snapPoint;

#pragma mark - distance helper methods

-(CGPoint)getOffsetFromPoint:(CGPoint)point;
-(CGPoint)getOffsetForPoint:(CGPoint)point withTouchOffset:(CGPoint)touchOffset;

@end
