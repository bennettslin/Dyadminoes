//
//  NSObject+Helper.h
//  Dyadminoes
//
//  Created by Bennett Lin on 2/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Dyadmino;

// constants that differ between iPhone and iPad
//------------------------------------------------------------------------------

  // iPad constants are iPhone constants times 1.5
#define kIsIPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

  // dyadmino size constants
  // one constant rules them all (literally, haha)
#define kDyadminoFaceRadius (kIsIPhone ? 21.75f : 32.625f) // for now, perfectly reflects image size

  // view constants
#define kTopBarHeight (kIsIPhone ? 80.f : 120.f)
#define kRackHeight (kIsIPhone ? 108.f : 162.f)

  // label constants
#define kLabelYPosition (kIsIPhone ? 5.f : 7.5f)
#define kButtonWidth (kIsIPhone ? 45.f : 60.f)
#define kButtonYPosition (kIsIPhone ? 20.f : 30.f)

  // animation constants
#define kConstantSpeed (kIsIPhone ? 0.002f : 0.0013333f)

//------------------------------------------------------------------------------

  // view controller constants
#define kViewControllerSpeed 0.2f
#define kCornerRadius 25.f

  // dyadmino size constants
#define kDyadminoFaceDiameter (kDyadminoFaceRadius * 2)
#define kDyadminoFaceWideRadius (kDyadminoFaceRadius * kTwoOverSquareRootOfThree)
#define kDyadminoFaceWideDiameter (kDyadminoFaceWideRadius * 3 / 2)

  // view constants
#define kBoardCoverAlpha 0.4f

  // label constants (maybe temp)
#define kButtonSize CGSizeMake(kButtonWidth, kButtonWidth * 2 / 3)

  // animation constants
#define kRotateWait 0.05f
#define kConstantTime 0.15f
#define kAnimateHoverTime 0.4f
#define kDoubleTapTime 0.25f

  // dyadmino state constants
#define kDyadminoResizedFactor 1.17f
#define kDyadminoColorBlendFactor 0.2f

  // math constants
#define kSquareRootOfThree 1.73205081f
#define kTwoOverSquareRootOfThree 1.15470054f

  // game logic constants
#define kNumDyadminoesInRack 6
#define kPileCount 66

  // distance constants
#define kAngleForSnapToPivot 0.1f
#define kDistanceForTouchingHoveringDyadmino (kDyadminoFaceRadius * kDyadminoResizedFactor) // was 32.f
#define kDistanceForTouchingRestingDyadmino (kDyadminoFaceRadius * 0.8f) // was 25.f
#define kMinDistanceForPivot kDistanceForTouchingHoveringDyadmino
#define kMaxDistanceForPivot (kDyadminoFaceRadius * 3.5f)
#define kPivotGuideAlpha 0.7f
#define kGapForHighlight (kRackHeight / 3.6f)

  //----------------------------------------------------------------------------

  // z positions
  // children of scene
#define kZPositionBoardCoverHidden 25.f
#define kZPositionBoard 50.f
#define kZPositionBoardCover 100.f
#define kZPositionSwapField 110.f

#define kZPositionTopBar 120.f
#define kZPositionRackField 130.f

  // children of board
#define kZPositionBoardCell 10.f
#define kZPositionBoardRestingDyadmino 20.f
#define kZPositionPivotGuide 450.f
#define kZPositionHoveredDyadmino 500.f

  // children of top bar
#define kZPositionTopBarButton 10.f
#define kZPositionTopBarLabel 20.f
#define kZPositionLogMessage 30.f

  // children of rack
#define kZPositionRackMovedDyadmino 10.f
#define kZPositionRackRestingDyadmino 20.f

  // data key constants
#define kMatchesKey @"myMatches"
#define kDyadminoIDKey @"myID"

  //----------------------------------------------------------------------------

  // colours

#define kHighlightedDyadminoYellow [SKColor yellowColor]
#define kPlayedDyadminoBlue [SKColor colorWithRed:.4f green:.35f blue:1.f alpha:1.f]
#define kEnemyDyadminoRed [SKColor colorWithRed:1.f green:.3f blue:.3f alpha:1.f]

