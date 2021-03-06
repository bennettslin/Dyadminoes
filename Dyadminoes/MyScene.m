//
//  MyScene.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/20/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "NSObject+Helper.h"
#import "MyScene.h"
#import "SceneViewController.h"
#import "SceneEngine.h"
#import "Dyadmino.h"
#import "Face.h"
#import "Player.h"
#import "Rack.h"
#import "Board.h"
#import "TopBar.h"
#import "PnPBar.h"
#import "ReplayBar.h"
#import "Cell.h"
#import "Button.h"
#import "Match.h"
#import "DataDyadmino.h"
#import "SoundEngine.h"
#import "SonorityLogic.h"
#import "DataCell.h" // for debugging purposes

#define kTopBarIn @"topBarIn"
#define kTopBarOut @"topBarOut"
#define kRackIn @"rackIn"
#define kRackOut @"rackOut"
#define kPnPBarIn @"pnpBarIn"
#define kPnPBarOut @"pnpBarOut"
#define kResetFadeOut @"resetFadeOut"
#define kResetFadeIn @"resetFadeIn"

@interface MyScene () <BarDelegate, FieldNodeDelegate, DyadminoDelegate, BoardDelegate, UIActionSheetDelegate, UIAlertViewDelegate, MatchDelegate>

  // the dyadminoes that the player sees
@property (strong, nonatomic) NSArray *playerRackDyadminoes;
@property (strong, nonatomic) NSSet *boardDyadminoes; // contains holding container dyadminoes
@property (strong, nonatomic) NSSet *legalChordsForHoveringBoardDyadmino; // instantiated and nillified along with hovering dyadmino
@property (strong, nonatomic) NSMutableSet *swapContainer; // whether this container exists is used to determine swap mode

@property (strong, nonatomic) NSMutableSet *replayDyadminoesNotMovedThisTurn;

@property (strong, nonatomic) NSSet *legalSonoritiesThisTurn;

@end

@implementation MyScene {
  
  Player *_myPlayer;
  
    // sprites and nodes
  Rack *_rackField;
  Rack *_swapField;
  Board *_boardField;

  TopBar *_topBar;
  PnPBar *_pnpBar;
  ReplayBar *_replayTop;
  ReplayBar *_replayBottom;

    // touches
  UITouch *_currentTouch;
  CGPoint _beganTouchLocation;
  CGPoint _currentTouchLocation;
  CGPoint _previousTouchLocation; // only used for selectFace, might actually not be needed
  CGPoint _endTouchLocationToMeasureDoubleTap;
  CGPoint _touchOffsetVector;
  
    // bools and modes
  BOOL _pnpBarUp;
  BOOL _replayMode;
  BOOL _lockMode;
  BOOL _boardDyadminoMovedShowResetButton;
  
//  BOOL _dyadminoesStationary;
  BOOL _dyadminoesAreLocked;
  
  BOOL _rackExchangeInProgress;
  BOOL _fieldActionInProgress;
  BOOL _boardToBeMovedOrBeingMoved;
  BOOL _boardBeingCorrectedWithinBounds;
  
  BOOL _currentTouchIsDyadmino;
  BOOL _previousTouchWasDyadmino;
  
  BOOL _canDoubleTapForBoardZoom;
  BOOL _canDoubleTapForDyadminoFlip;
  BOOL _hoveringDyadminoStaysFixedToBoard;
  BOOL _boardJustShiftedNotCorrected;
  BOOL _boardZoomedOut;
  BOOL _buttonsUpdatedThisTouch;
  
  BOOL _actionSheetShown;
  
  BOOL _zoomChangedCellsAlpha; // only used for pinch zoom
  
  HexCoord _uponTouchDyadminoHexCoord;
  DyadminoOrientation _uponTouchDyadminoOrientation;
  
    // pointers
  Dyadmino *_touchedDyadmino;
  Dyadmino *_recentRackDyadmino;
  Dyadmino *_hoveringDyadmino;
  BOOL _recentRackDyadminoFormsLegalChord;
  
  SKNode *_touchNode;
  SKSpriteNode *_soundedDyadminoFace;

    // hover and pivot properties
  BOOL _pivotInProgress;
  CFTimeInterval _hoverTime;
  NSUInteger _hoveringDyadminoBeingCorrected;
  NSUInteger _hoveringDyadminoFinishedCorrecting;
  CFTimeInterval _doubleTapTime;
  
    // test
  BOOL _debugMode;
  
    // pivot variables
  CGFloat _orientationOffset;
  CGFloat _originalDyadminoOrientation;
  
    // first time pivot values
  CGFloat _touchPivotOffsetAngle;
  
  NSUInteger _dyadminoFluxCounter;
  
  NSUInteger _pointsForExtending;
}

#pragma mark - set up methods

-(id)initWithSize:(CGSize)size {
  
  if (self = [super initWithSize:size]) {
    self.backgroundColor = kBackgroundBoardColour;
    self.name = @"scene";
    self.mySoundEngine = [SoundEngine sharedSoundEngine];
    
    self.swapContainer = nil;
    _dyadminoesAreLocked = NO;

    if (![self layoutRackField]) {
      NSLog(@"Rack field was not laid out properly.");
      abort();
    }
    
    if (![self layoutBoard]) {
      NSLog(@"Board was not laid out properly.");
      abort();
    }
    
    if (![self layoutSwapField]) {
      NSLog(@"Swap field was not laid out properly.");
      abort();
    }
    
    if (![self layoutReplayBars]) {
      NSLog(@"Replay bars were not laid out properly.");
      abort();
    }
    
    if (![self layoutPnPBar]) {
      NSLog(@"PnP bar was not laid out properly.");
      abort();
    }
    
    if (![self layoutTopBar]) {
      NSLog(@"Top bar was not laid out properly.");
      abort();
    }
  }
  return self;
}

-(BOOL)loadAfterNewMatchRetrievedForReset:(BOOL)forReset {
  
  _topBar.position = CGPointMake(0, self.frame.size.height - kTopBarHeight);
  
   // it should not happen that previous match was left
   // while pnpBar was still moving, but just in case
  
  [_pnpBar removeAllActions];
    
  if ([self.myMatch returnType] == kPnPGame && ![self.myMatch returnGameHasEnded] && !forReset) {
    _pnpBarUp = YES;
    _pnpBar.position = CGPointZero;
    _pnpBar.hidden = NO;
    
    [self.myDelegate barOrRackLabel:kPnPWaitingLabel show:_pnpBarUp toFade:NO withText:[self updatePnPLabelForNewPlayer] andColour:[self.myMatch colourForPlayer:[self.myMatch returnCurrentPlayer] forLabel:YES light:NO]];
    
    _rackField.position = CGPointMake(0, -kRackHeight);
    _rackField.hidden = YES;
    
  } else {
    _pnpBarUp = NO;
    _pnpBar.position = CGPointMake(0, -kRackHeight);
    _pnpBar.hidden = YES;
    
    _rackField.position = CGPointZero;
    _rackField.hidden = NO;
  }
  
  _swapField.position = CGPointMake(self.frame.size.width, kRackHeight);
  
  _boardZoomedOut = NO;
  self.myMatch.delegate = self;
  [self prepareForNewTurn];
  return YES;
}

-(void)prepareForNewTurn {
    // called both when scene is loaded, and when player finalises turn in PnP mode
  
  _boardDyadminoMovedShowResetButton = NO;
  _zoomChangedCellsAlpha = NO;
  _rackExchangeInProgress = NO;
  _hoveringDyadminoBeingCorrected = 0;
  _hoveringDyadminoFinishedCorrecting = 1;
  _buttonsUpdatedThisTouch = NO;
  _currentTouch = nil;
  _replayMode = NO;
  _fieldActionInProgress = NO;
  _boardToBeMovedOrBeingMoved = NO;
  _boardBeingCorrectedWithinBounds = NO;
  _currentTouchIsDyadmino = NO;
  _previousTouchWasDyadmino = NO;
  _canDoubleTapForBoardZoom = NO;
  _canDoubleTapForDyadminoFlip = NO;
  _hoveringDyadminoStaysFixedToBoard = NO;
  _boardJustShiftedNotCorrected = NO;
  _uponTouchDyadminoHexCoord = [self hexCoordFromX:NSIntegerMax andY:NSIntegerMax];
  _soundedDyadminoFace = nil;
  _touchedDyadmino = nil;
  _recentRackDyadmino = nil;
  _recentRackDyadminoFormsLegalChord = NO;
  [_hoveringDyadmino animateWiggleForHover:NO];
  _hoveringDyadmino = nil;
  self.legalChordsForHoveringBoardDyadmino = nil;
  _pivotInProgress = NO;
  _actionSheetShown = NO;
  _endTouchLocationToMeasureDoubleTap = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
  _dyadminoFluxCounter = 0;
  _pointsForExtending = 0;
  
  if (_lockMode) {
    [self handleDoubleTapForLockModeWithSound:NO];
  }
  
  _myPlayer = [self.myMatch returnCurrentPlayer];
  NSArray *turns = self.myMatch.turns;
  self.myMatch.replayTurn = turns.count;
}

-(void)didMoveToView:(SKView *)view {
  
    // ensures that match's board dyadminoes are reset
  [self.myMatch last];
  
  if (![self populateBoardSet]) {
    NSLog(@"Board set was not populated properly.");
    abort();
  }
  
    // this only needs the board dyadminoes to determine the board's cells ranges
    // this populates the board cells
  [self repositionBoardField];
  
  [_boardField establishHexOriginForCenteringBoardBasedOnBoardDyadminoes:self.boardDyadminoes];
  
  if (![self populateBoardWithDyadminoesAnimated:NO andSound:NO]) {
    NSLog(@"Dyadminoes were not placed on board properly.");
    abort();
  }
  
    // kludge way to remove activity indicator
  SKAction *wait = [SKAction waitForDuration:1.f];
  
  __weak typeof(self) weakSelf = self;
  SKAction *removeActivityIndicator = [SKAction runBlock:^{
    [weakSelf.myDelegate stopActivityIndicator];
  }];
  
  SKAction *sequence = [SKAction sequence:@[wait, removeActivityIndicator]];
  [self runAction:sequence];
  
  [self.myDelegate setUnchangingPlayerLabelProperties];
  [self updateTopBarLabelsFinalTurn:NO animated:NO];
  [self updateTopBarButtons];
  
    // cell alphas are visible by default, hide if PnP mode and not for reset
  NSLog(@"toggle dyadminoes locked in did move to view");
  [self toggleDyadminoesLockedAnimated:NO];
  
    // don't call just yet if it's a PnP game, unless it's just for reset
  if ([self.myMatch returnType] != kPnPGame) {
    [self afterNewPlayerReady];
  }
}

-(void)afterNewPlayerReady {
  
    // called both when scene is loaded, and when new player is ready in PnP mode
  [_boardField updatePivotGuidesForNewPlayer];

  if (![self populateRackArray]) {
    NSLog(@"Rack array was not populated properly.");
    abort();
  }
  
  if (![self refreshRackFieldAndDyadminoesFromUndo:NO withAnimation:NO]) {
    NSLog(@"Rack field dyadminoes not refreshed properly.");
    abort();
  }

  [self animateRecentlyPlayedDyadminoes];
  
  if (![self showTurnInfoOrGameResultsForReplay:NO]) {
    NSLog(@"Turn info or game results for replay not shown properly.");
    abort();
  }
}

#pragma mark - wrap up methods

-(void)willMoveFromView:(SKView *)view {
  [self willMoveFromViewForReset:NO];
}

-(void)willMoveFromViewForReset:(BOOL)forReset {
  if (_debugMode) {
    _debugMode = NO;
    [self toggleDebugMode];
  }
  
    // establish that cell and dyadmino alphas are normal
    // important because next match might have different dyadminoes
  [self toggleDyadminoesLockedAnimated:NO];
  
  self.swapContainer = nil;
  [self toggleSwapFieldWithAnimation:NO];
  
  self.replayDyadminoesNotMovedThisTurn = nil;
  self.boardDyadminoes = nil;
  
  for (SKNode *node in _boardField.children) {
    if ([node isKindOfClass:[Dyadmino class]]) {
      Dyadmino *dyadmino = (Dyadmino *)node;
      [self updateCellsForRemovedDyadmino:dyadmino];
      [dyadmino resetForNewMatch];
    }
  }
  
  [_boardField resetForNewMatch];
  
  if (!forReset) {
    [self prepareRackForNextPlayer];
  }
}

-(void)prepareRackForNextPlayer {
    // called both when leaving scene, and when player finalises turn in PnP mode
  self.playerRackDyadminoes = nil;
  for (Dyadmino *dyadmino in _rackField.children) {
    if ([dyadmino isKindOfClass:[Dyadmino class]]) {
      [dyadmino resetForNewMatch];
    }
  }
}

-(void)goBackToMainViewController {
  
  [self updateOrderOfDataDyadsThisTurnToReflectRackOrder];
  [self postSoundNotification:kNotificationToggleBarOrField];
  
//  _dyadminoesStationary = YES;
  
  if (_pnpBarUp) {
    _pnpBarUp = NO;
    [self togglePnPBarSyncWithRack:NO animated:YES];
  } else {
    [self toggleRackGoOut:YES completion:nil];
  }
  
  __weak typeof(self) weakSelf = self;
  void (^completion)(void) = ^void(void) {
    [weakSelf.myDelegate backToMainMenu];
  };
  
  [self toggleTopBarGoOut:YES completion:completion];
}

#pragma mark - sound methods

-(void)postSoundNotification:(NotificationName)whichNotification {
  
  [[SoundEngine sharedSoundEngine] playSoundNotificationName:whichNotification];
}

-(void)soundDyadmino:(Dyadmino *)dyadmino withFace:(Face *)face {
  
    // just sound the face
  if (face) {
    NSInteger pc;
    if (face == dyadmino.pc1Sprite) {
      pc = dyadmino.pc1;
    } else if (face == dyadmino.pc2Sprite) {
      pc = dyadmino.pc2;
    } else {
      pc = -1;
    }

    HexCoord hexCoord;
    BOOL dyadminoRightsideUp = dyadmino.orientation <= kPC1atTwoOClock || dyadmino.orientation >= kPC1atTenOClock;
    
    if (pc == dyadmino.pc1) {
      hexCoord = dyadminoRightsideUp ?
          [self retrieveTopHexCoordForBottomHexCoord:dyadmino.tempHexCoord andOrientation:dyadmino.orientation] : dyadmino.tempHexCoord;
      
    } else {
      hexCoord = dyadminoRightsideUp ?
          dyadmino.tempHexCoord : [self retrieveTopHexCoordForBottomHexCoord:dyadmino.tempHexCoord andOrientation:dyadmino.orientation];
    }

    [self.mySoundEngine handleMusicNote:pc withHexCoord:hexCoord];
    
      // no face means sound whole dyadmino
  } else {
    [self.mySoundEngine handleMusicNote1:dyadmino.pc1 andNote2:dyadmino.pc2 withOrientation:dyadmino.orientation];
  }
}

#pragma mark - layout methods

-(BOOL)populateRackArray {
    // keep player's order and orientation of dyadminoes until turn is submitted
  
  NSMutableArray *tempDyadminoArray = [NSMutableArray new];
  NSArray *dataDyadsThisTurn = [self.myMatch dataDyadsInIndexContainer:_myPlayer.rackIndexes];
  
  for (DataDyadmino *dataDyad in dataDyadsThisTurn) {
    
      // only add if it's not in the holding container
      // if it is, then don't add because holding container is added to board set instead
    if (![self.myMatch holdingsContainsDataDyadmino:dataDyad]) {
      Dyadmino *dyadmino = [self getDyadminoFromDataDyadmino:dataDyad];
      dyadmino.delegate = self;
      
      dyadmino.orientation = [dataDyad returnMyOrientation];
      dyadmino.rackIndex = [dataDyad returnMyRackOrder];
        // not the best place to set tempReturnOrientation for dyadmino
      dyadmino.homeOrientation = dyadmino.orientation;
      
      [dyadmino selectAndPositionSpritesZRotation:0.f];
      [tempDyadminoArray addObject:dyadmino];
    }
  }
  
    [self updateOrderOfDataDyadsThisTurnToReflectRackOrder];
  
    // make sure dyadminoes are sorted
  NSSortDescriptor *sortByRackOrder = [[NSSortDescriptor alloc] initWithKey:@"rackIndex" ascending:YES];
  self.playerRackDyadminoes = [tempDyadminoArray sortedArrayUsingDescriptors:@[sortByRackOrder]];
  return (self.playerRackDyadminoes.count == [(NSArray *)_myPlayer.rackIndexes count] - [(NSArray *)self.myMatch.holdingIndexContainer count]);
}

-(BOOL)populateBoardSet {
  
    // board must enumerate over both board and holding container dyadminoes
  NSMutableSet *tempDataEnumerationSet = [NSMutableSet setWithSet:self.myMatch.board];
  [tempDataEnumerationSet addObjectsFromArray:[self.myMatch dataDyadsInIndexContainer:self.myMatch.holdingIndexContainer]];
  
  NSMutableSet *tempSet = [[NSMutableSet alloc] initWithCapacity:tempDataEnumerationSet.count];
  
  for (DataDyadmino *dataDyad in tempDataEnumerationSet) {
    Dyadmino *dyadmino = [self getDyadminoFromDataDyadmino:dataDyad];
    
    dyadmino.homeHexCoord = dataDyad.myHexCoord;
    dyadmino.tempHexCoord = dyadmino.homeHexCoord;
    dyadmino.rackIndex = -1; // signifies it's not in rack
    
    dyadmino.orientation = [dataDyad returnMyOrientation];
    dyadmino.homeOrientation = dyadmino.orientation;
    
    if (![tempSet containsObject:dyadmino]) {
      
      [dyadmino selectAndPositionSpritesZRotation:0.f];
      [tempSet addObject:dyadmino];
    }
  }
  self.boardDyadminoes = [NSSet setWithSet:tempSet];
  
  return (self.boardDyadminoes.count == self.myMatch.board.count + [(NSArray *)self.myMatch.holdingIndexContainer count]);
}

-(BOOL)layoutBoard {
  
  CGSize size = CGSizeMake(self.frame.size.width, self.frame.size.height - kTopBarHeight - kRackHeight);

  SKTexture *cellTexture = [[SceneEngine sharedSceneEngine] textureForTextureCell:kTextureCell];
  _boardField = [[Board alloc] initWithColor:[SKColor clearColor] andSize:size andCellTexture:cellTexture];
  _boardField.delegate = self;
  [self addChild:_boardField];
  return (_boardField.parent == self);
}

-(void)repositionBoardField {
    // home position is changed with board movement, but origin never changes
  
  CGFloat yPosition = self.frame.size.height - kTopBarHeight + kRackHeight;
  CGPoint homePosition = CGPointMake(self.frame.size.width * 0.5, yPosition * 0.5);
  [_boardField repositionBoardWithHomePosition:homePosition andOrigin:homePosition];
}

