//
//  NSObject+Helper.h
//  Dyadminoes
//
//  Created by Bennett Lin on 2/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Dyadmino;

  // temporary sound files
#define kSoundFilePop @"hitCatLady.wav"
#define kSoundFileClick @"Click2-Sebastian-759472264.wav"
#define kSoundFileRing @"Electronic_Chime-KevanGC-495939803.wav"
#define kSoundFileSwoosh @"Slide_Closed_SoundBible_com_1521580537.wav"

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
#define kButtonWidth (kTopBarHeight / 1.5)
#define kButtonSize CGSizeMake(kButtonWidth, kButtonWidth)
#define kLargeButtonWidth (kIsIPhone ? (kRackHeight / 2) : (kRackHeight / 1.6))
#define kLargeButtonSize CGSizeMake(kLargeButtonWidth, kLargeButtonWidth)

  // animation constants
#define kConstantSpeed (kIsIPhone ? 0.002f : 0.0013333f)

//------------------------------------------------------------------------------

  // view controller constants
#define kCornerRadius 25.f

  // table view cell constants
#define kCellRowHeight (kIsIPhone ? 90.f : 90.f)
#define kCellSeparatorBuffer (kCellRowHeight / 1.8f)
#define kCellHeight (kCellRowHeight + kCellSeparatorBuffer)

#define kCellWidth (kIsIPhone ? 320.f : 648.f)
#define kStaveXBuffer (kCellWidth / 36.f)
#define kStaveYHeight (kIsIPhone ? (kCellHeight / 9.f) : (kCellHeight / 10.f))

#define kCellClefWidth (kStaveYHeight * 3)
#define kCellKeySigWidth (kCellClefWidth * 1.5)
#define kCellEndBarlineWidth (kCellClefWidth / 3) // not used to measure barline, only to figure out playerSlotWidth
#define kCellPlayerSlotWidth (kIsIPhone ? (kCellWidth - (kStaveXBuffer * 2) - kCellClefWidth - kCellKeySigWidth - kCellEndBarlineWidth - kPlayerLabelWidthPadding) : ((kCellWidth - (kStaveXBuffer * 2) - kCellClefWidth - kCellKeySigWidth - kCellEndBarlineWidth) / 4))
#define kCellPlayerLabelWidth (kIsIPhone ? (kCellPlayerSlotWidth * 0.75) : (kCellPlayerSlotWidth - (kPlayerLabelWidthPadding / 2)))
#define kCellIPhoneScoreLabelWidth (kCellPlayerSlotWidth * 0.25)

#define kPlayerLabelHeightPadding (kCellRowHeight / 12)
#define kPlayerLabelWidthPadding (kCellWidth / 25)
#define kScoreLabelHeight (kCellRowHeight / 2.66666667)
#define kMaxNumPlayers 4

#define kChordMessageLabelHeight (kRackHeight / 3)

  // top bar constants
#define kTopBarYEdgeBuffer (kIsIPhone ? (kTopBarHeight / 5) : (kTopBarHeight / 10))

  // PnP bar constants
#define kPnPXEdgeBuffer (kIsIPhone ? (kRackHeight / 7.5) : (kRackHeight / 2))
#define kPnPPaddingBetweenLabelAndButton (kIsIPhone ? kPnPXEdgeBuffer : (kPnPXEdgeBuffer / 2))

  // replay bar constants
#define kReplayXEdgeBuffer (kTopBarHeight / 2) // for labels

  // dyadmino size constants
#define kDyadminoFaceDiameter (kDyadminoFaceRadius * 2)
#define kDyadminoFaceWideRadius (kDyadminoFaceRadius * kTwoOverSquareRootOfThree)
#define kDyadminoFaceWideDiameter (kDyadminoFaceWideRadius * 3 / 2)
#define kDyadminoFaceAverageWideDiameter (kDyadminoFaceWideRadius + (kDyadminoFaceRadius * kTwoOverSquareRootOfThree / 2))
#define kDyadminoFaceAverageWideRadius (kDyadminoFaceAverageWideDiameter / 2)

  // view constants
#define kBoardCoverAlpha 0.4f
#define kZoomResizeFactor 0.5f

  // scene view constants
#define kSceneMessageLabelFontSize 30.f
#define kSceneLabelFontSize 24.f

  // topBar total is: buffer + playerLabel + scoreLabel + five buttons + pileTurnLabels + buffer
