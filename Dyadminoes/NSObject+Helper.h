//
//  NSObject+Helper.h
//  Dyadminoes
//
//  Created by Bennett Lin on 2/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Dyadmino;

  // animation constants
#define kRotateWait 0.05f
#define kConstantTime 0.15f
#define kSlowerConstantTime 0.2f
#define kConstantSpeed 0.002f
#define kAnimateHoverTime 0.35f

  // dyadmino state constants
#define kTouchedDyadminoSize 1.16f
#define kDyadminoColorBlendFactor 0.2f

  // math constants
#define kBoardDiagonalX 15.75f
#define kBoardDiagonalY 8.95f

  // view constants
#define kTopBarHeight 72.f
#define kRackHeight 108.f

  // game logic constants
#define kNumDyadminoesInRack 6

  // distance constants
#define kDistanceForSnapOut 10.f
#define kAngleForSnapToPivot 0.2f

#define kDistanceForOtherRackDyadminoToMoveOver 22.f
#define kDistanceForSnapIn 21.f // this is half the height of the cell space, plus wiggle room
#define kDistanceForTouchingHoveringDyadmino 37.5f
#define kDistanceForTouchingLockedDyadmino 25.f
#define kHeightGapToHighlightIntoPlay 40.f

  // z positions
#define kZPositionBoard 10.f
#define kZPositionBoardCell 20.f
#define kZPositionBoardNode 30.f
#define kZPositionBoardRestingDyadmino 40.f
#define kZPositionTopBar 100.f
#define kZPositionTopBarButton 110.f
#define kZPositionTopBarLabel 120.f
#define kZPositionSwapField 200.f
#define kZPositionSwapNode 210.f
#define kZPositionRackField 300.f
#define kZPositionRackNode 310.f
#define kZPositionRackMovedDyadmino 320.f
#define kZPositionRackRestingDyadmino 330.f
#define kZPositionHoveredDyadmino 400.f
#define kZPositionMessage 500.f

typedef enum dyadminoHoveringStatus {
  kDyadminoNoHoverStatus,
  kDyadminoHovering,
  kDyadminoContinuesHovering,
  kDyadminoFinishedHovering
} DyadminoHoveringStatus;

typedef enum dyadminoWithinSection {
  kDyadminoWithinRack,
  kDyadminoWithinBoard,
  kDyadminoWithinTopBar
} DyadminoWithinSection;

typedef enum pcMode {
  kPCModeLetter,
  kPCModeNumber
} PCMode;

typedef enum fieldNodeType {
  kFieldNodeRack,
  kFieldNodeSwap
} FieldNodeType;

typedef enum snapNodeType {
  kSnapNodeRack,
  kSnapNodeSwap,
  kSnapNodeBoardTwelveAndSix,
  kSnapNodeBoardTwoAndEight,
  kSnapNodeBoardFourAndTen
} SnapNodeType;

typedef enum dyadminoOrientation {
  kPC1atTwelveOClock,
  kPC1atTwoOClock,
  kPC1atFourOClock,
  kPC1atSixOClock,
  kPC1atEightOClock,
  kPC1atTenOClock
} DyadminoOrientation;

typedef enum pivotOnPC {
  kPivotCentre,
  kPivotOnPC1,
  kPivotOnPC2
} PivotOnPC;

@interface NSObject (Helper)

  // math stuff
-(NSUInteger)randomValueUpTo:(NSUInteger)high;
-(CGFloat)getDistanceFromThisPoint:(CGPoint)point1 toThisPoint:(CGPoint)point2;
-(CGPoint)addThisPoint:(CGPoint)point1 toThisPoint:(CGPoint)point2;
-(CGPoint)fromThisPoint:(CGPoint)point1 subtractThisPoint:(CGPoint)point2;
-(CGFloat)findAngleInDegreesFromThisPoint:(CGPoint)point1 toThisPoint:(CGPoint)point2;
-(CGFloat)getSextantChangeFromThisAngle:(CGFloat)angle1 toThisAngle:(CGFloat)angle2;

@end