-(BOOL)populateBoardWithDyadminoesAnimated:(BOOL)animated andSound:(BOOL)sound {
  
  for (Dyadmino *dyadmino in self.boardDyadminoes) {
    dyadmino.delegate = self;
    
      //------------------------------------------------------------------------
    
    if (animated) {
      [self moveDyadminoHome:dyadmino andSound:sound];
      
    } else {
      dyadmino.position = [self homePositionForDyadmino:dyadmino];
      [dyadmino selectAndPositionSpritesZRotation:0.f];
      [dyadmino orientWithAnimation:animated];
      
        // layout is called once afterwards
      [self updateCellsForPlacedDyadmino:dyadmino];
    }

    if (!dyadmino.parent) {
      [_boardField addChild:dyadmino];
    }
    
    if (dyadmino.parent != _boardField) {
      return NO;
    }
  }
  
  if (!animated) {
      // layout is necessary again to dequeue cells
    [_boardField layoutAndColourBoardCellsAndSnapPointsOfDyadminoes:[self allBoardDyadminoesPlusRecentRackDyadmino] minusDyadmino:nil updateBounds:YES];
  }
  
  return YES;
}

-(BOOL)layoutSwapField {
    // initial instantiation of swap field sprite
  _swapField = [[Rack alloc] initWithColour:kScoreWonGold
                                    andSize:CGSizeMake(self.frame.size.width, kRackHeight)
                             andAnchorPoint:CGPointZero
                                andPosition:CGPointMake(self.frame.size.width, kRackHeight)
                               andZPosition:kZPositionSwapField];
  _swapField.name = @"swap";
  [self addChild:_swapField];
  
    // initially sets swap mode
  self.swapContainer = nil;
  _swapField.hidden = YES;
  
  return (_swapField.parent == self);
}

-(BOOL)layoutTopBar {
  
  _topBar = [[TopBar alloc] initWithColor:[UIColor yellowColor] // kBarBrown
                                  andSize:CGSizeMake(self.frame.size.width, kTopBarHeight)
                                   andTop:YES
                           andAnchorPoint:CGPointZero
                              andPosition:CGPointMake(0, self.frame.size.height - kTopBarHeight)
                             andZPosition:kZPositionTopBar];
  _topBar.name = @"topBar";
  _topBar.delegate = self;
  [_topBar populateWithTopBarButtons];
  [self addChild:_topBar];

  return (_topBar.parent == self);
}

-(BOOL)layoutPnPBar {
  
  _pnpBar = [[PnPBar alloc] initWithColor:[UIColor yellowColor]
                                  andSize:CGSizeMake(self.frame.size.width, kRackHeight)
                                   andTop:NO
                           andAnchorPoint:CGPointZero
                              andPosition:CGPointZero
                             andZPosition:kZPositionReplayBottom];
  _pnpBar.name = @"pnpBar";
  _pnpBar.delegate = self;
  [self addChild:_pnpBar];
  
  [_pnpBar populateWithPnPButtonsAndLabel];
  
  return (_pnpBar.parent == self);
}

-(BOOL)layoutReplayBars {
  
    // initial position is beyond screen
  _replayTop = [[ReplayBar alloc] initWithColor:kReplayTopColour andSize:CGSizeMake(self.frame.size.width, kTopBarHeight) andTop:YES andAnchorPoint:CGPointZero andPosition:CGPointMake(0, self.frame.size.height) andZPosition:kZPositionReplayTop];
  _replayTop.name = @"replayTop";
  [self addChild:_replayTop];
  
  _replayBottom = [[ReplayBar alloc] initWithColor:kReplayBottomColour andSize:CGSizeMake(self.frame.size.width, kRackHeight) andTop:NO andAnchorPoint:CGPointZero andPosition:CGPointMake(0, -kRackHeight) andZPosition:kZPositionReplayBottom];
  _replayBottom.name = @"replayBottom";
  _replayBottom.delegate = self;
  [self addChild:_replayBottom];

  [_replayBottom populateWithBottomReplayButtons];
  
  _replayMode = NO;
  _replayTop.hidden = YES;
  _replayBottom.hidden = YES;
  
  return (_replayTop.parent == self && _replayTop.parent == self);
}

-(BOOL)layoutRackField {
  
  _rackField = [[Rack alloc] initWithColour:kSolidBlue
                                    andSize:CGSizeMake(self.frame.size.width, kRackHeight)
                             andAnchorPoint:CGPointZero
                                andPosition:([self.myMatch returnType] == kPnPGame ? CGPointMake(0, -kRackHeight) : CGPointZero)
                               andZPosition:kZPositionRackField];
  _rackField.delegate = self;
  _rackField.name = @"rack";
  [self addChild:_rackField];
  return (_rackField.parent == self);
}

-(BOOL)refreshRackFieldAndDyadminoesFromUndo:(BOOL)undo withAnimation:(BOOL)animation {
  
    // match is still in play
  if (![self.myMatch returnGameHasEnded]) {

    for (Dyadmino *dyadmino in self.playerRackDyadminoes) {
      dyadmino.delegate = self;
    }
    
    [_rackField repositionDyadminoes:self.playerRackDyadminoes fromUndo:undo withAnimation:animation];
    
  } else {
    [_rackField repositionDyadminoes:self.playerRackDyadminoes fromUndo:undo withAnimation:animation];
  }
  
  return YES;
}

#pragma mark - touch gestures

-(void)handlePinchGestureWithScale:(CGFloat)scale andVelocity:(CGFloat)velocity andLocation:(CGPoint)location {
  
  if (_hoveringDyadmino) {
    [self moveDyadminoHome:_hoveringDyadmino andSound:YES];
  }
  
    // kludge way to fix issue with pinch cancelling touched dyadmino that has not yet been assigned as hovering dyadmino
  if (_touchedDyadmino) {
    Dyadmino *dyadmino = _touchedDyadmino;
    _touchedDyadmino = nil;
    [self moveDyadminoHome:dyadmino andSound:YES];
  }
  
    // sceneVC sends Y upside down
  CGPoint correctLocation = CGPointMake((_boardField.homePosition.x - location.x) / kZoomResizeFactor + _boardField.origin.x,
                                 (_boardField.homePosition.y - (self.size.height - location.y)) / kZoomResizeFactor + _boardField.origin.y);
  
  if ((scale < kLowPinchScale && !_boardZoomedOut) || (scale > kHighPinchScale && _boardZoomedOut)) {
    [self toggleBoardZoomWithTapCentering:YES andCenterLocation:correctLocation];
  }
}

-(BOOL)validatePinchLocation:(CGPoint)location {
  
    // sceneVC sends Y upside down
  CGFloat rightSideUpY = self.size.height - location.y;
  CGFloat bottomFloat = self.swapContainer ? kRackHeight * 2 : kRackHeight;
  return (rightSideUpY > bottomFloat && rightSideUpY < self.size.height - kTopBarHeight) ? YES : NO;
}

-(void)handleDoubleTapForLockModeWithSound:(BOOL)withSound {
  
    // UPDATE: double tap no longer zooms; instead, it toggles lock mode
    // board will center back to user's touch location once zoomed back in
  
  _lockMode = !_lockMode;
  if (withSound) {
    [self postSoundNotification:kNotificationTogglePCs];
  }
  
  [self toggleDyadminoesLockedAnimated:YES];
//  [self updateTopBarButtons];
}

#pragma mark - touch methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /// 1. first, make sure there's only one current touch

  _currentTouch ? [self endTouchFromTouches:nil] : nil;
  _currentTouch = [touches anyObject];

  if (_fieldActionInProgress) {
    return;
  }
  
    //--------------------------------------------------------------------------
    /// 2. next, register the touch and decide what to do with it
  
    // get touch location and touched node
  _beganTouchLocation = [self findTouchLocationFromTouches:touches];
  _currentTouchLocation = _beganTouchLocation;
  _touchNode = [self nodeAtPoint:_currentTouchLocation];
  
  /*
  if ([_touchNode isKindOfClass:Cell.class]) {
    Cell *cell = (Cell *)_touchNode;
    
    CGFloat red = 0.f, green = 0.f, blue = 0.f, alpha = 0.f;
    UIColor *cellColour = cell.color;
    [cellColour getRed:&red green:&green blue:&blue alpha:&alpha];
    
    NSLog(@"Cell colour is %.2f, %.2f, %.2f, %.2f, minDistance is %lu", red, green, blue, alpha, (unsigned long)cell.minDistance);
  }
   */
  
  
//  NSLog(@"touch node is %@ of class %@", _touchNode.name, _touchNode.class);
  
    //--------------------------------------------------------------------------
    /// 3b. dyadmino touched
  
    // dyadmino is not registered if face is touched
  Dyadmino *dyadmino = [self selectDyadminoFromTouchPoint:_currentTouchLocation];
  
  if (!dyadmino.hidden && !_canDoubleTapForDyadminoFlip && ([dyadmino isOnBoard] || !dyadmino.isRotating)) {
    
        // register sound if dyadmino tapped
    if ((!_pnpBarUp && !_replayMode && dyadmino && (!self.swapContainer || (self.swapContainer && [dyadmino isInRack])) && !_pivotInProgress) && (!_boardZoomedOut || (_boardZoomedOut && [dyadmino isInRack]))) {
      
          // when face is nil, sound both faces (but not in lock mode)
      if (!_lockMode) {
        [self soundDyadmino:dyadmino withFace:nil];
      }
      
        // register sound if face tapped
    } else {
      Face *face = [self selectFaceWithTouchStruck:YES];
      if (face && face.parent != _hoveringDyadmino && !_pivotInProgress) {
        if ([face isKindOfClass:[Face class]]) {
          Dyadmino *resonatedDyadmino = (Dyadmino *)face.parent;
          if (!resonatedDyadmino.hidden && !resonatedDyadmino.isRotating &&
              (!_pnpBarUp || (_pnpBarUp && [resonatedDyadmino isOnBoard])) &&
              (!_replayMode || (_replayMode && [resonatedDyadmino isOnBoard]))) {
            
              // face may be sounded when zoomed
            [self soundDyadmino:resonatedDyadmino withFace:face];
            [resonatedDyadmino animateFaceForSound:face];
            _soundedDyadminoFace = face;
          }
        }
      }
    }
  }
  
  if (!_lockMode && !_pnpBarUp && !_replayMode && dyadmino && !dyadmino.isRotating && !_touchedDyadmino && (!_boardZoomedOut || [dyadmino isInRack])) {
    
    _touchedDyadmino = dyadmino;
    
    _previousTouchWasDyadmino = _currentTouchIsDyadmino;
    _currentTouchIsDyadmino = YES;
    
    [self beginTouchOrPivotOfDyadmino:dyadmino];
  
    //--------------------------------------------------------------------------
    /// 3c. board about to be moved
  
    // if pivot not in progress, or pivot in progress but dyadmino is not close enough
    // then the board is touched and being moved
  } else if (!_pivotInProgress || (_pivotInProgress && !_touchedDyadmino)) {
    
      // establish not a dyadmino (for pinch gesture safety)
    _previousTouchWasDyadmino = _currentTouchIsDyadmino;
    _currentTouchIsDyadmino = NO;
    
    if (_touchNode == _boardField || [_touchNode isKindOfClass:[MyScene class]] || (_touchNode.parent == _boardField && (![_touchNode isKindOfClass:[Dyadmino class]])) ||
        (_touchNode.parent.parent == _boardField && (![_touchNode.parent isKindOfClass:[Dyadmino class]]))) { // cell label, this one is necessary only for testing purposes
      
        // check if double tapped
      if (_canDoubleTapForBoardZoom && !_hoveringDyadmino) {
        CGFloat distance = [self getDistanceFromThisPoint:_beganTouchLocation toThisPoint:_endTouchLocationToMeasureDoubleTap];
        if (distance < kDistanceToDoubleTap) {
          if (!_pnpBarUp && !self.swapContainer && !_replayMode) {
            [self handleDoubleTapForLockModeWithSound:YES];
          }
        }
      } else {
        _boardToBeMovedOrBeingMoved = YES;
      }
      
      _canDoubleTapForBoardZoom = YES;
      
        // check to see if hovering dyadmino should be moved along with board or not
      if (_hoveringDyadmino) {
        [_boardField hideAllPivotGuides];

        PlacementResult placementResult = [self.myMatch checkPlacementOfDataDyadmino:[self getDataDyadminoFromDyadmino:_hoveringDyadmino] onBottomHexCoord:_hoveringDyadmino.tempHexCoord withOrientation:_hoveringDyadmino.orientation];
        
        _hoveringDyadminoStaysFixedToBoard = (placementResult != kNoChange && placementResult != kAddsOrExtendsNewChords);
      }
    }
  }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    /// 1. easy checks to determine whether to register the touch moved
  
    // this ensures no more than one touch at a time
  UITouch *thisTouch = [touches anyObject];
  if (thisTouch != _currentTouch) {
    return;
  }

  if (_fieldActionInProgress) {
    return;
  }
  
    //--------------------------------------------------------------------------
    /// 2. next, update the touch location
  _previousTouchLocation = _currentTouchLocation;
  _currentTouchLocation = [self findTouchLocationFromTouches:touches];
  
    // if touch hits a dyadmino face, sound and continue...
  if (!_boardToBeMovedOrBeingMoved && !_touchedDyadmino) {
    Face *face = [self selectFaceWithTouchStruck:NO];
    
    if (face && face.parent != _hoveringDyadmino) {
      if ([face isKindOfClass:[Face class]]) {
        Dyadmino *resonatedDyadmino = (Dyadmino *)face.parent;
        if ((!_replayMode || (_replayMode && [resonatedDyadmino isOnBoard])) &&
            (!_pnpBarUp || (_pnpBarUp && [resonatedDyadmino isOnBoard]))) {
          if (face !=_soundedDyadminoFace) {

            [self soundDyadmino:resonatedDyadmino withFace:face];
            [resonatedDyadmino animateFaceForSound:face];
            _soundedDyadminoFace = face;
          }
        }
      }
    } else {
      _soundedDyadminoFace = nil;
    }
  }
  
    //--------------------------------------------------------------------------
    /// 3a. board is being moved
  
    // if board is being moved, handle and return
  if (_boardToBeMovedOrBeingMoved) {
    [self moveBoard];
    return;
  }
  
    // check this *after* checking board move
    if (!_touchedDyadmino) {
    return;
  }
  
    //--------------------------------------------------------------------------
    /// 3b part i: dyadmino is being moved, take care of the prepwork
  
    // update currently touched dyadmino's section
  [self determineCurrentSectionOfDyadmino:_touchedDyadmino];
  
    // if it moved beyond certain distance, it can no longer flip
  if ([self distanceFromCurrentToHomePositionForDyadmino:_touchedDyadmino] > kDistanceAfterCannotRotate) {
    
    _touchedDyadmino.canFlip = NO;
    
      // buttons updated once
    if ([_touchedDyadmino isOnBoard] && !_buttonsUpdatedThisTouch) {
      [self updateTopBarButtons];
      _buttonsUpdatedThisTouch = YES;
    }
  }
  
    // touched dyadmino is now on board
  if (_touchedDyadmino.home == kRack && [_touchedDyadmino isOnBoard]) {
    
      // automatically zoom back in if rack dyadmino moved to board
    _boardZoomedOut ? [self toggleBoardZoomWithTapCentering:NO andCenterLocation:CGPointZero] : nil;
    
      // if rack dyadmino is moved to board, send home recentRack dyadmino
    if (_recentRackDyadmino && _touchedDyadmino != _recentRackDyadmino) {
      
      [self moveDyadminoHome:_recentRackDyadmino andSound:YES];
      
        // or same thing with hovering dyadmino (it will only ever be one or the other)
    } else if (_hoveringDyadmino && _touchedDyadmino != _hoveringDyadmino) {
      [self moveDyadminoHome:_hoveringDyadmino andSound:YES];
    }
    
      // buttons updated once
    if (!_buttonsUpdatedThisTouch) {
      [self updateTopBarButtons];
      _buttonsUpdatedThisTouch = YES;
    }
  }
  
    // not DRY, but repeats the above, only with touched dyadmino that belongs on board
    // recent rack must be sent home, otherwise chords get messed up
  if (_touchedDyadmino.home == kBoard && [_touchedDyadmino isOnBoard]) {
    [self sendHomeRecentRackDyadminoFromBoardDyadminoMove];
  }
  
    // continue to reset hover count
  [_touchedDyadmino isHovering] ? [_touchedDyadmino changeHoveringStatus:kDyadminoContinuesHovering] : nil;
  
    //  this is the only place that sets dyadmino highlight to YES
    //  dyadmino highlight is reset when sent home or finalised
  if (_touchedDyadmino.home == kRack && !self.swapContainer && !_pivotInProgress) {
      CGPoint dyadminoOffsetPosition = [self addToThisPoint:_currentTouchLocation thisPoint:_touchOffsetVector];
      [_touchedDyadmino adjustHighlightGivenDyadminoOffsetPosition:dyadminoOffsetPosition];
  }
  
    //--------------------------------------------------------------------------
    /// 3b part ii: pivot or move
  
    // if we're currently pivoting, just rotate and return
  if (_pivotInProgress) {
    [self handlePivotOfGuidesAndDyadmino:_hoveringDyadmino firstTime:NO];
    return;
  }
  
    // this ensures that pivot guides are not hidden if rack exchange
  if (_touchedDyadmino == _hoveringDyadmino) {
    [_boardField hideAllPivotGuides];
  }
  
    // move the dyadmino!
  _touchedDyadmino.position =
    [self getOffsetForTouchPoint:_currentTouchLocation forDyadmino:_touchedDyadmino];
  
  if (_touchedDyadmino == _hoveringDyadmino) {
      // move the pivot guide, taking into consideration whether dyadmino is child of board or rack
    CGPoint pivotGuidePosition = [_hoveringDyadmino isOnBoard] ? _hoveringDyadmino.position :
        [self subtractFromThisPoint:_hoveringDyadmino.position thisPoint:_boardField.position];
    [_boardField updatePositionsOfPivotGuidesForDyadminoPosition:pivotGuidePosition];
  }
  
  //--------------------------------------------------------------------------
  /// 3c. dyadmino is just being exchanged in rack
  
    // if it's a rack dyadmino, then while movement is within rack, rearrange dyadminoes
  if ((_touchedDyadmino.home == kRack && [_touchedDyadmino isInRack]) ||
      _touchedDyadmino.belongsInSwap) {

    NSUInteger closestRackIndex = [self closestRackIndexForDyadmino:_touchedDyadmino];
    
    self.playerRackDyadminoes = [_rackField handleRackExchangeOfTouchedDyadmino:_touchedDyadmino
                                                                 withDyadminoes:self.playerRackDyadminoes
                                                            andClosestRackIndex:closestRackIndex];
  }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  
    /// 1. first check whether to even register the touch ended
  
    // kludge way of ensuring that buttonPressed is cancelled upon multiple touches
  
    // this ensures no more than one touch at a time
  UITouch *thisTouch = [touches anyObject];
  _endTouchLocationToMeasureDoubleTap = [self findTouchLocationFromTouches:touches];
  
  if (thisTouch != _currentTouch) {
    return;
  }

  _currentTouch = nil;
  [self endTouchFromTouches:touches];
}