#define kTopBarPaddingBetweenStuff (kLargeButtonWidth / 4)
#define kTopBarPlayerLabelHeight (kTopBarHeight / 5)
#define kTopBarScoreLabelWidth (kTopBarPlayerLabelWidth / 3)
#define kTopBarTurnPileLabelsWidth (kIsIPhone ? kTopBarHeight : (kTopBarHeight / 2))
#define kTopBarXEdgeBuffer (kTopBarHeight / 6)

  // label constants (maybe temp)
#define kFontModern @"FilmotypeModern"
#define kFontHarmony @"FilmotypeHarmony"
#define kFontSonata @"Sonata"

  // pinch gesture constants
  // FIXME: might not need the iPhone constants
#define kLowPinchScale (kIsIPhone ? 0.7f : 0.85f)
#define kHighPinchScale (kIsIPhone ? 1.3f : 1.15f)

  // animation constants
#define kConstantTime 0.175f // was 0.15f
#define kAnimateHoverTime 0.775f
#define kDoubleTapTime 0.225f
#define kWaitTimeForRackDyadminoPopulate 0.05f

  // define action constants
#define kActionShowRecentlyPlayed @"recentlyPlayed"

#define kScoreScaleFactor 2.f
#define kScoreScaleInTime 0.1f
#define kScoreScaleOutTime 0.25f

  // dyadmino state constants
#define kDyadminoHoverResizeFactor 1.17f
#define kDyadminoColorBlendFactor 0.3f
#define kDyadminoAnimatedColorBlendFactor 0.35f

  // math constants
#define kSquareRootOfThree 1.73205081f
#define kTwoOverSquareRootOfThree 1.15470054f

  // game logic constants
#define kMaxNumPlayers 4
#define kNumDyadminoesInRack 6
#define kPileCount 66

  // distance constants
#define kAngleForSnapToPivot 0.1f
#define kDistanceAfterCannotRotate (kDyadminoFaceRadius * 0.25f)
#define kDistanceForTouchingFace (kDyadminoFaceRadius * 0.7f)
#define kDistanceForTouchingHoveringDyadmino (kDyadminoFaceRadius * kDyadminoHoverResizeFactor) // was 32.f
#define kDistanceForTouchingRestingDyadmino (kDyadminoFaceRadius * 0.8f) // was 25.f
#define kDistanceToDoubleTap 22.f // tweak as necessary
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
#define kZPositionBackgroundNode 5.f
#define kZPositionBoardCell 10.f
#define kZPositionBoardRestingDyadmino 20.f
#define kZPositionBoardReplayAnimatedDyadmino 30.f
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

  // legal placement error keys
#define kExcessNotes @"excessNotes"
#define kDoublePCs @"doublePCs"
#define kIllegalSonority @"illegalSonority"

  //----------------------------------------------------------------------------

  // colours
//#define kBackgroundBoardColour [UIColor colorWithRed:0.2f green:0.15f blue:0.1f alpha:1.f]
#define kBackgroundBoardColour [UIColor colorWithRed:0.25f green:0.2f blue:0.15f alpha:1.f]

#define kMainLighterYellow [UIColor colorWithRed:0.95f green:0.95f blue:0.85f alpha:1.f]
#define kMainDarkerYellow [UIColor colorWithRed:0.85f green:0.85f blue:0.75f alpha:1.f]
#define kMainSelectedYellow [UIColor colorWithRed:.97f green:.97f blue:.9f alpha:1.f]

#define kResignedGray [UIColor colorWithRed:0.8f green:0.77f blue:0.75f alpha:1.f]

#define kScoreNormalBrown [UIColor colorWithRed:0.62f green:0.42f blue:0.1f alpha:1.f]
#define kScoreWonGold [UIColor colorWithRed:0.82f green:0.62f blue:0.f alpha:1.f]
#define kScoreLostGray [UIColor colorWithRed:0.7f green:0.67f blue:0.65f alpha:1.f]

#define kMainBarsColour [UIColor colorWithRed:0.37f green:0.24f blue:0.21f alpha:1.f]
#define kMainButtonsColour [UIColor colorWithRed:.64f green:.57f blue:.38f alpha:1.f]
#define kEndedMatchCellLightColour [UIColor colorWithRed:0.94f green:0.85f blue:0.71f alpha:1.f]
#define kEndedMatchCellDarkColour [UIColor colorWithRed:0.83f green:0.74f blue:0.6f alpha:1.f]
#define kEndedMatchCellSelectedColour [UIColor colorWithRed:0.96f green:.88f blue:0.76f alpha:1.f]

