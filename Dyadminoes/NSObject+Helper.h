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
#define kConstantSpeed 0.002f
#define kAnimateHoverTime 0.4f
#define kDoubleTapTime 0.25f

  // dyadmino size constants
  // one constant rules them all (literally, haha)
#define kDyadminoFaceRadius 21.75f // for now, perfectly reflects image size
#define kDyadminoFaceDiameter (kDyadminoFaceRadius * 2)
#define kDyadminoFaceWideRadius (kDyadminoFaceRadius * kTwoOverSquareRootOfThree)
#define kDyadminoFaceWideDiameter (kDyadminoFaceWideRadius * 3 / 2)

  // dyadmino state constants
#define kDyadminoResizedFactor 1.17f
#define kDyadminoColorBlendFactor 0.2f

  // math constants
#define kSquareRootOfThree 1.73205081f
#define kTwoOverSquareRootOfThree 1.15470054f

  // view constants
#define kTopBarHeight 80.f
#define kRackHeight 108.f
#define kBoardCoverAlpha 0.4f

  // game logic constants
#define kNumDyadminoesInRack 6

  // distance constants
#define kAngleForSnapToPivot 0.1f

#define kDistanceForTouchingHoveringDyadmino (kDyadminoFaceRadius * kDyadminoResizedFactor) // was 32.f
#define kDistanceForTouchingRestingDyadmino (kDyadminoFaceRadius * 0.8f) // was 25.f

#define kMinDistanceForPivot kDistanceForTouchingHoveringDyadmino
#define kMaxDistanceForPivot kDyadminoFaceRadius * 5.f
#define kPivotGuideAlpha 0.7f

#define kGapForHighlight 30.f

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
#define kTestRed [SKColor colorWithRed:1.f green:.7f blue:.7f alpha:1.f]
#define kDarkGreen [SKColor colorWithRed:0.f green:.6f blue:.2f alpha:1.f]

typedef struct HexCoord {
  NSInteger x;
  NSInteger y;
} HexCoord;

typedef enum pcMode {
  kPCModeLetter,
  kPCModeNumber
} PCMode;

//typedef struct playerDyadminoSettings {
//  PCMode pcMode;
//  UIDeviceOrientation deviceOrientation;
//} PlayerDyadminoSettings;

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

typedef enum dyadminoHoveringStatus {
  kDyadminoNoHoverStatus,
  kDyadminoHovering,
  kDyadminoContinuesHovering,
  kDyadminoFinishedHovering
} DyadminoHoveringStatus;

typedef enum pivotOnPC {
  kPivotCentre,
  kPivotOnPC1,
  kPivotOnPC2
} PivotOnPC;

typedef enum physicalPlacementResult {
  kErrorStackedDyadminoes,
  kErrorLoneDyadmino,
  kNoError
} PhysicalPlacementResult;

//typedef enum dyadminoPCOnCell {
//  kNoPCsOnCell,
//  kPCOneOnCell,
//  kPCTwoOnCell
//} dyadminoPCOnCell;

@interface NSObject (Helper)

  // math stuff
-(NSUInteger)randomValueUpTo:(NSUInteger)high;
-(CGFloat)getDistanceFromThisPoint:(CGPoint)point1 toThisPoint:(CGPoint)point2;
-(CGPoint)addToThisPoint:(CGPoint)point1 thisPoint:(CGPoint)point2;
-(CGPoint)subtractFromThisPoint:(CGPoint)point1 thisPoint:(CGPoint)point2;
-(CGFloat)findAngleInDegreesFromThisPoint:(CGPoint)point1 toThisPoint:(CGPoint)point2;
-(CGFloat)getChangeFromThisAngle:(CGFloat)angle1 toThisAngle:(CGFloat)angle2;
-(CGFloat)getRadiansFromDegree:(CGFloat)degree;

  // struct stuff
-(HexCoord)hexCoordFromX:(NSInteger)x andY:(NSInteger)y;

@end