-(void)endTouchFromTouches:(NSSet *)touches {
  
  if (!_fieldActionInProgress) {

      // board no longer being moved
    if (_boardToBeMovedOrBeingMoved) {
      _boardToBeMovedOrBeingMoved = NO;
      
        // take care of hovering dyadmino
      if (_hoveringDyadminoStaysFixedToBoard) {
  
        _hoveringDyadmino.tempHexCoord = [self closestHexCoordForDyadmino:_hoveringDyadmino];
      }
      
      _boardField.homePosition = _boardField.position;
    }
    
      // check this *after* checking board move
    if (!_touchedDyadmino) {
      return;
    }
      //--------------------------------------------------------------------------
      /// 2c. handle touched dyadmino
    [self determineCurrentSectionOfDyadmino:_touchedDyadmino];
    Dyadmino *dyadmino = [self assignTouchEndedPointerToDyadmino:_touchedDyadmino];
    
    [self handleTouchEndOfDyadmino:dyadmino];
    
      // cleanup
    _pivotInProgress = NO;
    _touchOffsetVector = CGPointZero;
    _soundedDyadminoFace = nil;
    _buttonsUpdatedThisTouch = NO;
  }
}

#pragma mark - board methods

-(void)moveBoard {
    // if board isn't being corrected within bounds
  
  if (!_boardBeingCorrectedWithinBounds) {
    
    CGPoint oldBoardPosition = _boardField.position;
    
    CGPoint adjustedNewPosition = [_boardField adjustedNewPositionFromBeganLocation:_beganTouchLocation
                                                                  toCurrentLocation:_currentTouchLocation
                                                                           withSwap:(BOOL)self.swapContainer
                                                                   returnDifference:NO];
    
    if (_hoveringDyadminoStaysFixedToBoard) {
      _hoveringDyadmino.position = [self addToThisPoint:_hoveringDyadmino.position
                                              thisPoint:[self subtractFromThisPoint:oldBoardPosition
                                                                          thisPoint:adjustedNewPosition]];
      [_boardField updatePositionsOfPivotGuidesForDyadminoPosition:_hoveringDyadmino.position];
    }
  }
}

-(void)toggleBoardZoomWithTapCentering:(BOOL)tapCentering andCenterLocation:(CGPoint)location {
    // without tap centering, location is irrelevant
  if (![self noActionsInProgress]) {
    return;
  }

  [self postSoundNotification:kNotificationBoardZoom];
  
  _boardZoomedOut = !_boardZoomedOut;
  _boardField.zoomedOut = _boardZoomedOut;
  
  if (_boardZoomedOut) {
    _boardField.postZoomPosition = _boardField.homePosition;
    
  } else {

    if (tapCentering) {
      _boardField.postZoomPosition = location;
    }
    
      // ensures that board position is consistent with where view thinks it is,
      // so that there won't be a skip after user moves board
    _boardField.homePosition = _boardField.postZoomPosition;
  }
  
  CGPoint zoomOutBoardHomePositionDifference = [self subtractFromThisPoint:_boardField.position thisPoint:_boardField.homePosition];

    // prep board for bounds and position
    // if in replay, only determine cells based on these dyadminoes
  
  [_boardField determineOutermostCellsBasedOnDyadminoes:(_replayMode ? [self dyadminoesOnBoardThisReplayTurn] : [self allBoardDyadminoesPlusRecentRackDyadmino])];
  [_boardField determineBoardPositionBounds];
  
  CGPoint adjustedNewPosition = [_boardField repositionCellsForZoomWithSwap:(BOOL)self.swapContainer];
  
    // reposition and resize dyadminoes
  for (Dyadmino *dyadmino in [self allBoardDyadminoesPlusRecentRackDyadmino]) {
    
    CGPoint tempNewPosition = [self addToThisPoint:dyadmino.position thisPoint:adjustedNewPosition];
    
    if (_boardZoomedOut) {
      tempNewPosition = [self addToThisPoint:tempNewPosition thisPoint:zoomOutBoardHomePositionDifference];
    } else {
      tempNewPosition = [self addToThisPoint:tempNewPosition thisPoint:_boardField.zoomInBoardHomePositionDifference];
    }
    
    dyadmino.position = tempNewPosition;
    dyadmino.isTouchThenHoverResized = NO;
    dyadmino.isZoomResized = _boardZoomedOut;
    [self incrementDyadminoesInFluxWithLayoutFirst:NO minusDyadmino:nil];
    [dyadmino goToTempPositionWithLayout:NO andRescale:YES andOrient:NO];
  }
}



-(void)handleUserWantsPivotGuides {
  [_boardField hideAllPivotGuides];
}

#pragma mark - dyadmino methods

-(void)beginTouchOrPivotOfDyadmino:(Dyadmino *)dyadmino {
  
  if (dyadmino == _hoveringDyadmino) {
    [_hoveringDyadmino animateWiggleForHover:NO];
  }
  
    // record tempReturnOrientation only if it's settled and not hovering
  if (dyadmino != _hoveringDyadmino) {
    dyadmino.homeOrientation = dyadmino.orientation;
    
      // board dyadmino sends recent rack dyadmino home upon touch
      // rack dyadmino will do so upon move out of rack
      // (this needs to come before legal chords are checked, so that its placement on board is included)
    if (_hoveringDyadmino && [dyadmino isOnBoard]) {
      
      if (_hoveringDyadmino.home == kBoard) {
        [self moveDyadminoHome:_hoveringDyadmino andSound:YES withDecrement:NO];
        [self decrementDyadminoesInFluxWithLayoutLast:YES];
      } else {
        [self moveDyadminoHome:_hoveringDyadmino andSound:YES withDecrement:NO];
      }
    }
  }
  
  [dyadmino startTouchThenHoverResize];
  
  [self getReadyToMoveCurrentDyadmino:_touchedDyadmino];
  
    // if it's now about to pivot, just get pivot angle
  _pivotInProgress ? [self getReadyToPivotHoveringDyadmino:_hoveringDyadmino] : nil;
  
    // if it's on the board and not already rotating, two possibilities
  if ([_touchedDyadmino isOnBoard] && !_touchedDyadmino.isRotating) {

    _uponTouchDyadminoHexCoord = dyadmino.tempHexCoord;
    _uponTouchDyadminoOrientation = dyadmino.homeOrientation;
    
      // 1. it's not hovering, so make it hover
    if (!_touchedDyadmino.canFlip) {
      _touchedDyadmino.canFlip = YES;
      _canDoubleTapForDyadminoFlip = YES;
      
        // 2. it's already hovering, so tap inside to flip
    } else {
      [_touchedDyadmino animateFlip];
      
        // if it's not the recent rack dyadmino, send home recent rack dyadmino
      if (_touchedDyadmino != _recentRackDyadmino) {
        [self sendHomeRecentRackDyadminoFromBoardDyadminoMove];
      }
    }
  }
}

-(void)getReadyToMoveCurrentDyadmino:(Dyadmino *)dyadmino {
  
  if ([dyadmino isOnBoard] && dyadmino != _hoveringDyadmino) {
    [self incrementDyadminoesInFluxWithLayoutFirst:YES minusDyadmino:dyadmino];
    [self updateCellsForRemovedDyadmino:dyadmino];
  }

  _touchOffsetVector = [dyadmino isInRack] ? [self subtractFromThisPoint:_beganTouchLocation thisPoint:dyadmino.position] :
      [self subtractFromThisPoint:_beganTouchLocation
                        thisPoint:[self addToThisPoint:dyadmino.position thisPoint:_boardField.position]];
  
  
    // reset hover count
  [dyadmino isHovering] ? [dyadmino changeHoveringStatus:kDyadminoContinuesHovering] : nil;
//  [dyadmino removeActionsAndEstablishNotRotatingIncludingMove:YES];
  
    //--------------------------------------------------------------------------
  
    // if it's still in the rack, it can still rotate
  if ([dyadmino isInRack] || dyadmino.belongsInSwap) {
    dyadmino.canFlip = YES;
  }
  
    // no chord message while dyadmino is being moved
    [self.myDelegate fadeChordMessage];
  
    // various prep
  dyadmino.zPosition = kZPositionHoveredDyadmino;
}

-(void)handleTouchEndOfDyadmino:(Dyadmino *)dyadmino {
    // ensures we're not disrupting a rotating animation
  if (!dyadmino.isRotating) {
    
      // if dyadmino belongs in rack (or swap) and *isn't* on board...
    if ((dyadmino.home == kRack || [dyadmino belongsInSwap]) && ![dyadmino isOnBoard]) {
      
        // ...flip if possible, or send it home
      if (dyadmino.canFlip) {
        [dyadmino animateFlip];
        
      } else {
        [self moveDyadminoHome:dyadmino andSound:YES];
        
          // just settles into rack or swap
        [self updateTopBarButtons];
      }
      
        // or if dyadmino is in top bar...
    } else if (dyadmino.isInTopBar) {;
      
        // if it's a board dyadmino
      if (dyadmino.home == kBoard) {
        dyadmino.tempHexCoord = dyadmino.homeHexCoord;
      }
      
      [self moveDyadminoHome:dyadmino andSound:YES];
      
        // or if dyadmino is in rack but belongs on board (this seems to work)
    } else if (dyadmino.home == kBoard && [dyadmino isInRack]) {
      dyadmino.tempHexCoord = dyadmino.homeHexCoord;
      [self removeDyadmino:dyadmino fromParentAndAddToNewParent:_boardField withLayout:NO];
      dyadmino.position = [_boardField getOffsetFromPoint:dyadmino.position];
      [self moveDyadminoHome:dyadmino andSound:YES];
      
        // otherwise, prepare it for hover
    } else {
        // prepareForHover will get called in correctZRotation completion
      [dyadmino correctZRotationAfterHover];
    }
  }
}

-(void)prepareForHoverThisDyadmino:(Dyadmino *)dyadmino {
  
  if (dyadmino != _touchedDyadmino) {
    _hoveringDyadmino = dyadmino;
    [_hoveringDyadmino animateWiggleForHover:YES];
    
    dyadmino.tempHexCoord = [self closestHexCoordForDyadmino:dyadmino];
    
      // start hovering
    [self checkWhetherToEaseOrKeepHovering:dyadmino];
    
    if ((dyadmino.isHovering || dyadmino.continuesToHover) && _pointsForExtending == 0) {
       // add !_canDoubleTapForDyadminoFlip to have delay after touch ends
      dyadmino.isRotating ? nil : [_boardField hidePivotGuideAndShowPrePivotGuideForDyadmino:dyadmino];
    }
  }
}

-(void)sendDyadminoHome:(Dyadmino *)dyadmino byPoppingInForUndo:(BOOL)popInForUndo andSound:(BOOL)sound withDecrement:(BOOL)decrement {
    // only called by moveDyadminoHome and popDyadminoHome
  
  if ([dyadmino isOnBoard]) {
    [self updateCellsForRemovedDyadmino:dyadmino];
  }
  
  if (dyadmino != _touchedDyadmino) {
    [self.myDelegate fadeChordMessage];
  }
  
      // recalibrate coordinates if dyadmino is sent home to rack from board
  if (dyadmino.parent == _boardField && (dyadmino.home == kRack || popInForUndo)) {
    CGPoint newPosition = [self addToThisPoint:dyadmino.position thisPoint:_boardField.position];
    
    BOOL withLayout = dyadmino != _hoveringDyadmino;
    [self removeDyadmino:dyadmino fromParentAndAddToNewParent:_rackField withLayout:withLayout];
    dyadmino.position = newPosition;
  }
  
    // animate going home
  if (dyadmino.home == kRack) {
    [dyadmino returnToRackByPoppingInForUndo:popInForUndo withResize:_boardZoomedOut];
    
  } else {
    
    dyadmino.tempHexCoord = dyadmino.homeHexCoord;
    [dyadmino returnHomeToBoardWithLayout:YES andSound:sound withDecrement:decrement];
  }

    // reset properties
  _uponTouchDyadminoHexCoord = [self hexCoordFromX:NSIntegerMax andY:NSIntegerMax];
  dyadmino.canFlip = NO;
  [dyadmino endTouchThenHoverResize];
  
    // make nil all pointers
  if (dyadmino == _recentRackDyadmino && [_recentRackDyadmino isInRack]) {
    _recentRackDyadmino = nil;
    _recentRackDyadminoFormsLegalChord = NO;
  };
  
  if (dyadmino == _hoveringDyadmino) {
      // this ensures that pivot guide doesn't disappear if rack exchange
    [_boardField hideAllPivotGuides];
    [_hoveringDyadmino animateWiggleForHover:NO];
    _hoveringDyadmino = nil;
    
      // don't reset self.boardDyadminoBelongsInTheseLegalChords just yet
      // if there's a currently touched dyadmino that still needs to be compared
    if (!_touchedDyadmino) {
      self.legalChordsForHoveringBoardDyadmino = nil;
    }
  }

  [self updateTopBarButtons];
}

-(void)sendHomeRecentRackDyadminoFromBoardDyadminoMove {
    // if there's a recent rack dyadmino, send home recentRack dyadmino
  if (_recentRackDyadmino) {
    [self moveDyadminoHome:_recentRackDyadmino andSound:YES];
  }
  
    // buttons updated once
  if (!_buttonsUpdatedThisTouch) {
    [self updateTopBarButtons];
    _buttonsUpdatedThisTouch = YES;
  }
}

-(void)handlePivotOfGuidesAndDyadmino:(Dyadmino *)dyadmino firstTime:(BOOL)firstTime {
  
  CGPoint touchBoardOffset = [_boardField getOffsetFromPoint:_currentTouchLocation];
  
    // rotate pivot guides
  CGFloat guideAngle = [self pivotAngleBasedOnTouchLocation:touchBoardOffset forDyadmino:dyadmino firstTime:firstTime];
  [_boardField rotatePivotGuidesBasedOnPivotAroundPoint:dyadmino.pivotAroundPoint andTrueAngle:guideAngle];
  
    // rotate dyadmino
  CGFloat dyadminoAngle = guideAngle - _orientationOffset + (dyadmino.orientation * 60) - (_originalDyadminoOrientation * 60);
  BOOL pivotChanged = [dyadmino pivotBasedOnTouchLocation:touchBoardOffset
                                        andZRotationAngle:dyadminoAngle
                                             andPivotOnPC:_boardField.pivotOnPC];
  
  if (!pivotChanged) {
    [dyadmino zRotateToAngle:dyadminoAngle];
  }
}

-(Dyadmino *)assignTouchEndedPointerToDyadmino:(Dyadmino *)dyadmino {
    // rack dyadmino only needs pointer if it's still on board
  if (dyadmino.home == kRack && [dyadmino isOnBoard]) {
    _recentRackDyadmino = dyadmino;
  }
  
  _touchedDyadmino = nil;
  return dyadmino;
}

-(void)getReadyToPivotHoveringDyadmino:(Dyadmino *)dyadmino {
  
//  [dyadmino removeActionsAndEstablishNotRotatingIncludingMove:YES];
  
    // this section just determines which pc to pivot on
    // it's not relevant after dyadmino is moved
  CGPoint touchBoardOffset = [_boardField getOffsetFromPoint:_beganTouchLocation];
  dyadmino.initialPivotAngle = [self findAngleInDegreesFromThisPoint:touchBoardOffset
                                                         toThisPoint:dyadmino.position];
  
  dyadmino.zRotationCorrectedAfterPivot = NO;
  dyadmino.prePivotDyadminoOrientation = dyadmino.orientation;
  dyadmino.initialPivotPosition = dyadmino.position;
  [_boardField determinePivotOnPCForDyadmino:dyadmino];
  
  [dyadmino determinePivotAroundPointBasedOnPivotOnPC:_boardField.pivotOnPC];
  
  [self handlePivotOfGuidesAndDyadmino:dyadmino firstTime:YES];
}

#pragma mark - button methods

-(void)togglePCsUserShaken:(BOOL)userShaken {
  userShaken ? [self postSoundNotification:kNotificationTogglePCs] : nil;
  [[SceneEngine sharedSceneEngine] toggleBetweenLetterAndNumberMode];
}

