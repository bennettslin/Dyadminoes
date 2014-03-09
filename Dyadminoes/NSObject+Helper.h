//
//  NSObject+Helper.h
//  Dyadminoes
//
//  Created by Bennett Lin on 2/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

  // animation constants
#define kRotateWait 0.05f
#define kConstantTime 0.15f
#define kSlowerConstantTime 0.2f
#define kConstantSpeed 0.002f
#define kAnimateHoverTime 0.4f
#define kHighlightedDyadminoSize 1.15f

  // math constants
#define kBoardDiagonalX 15.75f
#define kBoardDiagonalY 9.0932667f

  // view constants
#define kTopBarHeight 72.f
#define kPlayerRackHeight 108.f

  // logic constants
#define kNumDyadminoesInRack 6

  // distance constants
#define kDistanceForSnapOut 10.f
#define kDistanceForOtherRackDyadminoToMoveOver 22.f
#define kDistanceForSnapIn 21.f // this is half the height of the cell space, plus wiggle room
#define kDistanceForTouchingHoveringDyadmino 37.5f
#define kDistanceForTouchingLockedDyadmino 25.f

typedef enum dyadminoHoveringStatus {
  kDyadminoHovering,
  kDyadminoFinishedHovering,
  kDyadminoNoHoverStatus
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

typedef enum snapNodeType {
  kSnapNodeRack,
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

@interface NSObject (Helper)

-(NSUInteger)randomValueUpTo:(NSUInteger)high;

-(CGFloat)getDistanceFromThisPoint:(CGPoint)point1 toThisPoint:(CGPoint)point2;

-(CGPoint)addThisPoint:(CGPoint)point1 toThisPoint:(CGPoint)point2;
-(CGPoint)fromThisPoint:(CGPoint)point1 subtractThisPoint:(CGPoint)point2;

-(CGFloat)findAngleInDegreesFromThisPoint:(CGPoint)point1 toThisPoint:(CGPoint)point2;
-(CGFloat)getSextantChangeFromThisAngle:(CGFloat)angle1 toThisAngle:(CGFloat)angle2;

@end