#define kStaveColour [UIColor colorWithRed:0.7f green:0.58f blue:0.5f alpha:1.f]
#define kStaveEndedGameColour [UIColor colorWithRed:0.62f green:0.52f blue:0.46f alpha:1.f]

#define kScrollingBackgroundFade [UIColor colorWithRed:0.33f green:.30f blue:0.24f alpha:1.f]

#define kNeutralYellow [UIColor yellowColor]
#define kPlayerBlue [UIColor colorWithRed:.04f green:.52f blue:.91f alpha:1.f]
#define kPlayerRed [UIColor colorWithRed:.81f green:.31f blue:.83f alpha:1.f]
#define kPlayerGreen [UIColor colorWithRed:0.f green:.65f blue:.19f alpha:1.f]
#define kPlayerOrange [UIColor colorWithRed:0.85f green:.50f blue:.18f alpha:1.f]

#define kDarkBlue [SKColor colorWithRed:.29f green:.4f blue:.63f alpha:1.f]
#define kSkyBlue [SKColor colorWithRed:.7f green:.8f blue:.9f alpha:1.f]
#define kFieldPurple [SKColor colorWithRed:.3f green:.2f blue:.4f alpha:1.f]
#define kSolidBlue [SKColor colorWithRed:.15f green:.19f blue:.55f alpha:1.f]
//#define kGold 
#define kTestRed [SKColor colorWithRed:1.f green:.7f blue:.7f alpha:1.f]
#define kDarkGreen [SKColor colorWithRed:0.f green:.6f blue:.2f alpha:1.f]
#define kBarBrown [SKColor colorWithRed:0.3f green:0.15f blue:0.1f alpha:1.f]
#define kPianoBlack [SKColor colorWithRed:0.1f green:0.05f blue:0.f alpha:1.f]

#define kReplayTopColour [SKColor colorWithRed:0.1f green:0.15f blue:0.1f alpha:1.f]
#define kReplayBottomColour [SKColor colorWithRed:0.1f green:0.15f blue:0.1f alpha:1.f]

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

typedef enum musicSymbol {
  kSymbolTrebleClef,
  kSymbolAltoClef,
  kSymbolTenorClef,
  kSymbolBassClef,
  kSymbolFermata,
  kSymbolEndBarline,
  kSymbolQuarterRest,
  kSymbolHalfRest,
  kSymbolSharp,
  kSymbolFlat,
  kSymbolBullet
} MusicSymbol;

typedef enum sceneVCLabel {
  kTopBarTurnLabel,
  kTopBarPileCountLabel,
  kLastTurnLabel,
  kPnPWaitingLabel,
  kReplayTurnLabel,
} SceneVCLabel;

typedef enum notificationName {
  kNotificationDeviceOrientation,
  kNotificationToggleBarOrField,
  kNotificationBoardZoom,
  kNotificationPopIntoNode,
  kNotificationPivotClick,
  kNotificationEaseIntoNode,
  kNotificationRackExchangeClick,
  kNotificationButtonSunkIn,
  kNotificationButtonLifted,
  kNotificationTogglePCs,
  kNotificationOptionsMusic
} NotificationName;

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
  kGCFriendGame,
  kGCRandomGame
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

typedef enum placeStatus {
  kInPile,
  kInRack,
  kOnBoard
} PlaceStatus;

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
  kChordNoChord,
  kChordLegalMonad,
  kChordLegalDyad,
  kChordLegalIncompleteSeventh,
  kChordIllegalChord
} ChordType;

typedef struct Chord {
  ChordType chordType;
  NSInteger root;
} Chord;

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

typedef enum chordMessageSign {
  kChordMessageGood,
  kChordMessageNeutral,
  kChordMessageBad
} ChordMessageSign;

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
-(Chord)chordFromRoot:(NSInteger)root andChordType:(ChordType)chordType;

  // date stuff
-(NSString *)returnGameEndedDateStringFromDate:(NSDate *)date;
-(NSString *)returnLastPlayedStringFromDate:(NSDate *)date andTurn:(NSUInteger)turn;

  // view stuff
-(void)addGradientToView:(UIView *)thisView WithColour:(UIColor *)colour andUpsideDown:(BOOL)upsideDown;
-(void)addShadowToView:(UIView *)thisView upsideDown:(BOOL)upsideDown;

-(NSString *)stringForMusicSymbol:(MusicSymbol)symbol;
-(MusicSymbol)musicSymbolForMatchType:(GameType)type;

@end