-(void)handleButtonPressed:(Button *)button {
  
      /// games button
  if (button == _topBar.returnOrStartButton) {
    if (self.swapContainer) {
      [self cancelSwappedDyadminoes];
      [self toggleSwapFieldWithAnimation:YES];
    }
    [self goBackToMainViewController];
    return;
    
      /// pnp button
  } else if (button == _pnpBar.returnOrStartButton) {

    _pnpBarUp = NO;
    [self togglePnPBarSyncWithRack:YES animated:YES];
    [self toggleDyadminoesLockedAnimated:YES];
    [self afterNewPlayerReady];
  
      /// unlock button
  } else if (button == _topBar.swapCancelOrUndoButton &&
             [button confirmSwapCancelOrUndo] == kUnlockButton) {
    [self handleDoubleTapForLockModeWithSound:YES];
    
      /// swap button
  } else if (button == _topBar.swapCancelOrUndoButton &&
             [button confirmSwapCancelOrUndo] == kSwapButton) {
    if (!self.swapContainer) {
      self.swapContainer = [NSMutableSet new];
      [self toggleSwapFieldWithAnimation:YES];
    }
    
      /// cancel button
  } else if (button == _topBar.swapCancelOrUndoButton &&
             [button confirmSwapCancelOrUndo] == kCancelButton) {
    
      // if in swap mode, cancel swap
    if (self.swapContainer) {
      [self cancelSwappedDyadminoes];
      [self toggleSwapFieldWithAnimation:YES];
      
        // else send dyadmino home
    } else if (_hoveringDyadmino) {
      [self moveDyadminoHome:_hoveringDyadmino andSound:YES];

        // recent rack dyadmino is sent home
    } else if (_recentRackDyadmino) {
      [self moveDyadminoHome:_recentRackDyadmino andSound:YES];
    }
    
      /// reset button
  } else if (button == _topBar.swapCancelOrUndoButton &&
             [button confirmSwapCancelOrUndo] == kResetButton) {
    [self presentActionSheet:kActionSheetReset withPoints:0];
    
      /// undo button
  } else if (button == _topBar.swapCancelOrUndoButton &&
             [button confirmSwapCancelOrUndo] == kUndoButton) {
    
    [self undoLastPlayedDyadmino];
  
      /// play button
  } else if (button == _topBar.passPlayOrDoneButton &&
             [button confirmPassPlayOrDone] == kPlayButton) {
    [self playDyadmino];
    
      /// pass or done button
  } else if (button == _topBar.passPlayOrDoneButton &&
             ([button confirmPassPlayOrDone] == kDoneButton || [button confirmPassPlayOrDone] == kPassButton)) {
    if (!self.swapContainer) {
      
      NSUInteger pointsThisTurn = [self.myMatch pointsForAllChordsThisTurn];
      if (pointsThisTurn == 0) {
        
          // it's a pass, so confirm with action sheet
        [self presentActionSheet:kActionSheetPass withPoints:0];
      } else {
        [self presentActionSheet:kActionSheetTurnDone withPoints:pointsThisTurn];
      }
          // finalising a swap
    } else if (self.swapContainer) {
        // confirm that there's enough dyadminoes in the pile
      if (self.swapContainer.count > self.myMatch.pile.count) {
        
        [self presentActionSheet:kActionSheetPileNotEnough withPoints:0];
        return;
      } else {
        [self presentActionSheet:kActionSheetSwap withPoints:0];
      }
    }
    
      /// debug button
  } else if (button == _topBar.debugButton) {
    _debugMode = _debugMode ? NO : YES;
    [self toggleDebugMode];
    
      /// options button
  } else if (button == _topBar.optionsButton) {
  
    [self.myDelegate presentFromSceneOptionsVC];
    
      /// replay button
  } else if (button == _topBar.replayButton || button == _replayBottom.returnOrStartButton) {
    _replayMode = _replayMode ? NO : YES;
    
      // if game has ended, then do not toggle in replay field from here
      // toggleReplay will be called from
    [self toggleReplayFields];
    
    if (_replayMode) {
      [self storeDyadminoAttributesBeforeReplay];
      [self.myMatch startReplay];
      [self updateViewForReplayInReplay:YES];
      
    } else {
      [self.myMatch leaveReplay];
      [self restoreDyadminoAttributesAfterReplay];
      [self updateViewForReplayInReplay:NO];
      
        // animate last play, or game results if game ended unless player's turn is already over
      if (_myPlayer == [self.myMatch returnCurrentPlayer]) {
        [self animateRecentlyPlayedDyadminoes];
      }
    }
    return;
    
      // replay buttons
  } else if (button == _replayBottom.firstTurnButton) {
    [self.myMatch first];
    [self updateViewForReplayInReplay:YES];
  } else if (button == _replayBottom.previousTurnButton) {
    [self.myMatch previous];
    [self updateViewForReplayInReplay:YES];
  } else if (button == _replayBottom.nextTurnButton) {
    [self.myMatch next];
    [self updateViewForReplayInReplay:YES];
  } else if (button == _replayBottom.lastTurnButton) {
    [self.myMatch last];
    [self updateViewForReplayInReplay:YES];
  } else {
    return;
  }
  
  [self updateTopBarLabelsFinalTurn:NO animated:NO];
  [self updateTopBarButtons];
}

#pragma mark - match interaction methods

-(void)cancelSwappedDyadminoes {
  self.swapContainer = nil;
  for (Dyadmino *dyadmino in self.playerRackDyadminoes) {
    if (dyadmino.belongsInSwap) {
      [dyadmino placeInBelongsInSwap:NO];
      [dyadmino returnToRackByPoppingInForUndo:NO withResize:NO];
    }
  }
}

-(BOOL)finaliseSwap {
  
    // extra confirmation; this will have been checked when button was done button was first pressed
  if (self.swapContainer.count <= self.myMatch.pile.count) {
    
    NSMutableArray *toPile = [NSMutableArray new];
    for (Dyadmino *dyadmino in self.playerRackDyadminoes) {
      [dyadmino belongsInSwap] ? [toPile addObject:dyadmino] : nil;
    }
    
    __weak typeof(self) weakSelf = self;
    
    void(^lastDyadminoCompletion)(void) = ^void(void) {
      [weakSelf updateOrderOfDataDyadsThisTurnToReflectRackOrder];
      
        // then swap in the logic
      if (![weakSelf.myMatch passTurnBySwappingDyadminoes:self.swapContainer]) {
        NSLog(@"Failed to swap dyadminoes.");
        abort();
      } else {
        weakSelf.swapContainer = nil;
        [weakSelf toggleSwapFieldWithAnimation:YES];
      }
      
      if ([weakSelf.myMatch returnType] != kPnPGame) {
        [weakSelf populateRackArray];
        [weakSelf refreshRackFieldAndDyadminoesFromUndo:NO withAnimation:YES];
      }
      
        // call this again because animation delays completion
      [weakSelf updateTopBarLabelsFinalTurn:YES animated:NO];
      [weakSelf updateTopBarButtons];
      
      [weakSelf doSomethingSpecial:@"dyadminoes have been swapped."];
    };
    
    [self animateRackEmptyDyadminoes:toPile lastDyadminoCompletion:lastDyadminoCompletion];
    return YES;
  } else {
    
      // won't get called unless error
    [self updateTopBarLabelsFinalTurn:YES animated:NO];
    [self updateTopBarButtons];
    return NO;
  }
}

-(void)animateRackEmptyDyadminoes:(NSArray *)dyadminoesToEmpty
                       lastDyadminoCompletion:(void(^)(void))lastDyadminoCompletionBlock {
  
  __weak typeof(self) weakSelf = self;
  
    // first take care of views
  for (int i = 0; i < dyadminoesToEmpty.count; i++) {
    
    Dyadmino *dyadmino = dyadminoesToEmpty[i];
    [self removeFromPlayerRackDyadminoes:dyadmino];
    
    SKAction *waitAction = [SKAction waitForDuration:i * kWaitTimeForRackDyadminoPopulate];
    SKAction *soundAction = [SKAction runBlock:^{
      [weakSelf postSoundNotification:kNotificationRackExchangeClick];
    }];
    
    SKAction *moveAction = [SKAction moveToX:0 - _rackField.xIncrementInRack duration:kConstantTime];
    moveAction.timingMode = SKActionTimingEaseOut;
    
    SKAction *lastDyadminoCompletionAction = [SKAction runBlock:^{
      [dyadmino resetForNewMatch];
      
      if (i == dyadminoesToEmpty.count - 1) {
        lastDyadminoCompletionBlock();
      }
    }];
    
    SKAction *sequence = [SKAction sequence:@[waitAction, soundAction, moveAction, lastDyadminoCompletionAction]];
//    [dyadmino removeActionsAndEstablishNotRotatingIncludingMove:YES];
    [dyadmino runAction:sequence withKey:@"emptyDyadmino"];
  }
}

-(void)playDyadmino {
  
    // played dyadmino will only ever be the recent rack dyadmino
  Dyadmino *dyadmino = _recentRackDyadmino;
  
    // establish that dyadmino is indeed a rack dyadmino placed on the board
  if (dyadmino.home == kRack && [dyadmino isOnBoard]) {
    
    DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
    
      // show chord message
    NSString *chordsText = [self.myMatch stringForPlacementOfDataDyadmino:dataDyad
                                                                   onBottomHexCoord:dyadmino.tempHexCoord
                                                                    withOrientation:dyadmino.orientation
                                                                      withCondition:kBothNewAndExtendedChords
                                                                  withInitialString:@"Built "
                                                                    andEndingString:@"."];
    [self.myDelegate showChordMessage:chordsText sign:kChordMessageGood autoFade:YES];
    
      // confirm that the dyadmino was successfully played in match
    if (![self.myMatch playDataDyadmino:dataDyad
                       onBottomHexCoord:dyadmino.tempHexCoord
                        withOrientation:dyadmino.orientation]) {
      
      NSLog(@"Match failed to play dyadmino.");
      abort();
    }
    
      // change scene values
    [self removeFromPlayerRackDyadminoes:dyadmino];
    [self addToSceneBoardDyadminoes:dyadmino];
    
      // do cleanup, dyadmino's home node is now the board node
    dyadmino.homeHexCoord = dyadmino.tempHexCoord;
    dyadmino.homeOrientation = dyadmino.orientation;
    dyadmino.rackIndex = -1;
    
    [dyadmino highlightBoardDyadminoWithColour:[self.myMatch colourForPlayer:_myPlayer forLabel:YES light:NO]];
    
      // empty pointers
    _recentRackDyadmino = nil;
    _recentRackDyadminoFormsLegalChord = NO;
    [_hoveringDyadmino animateWiggleForHover:NO];
    _hoveringDyadmino = nil;
    self.legalChordsForHoveringBoardDyadmino = nil;
  }
  
  [self refreshRackFieldAndDyadminoesFromUndo:NO withAnimation:YES];
  [self recordChangedDataForRackDyadminoes:self.playerRackDyadminoes];
  
  [self updateTopBarLabelsFinalTurn:NO animated:YES];
  [self updateTopBarButtons];
}

-(void)undoLastPlayedDyadmino {
    // remove data dyadmino from holding container
  DataDyadmino *undoneDataDyadmino = [self.myMatch undoLastPlayedDyadmino];
  
    // couldn't play because it leaves stranded dyadminoes
  if (!undoneDataDyadmino) {
    [self presentActionSheet:kActionSheetStrandedCannotUndo withPoints:0];
    
  } else {
    
      // recalibrate undone dyadmino
    Dyadmino *undoneDyadmino = [self getDyadminoFromDataDyadmino:undoneDataDyadmino];
    undoneDyadmino.homeOrientation = [undoneDataDyadmino returnMyOrientation];
    
      // re-add dyadmino to player rack, remove from scene board, refresh chords
    [self reAddToPlayerRackDyadminoes:undoneDyadmino];
    [self removeFromSceneBoardDyadminoes:undoneDyadmino];
    
    [self recordChangedDataForRackDyadminoes:self.playerRackDyadminoes];
    
      // take care of views
    [self incrementDyadminoesInFluxWithLayoutFirst:YES minusDyadmino:undoneDyadmino];
    [self popDyadminoHome:undoneDyadmino];
  }
}

-(void)resetBoardFromPass:(BOOL)fromPass {
  
  self.replayDyadminoesNotMovedThisTurn = [NSMutableSet new];
  
  [self.myDelegate fadeChordMessage];
  [self updateOrderOfDataDyadsThisTurnToReflectRackOrder];
    
    // reset dataDyad info
  [self.myMatch resetToStartOfTurn];
  
  for (Dyadmino *dyadmino in self.boardDyadminoes) {
    DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
    
    if (dyadmino.homeHexCoord.x == dataDyad.myHexCoord.x &&
        dyadmino.homeHexCoord.y == dataDyad.myHexCoord.y &&
        dyadmino.homeOrientation == (DyadminoOrientation)[dataDyad returnMyOrientation]) {
      [self.replayDyadminoesNotMovedThisTurn addObject:dyadmino];
    }
    
    dyadmino.homeOrientation = (DyadminoOrientation)[dataDyad returnMyOrientation];
    
    dyadmino.homeHexCoord = dataDyad.myHexCoord;
    dyadmino.tempHexCoord = dyadmino.homeHexCoord;

    [self incrementDyadminoesInFluxWithLayoutFirst:NO minusDyadmino:nil];
  }
  
  if (![self populateBoardWithDyadminoesAnimated:YES andSound:NO]) {
    NSLog(@"Dyadminoes were not placed on board properly.");
    abort();
  }
  
  if (fromPass) {
    [self finalisePlayerTurn];
  }

  [self updateTopBarButtons];
  [self updateTopBarLabelsFinalTurn:NO animated:YES];
}

-(void)finalisePlayerTurn {
  
  [self updateOrderOfDataDyadsThisTurnToReflectRackOrder];
  
    // no recent rack dyadmino on board
  if (!_recentRackDyadmino) {
    
    [self.myMatch recordDyadminoesFromCurrentPlayerWithSwap:NO];

    if ([self.myMatch returnType] != kPnPGame) {
      [self populateRackArray];
      [self refreshRackFieldAndDyadminoesFromUndo:NO withAnimation:YES];
    }
    
      // update views
    [self updateTopBarLabelsFinalTurn:YES animated:YES];
    [self updateTopBarButtons];
    [self doSomethingSpecial:@"acknowledge that turn has been finalised."];
    
    ([self.myMatch returnType] == kSelfGame) ? [self animateRecentlyPlayedDyadminoes] : nil;
    
    [self showTurnInfoOrGameResultsForReplay:NO];
  }
}

-(void)handleSwitchToNextPlayer {
  
  if ([self.myMatch returnType] == kPnPGame) {
    
    [self toggleDyadminoesLockedAnimated:YES];
    
    _pnpBarUp = YES;
    [self togglePnPBarSyncWithRack:YES animated:YES];
    
      // note that prepareRackForNextPlayer and prepareForNewTurn
      // are called in togglePnPBar completion block
      // this is the only place method is called where pnpBarUp is YES
  }
}

-(void)handleEndGame {
  __weak typeof(self) weakSelf = self;
  void(^completion)(void) = ^void(void) {
    [weakSelf.myDelegate presentFromSceneGameEndedVC];
    
      // call this again because animation delays completion
    NSLog(@"top bar labels updated in handle end game completion.");
    
    [weakSelf updateTopBarLabelsFinalTurn:YES animated:NO];
    [weakSelf updateTopBarButtons];
    
    [weakSelf doSomethingSpecial:@"dyadminoes have been swapped."];
  };
  
    // empty rack first, then present game ended VC
  [self animateRackEmptyDyadminoes:self.playerRackDyadminoes lastDyadminoCompletion:completion];
}

#pragma mark - realtime update methods

-(void)update:(CFTimeInterval)currentTime {
  
  [self updateForDoubleTap:currentTime];
  _hoveringDyadmino ? [self updateDyadmino:_hoveringDyadmino forHover:currentTime] : nil;
  
    // snap back somewhat from board bounds
  [self updateForBoardBeingCorrectedWithinBounds];
  [self updateForHoveringDyadminoBeingCorrectedWithinBounds];
  [self updatePivotForDyadminoMoveWithoutBoardCorrected];
}

-(void)updateForDoubleTap:(CFTimeInterval)currentTime {
  if (_canDoubleTapForDyadminoFlip || _canDoubleTapForBoardZoom) {
    if (_doubleTapTime == 0.f) {
      _doubleTapTime = currentTime;
    }
  }
  
  if (_doubleTapTime != 0.f && currentTime > _doubleTapTime + kDoubleTapTime) {
    _canDoubleTapForBoardZoom = NO;
    _endTouchLocationToMeasureDoubleTap = CGPointMake(2147483647, 2147483647);
    _canDoubleTapForDyadminoFlip = NO;
    _hoveringDyadmino.canFlip = NO;
    _doubleTapTime = 0.f;
  }
}

-(void)updateForHoveringDyadminoBeingCorrectedWithinBounds {
  if (!_hoveringDyadmino.isRotating && !_boardToBeMovedOrBeingMoved &&
      !_boardBeingCorrectedWithinBounds && !_boardJustShiftedNotCorrected &&
      _hoveringDyadmino && _hoveringDyadmino != _touchedDyadmino &&
      ![_hoveringDyadmino isInRack] && !_hoveringDyadmino.isInTopBar) {
    
    CGFloat xLowLimit = -_boardField.position.x;
    CGFloat xHighLimit = self.view.frame.size.width - _boardField.position.x;
    
    CGFloat thisDistance;
    CGFloat distanceDivisor = 5.333f; // tweak this number if desired
    CGFloat dyadminoXBuffer = (_hoveringDyadmino.orientation == kPC1atTwelveOClock || _hoveringDyadmino.orientation == kPC1atSixOClock) ?
    kDyadminoFaceWideRadius * 1.5 : kDyadminoFaceWideDiameter * 1.5;
    
    if (_hoveringDyadmino.position.x - dyadminoXBuffer < xLowLimit) {
      _hoveringDyadminoBeingCorrected++;
      thisDistance = 1.f + (xLowLimit - (_hoveringDyadmino.position.x - dyadminoXBuffer)) / distanceDivisor;
      _hoveringDyadmino.position = CGPointMake(_hoveringDyadmino.position.x + thisDistance, _hoveringDyadmino.position.y);
      [_boardField updatePositionsOfPivotGuidesForDyadminoPosition:_hoveringDyadmino.position];
      
    } else if (_hoveringDyadmino.position.x + dyadminoXBuffer > xHighLimit) {
      _hoveringDyadminoBeingCorrected++;
      thisDistance = 1.f + ((_hoveringDyadmino.position.x + dyadminoXBuffer) - xHighLimit) / distanceDivisor;
      _hoveringDyadmino.position = CGPointMake(_hoveringDyadmino.position.x - thisDistance, _hoveringDyadmino.position.y);
      [_boardField updatePositionsOfPivotGuidesForDyadminoPosition:_hoveringDyadmino.position];
      
    } else {
      _hoveringDyadminoFinishedCorrecting++;
        // so it doesn't grow insanely big
      _hoveringDyadminoFinishedCorrecting = _hoveringDyadminoFinishedCorrecting > 2 ? 2 : _hoveringDyadminoFinishedCorrecting;
    }
    
      // only goes through one time
    if (_hoveringDyadminoBeingCorrected == 1) {
      [_boardField hideAllPivotGuides];
      
      _hoveringDyadminoFinishedCorrecting = (_hoveringDyadminoBeingCorrected >= 1) ? 0 : _hoveringDyadminoFinishedCorrecting;
      
    } else if (_hoveringDyadminoFinishedCorrecting == 1) {
      
      if (_hoveringDyadminoFinishedCorrecting >= 1) {
        _hoveringDyadmino.tempHexCoord = [self closestHexCoordForDyadmino:_hoveringDyadmino];
        
        if (!_canDoubleTapForDyadminoFlip && !_hoveringDyadmino.isRotating) {
          [_boardField hidePivotGuideAndShowPrePivotGuideForDyadmino:_hoveringDyadmino];
        }
        
        _hoveringDyadminoBeingCorrected = (_hoveringDyadminoFinishedCorrecting >= 1) ? 0 : _hoveringDyadminoBeingCorrected;
      }
    }
  }
}

-(void)correctBoardForPositionAfterZoom {
  
  CGPoint tempBoardPosition = _boardField.position;
  
  CGFloat zoomFactor = _boardZoomedOut ? kZoomResizeFactor : 1.f;
  CGFloat swapBuffer = self.swapContainer ? kRackHeight : 0.f; // the height of the swap field
  
  CGFloat lowestXBuffer = _boardField.lowestXPos + (kDyadminoFaceAverageWideRadius * zoomFactor);
  CGFloat lowestYBuffer = _boardField.lowestYPos + (kDyadminoFaceRadius * zoomFactor);
  CGFloat highestXBuffer = _boardField.highestXPos - (kDyadminoFaceAverageWideRadius * zoomFactor);
  CGFloat highestYBuffer = _boardField.highestYPos - (kDyadminoFaceRadius * zoomFactor) + swapBuffer;
  
  if (_boardField.position.x < lowestXBuffer) {
    CGFloat thisDistance = (lowestXBuffer - _boardField.position.x);
    _boardField.position = CGPointMake(_boardField.position.x + thisDistance, _boardField.position.y);
    _boardField.homePosition = _boardField.position;
  }
  
  if (_boardField.position.y < lowestYBuffer) {
    CGFloat thisDistance = (lowestYBuffer - _boardField.position.y);
    _boardField.position = CGPointMake(_boardField.position.x, _boardField.position.y + thisDistance);
    _boardField.homePosition = _boardField.position;
  }

  if (_boardField.position.x > highestXBuffer) {
    CGFloat thisDistance = (_boardField.position.x - highestXBuffer);
    _boardField.position = CGPointMake(_boardField.position.x - thisDistance, _boardField.position.y);
    _boardField.homePosition = _boardField.position;
  }
  
  if (_boardField.position.y > highestYBuffer) {
    CGFloat thisDistance = _boardField.position.y - highestYBuffer;
    _boardField.position = CGPointMake(_boardField.position.x, _boardField.position.y - thisDistance);
    _boardField.homePosition = _boardField.position;
  }
  
  _boardField.zoomInBoardHomePositionDifference = [self subtractFromThisPoint:tempBoardPosition
                                                                    thisPoint:_boardField.homePosition];
}

