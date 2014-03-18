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

  // dyadmino size constants
  // one constant rules them all (literally, haha)
#define kDyadminoFaceRadius 21.75f // for now, perfectly reflects image size

  // dyadmino state constants
#define kDyadminoResizedFactor 1.17f
#define kDyadminoColorBlendFactor 0.2f

  // math constants
#define kSquareRootOfThree 1.73205081f

  // view constants
#define kTopBarHeight 72.f
#define kRackHeight 108.f
#define kBoardCoverAlpha 0.4f

  // game logic constants
#define kNumDyadminoesInRack 6

  // distance constants
#define kDistanceForSnapOut 10.f
#define kAngleForSnapToPivot 0.1f

#define kDistanceForOtherRackDyadminoToMoveOver 22.f
#define kDistanceForSnapIn 21.f // this is half the height of the cell space, plus wiggle room

#define kDistanceForTouchingHoveringDyadmino 32.f // this is also the min distance for pivot
#define kDistanceForTouchingLockedDyadmino 25.f
#define kMinDistanceForPivot kDistanceForTouchingHoveringDyadmino
#define kMaxDistanceForPivot 200.f

#define kGapForHighlight 30.f
#define kGapForShiftingDyadminoes 40.f
#define kBufferUnderShiftingGapForExchangingDyadminoes 10.f

  // z positions
#define kZPositionBoardCoverHidden 5.f
#define kZPositionBoard 10.f
#define kZPositionBoardCell 20.f
#define kZPositionBoardCover 25.f
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

  // colours
#define kDarkBlue [SKColor colorWithRed:.29f green:.4f blue:.63f alpha:1.f]
#define kSkyBlue [SKColor colorWithRed:.7f green:.8f blue:.9f alpha:1.f]
#define kFieldPurple [SKColor colorWithRed:.3f green:.2f blue:.4f alpha:1.f]
#define kSolidBlue [SKColor colorWithRed:.15f green:.19f blue:.55f alpha:1.f]
#define kGold [SKColor colorWithRed:.64f green:.57f blue:.38f alpha:1.f]

typedef struct BoardXY {
  NSInteger x;
  NSInteger y;
} BoardXY;

typedef enum dyadminoHoveringStatus {
  kDyadminoNoHoverStatus,
  kDyadminoHovering,
  kDyadminoContinuesHovering,
  kDyadminoFinishedHovering
} DyadminoHoveringStatus;

typedef enum pcMode {
  kPCModeLetter,
  kPCModeNumber
} PCMode;

typedef enum snapPointType {
  kSnapPointRack,
  kSnapPointSwap,
  kSnapPointBoardTwelveOClock,
  kSnapPointBoardTwoOClock,
  kSnapPointBoardTenOClock
} SnapPointType;

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

typedef enum dyadminoPCOnCell {
  kNoPCsOnCell,
  kPCOneOnCell,
  kPCTwoOnCell
} dyadminoPCOnCell;

@interface NSObject (Helper)

  // math stuff
-(NSUInteger)randomValueUpTo:(NSUInteger)high;
-(CGFloat)getDistanceFromThisPoint:(CGPoint)point1 toThisPoint:(CGPoint)point2;
-(CGPoint)addThisPoint:(CGPoint)point1 toThisPoint:(CGPoint)point2;
-(CGPoint)fromThisPoint:(CGPoint)point1 subtractThisPoint:(CGPoint)point2;
-(CGFloat)findAngleInDegreesFromThisPoint:(CGPoint)point1 toThisPoint:(CGPoint)point2;
-(CGFloat)getChangeFromThisAngle:(CGFloat)angle1 toThisAngle:(CGFloat)angle2;
-(CGFloat)getRadiansFromDegree:(CGFloat)degree;

  // struct stuff
-(BoardXY)boardXYFromX:(NSInteger)x andY:(NSInteger)y;

@end
