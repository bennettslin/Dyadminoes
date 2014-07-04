//
//  NSObject+Helper.h
//  Dyadminoes
//
//  Created by Bennett Lin on 2/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Dyadmino;

  // temporary sounds
#define kSoundPop @"hitCatLady.wav"
#define kSoundClick @"Click2-Sebastian-759472264.wav"
#define kSoundRing @"Electronic_Chime-KevanGC-495939803.wav"
#define kSoundSwoosh @"Slide_Closed_SoundBible_com_1521580537.wav"

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
#define kZoomResizeFactor 0.5f

  // label constants (maybe temp)
#define kButtonSize CGSizeMake(kButtonWidth, kButtonWidth)

  // animation constants
#define kRotateWait 0.05f
#define kConstantTime 0.15f
#define kAnimateHoverTime 0.775f
#define kDoubleTapTime 0.225f

  // dyadmino state constants
#define kDyadminoHoverResizeFactor 1.17f
#define kDyadminoColorBlendFactor 0.2f

  // math constants
#define kSquareRootOfThree 1.73205081f
#define kTwoOverSquareRootOfThree 1.15470054f

  // game logic constants
#define kNumDyadminoesInRack 6
#define kPileCount 66

  // distance constants
#define kAngleForSnapToPivot 0.1f
#define kDistanceAfterCannotRotate (kDyadminoFaceRadius * 0.25f)
#define kDistanceForTouchingFace (kDyadminoFaceRadius * 0.7f)
#define kDistanceForTouchingHoveringDyadmino (kDyadminoFaceRadius * kDyadminoHoverResizeFactor) // was 32.f
#define kDistanceForTouchingRestingDyadmino (kDyadminoFaceRadius * 0.8f) // was 25.f
#define kDistanceToDoubleTap 44.f
#define kMinDistanceForPivot kDistanceForTouchingHoveringDyadmino
#define kMaxDistanceForPivot (kDyadminoFaceRadius * 3.5f)
#define kPivotGuideAlpha 0.9f
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
#define kZPositionLogMessage 25.f

  // children of rack
#define kZPositionRackMovedDyadmino 10.f
#define kZPositionRackRestingDyadmino 20.f
#define kZPositionDyadminoFace 5.f

  // replay fields
#define kZPositionReplayTop 150.f
#define kZPositionReplayBottom 160.f

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
#define kBarBrown [SKColor colorWithRed:0.3f green:0.15f blue:0.1f alpha:1.f]
#define kPianoBlack [SKColor colorWithRed:0.1f green:0.05f blue:0.f alpha:1.f]

#define kReplayTopColour [SKColor colorWithRed:0.9f green:0.15f blue:0.1f alpha:1.f]
#define kReplayBottomColour [SKColor colorWithRed:0.9f green:0.15f blue:0.1f alpha:1.f]

#define kPivotOrange [SKColor colorWithRed:0.9f green:.8f blue:.6f alpha:1.f]
#define kPivotRed [SKColor colorWithRed:1.f green:.8f blue:.8f alpha:1.f]
#define kVanilla [SKColor colorWithRed:1.f green:1.f blue:.92f alpha:1.f]
#define kWhite [SKColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f]
#define kYellow [SKColor colorWithRed:0.9f green:0.86f blue:.52f alpha:1.f]
#define kCyanBlue [SKColor colorWithRed:.62f green:.96f blue:1.f alpha:1.f]

  //----------------------------------------------------------------------------

typedef struct HexCoord {
  NSInteger x;
  NSInteger y;
} HexCoord;

typedef enum faceVector {
  kFaceVectorNone,
  kFaceVectorUpLeft,
  kFaceVectorVertical,
  kFaceVectorUpRight
} FaceVector;

typedef enum dyadminoOrientation {
  kPC1atTwelveOClock,
  kPC1atTwoOClock,
  kPC1atFourOClock,
  kPC1atSixOClock,
  kPC1atEightOClock,
  kPC1atTenOClock
} DyadminoOrientation;

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
  kNoError,
  kErrorStackedDyadminoes,
  kErrorLoneDyadmino
} PhysicalPlacementResult;

typedef enum chordType {
  kChordMinorTriad,
  kChordMajorTriad,
  kChordHalfDiminishedSeventh,
  kChordMinorSeventh,
  kChordDominantSeventh,
  kChordDiminishedTriad,
  kChordAugmentedTriad,
  kChordFullyDiminishedSeventh,
  kChordMinorMajorSeventh,
  kChordMajorSeventh,
  kChordAugmentedMajorSeventh,
  kChordItalianSixth,
  kChordFrenchSixth,
  kChordNoChord
} ChordType;

typedef enum swapCancelOrUndoButton {
  kSwapButton,
  kCancelButton,
  kUndoButton
} SwapCancelOrUndoButton;

typedef enum passPlayOrDoneButton {
  kPassButton,
  kPlayButton,
  kDoneButton
} PassPlayOrDoneButton;

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

  // chord label stuff
-(NSString *)stringForChord:(ChordType)chordType;
-(NSString *)stringForRoot:(NSUInteger)root andChordType:(ChordType)chordType;

@end