-(void)updateForBoardBeingCorrectedWithinBounds {
  
  if (_fieldActionInProgress) {
    _boardField.homePosition = _boardField.position;
  }

  CGFloat swapBuffer = self.swapContainer ? kRackHeight : 0.f; // the height of the swap field
  
    // only prevents board move from touch if it's truly out of bounds
    // it's fine if it's still within the buffer
  _boardBeingCorrectedWithinBounds = ((_boardField.position.x < _boardField.lowestXPos) ||
                                      (_boardField.position.y < _boardField.lowestYPos) ||
                                      (_boardField.position.x > _boardField.highestXPos) ||
                                      (_boardField.position.y > _boardField.highestYPos + swapBuffer)) ? YES : NO;
  
  if (!_boardToBeMovedOrBeingMoved || _boardBeingCorrectedWithinBounds) {
    
    if (_hoveringDyadmino && _boardBeingCorrectedWithinBounds) {
      [_boardField hideAllPivotGuides];
    }
    
    CGFloat thisDistance;
      // this number can be tweaked, but it seems fine for now
    CGFloat distanceDivisor = 8.f;
    
      // this establishes when board is no longer being corrected within bounds
    NSUInteger alreadyCorrect = 0;

    CGFloat boundsFactor = 1.5f; // tweak
    CGFloat zoomFactor = _boardZoomedOut ? kZoomResizeFactor : 1.f;
    CGFloat factor = zoomFactor * boundsFactor;
    
    CGFloat lowestXBuffer = _boardField.lowestXPos + (kDyadminoFaceAverageWideRadius * factor);
    CGFloat lowestYBuffer = _boardField.lowestYPos + (kDyadminoFaceRadius * factor);
    CGFloat highestXBuffer = _boardField.highestXPos - (kDyadminoFaceAverageWideRadius * factor);
    CGFloat highestYBuffer = _boardField.highestYPos - (kDyadminoFaceRadius * factor) + swapBuffer;
    
      // this way when the board is being corrected,
      // it doesn't jump afterwards
    if (_boardToBeMovedOrBeingMoved) {
      _beganTouchLocation = _currentTouchLocation;
    }
  
      // establishes the board is being shifted away from hard edge, not as a correction
    if (_boardField.position.x < lowestXBuffer) {
      _boardJustShiftedNotCorrected = YES;
      thisDistance = (1.f + (lowestXBuffer - _boardField.position.x) / distanceDivisor);
      _boardField.position = CGPointMake(_boardField.position.x + thisDistance, _boardField.position.y);
      _boardField.homePosition = _boardField.position;
      
      if (_hoveringDyadminoStaysFixedToBoard) {
        _hoveringDyadmino.position = CGPointMake(_hoveringDyadmino.position.x - thisDistance, _hoveringDyadmino.position.y);
        [_boardField updatePositionsOfPivotGuidesForDyadminoPosition:_hoveringDyadmino.position];
      }
      
      if (_touchedDyadmino) {
        _touchedDyadmino.position = CGPointMake(_touchedDyadmino.position.x - thisDistance, _touchedDyadmino.position.y);
      }
      
    } else {
      alreadyCorrect++;
    }
    
    if (_boardField.position.y < lowestYBuffer) {
      _boardJustShiftedNotCorrected = YES;
      thisDistance = (1.f + (lowestYBuffer - _boardField.position.y) / distanceDivisor);
      _boardField.position = CGPointMake(_boardField.position.x, _boardField.position.y + thisDistance);
      _boardField.homePosition = _boardField.position;
      
      if (_hoveringDyadminoStaysFixedToBoard) {
        _hoveringDyadmino.position = CGPointMake(_hoveringDyadmino.position.x, _hoveringDyadmino.position.y - thisDistance);
        [_boardField updatePositionsOfPivotGuidesForDyadminoPosition:_hoveringDyadmino.position];
      }
      
      if (_touchedDyadmino) {
        _touchedDyadmino.position = CGPointMake(_touchedDyadmino.position.x, _touchedDyadmino.position.y - thisDistance);
      }
      
    } else {
      alreadyCorrect++;
    }

    if (_boardField.position.x > highestXBuffer) {
      _boardJustShiftedNotCorrected = YES;
      thisDistance = (1.f + (_boardField.position.x - highestXBuffer) / distanceDivisor);
      _boardField.position = CGPointMake(_boardField.position.x - thisDistance, _boardField.position.y);
      _boardField.homePosition = _boardField.position;
      
      if (_hoveringDyadminoStaysFixedToBoard) {
        _hoveringDyadmino.position = CGPointMake(_hoveringDyadmino.position.x + thisDistance, _hoveringDyadmino.position.y);
        [_boardField updatePositionsOfPivotGuidesForDyadminoPosition:_hoveringDyadmino.position];
      }
      
      if (_touchedDyadmino) {
        _touchedDyadmino.position = CGPointMake(_touchedDyadmino.position.x + thisDistance, _touchedDyadmino.position.y);
      }
      
    } else {
      alreadyCorrect++;
    }

    if (_boardField.position.y > highestYBuffer) {
      _boardJustShiftedNotCorrected = YES;
      thisDistance = (1.f + (_boardField.position.y - highestYBuffer) / distanceDivisor);
      _boardField.position = CGPointMake(_boardField.position.x, _boardField.position.y - thisDistance);
      _boardField.homePosition = _boardField.position;
      
      if (_hoveringDyadminoStaysFixedToBoard) {
        _hoveringDyadmino.position = CGPointMake(_hoveringDyadmino.position.x, _hoveringDyadmino.position.y + thisDistance);
        [_boardField updatePositionsOfPivotGuidesForDyadminoPosition:_hoveringDyadmino.position];
      }
      
      if (_touchedDyadmino) {
        _touchedDyadmino.position = CGPointMake(_touchedDyadmino.position.x, _touchedDyadmino.position.y + thisDistance);
      }
      
    } else {
      alreadyCorrect++;
    }

      // this one is constantly being called even when board is motionless
    if (alreadyCorrect == 4) {

      if (_boardJustShiftedNotCorrected &&
          _hoveringDyadmino && _hoveringDyadmino != _touchedDyadmino) {
        
        _boardJustShiftedNotCorrected = NO;
        _hoveringDyadmino.tempHexCoord = [self closestHexCoordForDyadmino:_hoveringDyadmino];
        
        if (_hoveringDyadminoBeingCorrected == 0) {
          if (!_canDoubleTapForDyadminoFlip && !_hoveringDyadmino.isRotating) {
            [_boardField hidePivotGuideAndShowPrePivotGuideForDyadmino:_hoveringDyadmino];
          }
        }
      }
      
      _boardBeingCorrectedWithinBounds = NO;
    }
  }
}

-(void)updatePivotForDyadminoMoveWithoutBoardCorrected {
    // if board not shifted or corrected, show prepivot guide
  if (_hoveringDyadmino && _hoveringDyadminoBeingCorrected == 0 && _hoveringDyadmino.zRotationCorrectedAfterPivot && !_touchedDyadmino && !_currentTouch && !_boardBeingCorrectedWithinBounds && !_boardJustShiftedNotCorrected && ![_boardField.children containsObject:_boardField.prePivotGuide]) {
    if (!_canDoubleTapForDyadminoFlip && !_hoveringDyadmino.isRotating && _pointsForExtending == 0) {
      [_boardField hidePivotGuideAndShowPrePivotGuideForDyadmino:_hoveringDyadmino];
    }
  }
}

-(void)updateDyadmino:(Dyadmino *)dyadmino forHover:(CFTimeInterval)currentTime {
  if (!self.swapContainer) {
    if ([dyadmino isHovering]) {
      if (_hoverTime == 0.f) {
        _hoverTime = currentTime;
      }
    }
    
      // reset hover time if continues to hover
    if ([dyadmino continuesToHover]) {
      _hoverTime = currentTime;
      [dyadmino changeHoveringStatus:kDyadminoHovering];
    }
    
    if (_hoverTime != 0.f && currentTime > _hoverTime + kAnimateHoverTime) {
      _hoverTime = 0.f;
      
        // FIXME: this is an extremely clumsy way of resetting upon touch hex coord
      _uponTouchDyadminoHexCoord = [self hexCoordFromX:NSIntegerMax andY:NSIntegerMax];
      [dyadmino changeHoveringStatus:kDyadminoFinishedHovering];
    }
    
    if ([dyadmino isFinishedHovering]) {
      [self checkWhetherToEaseOrKeepHovering:dyadmino];
    }
  }
}

-(void)checkWhetherToEaseOrKeepHovering:(Dyadmino *)dyadmino {

      // finish hovering only if placement is legal
  if ([dyadmino isOnBoard] && _touchedDyadmino != dyadmino) {

      // ensures that validation takes place only if placement is uncertain
      // will not get called if returning home from top bar

      // ease in right away if dyadmino was not moved from original spot, or if it's a rack dyadmino
    if (dyadmino.tempHexCoord.x == _uponTouchDyadminoHexCoord.x &&
        dyadmino.tempHexCoord.y == _uponTouchDyadminoHexCoord.y &&
        dyadmino.orientation == _uponTouchDyadminoOrientation) {
    
      NSLog(@"ease in right away, since dyadmino was not moved from original spot.");
        // however, ensure that buttons are updated if chords are changed after flip
      [self updateTopBarButtons];
      [dyadmino changeHoveringStatus:kDyadminoContinuesHovering];
      
    } else {
      
      NSString *messageString;
      DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
      PlacementResult placementResult = [self.myMatch checkPlacementOfDataDyadmino:dataDyad
                                                                  onBottomHexCoord:dyadmino.tempHexCoord
                                                                   withOrientation:dyadmino.orientation];
      
//----------------------------------------------------------------------------
// illegal placement, either lone dyadmino or stacked dyadminoes
//----------------------------------------------------------------------------
          
      if (placementResult == kIllegalPhysicalPlacement) {
        [dyadmino changeHoveringStatus:kDyadminoContinuesHovering];
          // ensure that buttons are updated if chords are changed after flip
        [self updateTopBarButtons];
        return;
        
//----------------------------------------------------------------------------
// illegal sonorities: either excess notes, repeated notes, or illegal chord
//----------------------------------------------------------------------------
        
      } else if (placementResult == kExcessNotesResult ||
                 placementResult == kDoublePCsResult ||
                 placementResult == kIllegalSonorityResult) {
        
        switch (placementResult) {
          case kExcessNotesResult:
            messageString = @"Can't have excess notes.";
            break;
          case kDoublePCsResult:
            messageString = @"Can't repeat notes.";
            break;
          case kIllegalSonorityResult:
            messageString = @"Sonority isn't legal.";
            break;
            default:
            break;
        }
        
          // if board dyadmino, keep hovering
        if (dyadmino.home == kBoard) {
          [dyadmino changeHoveringStatus:kDyadminoContinuesHovering];
             // ensure that buttons are updated if chords are changed after flip
          [self updateTopBarButtons];
          
            // if rack dyadmino, allow to ease into node but do nothing else
        } else if (dyadmino.home == kRack) {
          [self finishHoveringAfterCheckDyadmino:dyadmino];
        }
        
        [self.myDelegate showChordMessage:messageString sign:kChordMessageBad autoFade:NO];
        return;
      
    //------------------------------------------------------------------------
    // moved board dyadmino broke existing chords
    //------------------------------------------------------------------------

      } else if (placementResult == kBreaksExistingChords) {

        NSString *chordsText = [self.myMatch stringForPlacementOfDataDyadmino:dataDyad
                                                             onBottomHexCoord:dyadmino.tempHexCoord
                                                              withOrientation:dyadmino.orientation
                                                                withCondition:kNeitherNewNorExtendedChords
                                                            withInitialString:@"Can't break "
                                                              andEndingString:@"."];

        [self.myDelegate showChordMessage:chordsText sign:kChordMessageBad autoFade:NO];
        
        [dyadmino changeHoveringStatus:kDyadminoContinuesHovering];
        return;
        
    //------------------------------------------------------------------------
    // dyadmino adds or extends new chords
    //------------------------------------------------------------------------
        
      } else if (placementResult == kAddsOrExtendsNewChords) {
        
          // it's a preTurn dyadmino
          // show action sheet with potential points from newly built chord
          // updates will be made from after action sheet button is clicked
        if (dyadmino.home == kBoard && [self.myMatch.board containsObject:dataDyad]) {

          _pointsForExtending = [self.myMatch pointsForPlacingDyadmino:dataDyad
                                                      onBottomHexCoord:dyadmino.tempHexCoord
                                                       withOrientation:dyadmino.orientation];
          
          [_boardField hideAllPivotGuidesAndShowExtendedChordActionSheet];
          
          NSString *chordsText = [self.myMatch stringForPlacementOfDataDyadmino:dataDyad
                                                               onBottomHexCoord:dyadmino.tempHexCoord
                                                                withOrientation:dyadmino.orientation
                                                                  withCondition:kBothNewAndExtendedChords
                                                              withInitialString:@"Build "
                                                                andEndingString:@"?"];
          [self.myDelegate showChordMessage:chordsText sign:kChordMessageNeutral autoFade:NO];
          
          [dyadmino changeHoveringStatus:kDyadminoContinuesHovering];
          return;
          
            // thisTurn dyadmino
            // just keep the new chord
        } else if (dyadmino.home == kBoard && [self.myMatch.holdingIndexContainer containsObject:dataDyad.myID]) {
          NSString *chordsText = [self.myMatch stringForPlacementOfDataDyadmino:dataDyad
                                                               onBottomHexCoord:dyadmino.tempHexCoord
                                                                withOrientation:dyadmino.orientation
                                                                  withCondition:kBothNewAndExtendedChords
                                                              withInitialString:@"Built "
                                                                andEndingString:@"."];
          [self.myDelegate showChordMessage:chordsText sign:kChordMessageGood autoFade:YES];
          
            // recent rack dyadmino
        } else if (dyadmino == _recentRackDyadmino) {
          _recentRackDyadminoFormsLegalChord = YES;
          NSString *chordsText = [self.myMatch stringForPlacementOfDataDyadmino:dataDyad
                                                               onBottomHexCoord:dyadmino.tempHexCoord
                                                                withOrientation:dyadmino.orientation
                                                                  withCondition:kBothNewAndExtendedChords
                                                              withInitialString:@"Building "
                                                                andEndingString:@"."];
          [self.myDelegate showChordMessage:chordsText sign:kChordMessageGood autoFade:NO];
        }
        
        [self finishHoveringAfterCheckDyadmino:dyadmino];
        [self updateTopBarLabelsFinalTurn:NO animated:YES];
        return;
        
    //------------------------------------------------------------------------
    // no new chord made, so it can finish hovering, but it can't be played
    //------------------------------------------------------------------------
      } else if (placementResult == kNoChange) {
          // if preTurn or thisTurn dyadmino, obviously this works fine
        if (dyadmino.home == kBoard) {
          [self.myDelegate fadeChordMessage];
          
            // however, recent rack dyadmino must form new chord
        } else {
          _recentRackDyadminoFormsLegalChord = NO;
          [self.myDelegate showChordMessage:@"Must build new chord." sign:kChordMessageNeutral autoFade:NO];
        }
        
        [self finishHoveringAfterCheckDyadmino:dyadmino];
      }
    }
  }
}

-(void)finishHoveringAfterCheckDyadmino:(Dyadmino *)dyadmino {
  
  [dyadmino changeHoveringStatus:kDyadminoFinishedHovering];
  if (dyadmino.home == kBoard) {
    
    DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
    
    if (![self.myMatch moveBoardDataDyadmino:dataDyad
                            toBottomHexCoord:dyadmino.tempHexCoord
                             withOrientation:dyadmino.orientation]) {
      NSLog(@"Match failed to move dyadmino.");
      abort();
    }

      // this method will record a dyadmino that's already in the match's board
      // this method also gets called if a recently played dyadmino
      // has been moved, but data will not be submitted until the turn is officially done.
    dyadmino.homeHexCoord = dyadmino.tempHexCoord;
    dyadmino.homeOrientation = dyadmino.orientation;
  }
  
  [_boardField hideAllPivotGuides];
  [dyadmino animateEaseIntoNodeAfterHover];
  [_hoveringDyadmino animateWiggleForHover:NO];
  _hoveringDyadmino = nil;
  self.legalChordsForHoveringBoardDyadmino = nil;
  [self updateTopBarButtons];
}

#pragma mark - update label and button methods

-(void)updateTopBarLabelsFinalTurn:(BOOL)finalTurn animated:(BOOL)animated {
  
    // update player labels
  [self.myDelegate updatePlayerLabelsWithFinalTurn:finalTurn andAnimatedScore:animated];
  
    // show turn count and pile left if game has not ended
    NSString *pileLeftText = [self.myMatch returnGameHasEnded] ? @"" : [NSString stringWithFormat:@"%lu in pile",
                                                          (unsigned long)self.myMatch.pile.count];
  NSArray *turns = self.myMatch.turns;
  NSString *turnText = [self.myMatch returnGameHasEnded] ? @"" : [NSString stringWithFormat:@"Turn %lu", (long)(turns.count + 1)];
  
  [self.myDelegate barOrRackLabel:kTopBarTurnLabel show:YES toFade:NO withText:turnText andColour:[UIColor whiteColor]];
  [self.myDelegate barOrRackLabel:kTopBarPileCountLabel show:YES toFade:NO withText:pileLeftText andColour:[UIColor whiteColor]];
}