#define kDarkBlue [SKColor colorWithRed:.29f green:.4f blue:.63f alpha:1.f]
#define kSkyBlue [SKColor colorWithRed:.7f green:.8f blue:.9f alpha:1.f]
#define kFieldPurple [SKColor colorWithRed:.3f green:.2f blue:.4f alpha:1.f]
#define kSolidBlue [SKColor colorWithRed:.15f green:.19f blue:.55f alpha:1.f]
#define kGold [SKColor colorWithRed:.64f green:.57f blue:.38f alpha:1.f]
#define kTestRed [SKColor colorWithRed:1.f green:.7f blue:.7f alpha:1.f]
#define kDarkGreen [SKColor colorWithRed:0.f green:.6f blue:.2f alpha:1.f]

#define kPivotRed [SKColor colorWithRed:1.f green:.8f blue:.8f alpha:1.f]
#define kVanilla [SKColor colorWithRed:1.f green:1.f blue:.92f alpha:1.f]
#define kWhite [SKColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f]
#define kYellow [SKColor colorWithRed:1.f green:0.96f blue:.62f alpha:1.f]
#define kCyanBlue [SKColor colorWithRed:.62f green:.96f blue:1.f alpha:1.f]

  //----------------------------------------------------------------------------

typedef struct HexCoord {
  NSInteger x;
  NSInteger y;
} HexCoord;

  // this might be unnecessary
//typedef enum dyadminoLocation {
//  kBoardDyadmino,
//  kRackDyadmino,
//  kPileDyadmino
//} DyadminoLocation;

typedef enum dyadminoOrientation {
  kPC1atTwelveOClock,
  kPC1atTwoOClock,
  kPC1atFourOClock,
  kPC1atSixOClock,
  kPC1atEightOClock,
  kPC1atTenOClock
} DyadminoOrientation;

//typedef struct PersistDyadmino {
//  HexCoord myCoord;
//  int dyadminoID;
//  DyadminoLocation dyadminoLocation;
//  DyadminoOrientation dyadminoOrient;
//} PersistDyadmino;

typedef enum gameRules {
  kGameRulesTonal,
  kGameRulesPostTonal
} GameRules;

typedef enum gameType {
  kSelfGame,
  kPnPGame,
  kGCGame
} GameType;

typedef enum gameSkill {
  kBeginner,
  kIntermediate,
  kExpert
} GameSkill;

//typedef enum mainPageButtonType {
//  kSoloGameButton,
//  kPassNPlayButton,
//  kGameCenterMatchButton,
//  kHelpButton,
//  kStoreButton,
//  kLeaderboardButton,
//  kOptionsButton,
//  kAboutButton
//} MainPageButtonType;

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
-(NSUInteger)randomIntegerUpTo:(NSUInteger)high;
-(CGFloat)randomFloatUpTo:(CGFloat)high;
-(CGFloat)getDistanceFromThisPoint:(CGPoint)point1 toThisPoint:(CGPoint)point2;
-(CGPoint)addToThisPoint:(CGPoint)point1 thisPoint:(CGPoint)point2;
-(CGPoint)subtractFromThisPoint:(CGPoint)point1 thisPoint:(CGPoint)point2;
-(CGFloat)findAngleInDegreesFromThisPoint:(CGPoint)point1 toThisPoint:(CGPoint)point2;
-(CGFloat)getChangeFromThisAngle:(CGFloat)angle1 toThisAngle:(CGFloat)angle2;
-(CGFloat)getRadiansFromDegree:(CGFloat)degree;

  // struct stuff
-(HexCoord)hexCoordFromX:(NSInteger)x andY:(NSInteger)y;

  // date stuff
-(NSString *)returnGameEndedDateStringFromDate:(NSDate *)date;
-(NSString *)returnLastPlayedStringFromDate:(NSDate *)date;

  // view stuff
-(void)addGradientToView:(UIView *)thisView WithColour:(UIColor *)colour andUpsideDown:(BOOL)upsideDown;

@end