-(void)updateTopBarButtons {
  
  NSArray *turns = self.myMatch.turns;
  NSArray *holdingIndexContainer = self.myMatch.holdingIndexContainer;
    // three main possibilities: game has ended, in game but not player's turn, in game and player's turn
  BOOL gameHasEndedForPlayer = [_myPlayer returnResigned] || [self.myMatch returnGameHasEnded];
  BOOL currentPlayerHasTurn = _myPlayer == [self.myMatch returnCurrentPlayer];
  BOOL thereIsATouchedOrHoveringDyadmino = _touchedDyadmino || _hoveringDyadmino;
  BOOL swapContainerNotEmpty = self.swapContainer.count > 0;
  
    // this determines whether cancel or undo, so it only cares about rack dyadminoes played
  BOOL noRackDyadminoesPlayedAndNoRecentRackDyadmino = holdingIndexContainer.count == 0 && !_recentRackDyadmino;
  
      // if player has points from moving a board dyadmino, that counts as well
  BOOL noBoardDyadminoesPlayedAndNoRecentRackDyadmino = ([self.myMatch pointsForAllChordsThisTurn] == 0) && !_recentRackDyadmino;
  BOOL noActionsInProgress = [self noActionsInProgress];
  
  [_topBar node:_topBar.returnOrStartButton shouldBeEnabled:noActionsInProgress && !self.swapContainer && !thereIsATouchedOrHoveringDyadmino];
  [_topBar node:_topBar.replayButton shouldBeEnabled:noActionsInProgress && (gameHasEndedForPlayer || !currentPlayerHasTurn || (currentPlayerHasTurn && !self.swapContainer)) && (turns.count > 0) && !_pnpBarUp];
  [_topBar node:_topBar.swapCancelOrUndoButton shouldBeEnabled:(noActionsInProgress && (!gameHasEndedForPlayer && currentPlayerHasTurn) && !_pnpBarUp) || (thereIsATouchedOrHoveringDyadmino && !_fieldActionInProgress)];
  [_topBar node:_topBar.passPlayOrDoneButton shouldBeEnabled:noActionsInProgress && ((!gameHasEndedForPlayer && currentPlayerHasTurn) && (!thereIsATouchedOrHoveringDyadmino) && !_pnpBarUp && ((self.swapContainer && swapContainerNotEmpty) || !self.swapContainer) && (self.swapContainer || (!noBoardDyadminoesPlayedAndNoRecentRackDyadmino || (noBoardDyadminoesPlayedAndNoRecentRackDyadmino && [self.myMatch returnType] != kSelfGame))) && (!_recentRackDyadmino || (_recentRackDyadmino && _recentRackDyadminoFormsLegalChord)))];
  [_topBar node:_topBar.optionsButton shouldBeEnabled:noActionsInProgress && (!gameHasEndedForPlayer && (!currentPlayerHasTurn || (currentPlayerHasTurn && !self.swapContainer))) && !_pnpBarUp];
  
  if (self.swapContainer) {
    [_topBar changeSwapCancelOrUndo:kCancelButton];
    [_topBar changePassPlayOrDone:kDoneButton];

  } else if (thereIsATouchedOrHoveringDyadmino) {
    [_topBar changeSwapCancelOrUndo:kCancelButton];
//    [_topBar node:_topBar.swapCancelOrUndoButton shouldBeEnabled:!_fieldActionInProgress];
    [_topBar node:_topBar.replayButton shouldBeEnabled:NO];
    
      // no dyadminoes played, and no recent rack dyadmino
  } else if (noRackDyadminoesPlayedAndNoRecentRackDyadmino) {
    
      // reset button shows when board dyadminoes have been moved
    [self.myMatch boardDyadminoesHaveMovedSinceStartOfTurn] ?
        [_topBar changeSwapCancelOrUndo:kResetButton] :
        [_topBar changeSwapCancelOrUndo:kSwapButton];
    
      // no pass option in self mode
    if ([self.myMatch returnType] == kSelfGame) {
      [_topBar changePassPlayOrDone:(noBoardDyadminoesPlayedAndNoRecentRackDyadmino ? kPlayButton : kDoneButton)];
    } else {
      [_topBar changePassPlayOrDone:(noBoardDyadminoesPlayedAndNoRecentRackDyadmino ? kPassButton : kDoneButton)];
    }
    
      // there is a recent rack dyadmino placed on board
     // doesn't matter whether holding container is empty
  } else if (_recentRackDyadmino) {
    [_topBar changeSwapCancelOrUndo:kCancelButton];
    [_topBar changePassPlayOrDone:kPlayButton];
    
      // holding container is not empty, and no recent rack dyadmino
  } else {
    [_topBar changeSwapCancelOrUndo:kUndoButton];
    [_topBar changePassPlayOrDone:kDoneButton];
  }
  
  if (_lockMode && !_replayMode && !_pnpBarUp && !self.swapContainer) {
    [_topBar changeSwapCancelOrUndo:kUnlockButton];
    [_topBar node:_topBar.swapCancelOrUndoButton shouldBeEnabled:noActionsInProgress];
    [_topBar node:_topBar.passPlayOrDoneButton shouldBeEnabled:NO];
  }
}

-(void)updateReplayButtons {
  NSArray *turns = self.myMatch.turns;
  BOOL zeroTurns = turns.count <= 1;
  BOOL firstTurn = (self.myMatch.replayTurn == 1);
  BOOL lastTurn = (self.myMatch.replayTurn == turns.count);
  BOOL noActionsInProgress = [self noActionsInProgress];
  
//  NSLog(@"in update replay buttons, no actions in progress is %i", noActionsInProgress);
  
  [_replayBottom node:_replayBottom.firstTurnButton shouldBeEnabled:noActionsInProgress && !zeroTurns && !firstTurn];
  [_replayBottom node:_replayBottom.previousTurnButton shouldBeEnabled:noActionsInProgress && !zeroTurns && !firstTurn];
  [_replayBottom node:_replayBottom.nextTurnButton shouldBeEnabled:noActionsInProgress && !zeroTurns && !lastTurn];
  [_replayBottom node:_replayBottom.lastTurnButton shouldBeEnabled:noActionsInProgress && !zeroTurns && !lastTurn];
  [_replayBottom node:_replayBottom.returnOrStartButton shouldBeEnabled:noActionsInProgress];
}

-(NSString *)updatePnPLabelForNewPlayer {
  Player *currentPlayer = [self.myMatch returnCurrentPlayer];
  
  return kIsIPhone ?
      [NSString stringWithFormat:@"%@,\nit's your turn!", currentPlayer.name] :
      [NSString stringWithFormat:@"%@, it's your turn!", currentPlayer.name];
}

#pragma mark - field animation methods

-(void)toggleDyadminoesLockedAnimated:(BOOL)animated {
    // check http://stackoverflow.com/questions/23007535/fade-between-two-different-sktextures-on-skspritenode
  
    // if dyadminoes already locked, just return
  BOOL dyadminoesShouldBeLocked = [self dyadminoShouldBeLocked:nil];
  if (dyadminoesShouldBeLocked == _dyadminoesAreLocked) {
    return;
  }
  
  for (Dyadmino *dyadmino in [self allSceneDyadminoes]) {
    if (animated) {
//      [dyadmino runAction:fadeDyadminoAlpha withKey:@"fadeDyadminoAlpha"];
      [dyadmino selectAndPositionSpritesZRotation:0.f];
    } else {
//      [dyadmino setAlpha:desiredDyadminoAlpha];
      [dyadmino selectAndPositionSpritesZRotation:0.f];
    }
  }
  
  if (animated) {
      // wait for field action in progress
    _fieldActionInProgress = YES;
    [self updateTopBarButtons];
    SKAction *waitAction = [SKAction waitForDuration:kConstantTime];
    SKAction *completionAction = [SKAction runBlock:^{
      _fieldActionInProgress = NO;
      _dyadminoesAreLocked = dyadminoesShouldBeLocked;
      [self updateTopBarButtons];
    }];
    SKAction *sequence = [SKAction sequence:@[waitAction, completionAction]];
    [self runAction:sequence];
    
  } else {
      // confirm that dyadminoes reflect whether they should be stationary
    _dyadminoesAreLocked = dyadminoesShouldBeLocked;
    NSLog(@"update top bar buttons in toggle dyadminoes");
    [self updateTopBarButtons];
  }
}

-(void)toggleTopBarGoOut:(BOOL)goOut completion:(void(^)(void))completion {

  _topBar.position = goOut ? CGPointMake(0, self.frame.size.height - kTopBarHeight) : CGPointMake(0, self.frame.size.height);
  CGFloat toYPosition = goOut ? self.frame.size.height : self.frame.size.height - kTopBarHeight;
  [_topBar toggleToYPosition:toYPosition goOut:goOut completion:completion withKey:@"toggleTopBar"];
  [self.myDelegate animateTopBarLabelsGoOut:goOut];
}

-(void)toggleRackGoOut:(BOOL)goOut completion:(void (^)(void))completion {
    // this will only happen during PnP or replay animation
  
  _rackField.position = goOut ? CGPointZero : CGPointMake(0, -kRackHeight);
  CGFloat desiredY = goOut ? -kRackHeight : 0;
  [_rackField toggleToYPosition:desiredY goOut:goOut completion:completion withKey:@"toggleRackField"];
}

-(void)togglePnPBarSyncWithRack:(BOOL)sync animated:(BOOL)animated {
  
  __weak typeof(self) weakSelf = self;
  
    // cells will toggle faster than pnpBar moves
  [self postSoundNotification:kNotificationToggleBarOrField];
  
  [self toggleFieldActionInProgress:YES];
  if (_pnpBarUp) {
    
    [self.myDelegate barOrRackLabel:kPnPWaitingLabel show:YES toFade:NO withText:[self updatePnPLabelForNewPlayer] andColour:[self.myMatch colourForPlayer:[self.myMatch returnCurrentPlayer] forLabel:YES light:NO]];
    
    _pnpBar.hidden = NO;
    CGFloat yPosition = CGPointZero.y;

    void (^pnpCompletion)(void) = ^void(void) {
      [self toggleFieldActionInProgress:NO];
      _rackField.hidden = YES;
      [weakSelf prepareRackForNextPlayer];
      [weakSelf prepareForNewTurn];
    };

    if (sync) {
      void (^completion)(void) = ^void(void) {
        [_pnpBar toggleToYPosition:yPosition goOut:NO completion:pnpCompletion withKey:@"togglePnpBar"];
        [weakSelf.myDelegate animatePnPLabelGoOut:NO];
      };
      
      [self toggleRackGoOut:YES completion:completion];
      
    } else {
      [_pnpBar toggleToYPosition:yPosition goOut:NO completion:pnpCompletion withKey:@"togglePnpBar"];
      [self.myDelegate animatePnPLabelGoOut:NO];
    }
    
  } else {
    
    CGFloat yPosition = -kRackHeight;
    
    void (^pnpCompletion)(void);
    
    if (sync) {
      _rackField.hidden = NO;
      
      void (^completion)(void) = ^void(void) {
        [self toggleFieldActionInProgress:NO];
      };

      pnpCompletion = ^void(void) {
        _pnpBar.hidden = YES;
        [weakSelf toggleRackGoOut:NO completion:completion];
      };

    } else {
      pnpCompletion = ^void(void) {
        [self toggleFieldActionInProgress:NO];
        _pnpBar.hidden = YES;
      };
    }
    
    [_pnpBar toggleToYPosition:yPosition goOut:YES completion:pnpCompletion withKey:@"togglePnpBar"];
    [self.myDelegate animatePnPLabelGoOut:YES];
  }
}

-(void)toggleReplayFields {
  
    // technically, this will never actually get called
    // because replay button is not enabled when dyadmino is hovering
  if (_hoveringDyadmino) {
    [self moveDyadminoHome:_hoveringDyadmino andSound:YES];
  }
  
    // cells will toggle faster than replayBars moves
  
  if (!_lockMode) {
    [self toggleDyadminoesLockedAnimated:YES];
  }

  [self postSoundNotification:kNotificationToggleBarOrField];
  
  [self toggleFieldActionInProgress:YES];
  
  if (_replayMode) {
      // scene views
    _replayTop.hidden = NO;
    _replayBottom.hidden = NO;
    
    __weak typeof(self) weakSelf = self;
    
    CGFloat topYPosition = self.frame.size.height - kTopBarHeight;
    void (^replayCompletion)(void) = ^void(void) {
      [self toggleFieldActionInProgress:NO];
      _topBar.hidden = YES;
      _rackField.hidden = YES;
    };
    
    void (^topBarCompletion)(void) = ^void(void) {
      [_replayTop toggleToYPosition:topYPosition goOut:NO completion:replayCompletion withKey:@"toggleReplayTop"];
      [weakSelf.myDelegate animateReplayLabelGoOut:NO];
    };
    [self toggleTopBarGoOut:YES completion:topBarCompletion];
    
    CGFloat bottomYPosition = CGPointZero.y;
    
    SKAction *bottomMoveAction = [SKAction moveToY:CGPointZero.y duration:kConstantTime];
    bottomMoveAction.timingMode = SKActionTimingEaseOut;
    
    void (^bottomCompletion)(void) = ^void(void) {
      [_replayBottom toggleToYPosition:bottomYPosition goOut:NO completion:nil withKey:@"toggleReplayBottom"];
    };
    [self toggleRackGoOut:YES completion:bottomCompletion];
    
      // it's not in replay mode
  } else {
    
    __weak typeof(self) weakSelf = self;
    
    _topBar.hidden = NO;
    
    CGFloat topYPosition = self.frame.size.height;
    void (^topReplayCompletion)(void) = ^void(void) {
      _replayTop.hidden = YES;
      void (^completion)(void) = ^void(void) {
        [self toggleFieldActionInProgress:NO];
      };
      [weakSelf toggleTopBarGoOut:NO completion:completion];
    };
    
    [_replayTop toggleToYPosition:topYPosition goOut:YES completion:topReplayCompletion withKey:@"toggleReplayTop"];
    [self.myDelegate animateReplayLabelGoOut:YES];

    _rackField.hidden = NO;
    
    CGFloat bottomYPosition = -kRackHeight;
    void (^bottomReplayCompletion)(void) = ^void(void) {
      _replayBottom.hidden = YES;
      
      void (^completion)(void) = ^void(void) {
        [self toggleFieldActionInProgress:NO];
      };
      [weakSelf toggleRackGoOut:NO completion:completion];
    };
    
    [_replayBottom toggleToYPosition:bottomYPosition goOut:NO completion:bottomReplayCompletion withKey:@"toggleReplayBottom"];
  }
}

-(void)toggleSwapFieldWithAnimation:(BOOL)animated {

    // this gets called before scene is removed from view
  if (!animated) {
    _swapField.hidden = YES;
    return;
  }
  
    // cells will toggle faster than field moves
  [self toggleDyadminoesLockedAnimated:YES]; // only animate if board zoomed in
  
  [self postSoundNotification:kNotificationToggleBarOrField];
  
  if (!self.swapContainer) {
    [self toggleFieldActionInProgress:YES];
    
      // swap field action
    CGFloat desiredX = -self.frame.size.width;
    void (^swapCompletion)(void) = ^void(void) {
      [self toggleFieldActionInProgress:NO];
      _swapField.hidden = YES;
    };
    
    [_swapField toggleToXPosition:desiredX goOut:YES completion:swapCompletion withKey:@"toggleSwap"];
    
      // board action
      // FIXME: when board is moved to top in swap mode, board goes down, then pops back up
    CGFloat swapBuffer = (_boardField.position.y > _boardField.highestYPos) ? _boardField.highestYPos : _boardField.position.y - (kRackHeight / 2);
      
    SKAction *moveBoardAction = [SKAction moveToY:swapBuffer duration:kConstantTime];
    [_boardField runAction:moveBoardAction withKey:@"boardMoveFromSwap"];

  } else {
    [self toggleFieldActionInProgress:YES];
    _swapField.hidden = NO;
    _swapField.position = CGPointMake(self.frame.size.width, kRackHeight);
    
      // swap field action
    
    void (^swapCompletion)(void) = ^void(void) {
      [self toggleFieldActionInProgress:NO];
    };
    
    [_swapField toggleToXPosition:0 goOut:NO completion:swapCompletion withKey:@"toggleSwap"];
    
      // board action
    SKAction *moveBoardAction = [SKAction moveToY:_boardField.position.y + kRackHeight / 2 duration:kConstantTime];
    [_boardField runAction:moveBoardAction withKey:@"boardMoveFromSwap"];
  }
}

#pragma mark - match helper methods

-(void)addDataDyadminoToSwapContainerForDyadmino:(Dyadmino *)dyadmino {
  DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
  [self.swapContainer addObject:dataDyad];
}

-(void)removeDataDyadminoFromSwapContainerForDyadmino:(Dyadmino *)dyadmino {
  DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
  [self.swapContainer removeObject:dataDyad];
}

-(void)updateOrderOfDataDyadsThisTurnToReflectRackOrder {
  
  for (NSInteger i = 0; i < self.playerRackDyadminoes.count; i++) {
    Dyadmino *dyadmino = self.playerRackDyadminoes[i];
    DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
    
    dataDyad.myOrientation = [NSNumber numberWithUnsignedInteger:dyadmino.orientation];
    dataDyad.myRackOrder = [NSNumber numberWithInteger:i];
    
    if ([_myPlayer doesRackContainDataDyadmino:dataDyad] &&
        ![self.swapContainer containsObject:dataDyad]) {
      
      [_myPlayer removeFromRackDataDyadmino:dataDyad];
      [_myPlayer insertIntoRackDataDyadmino:dataDyad withOrderNumber:i];
    }
  }
}

#pragma mark - undo manager

-(void)reAddToPlayerRackDyadminoes:(Dyadmino *)dyadmino {
  if (![self.playerRackDyadminoes containsObject:dyadmino]) {
    NSMutableArray *tempRackArray = [NSMutableArray arrayWithArray:self.playerRackDyadminoes];
    [tempRackArray addObject:dyadmino];
    self.playerRackDyadminoes = [NSArray arrayWithArray:tempRackArray];
  }
}

-(void)removeFromPlayerRackDyadminoes:(Dyadmino *)dyadmino {
  if ([self.playerRackDyadminoes containsObject:dyadmino]) {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.playerRackDyadminoes];
    [tempArray removeObject:dyadmino];
    self.playerRackDyadminoes = [NSArray arrayWithArray:tempArray];
  }
}

-(void)addToSceneBoardDyadminoes:(Dyadmino *)dyadmino {
  if (![self.boardDyadminoes containsObject:dyadmino]) {
    NSMutableSet *tempSet = [NSMutableSet setWithSet:self.boardDyadminoes];
    [tempSet addObject:dyadmino];
    self.boardDyadminoes = [NSSet setWithSet:tempSet];
  }
}

-(void)removeFromSceneBoardDyadminoes:(Dyadmino *)dyadmino {
    // not sure why fast enumeration works but containsObject method doesn't?!
  for (Dyadmino *boardDyadmino in self.boardDyadminoes) {
    if (boardDyadmino == dyadmino) {
      NSMutableSet *tempSet = [NSMutableSet setWithSet:self.boardDyadminoes];
      [tempSet removeObject:dyadmino];
      self.boardDyadminoes = [NSSet setWithSet:tempSet];
    }
  }
}

#pragma mark - board helper methods

-(void)updateCellsForPlacedDyadmino:(Dyadmino *)dyadmino {
    // only called in populateBoardWithDyadminoes and sendDyadminoHome (in completion block after animation)

  [_boardField updateCellsForDyadmino:dyadmino placedOnBottomHexCoord:dyadmino.tempHexCoord];
}

-(void)updateCellsForRemovedDyadmino:(Dyadmino *)dyadmino {
    // only called in willMoveFromView and getReadyToMoveCurrentDyadmino and sendDyadminoHome

  [_boardField updateCellsForDyadmino:dyadmino removedFromBottomHexCoord:dyadmino.tempHexCoord];
}

-(NSSet *)allSceneDyadminoes {
  
  NSMutableSet *dyadminoesInScene = [NSMutableSet setWithSet:self.boardDyadminoes];
  
    // add dyadmino to set if dyadmino is a recent rack dyadmino
  for (Dyadmino *dyadmino in self.playerRackDyadminoes) {
    [dyadminoesInScene addObject:dyadmino];
  }
  return [NSSet setWithSet:dyadminoesInScene];
}

-(NSSet *)allBoardDyadminoesPlusRecentRackDyadmino {
  
  NSMutableSet *dyadminoesOnBoard = [NSMutableSet setWithSet:self.boardDyadminoes];
  
    // add dyadmino to set if dyadmino is a recent rack dyadmino
  if ([_recentRackDyadmino isOnBoard] && ![dyadminoesOnBoard containsObject:_recentRackDyadmino]) {
    [dyadminoesOnBoard addObject:_recentRackDyadmino];
  }
  return [NSSet setWithSet:dyadminoesOnBoard];
}

-(NSSet *)allBoardDyadminoesNotTurnOrRecentRack {
  
  NSMutableSet *dyadminoesOnBoard = [NSMutableSet setWithSet:self.boardDyadminoes];
  NSSet *turnDyadminoesPlusRecentRack = [self allTurnDyadminoesPlusRecentRackDyadmino];
  for (Dyadmino *dyadmino in turnDyadminoesPlusRecentRack) {
    if ([dyadminoesOnBoard containsObject:dyadmino]) {
      [dyadminoesOnBoard removeObject:dyadmino];
    }
  }

  return [NSSet setWithSet:dyadminoesOnBoard];
}

-(NSSet *)allTurnDyadminoesPlusRecentRackDyadmino {
  
  NSMutableSet *tempSet = [NSMutableSet new];
  for (DataDyadmino *dataDyad in [self.myMatch dataDyadsInIndexContainer:self.myMatch.holdingIndexContainer]) {
    Dyadmino *dyadmino = [self getDyadminoFromDataDyadmino:dataDyad];
    if (![tempSet containsObject:dyadmino]) {
      [tempSet addObject:dyadmino];
    }
  }
  
  if (_recentRackDyadmino && ![tempSet containsObject:_recentRackDyadmino]) {
    [tempSet addObject:_recentRackDyadmino];
  }
  
  return [NSSet setWithSet:tempSet];
}

#pragma mark - touch helper methods

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self touchesEnded:touches withEvent:event];
}

-(CGPoint)findTouchLocationFromTouches:(NSSet *)touches {
  CGPoint uiTouchLocation = [[touches anyObject] locationInView:self.view];
  return CGPointMake(uiTouchLocation.x, self.frame.size.height - uiTouchLocation.y);
}

#pragma mark - data dyadmino methods

-(Dyadmino *)getDyadminoFromDataDyadmino:(DataDyadmino *)dataDyad {
  SceneEngine *sceneEngine = [SceneEngine sharedSceneEngine];
  
    // off by one error before
  Dyadmino *dyadmino = (Dyadmino *)sceneEngine.allDyadminoes[[dataDyad returnMyID]];
  return dyadmino;
}

-(DataDyadmino *)getDataDyadminoFromDyadmino:(Dyadmino *)dyadmino {
  
  NSMutableSet *tempDataDyadSet = [NSMutableSet setWithSet:self.myMatch.board];
  
  [tempDataDyadSet addObjectsFromArray:[self.myMatch dataDyadsInIndexContainer:_myPlayer.rackIndexes]];
  
  for (DataDyadmino *dataDyad in tempDataDyadSet) {
    if ([dataDyad returnMyID] == dyadmino.myID) {
      return dataDyad;
    }
  }
  return nil;
}

#pragma mark - dyadmino helper methods

-(void)determineCurrentSectionOfDyadmino:(Dyadmino *)dyadmino {
    // this the ONLY place that determines current section of dyadmino
    // this is the ONLY place that sets dyadmino's belongsInSwap to YES
  
    // if it's pivoting, it's on the board, period
    // it's also on board, if not in swap and above rack and below top bar
  
  if (_pivotInProgress || (!self.swapContainer && _currentTouchLocation.y - _touchOffsetVector.y >= kRackHeight &&
      _currentTouchLocation.y - _touchOffsetVector.y < self.frame.size.height - kTopBarHeight)) {
    [self removeDyadmino:dyadmino fromParentAndAddToNewParent:_boardField withLayout:NO];
    [dyadmino placeInTopBar:NO];
    
      // it's in swap
  } else if (self.swapContainer && _currentTouchLocation.y - _touchOffsetVector.y > kRackHeight) {
    [dyadmino placeInBelongsInSwap:YES];
    [self addDataDyadminoToSwapContainerForDyadmino:dyadmino];
    
    [dyadmino placeInTopBar:NO];

    // if in rack field, doesn't matter if it's in swap
  } else if (_currentTouchLocation.y - _touchOffsetVector.y <= kRackHeight) {
    [self removeDyadmino:dyadmino fromParentAndAddToNewParent:_rackField withLayout:NO];
    [dyadmino placeInBelongsInSwap:NO];
    [self removeDataDyadminoFromSwapContainerForDyadmino:dyadmino];
    [dyadmino placeInTopBar:NO];

      // else it's in the top bar, but this is a clumsy workaround, so be careful!
  } else if (!self.swapContainer && _currentTouchLocation.y - _touchOffsetVector.y >=
             self.frame.size.height - kTopBarHeight) {
    [dyadmino placeInTopBar:YES];
  }
}

-(CGPoint)getOffsetForTouchPoint:(CGPoint)touchPoint forDyadmino:(Dyadmino *)dyadmino {
  return dyadmino.parent == _boardField ?
    [_boardField getOffsetForPoint:touchPoint withTouchOffset:_touchOffsetVector] :
    [self subtractFromThisPoint:touchPoint thisPoint:_touchOffsetVector];
}

-(Face *)selectFaceWithTouchStruck:(BOOL)touchStruck {

  NSArray *touchNodes = [self nodesAtPoint:_currentTouchLocation];

    // in hindsight, touches happening too quickly might not be the problem
    // it might be because it isn't getting the right nodes in the first place
  if (!touchStruck) {
    NSMutableArray *newTempTouchNodes = [NSMutableArray arrayWithArray:touchNodes];
    CGPoint midPoint = CGPointMake(((_currentTouchLocation.x - _previousTouchLocation.x) / 2) + _previousTouchLocation.x,
                                   ((_currentTouchLocation.y - _previousTouchLocation.y) / 2) + _previousTouchLocation.y);
    NSArray *newTouchNodes = [self nodesAtPoint:midPoint];
    [newTempTouchNodes addObjectsFromArray:newTouchNodes];
    touchNodes = [NSArray arrayWithArray:newTempTouchNodes];
  }
  
  for (SKSpriteNode *touchNode in touchNodes) {
    if ([touchNode isKindOfClass:[Face class]]) {
      return (Face *)touchNode;
    }
  }
  return nil;
}

-(Dyadmino *)selectDyadminoFromTouchPoint:(CGPoint)touchPoint {
    // also establishes if pivot is in progress; touchOffset isn't relevant for this method

    // if we're in hovering mode...
  if ([_hoveringDyadmino isHovering]) {
    
      // accommodate if it's on board
    CGPoint touchBoardOffset = [_boardField getOffsetFromPoint:touchPoint];

      // if touch point is close enough, just rotate
    if ([self getDistanceFromThisPoint:touchBoardOffset toThisPoint:_hoveringDyadmino.position] <
        kDistanceForTouchingHoveringDyadmino) {
      return _hoveringDyadmino;
 
        // otherwise, we're pivoting, so establish that
    } else if ([self getDistanceFromThisPoint:touchBoardOffset toThisPoint:_hoveringDyadmino.position] <
            kMaxDistanceForPivot) {
      _pivotInProgress = YES;
      _hoveringDyadmino.canFlip = NO;
      return _hoveringDyadmino;
    }
  }

    //--------------------------------------------------------------------------
  
    // otherwise, first restriction is that the node being touched is the dyadmino
  
  NSArray *touchNodes = [self nodesAtPoint:touchPoint];
  for (SKNode *touchNode in touchNodes) {
    Dyadmino *dyadmino;
    if ([touchNode isKindOfClass:[Dyadmino class]]) {
      dyadmino = (Dyadmino *)touchNode;
    } else if ([touchNode.parent isKindOfClass:[Dyadmino class]]) {
      dyadmino = (Dyadmino *)touchNode.parent;
    } else if ([touchNode.parent.parent isKindOfClass:[Dyadmino class]]) {
      dyadmino = (Dyadmino *)touchNode.parent.parent;
    }

    if (dyadmino) {
      
        // second restriction is that touch point is close enough based on following criteria:
        // if dyadmino is on board, not hovering and thus locked in a node, and we're not in swap mode...
      [self determineCurrentSectionOfDyadmino:dyadmino];
      if ([dyadmino isOnBoard] && !self.swapContainer) {
        
          // accommodate the fact that dyadmino's position is now relative to board
        CGPoint relativeToBoardPoint = [_boardField getOffsetFromPoint:touchPoint];
        if ([self getDistanceFromThisPoint:relativeToBoardPoint toThisPoint:dyadmino.position] <
            kDistanceForTouchingRestingDyadmino) {
          return dyadmino;
        }
          // if dyadmino is in rack...
      } else if (dyadmino && ([dyadmino isInRack] || dyadmino.belongsInSwap)) {
        if ([self getDistanceFromThisPoint:touchPoint toThisPoint:dyadmino.position] <
            kDistanceForTouchingRestingDyadmino) { // was _rackField.xIncrementInRack
          return dyadmino;
        }
      }
    }
  }
    // otherwise, dyadmino is not close enough
  return nil;
}

-(CGFloat)distanceFromCurrentToHomePositionForDyadmino:(Dyadmino *)dyadmino {
  CGPoint homePosition = (dyadmino.home == kRack) ?
      [self rackPositionForDyadmino:dyadmino] : [self homePositionForDyadmino:dyadmino];
  
  return [self getDistanceFromThisPoint:homePosition toThisPoint:dyadmino.position];
}

-(HexCoord)closestHexCoordForDyadmino:(Dyadmino *)dyadmino {
  return [_boardField findClosestHexCoordForDyadminoPosition:dyadmino.position andOrientation:dyadmino.orientation];
}

-(NSUInteger)closestRackIndexForDyadmino:(Dyadmino *)dyadmino {
  return [_rackField findClosestRackIndexForDyadminoPosition:dyadmino.position withCount:self.playerRackDyadminoes.count];
}

-(CGFloat)pivotAngleBasedOnTouchLocation:(CGPoint)touchLocation forDyadmino:(Dyadmino *)dyadmino firstTime:(BOOL)firstTime {
  
    // establish angles
  CGFloat touchAngle = [self findAngleInDegreesFromThisPoint:touchLocation toThisPoint:dyadmino.pivotAroundPoint];
  while (touchAngle < 0) {
    touchAngle += 360.f;
  }
  
  NSUInteger dyadOrient = 360 - dyadmino.orientation * 60;
  
  CGFloat touchAngleRelativeToDyadOrient = touchAngle + dyadmino.orientation * 60.f;
  while (touchAngleRelativeToDyadOrient > 360) {
    touchAngleRelativeToDyadOrient -= 360;
  }
  
  if (firstTime) {
    
    _originalDyadminoOrientation = dyadmino.orientation;
    
    _orientationOffset = 0;
    if (touchAngleRelativeToDyadOrient > (0 + 330) % 360 ||
        touchAngleRelativeToDyadOrient <= (0 + 30) % 360) {
      _orientationOffset = 0 + dyadOrient;
      
    } else if (touchAngleRelativeToDyadOrient > (0 + 30) % 360 &&
               touchAngleRelativeToDyadOrient <= (0 + 150) % 360) {
      _orientationOffset = 90 + dyadOrient;
      
    } else if (touchAngleRelativeToDyadOrient > (0 + 150) % 360 &&
               touchAngleRelativeToDyadOrient <= (0 + 210) % 360) {
      _orientationOffset = 180 + dyadOrient;
      
    } else if (touchAngleRelativeToDyadOrient > (0 + 210) % 360 &&
               touchAngleRelativeToDyadOrient <= (0 + 330) % 360) {
      _orientationOffset = 270 + dyadOrient;
    }
    
    while (_orientationOffset > 360) {
      _orientationOffset -= 360;
    }
    
    _touchPivotOffsetAngle = touchAngle - _orientationOffset;
  }
  
  CGFloat trueAngle = (touchAngle - _touchPivotOffsetAngle);
  return trueAngle;
}

-(void)removeDyadmino:(Dyadmino *)dyadmino fromParentAndAddToNewParent:(SKSpriteNode *)newParent withLayout:(BOOL)layout {
  if (dyadmino && newParent && dyadmino.parent != newParent) {
    [dyadmino removeFromParent];
    [newParent addChild:dyadmino];
    
    if (newParent == _boardField) {
      [self incrementDyadminoesInFluxWithLayoutFirst:NO minusDyadmino:nil];
    } else if (newParent == _rackField) {
      NSLog(@"decrement called in method to remove %@", dyadmino);
      [self decrementDyadminoesInFluxWithLayoutLast:layout];
    }
  }
}

-(void)animateRecentlyPlayedDyadminoes {
  
    // this is also in populateBoardSet method, but repeated code can't be helped
  NSDictionary *lastTurn = (NSDictionary *)[self.myMatch.turns lastObject];
  Player *lastPlayer = (Player *)[self.myMatch playerForIndex:[[lastTurn valueForKey:kTurnPlayer] unsignedIntegerValue]];
  NSArray *lastContainer = (NSArray *)[lastTurn valueForKey:kTurnDyadminoes];
  NSArray *lastContainerDataDyads = [self.myMatch dataDyadsInIndexContainer:lastContainer];
  
    // board must enumerate over both board and holding container dyadminoes
  NSMutableSet *tempDataEnumerationSet = [NSMutableSet setWithSet:self.myMatch.board];
  [tempDataEnumerationSet addObjectsFromArray:[self.myMatch dataDyadsInIndexContainer:self.myMatch.holdingIndexContainer]];
  
  for (DataDyadmino *dataDyad in tempDataEnumerationSet) {
    Dyadmino *dyadmino = [self getDyadminoFromDataDyadmino:dataDyad];
    
      // animate last played dyadminoes, and highlight dyadminoes currently in holding container
    [lastContainerDataDyads containsObject:dataDyad] ? [dyadmino animateDyadminoesRecentlyPlayedWithColour:[self.myMatch colourForPlayer:lastPlayer forLabel:YES light:NO]] : nil;
    [self.myMatch holdingsContainsDataDyadmino:dataDyad] ? [dyadmino highlightBoardDyadminoWithColour:[self.myMatch colourForPlayer:_myPlayer forLabel:YES light:NO]] : nil;
  }
}

-(void)moveDyadminoHome:(Dyadmino *)dyadmino andSound:(BOOL)sound {
  [self sendDyadminoHome:dyadmino byPoppingInForUndo:NO andSound:sound withDecrement:YES];
}

-(void)moveDyadminoHome:(Dyadmino *)dyadmino andSound:(BOOL)sound withDecrement:(BOOL)decrement {
    // the sole purpose of having the decrement bool here is when touched board dyadmino
    // sends hovering dyadmino home
  [self sendDyadminoHome:dyadmino byPoppingInForUndo:NO andSound:sound withDecrement:decrement];
}

-(void)popDyadminoHome:(Dyadmino *)dyadmino {
  [self sendDyadminoHome:dyadmino byPoppingInForUndo:YES andSound:NO withDecrement:YES];
}

-(CGPoint)homePositionForDyadmino:(Dyadmino *)dyadmino {
  return [Cell snapPositionForHexCoord:dyadmino.homeHexCoord orientation:dyadmino.homeOrientation andResize:_boardZoomedOut givenHexOrigin:_boardField.hexOrigin];
}

-(CGPoint)tempPositionForDyadmino:(Dyadmino *)dyadmino withHomeOrientation:(BOOL)homeOrientation {
  
  DyadminoOrientation orientation = homeOrientation && (dyadmino != _recentRackDyadmino) ? dyadmino.homeOrientation : dyadmino.orientation;
  return [Cell snapPositionForHexCoord:dyadmino.tempHexCoord orientation:orientation andResize:_boardZoomedOut givenHexOrigin:_boardField.hexOrigin];
}

-(CGPoint)rackPositionForDyadmino:(Dyadmino *)dyadmino {
  return [_rackField getRackPositionAtIndex:dyadmino.rackIndex withCountNumber:self.playerRackDyadminoes.count];
}

#pragma mark - replay and turn methods

-(BOOL)showTurnInfoOrGameResultsForReplay:(BOOL)replay {
  NSArray *turns = self.myMatch.turns;
  if (turns.count > 0) {
    
      // if game has ended, give results
    NSString *turnOrResultsText;
    SKColor *colour;
    Player *turnPlayer;
    
    if (replay) {
      turnOrResultsText = [self.myMatch turnTextLastPlayed:NO];
      
      NSUInteger playerOrder = [[self.myMatch.turns[self.myMatch.replayTurn - 1] objectForKey:kTurnPlayer] unsignedIntegerValue];
      turnPlayer = [self.myMatch playerForIndex:playerOrder];
      colour = [self.myMatch colourForPlayer:turnPlayer forLabel:YES light:NO];

    } else {
      if ([self.myMatch returnGameHasEnded]) {
        turnOrResultsText = [self.myMatch endGameResultsText];
        colour = [SKColor whiteColor];
          // just say it was the last play, no turn number
      } else {
        turnOrResultsText = [self.myMatch turnTextLastPlayed:YES];
        
        NSUInteger playerOrder = [[self.myMatch.turns[self.myMatch.replayTurn - 1] objectForKey:kTurnPlayer] unsignedIntegerValue];
        turnPlayer = [self.myMatch playerForIndex:playerOrder];
        colour = [self.myMatch colourForPlayer:turnPlayer forLabel:YES light:NO];
      }
    }
    
    replay ?
        [self.myDelegate barOrRackLabel:kReplayTurnLabel show:YES toFade:NO withText:turnOrResultsText andColour:colour] :
        [self.myDelegate barOrRackLabel:kLastTurnLabel show:YES toFade:YES withText:turnOrResultsText andColour:colour];
  }
  return YES;
}

-(void)storeDyadminoAttributesBeforeReplay {
  
  self.replayDyadminoesNotMovedThisTurn = [NSMutableSet new];
  
  NSSet *holdingContainerAndRecentRackDyadminoes = [self allTurnDyadminoesPlusRecentRackDyadmino];
  for (Dyadmino *dyadmino in [self allBoardDyadminoesPlusRecentRackDyadmino]) {
    
      // hide player turn dyadminoes
    if ([holdingContainerAndRecentRackDyadminoes containsObject:dyadmino]) {
      [dyadmino animateShrinkForReplayToShrink:YES];
      
    } else {
      dyadmino.preReplayHexCoord = dyadmino.tempHexCoord;
      dyadmino.preReplayOrientation = dyadmino.orientation;
      dyadmino.preReplayTempOrientation = dyadmino.homeOrientation;
    }
  }
}

-(void)restoreDyadminoAttributesAfterReplay {
  
  [self.replayDyadminoesNotMovedThisTurn removeAllObjects];
  
  NSSet *holdingContainerAndRecentRackDyadminoes = [self allTurnDyadminoesPlusRecentRackDyadmino];
  
  for (Dyadmino *dyadmino in [self allBoardDyadminoesPlusRecentRackDyadmino]) {
    
      // show player turn dyadminoes
    if ([holdingContainerAndRecentRackDyadminoes containsObject:dyadmino]) {
      
        // this effectively only updates recent rack dyadmino
      [dyadmino animateShrinkForReplayToShrink:NO];
      
    } else {
      
      if (dyadmino.tempHexCoord.x == dyadmino.preReplayHexCoord.x &&
          dyadmino.tempHexCoord.y == dyadmino.preReplayHexCoord.y &&
          dyadmino.homeOrientation == dyadmino.preReplayTempOrientation) {
        [self.replayDyadminoesNotMovedThisTurn addObject:dyadmino];
      }
      
      dyadmino.tempHexCoord = dyadmino.preReplayHexCoord;
      
        // orientation will be animated in sendDyadminoHome method called by updateBoardForReplay
      dyadmino.homeOrientation = dyadmino.preReplayTempOrientation;
    }
  }
}

-(void)updateViewForReplayInReplay:(BOOL)inReplay {

  [self updateBoardForReplayInReplay:inReplay];
  [self showTurnInfoOrGameResultsForReplay:inReplay];
  inReplay ? [self updateReplayButtons] : nil;
}

-(void)updateBoardForReplayInReplay:(BOOL)inReplay {
  
  if (inReplay) {
    [self.replayDyadminoesNotMovedThisTurn removeAllObjects];
  }

    // match already knows the turn number
    // get player and dyadminoes for this turn
  Player *turnPlayer;
  NSArray *turnDataDyadminoIndexes;
  
  if (inReplay) {
    NSUInteger playerOrder = [[self.myMatch.turns[self.myMatch.replayTurn - 1] objectForKey:kTurnPlayer] unsignedIntegerValue];
    turnPlayer = [self.myMatch playerForIndex:playerOrder];
    turnDataDyadminoIndexes = [self.myMatch.turns[self.myMatch.replayTurn - 1] objectForKey:kTurnDyadminoes];
  } else {
    turnPlayer = _myPlayer;
    turnDataDyadminoIndexes = @[];
  }
  
  for (Dyadmino *dyadmino in [self allBoardDyadminoesNotTurnOrRecentRack]) {
    DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
    
      // if in replay only show dyadminoes played up to this turn,
      // and add to set that will be passed to board
      // if not in replay, conditional is automatically yes
    
    BOOL conditionalToHideDyadmino = inReplay ? ![self.myMatch.replayBoard containsObject:dataDyad] : NO;
    
      // do not add to board
    if (conditionalToHideDyadmino) {
      
          // animate shrinkage
      [dyadmino animateShrinkForReplayToShrink:YES];
      
    } else {
          // animate growage
      [dyadmino animateShrinkForReplayToShrink:NO];
      
        // highlight dyadminoes played on this turn
      [turnDataDyadminoIndexes containsObject:dataDyad.myID] ? [dyadmino highlightBoardDyadminoWithColour:[self.myMatch colourForPlayer:turnPlayer forLabel:YES light:NO]] : [dyadmino unhighlightOutOfPlay];
      
        // if leaving replay, properties have already been reset
      if (inReplay) {
        
        HexCoord turnHexCoord = [dataDyad getHexCoordForTurn:self.myMatch.replayTurn];
        DyadminoOrientation turnOrientation = [dataDyad getOrientationForTurn:self.myMatch.replayTurn];
        
        if (dyadmino.tempHexCoord.x == turnHexCoord.x &&
            dyadmino.tempHexCoord.y == turnHexCoord.y &&
            dyadmino.homeOrientation == turnOrientation) {
          [self.replayDyadminoesNotMovedThisTurn addObject:dyadmino];
        }
        
          // get position and orientation attributes
        dyadmino.tempHexCoord = turnHexCoord;
        dyadmino.homeOrientation = turnOrientation;
      }
      
        // position dyadmino
      [self incrementDyadminoesInFluxWithLayoutFirst:NO minusDyadmino:nil];
      
      if (inReplay) {
        [dyadmino goToTempPositionWithLayout:YES andRescale:NO andOrient:YES];
        
      } else {
        [dyadmino returnHomeToBoardWithLayout:YES andSound:NO withDecrement:YES];
      }
    }
  }
  
  [_boardField layoutAndColourBoardCellsAndSnapPointsOfDyadminoes:self.replayDyadminoesNotMovedThisTurn minusDyadmino:nil updateBounds:NO];
}

-(NSMutableSet *)dyadminoesOnBoardThisReplayTurn {
    // this is only called in toggleBoardZoom
  
  NSMutableSet *dyadminoesOnBoardUpToThisPoint = [NSMutableSet new];
  
  for (Dyadmino *dyadmino in [self allBoardDyadminoesNotTurnOrRecentRack]) {
    DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
    
      // add to board
    if ([self.myMatch.replayBoard containsObject:dataDyad]) {
      [dyadminoesOnBoardUpToThisPoint addObject:dyadmino];
    }
  }
  return dyadminoesOnBoardUpToThisPoint;
}

#pragma mark - action sheet methods

-(void)presentActionSheet:(ActionSheetTag)actionSheetTag withPoints:(NSUInteger)points {
  
  if (!_actionSheetShown) {
    NSString *messageString;
    NSString *cancelButtonString = @"Cancel";
    NSString *destructiveButtonString;
    GameType gameType;
    
    switch (actionSheetTag) {
      case kActionSheetPileNotEnough:
        messageString = @"There aren't enough dyadminoes left in the pile.";
        cancelButtonString = @"Okay";
        break;
        
      case kActionSheetPass:
        messageString = @"Are you sure? This will count as your turn.";
        destructiveButtonString = @"Pass";
        break;
        
      case kActionSheetSwap:
        messageString = ([self.myMatch returnType] == kSelfGame) ?
            @"Are you sure you want to swap?" :
            @"Are you sure? This will count as your turn.";
        destructiveButtonString = @"Swap";
        break;
        
      case kActionSheetStrandedCannotUndo:
        messageString = [NSString stringWithFormat:@"Can't undo dyadmino %@ without leaving others stranded.", [self messageStringForStrandedCannotUndo]];
//        destructiveButtonString = @"Reset";
        cancelButtonString = @"Okay";
        break;
        
      case kActionSheetReset:
        messageString = @"Reset the board and restart this turn?";
        destructiveButtonString = @"Reset";
        break;
        
      case kActionSheetNewLegalChord:
        messageString = [NSString stringWithFormat:@"Are you sure? This can only be undone by resetting the board. You will gain %lu %@.", (unsigned long)points, ((points == 1) ? @"point" : @"points")];
        destructiveButtonString = @"Build";
        break;
        
      case kActionSheetResignPlayer:
         gameType = [self.myMatch returnType];
        if (gameType == kSelfGame) {
          messageString = @"Are you sure you want to end the game?";
        } else if (gameType == kPnPGame || gameType == kGCFriendGame) {
          messageString = @"Are you sure you want to resign?";
        } else if (gameType == kGCRandomGame) {
          messageString = @"Are you sure? This will count as a loss in Game Center.";
        }
        destructiveButtonString = ([self.myMatch returnType] == kSelfGame) ? @"End game" : @"Resign";
        break;
        
      case kActionSheetTurnDone:
        messageString = [NSString stringWithFormat:@"Complete your turn for %lu %@?", (unsigned long)points, ((points == 1) ? @"point" : @"points")];
        destructiveButtonString = @"Complete";
        break;
      default:
        break;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:messageString delegate:self cancelButtonTitle:cancelButtonString destructiveButtonTitle:destructiveButtonString otherButtonTitles:nil, nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    actionSheet.tag = actionSheetTag;
    [actionSheet showInView:self.view];
    _actionSheetShown = YES;
  }
}

-(NSString *)messageStringForStrandedCannotUndo {
  DataDyadmino *dataDyad = [self.myMatch mostRecentDyadminoPlayed];
  Dyadmino *dyadmino = [self getDyadminoFromDataDyadmino:dataDyad];
  return dyadmino.name;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *buttonText = [actionSheet buttonTitleAtIndex:buttonIndex];
  
  _actionSheetShown = NO;
  
  switch (actionSheet.tag) {
    case kActionSheetPileNotEnough:
      break;
      
    case kActionSheetPass:
      if ([buttonText isEqualToString:@"Pass"]) {
        
          // player turn will be finalised after reset board animation
        [self resetBoardFromPass:YES];
      }
      break;
      
    case kActionSheetSwap:
      if ([buttonText isEqualToString:@"Swap"]) {
        
          // because of swap animation, updating topBar labels and buttons must be delayed
          // and thus will be called in finaliseSwap; so just return at this point
        [self finaliseSwap];
        return;
        
      } else if ([buttonText isEqualToString:@"Cancel"]) {
        if (self.swapContainer) {
          [self cancelSwappedDyadminoes];
          [self toggleSwapFieldWithAnimation:YES];
        }
        [self updateTopBarButtons];
        return;
      }
      break;

    case kActionSheetStrandedCannotUndo:
      break;
    case kActionSheetReset:
      if ([buttonText isEqualToString:@"Reset"]) {
        [self resetBoardFromPass:NO];
      }
      break;
      
    case kActionSheetNewLegalChord:
      if ([buttonText isEqualToString:@"Build"]) {
        NSLog(@"_hovering dyadmino is %@", _hoveringDyadmino.name);
        
        NSString *chordsText = [self.myMatch stringForPlacementOfDataDyadmino:[self getDataDyadminoFromDyadmino:_hoveringDyadmino] onBottomHexCoord:_hoveringDyadmino.tempHexCoord withOrientation:_hoveringDyadmino.orientation withCondition:kBothNewAndExtendedChords withInitialString:@"Built " andEndingString:@"."];
        
        [self.myDelegate showChordMessage:chordsText sign:kChordMessageGood autoFade:YES];
        
        [self.myMatch moveBoardDataDyadmino:[self getDataDyadminoFromDyadmino:_hoveringDyadmino] toBottomHexCoord:_hoveringDyadmino.tempHexCoord withOrientation:_hoveringDyadmino.orientation];
        
        [self finishHoveringAfterCheckDyadmino:_hoveringDyadmino];
        
      } else if ([buttonText isEqualToString:@"Cancel"]) {
        [self moveDyadminoHome:_hoveringDyadmino andSound:YES];
      }
      break;
      
    case kActionSheetResignPlayer:
      if ([buttonText isEqualToString:@"Resign"] || [buttonText isEqualToString:@"End game"]) {
        [self.myMatch resignPlayer:_myPlayer];
      }
      break;
      
    case kActionSheetTurnDone:
      if ([buttonText isEqualToString:@"Complete"]) {
        [self finalisePlayerTurn];
      }
      break;
      
    default:
      break;
  }
  
  [self updateTopBarLabelsFinalTurn:YES animated:NO];
  [self updateTopBarButtons];
}

-(void)doSomethingSpecial:(NSString *)specialThing {
    // FIXME: eventually show a screen of some kind
  /*
   UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:specialThing delegate:self cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
   actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
   [actionSheet showInView:self.view];
   */
}

#pragma mark - delegate methods

  // called from rack exchange
-(void)recordChangedDataForRackDyadminoes:(NSArray *)rackArray {
  for (int i = 0; i < rackArray.count; i++) {
    if ([rackArray[i] isKindOfClass:[Dyadmino class]]) {
      Dyadmino *dyadmino = (Dyadmino *)rackArray[i];
      dyadmino.rackIndex = i;
//      NSLog(@"dyadmino %@ has index %i", dyadmino.name, dyadmino.rackIndex);
      DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
      dataDyad.myOrientation = @(dyadmino.orientation);
      dataDyad.myRackOrder = [NSNumber numberWithInteger:dyadmino.rackIndex];
    }
  }
}

  // called by match
-(BOOL)isFirstAndOnlyDyadminoID:(NSUInteger)dyadminoID {
  Dyadmino *dyadmino = [self getDyadminoFromDataDyadmino:[self.myMatch dataDyadminoForIndex:dyadminoID]];
  BOOL firstDyadmino = (self.boardDyadminoes.count == 1 && dyadmino == [self.boardDyadminoes anyObject] && !_recentRackDyadmino);
  return firstDyadmino;
}

-(UIColor *)pivotColourForCurrentPlayerLight:(BOOL)light {
  return [self.myMatch colourForPlayer:_myPlayer forLabel:NO light:light];
}

-(BOOL)actionSheetShown {
  return _actionSheetShown;
}

-(void)toggleFieldActionInProgress:(BOOL)actionInProgress {
  _fieldActionInProgress = actionInProgress;
  [self updateTopBarButtons];
  if (_replayMode) {
    [self updateReplayButtons];
  }
}

-(Dyadmino *)touchDyadminoIfAny {
    // kludge way of letting board know if there is a touched dyadmino
    // because layout of cells will never acknowledge touched dyadmino
  return _touchedDyadmino;
}

-(void)presentActionSheetAfterPivotGuidesHidden {
  [self presentActionSheet:kActionSheetNewLegalChord
                withPoints:_pointsForExtending];
}

-(BOOL)dyadminoShouldBeLocked:(Dyadmino *)dyadmino {
  if (_lockMode) {
    return YES;
  } else if (_replayMode || self.swapContainer || _pnpBarUp) {
    if (!dyadmino) {
      return YES;
    }
    return dyadmino.home == kBoard;
  }
  return NO;
}

//-(SKTexture *)textureForTextureDyadmino:(TextureDyadmino)textureDyadmino {
//  SceneEngine *sceneEngine = [SceneEngine sharedSceneEngine];
//  return [sceneEngine textureForTextureDyadmino:textureDyadmino];
//}

#pragma mark - increment and decrement methods for completing dyadmino animation to temp board cell

-(void)incrementDyadminoesInFluxWithLayoutFirst:(BOOL)layoutFirst minusDyadmino:(Dyadmino *)minusDyadmino {
    // with layout first called only in getReadyToMove (placed board dyadmino only) and undoLastPlayedDyadmino
    // without layout first called only in removeDyadmino:FromParent, updateBoardForReplay, and toggleBoardZoom
  
  _dyadminoFluxCounter++;
  
  if (_dyadminoFluxCounter == 1) {
    
    [self updateTopBarButtons];
    if (_replayMode) {
      [self updateReplayButtons];
    }
    
    if (layoutFirst) {
//      NSLog(@"Layout in first increment");
      NSSet *dyadminoes = _replayMode ? self.replayDyadminoesNotMovedThisTurn : [self allBoardDyadminoesPlusRecentRackDyadmino];
      [_boardField layoutAndColourBoardCellsAndSnapPointsOfDyadminoes:dyadminoes minusDyadmino:minusDyadmino updateBounds:YES];
    }
  }
}

-(void)decrementDyadminoesInFluxWithLayoutLast:(BOOL)layoutLast {
    // with layout last called by completion in dyadmino for replay, ease into board node, and return home to board
    // without layout last called only in removeDyadmino:FromParent (or with, if cancelled board dyadmino)
    // and by completion in dyadmino in returnToRack (for undo only)
  
  if (_dyadminoFluxCounter > 0) {
    _dyadminoFluxCounter--;
  }
  
    // allows for layout when touched rack dyadmino sends home hovering board dyadmino
  if (_dyadminoFluxCounter == 0 || (_dyadminoFluxCounter == 1 && _touchedDyadmino)) {
    
    [self updateTopBarButtons];
    if (_replayMode) {
      [self updateReplayButtons];
    }
    
    if (layoutLast) {
//      NSLog(@"Layout in last decrement");
      NSSet *dyadminoes = _replayMode ? [self dyadminoesOnBoardThisReplayTurn] : [self allBoardDyadminoesPlusRecentRackDyadmino];
      [_boardField layoutAndColourBoardCellsAndSnapPointsOfDyadminoes:dyadminoes minusDyadmino:nil updateBounds:YES];
    }
  }
}

-(BOOL)noActionsInProgress {
  return _dyadminoFluxCounter == 0 && !_fieldActionInProgress;
}

#pragma mark - debugging methods

-(void)toggleDebugMode {
  
  if (_hoveringDyadmino) {
    [self moveDyadminoHome:_hoveringDyadmino andSound:YES];
  }

  for (Dyadmino *dyadmino in [self allBoardDyadminoesPlusRecentRackDyadmino]) {
    dyadmino.hidden = _debugMode;
  }

  [self updateTopBarLabelsFinalTurn:NO animated:NO];
  [self updateTopBarButtons];
}

-(void)logRackDyadminoes {
  NSLog(@"dataDyads are:  %@", [[_myPlayer.rackIndexes valueForKey:@"stringValue"] componentsJoinedByString:@", "]);
  NSLog(@"Dyadminoes are: %@", [[self.playerRackDyadminoes valueForKey:@"name"] componentsJoinedByString:@", "]);
  NSLog(@"holdingCon is:  %@", [[self.myMatch.holdingIndexContainer valueForKey:@"stringValue"] componentsJoinedByString:@", "]);
  NSLog(@"swapContainer:  %@", [[self.swapContainer.allObjects valueForKey:@"stringValue"] componentsJoinedByString:@", "]);
  NSLog(@"rackDyad order: %@", [[self.playerRackDyadminoes valueForKey:@"rackIndex"] componentsJoinedByString:@", "]);
  NSLog(@"board is:       %@", self.boardDyadminoes);
  NSLog(@"match board is  %@", self.myMatch.board);
  NSLog(@"rack is:        %@", self.playerRackDyadminoes);
  NSLog(@"recent rack is: %@", _recentRackDyadmino.name);
}

#pragma mark - singleton method

+(id)sharedMySceneWithSize:(CGSize)size {
  static MyScene *shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[self alloc] initWithSize:size];
  });
  return shared;
}

@end
