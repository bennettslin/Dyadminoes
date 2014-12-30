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
#import "SnapPoint.h"
#import "Player.h"
#import "Rack.h"
#import "Board.h"
#import "TopBar.h"
#import "PnPBar.h"
#import "ReplayBar.h"
#import "Cell.h"
#import "Button.h"
#import "Label.h"
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

@interface MyScene () <FieldNodeDelegate, DyadminoDelegate, BoardDelegate, UIActionSheetDelegate, UIAlertViewDelegate, MatchDelegate, ReturnToGamesButtonDelegate>

  // the dyadminoes that the player sees
@property (strong, nonatomic) NSArray *playerRackDyadminoes;
@property (strong, nonatomic) NSSet *boardDyadminoes; // contains holding container dyadminoes
@property (strong, nonatomic) NSSet *legalChordsForHoveringBoardDyadmino; // instantiated and nillified along with hovering dyadmino
@property (strong, nonatomic) NSSet *allBoardChords;

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
  BOOL _swapMode;
  BOOL _lockMode;
  BOOL _dyadminoesStationary;
  BOOL _dyadminoesHollowed;
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
  
  BOOL _boardDyadminoActionSheetShown;
  
  NSSet *_tempChordSonoritiesFromMovedBoardDyadmino;
  
  BOOL _zoomChangedCellsAlpha; // only used for pinch zoom
  
  SnapPoint *_uponTouchDyadminoNode;
  DyadminoOrientation _uponTouchDyadminoOrientation;
  
    // pointers
  Dyadmino *_touchedDyadmino;
  Dyadmino *_recentRackDyadmino;
  Dyadmino *_hoveringDyadmino;
  BOOL _recentRackDyadminoFormsLegalChord;
  BOOL _undoButtonAllowed; // ensures that player can't quickly undo too many at once, which screws up the animation
  
  Button *_buttonPressed;
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
}

#pragma mark - set up methods

-(id)initWithSize:(CGSize)size {
  
  if (self = [super initWithSize:size]) {
    self.backgroundColor = kBackgroundBoardColour;
    self.name = @"scene";
    self.mySoundEngine = [SoundEngine sharedSoundEngine];
    [self addChild:self.mySoundEngine];
    
    _swapMode = NO;
    _dyadminoesStationary = NO;
    _dyadminoesHollowed = NO;

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

-(BOOL)loadAfterNewMatchRetrieved {
  
  _topBar.position = CGPointMake(0, self.frame.size.height - kTopBarHeight);
  
   // it should not happen that previous match was left
   // while pnpBar was still moving, but just in case
  [_pnpBar removeAllActions];
  
  if ([self.myMatch returnType] == kPnPGame && ![self.myMatch returnGameHasEnded]) {
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
  
  [self.mySoundEngine removeAllActions];
  
  _zoomChangedCellsAlpha = NO;
  _rackExchangeInProgress = NO;
  [_buttonPressed liftWithAnimation:NO andCompletion:nil];
  _buttonPressed = nil;
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
  _uponTouchDyadminoNode = nil;
  _soundedDyadminoFace = nil;
  _touchedDyadmino = nil;
  _recentRackDyadmino = nil;
  _recentRackDyadminoFormsLegalChord = NO;
  [_hoveringDyadmino animateHover:NO];
  _hoveringDyadmino = nil;
  self.legalChordsForHoveringBoardDyadmino = nil;
  _pivotInProgress = NO;
  _boardDyadminoActionSheetShown = NO;
  _endTouchLocationToMeasureDoubleTap = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
  _undoButtonAllowed = YES;
  _tempChordSonoritiesFromMovedBoardDyadmino = nil;
  self.allBoardChords = nil;
  
  if (_lockMode) {
    [self handleDoubleTapForLockModeWithSound:NO];
  }
  
  _myPlayer = [self.myMatch returnCurrentPlayer];
  NSArray *turns = self.myMatch.turns;
  self.myMatch.replayTurn = [NSNumber numberWithUnsignedInteger:turns.count];
  
  
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
  if (![_boardField layoutBoardCellsAndSnapPointsOfDyadminoes:self.boardDyadminoes]) {
    NSLog(@"Board cells and snap points not laid out properly.");
    abort();
  }
  
  if (![self populateBoardWithDyadminoes]) {
    NSLog(@"Dyadminoes were not placed on board properly.");
    abort();
  }
  
    // not for first version
  /*
  [self handleDeviceOrientationChange:[UIDevice currentDevice].orientation];
   */
  
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
  
    // cell alphas are visible by default, hide if PnP mode
  _dyadminoesStationary = ([self.myMatch returnType] == kPnPGame && ![self.myMatch returnGameHasEnded]);
  [self toggleCellsAndDyadminoesAlphaAnimated:NO];
  
    // don't call just yet if it's a PnP game
  if ([self.myMatch returnType] != kPnPGame) {
    [self afterNewPlayerReady];
  }
}

-(void)afterNewPlayerReady {
    // called both when scene is loaded, and when new player is ready in PnP mode
  
  [self refreshBoardChords];
  
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

  if (_debugMode) {
    _debugMode = NO;
    [self toggleDebugMode];
  }

    // establish that cell and dyadmino alphas are normal
    // important because next match might have different dyadminoes
  _dyadminoesStationary = NO;
  [self toggleCellsAndDyadminoesAlphaAnimated:NO];
  
  _swapMode = NO;
  [self toggleSwapFieldWithAnimation:NO];
  
  self.boardDyadminoes = nil;
  self.allBoardChords = nil;
  
  for (SKNode *node in _boardField.children) {
    if ([node isKindOfClass:[Dyadmino class]]) {
      Dyadmino *dyadmino = (Dyadmino *)node;
      [self updateCellsForRemovedDyadmino:dyadmino andColour:YES];
      [dyadmino resetForNewMatch];
    }
  }
  
  [_boardField resetForNewMatch];
  [self prepareRackForNextPlayer];
}

-(void)prepareRackForNextPlayer {
    // called both when leaving scene, and when player finalises turn in PnP mode
  self.playerRackDyadminoes = @[];
  for (Dyadmino *dyadmino in _rackField.children) {
    if ([dyadmino isKindOfClass:[Dyadmino class]]) {
      [dyadmino resetForNewMatch];
    }
  }
}

-(void)goBackToMainViewController {
  
  [self updateOrderOfDataDyadsThisTurnToReflectRackOrder];
  [self postSoundNotification:kNotificationToggleBarOrField];
  
  _dyadminoesStationary = YES;
  [self toggleCellsAndDyadminoesAlphaAnimated:YES];
  
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

#pragma mark - validate chords methods

-(void)refreshBoardChords {
  
    // this is called in afterNewPlayerReady method
    // and after adding to or undoing from array of chords
    // self.allBoardChords is made nil in prepareForNewTurn and willMoveFromView
  
  NSSet *sceneChords = [self loadChordsFromSceneBoardDyadminoes];
  self.allBoardChords = nil;
  self.allBoardChords = sceneChords;
}

-(NSSet *)loadChordsFromSceneBoardDyadminoes {
  
  NSMutableSet *tempLegalChordSonorities = [NSMutableSet new];
  
  NSMutableSet *tempBoardAndPlayedDyadminoes = [NSMutableSet new];
  
    // add board dyadminoes
  [tempBoardAndPlayedDyadminoes addObjectsFromArray:[self.myMatch.board allObjects]];
  
    // add played dyadminoes
  for (NSNumber *indexNumber in self.myMatch.holdingIndexContainer) {
    DataDyadmino *dataDyad = [self.myMatch dataDyadminoForIndex:[indexNumber unsignedIntegerValue]];
    [tempBoardAndPlayedDyadminoes addObject:dataDyad];
  }
  
  for (DataDyadmino *dataDyadmino in tempBoardAndPlayedDyadminoes) {
    Dyadmino *dyadmino = [self getDyadminoFromDataDyadmino:dataDyadmino];
    NSSet *allSonorities = [self.myMatch sonoritiesFromPlacingDyadminoID:dyadmino.myID onBottomHexCoord:dyadmino.homeNode.myCell.hexCoord withOrientation:dyadmino.orientation rulingOutRecentRackID:-1];
    NSSet *legalChordSonorities = [[SonorityLogic sharedLogic] legalChordSonoritiesFromFormationOfSonorities:allSonorities];
    [tempLegalChordSonorities addObjectsFromArray:[legalChordSonorities allObjects]];
  }
  
  return [NSSet setWithSet:tempLegalChordSonorities];
}

#pragma mark - sound methods

-(void)postSoundNotification:(NotificationName)whichNotification {
  NSNumber *whichNotificationObject = [NSNumber numberWithUnsignedInteger:whichNotification];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"playSound" object:self userInfo:@{@"sound": whichNotificationObject}];
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
      [self.myMatch retrieveTopHexCoordForBottomHexCoord:dyadmino.myHexCoord andOrientation:dyadmino.orientation] : dyadmino.myHexCoord;
      
    } else {
      hexCoord = dyadminoRightsideUp ?
      dyadmino.myHexCoord : [self.myMatch retrieveTopHexCoordForBottomHexCoord:dyadmino.myHexCoord andOrientation:dyadmino.orientation];
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
  NSArray *dataDyadsThisTurn = [self.myMatch dataDyadsInIndexContainer:_myPlayer.dataDyadminoIndexesThisTurn];
  
  for (DataDyadmino *dataDyad in dataDyadsThisTurn) {
      // only add if it's not in the holding container
      // if it is, then don't add because holding container is added to board set instead
    if (![self.myMatch holdingsContainsDataDyadmino:dataDyad]) {
      Dyadmino *dyadmino = [self getDyadminoFromDataDyadmino:dataDyad];
      dyadmino.myHexCoord = dataDyad.myHexCoord;
      dyadmino.orientation = [dataDyad returnMyOrientation];
      dyadmino.myRackOrder = [dataDyad returnMyRackOrder];
        // not the best place to set tempReturnOrientation for dyadmino
      dyadmino.tempReturnOrientation = dyadmino.orientation;
      
      [dyadmino selectAndPositionSprites];
      [tempDyadminoArray addObject:dyadmino];
    }
  }
  
    // make sure dyadminoes are sorted
  NSSortDescriptor *sortByRackOrder = [[NSSortDescriptor alloc] initWithKey:@"myRackOrder" ascending:YES];
  [self updateOrderOfDataDyadsThisTurnToReflectRackOrder];
  self.playerRackDyadminoes = [tempDyadminoArray sortedArrayUsingDescriptors:@[sortByRackOrder]];
  return (self.playerRackDyadminoes.count == [(NSArray *)_myPlayer.dataDyadminoIndexesThisTurn count] - [(NSArray *)self.myMatch.holdingIndexContainer count]);
}

-(BOOL)populateBoardSet {
  
    // board must enumerate over both board and holding container dyadminoes
  NSMutableSet *tempDataEnumerationSet = [NSMutableSet setWithSet:self.myMatch.board];
  [tempDataEnumerationSet addObjectsFromArray:[self.myMatch dataDyadsInIndexContainer:self.myMatch.holdingIndexContainer]];
  
  NSMutableSet *tempSet = [[NSMutableSet alloc] initWithCapacity:tempDataEnumerationSet.count];
  
  for (DataDyadmino *dataDyad in tempDataEnumerationSet) {
    Dyadmino *dyadmino = [self getDyadminoFromDataDyadmino:dataDyad];
    dyadmino.myHexCoord = dataDyad.myHexCoord;
    dyadmino.orientation = [dataDyad returnMyOrientation];
    dyadmino.myRackOrder = -1; // signifies it's not in rack
      // not the best place to set tempReturnOrientation here either
    dyadmino.tempReturnOrientation = dyadmino.orientation;
    
    if (![tempSet containsObject:dyadmino]) {
      
      [dyadmino selectAndPositionSprites];
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
  [_boardField repositionBoardWithHomePosition:homePosition andOrigin:(CGPoint)homePosition];
}

-(BOOL)populateBoardWithDyadminoes {
  for (Dyadmino *dyadmino in self.boardDyadminoes) {
    dyadmino.delegate = self;
    
      // this is for the first dyadmino, which doesn't have a boardNode
      // and also other dyadminoes when reloading
    if (!dyadmino.homeNode) {
      NSMutableSet *snapPointsToSearch;
      switch (dyadmino.orientation) {
        case kPC1atTwelveOClock:
        case kPC1atSixOClock:
          snapPointsToSearch = _boardField.snapPointsTwelveOClock;
          break;
        case kPC1atTwoOClock:
        case kPC1atEightOClock:
          snapPointsToSearch = _boardField.snapPointsTwoOClock;
          break;
        case kPC1atFourOClock:
        case kPC1atTenOClock:
          snapPointsToSearch = _boardField.snapPointsTenOClock;
          break;
      }
      
      for (SnapPoint *snapPoint in snapPointsToSearch) {
        if ( snapPoint.myCell.hexCoord.x == dyadmino.myHexCoord.x && snapPoint.myCell.hexCoord.y == dyadmino.myHexCoord.y) {
          dyadmino.homeNode = snapPoint;
          dyadmino.tempBoardNode = dyadmino.homeNode;
        }
      }
    }
    
      //------------------------------------------------------------------------
    
      // update cells
    [self updateCellsForPlacedDyadmino:dyadmino andColour:YES];
    dyadmino.position = dyadmino.homeNode.position;
    [dyadmino orientBySnapNode:dyadmino.homeNode];
    [dyadmino selectAndPositionSprites];
    if (!dyadmino.parent) {
      [_boardField addChild:dyadmino];
    }
    
    if (dyadmino.parent != _boardField) {
      return NO;
    }
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
  _swapMode = NO;
  _swapField.hidden = YES;
  
  return (_swapField.parent == self);
}

-(BOOL)layoutTopBar {
  
  _topBar = [[TopBar alloc] initWithColor:[UIColor clearColor] // kBarBrown
                               andSize:CGSizeMake(self.frame.size.width, kTopBarHeight)
                        andAnchorPoint:CGPointZero
                           andPosition:CGPointMake(0, self.frame.size.height - kTopBarHeight)
                          andZPosition:kZPositionTopBar];
  _topBar.name = @"topBar";
  [_topBar populateWithTopBarButtons];
  [self addChild:_topBar];
  
  _topBar.returnOrStartButton.delegate = self;
  
  return (_topBar.parent == self);
}

-(BOOL)layoutPnPBar {
  
  _pnpBar = [[PnPBar alloc] initWithColor:kFieldPurple andSize:CGSizeMake(self.frame.size.width, kRackHeight) andAnchorPoint:CGPointZero andPosition:CGPointZero andZPosition:kZPositionReplayBottom];
  _pnpBar.name = @"pnpBar";
  [self addChild:_pnpBar];
  
  [_pnpBar populateWithPnPButtonsAndLabel];
  
  return (_pnpBar.parent == self);
}

-(BOOL)layoutReplayBars {
    // initial position is beyond screen
  _replayTop = [[ReplayBar alloc] initWithColor:kReplayTopColour andSize:CGSizeMake(self.frame.size.width, kTopBarHeight) andAnchorPoint:CGPointZero andPosition:CGPointMake(0, self.frame.size.height) andZPosition:kZPositionReplayTop];
  _replayTop.name = @"replayTop";
  [self addChild:_replayTop];
  
  _replayBottom = [[ReplayBar alloc] initWithColor:kReplayBottomColour andSize:CGSizeMake(self.frame.size.width, kRackHeight) andAnchorPoint:CGPointZero andPosition:CGPointMake(0, -kRackHeight) andZPosition:kZPositionReplayBottom];
  _replayBottom.name = @"replayBottom";
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

    [_rackField layoutOrRefreshNodesWithCount:self.playerRackDyadminoes.count];
    [_rackField repositionDyadminoes:self.playerRackDyadminoes fromUndo:undo withAnimation:animation];
    
    for (Dyadmino *dyadmino in self.playerRackDyadminoes) {
      dyadmino.delegate = self;
    }

  } else {
    [_rackField layoutOrRefreshNodesWithCount:self.playerRackDyadminoes.count];
    [_rackField repositionDyadminoes:self.playerRackDyadminoes fromUndo:undo withAnimation:animation];
  }
  
  return YES;
}

#pragma mark - touch gestures

-(void)handlePinchGestureWithScale:(CGFloat)scale andVelocity:(CGFloat)velocity andLocation:(CGPoint)location {
  
  if (_hoveringDyadmino) {
    [self sendDyadminoHome:_hoveringDyadmino fromUndo:NO byPoppingIn:NO andSounding:YES andUpdatingBoardBounds:YES];
  }
  
    // kludge way to fix issue with pinch cancelling touched dyadmino that has not yet been assigned as hovering dyadmino
  if (_touchedDyadmino) {
    Dyadmino *dyadmino = _touchedDyadmino;
    _touchedDyadmino = nil;
    [self sendDyadminoHome:dyadmino fromUndo:NO byPoppingIn:NO andSounding:YES andUpdatingBoardBounds:YES];
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
  CGFloat bottomFloat = _swapMode ? kRackHeight * 2 : kRackHeight;
  return (rightSideUpY > bottomFloat && rightSideUpY < self.size.height - kTopBarHeight) ? YES : NO;
}

-(void)handleDoubleTapForLockModeWithSound:(BOOL)withSound {
  
    // UPDATE: double tap no longer zooms; instead, it toggles lock mode
    // board will center back to user's touch location once zoomed back in
  
  _lockMode = _lockMode ? NO : YES;
  if (withSound) {
    [self postSoundNotification:kNotificationTogglePCs];
  }
  
    // FIXME: this should change dyadmino texture
  SceneEngine *sceneEngine = [SceneEngine sharedSceneEngine];
  for (Dyadmino *dyadmino in sceneEngine.allDyadminoes) {
    dyadmino.hidden = _lockMode;
  }
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

    //--------------------------------------------------------------------------
    /// 3a. button pressed
  
    // cancels button pressed if there's any other touch
  if (_buttonPressed) {
    [self buttonPressedMakeNil];
    return;
  }
  
    // if it's a button, take care of it when touch ended
  if ([_touchNode isKindOfClass:[Button class]] || [_touchNode.parent isKindOfClass:[Button class]]) {
    Button *touchedButton = [_touchNode isKindOfClass:[Button class]] ? (Button *)_touchNode : (Button *)_touchNode.parent;
    
    if ([touchedButton isEnabled] && !_fieldActionInProgress) {
      [self postSoundNotification:kNotificationButtonSunkIn];
      _buttonPressed = touchedButton;
      [_buttonPressed sinkInWithAnimation:YES];
      return;
    }
  }
  
    //--------------------------------------------------------------------------
    /// 3b. dyadmino touched
  
    // dyadmino is not registered if face is touched
  Dyadmino *dyadmino = [self selectDyadminoFromTouchPoint:_currentTouchLocation];
  
  if (!dyadmino.hidden && !_canDoubleTapForDyadminoFlip && ([dyadmino isOnBoard] || !dyadmino.isRotating)) {
    
        // register sound if dyadmino tapped
    if ((!_pnpBarUp && !_replayMode && dyadmino && (!_swapMode || (_swapMode && [dyadmino isInRack])) && !_pivotInProgress) && (!_boardZoomedOut || (_boardZoomedOut && [dyadmino isInRack]))) {
      
          // when face is nil, sound both faces
        [self soundDyadmino:dyadmino withFace:nil];
      
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
            [resonatedDyadmino animateFace:face];
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
    
    if (_touchNode == _boardField || (_touchNode.parent == _boardField && (![_touchNode isKindOfClass:[Dyadmino class]])) ||
        (_touchNode.parent.parent == _boardField && (![_touchNode.parent isKindOfClass:[Dyadmino class]]))) { // cell label, this one is necessary only for testing purposes
      
        // check if double tapped
      if (_canDoubleTapForBoardZoom && !_hoveringDyadmino) {
        CGFloat distance = [self getDistanceFromThisPoint:_beganTouchLocation toThisPoint:_endTouchLocationToMeasureDoubleTap];
        if (distance < kDistanceToDoubleTap) {
          if (!_pnpBarUp && !_swapMode && !_replayMode) {
            [self handleDoubleTapForLockModeWithSound:YES];
          }
        }
      }
      
      _boardToBeMovedOrBeingMoved = YES;
      _canDoubleTapForBoardZoom = YES;
      
        // check to see if hovering dyadmino should be moved along with board or not
      if (_hoveringDyadmino) {
        [_boardField hideAllPivotGuides];
        if ([self.myMatch validatePhysicallyPlacingDyadminoID:_hoveringDyadmino.myID withOrientation:_hoveringDyadmino.orientation onBottomHexCoord:_hoveringDyadmino.tempBoardNode.myCell.hexCoord]) {
          
          _hoveringDyadminoStaysFixedToBoard = YES;
          [self updateCellsForRemovedDyadmino:_hoveringDyadmino andColour:NO];
        } else {
          _hoveringDyadminoStaysFixedToBoard = NO;
        }
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
  
    // if the touch started on a button, do nothing and return
  if (_buttonPressed) {
    SKNode *node = [self nodeAtPoint:[self findTouchLocationFromTouches:touches]];
    
      // although these methods are called, button will check itself
      // to determine whether animations are actually needed
    if (node == _buttonPressed || node.parent == _buttonPressed) {
      [_buttonPressed sinkInWithAnimation:YES];
    } else {
      [_buttonPressed liftWithAnimation:YES andCompletion:nil];
    }
    return;
  }
  
    // register no touches moved while field is being toggled
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
            [resonatedDyadmino animateFace:face];
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
  if ([self getDistanceFromThisPoint:_touchedDyadmino.position toThisPoint:_touchedDyadmino.homeNode.position] > kDistanceAfterCannotRotate) {
    _touchedDyadmino.canFlip = NO;
    
      // buttons updated once
    if ([_touchedDyadmino isOnBoard] && !_buttonsUpdatedThisTouch) {
      [self updateTopBarButtons];
      _buttonsUpdatedThisTouch = YES;
    }
  }
  
    // touched dyadmino is now on board
  if ([_touchedDyadmino belongsInRack] && [_touchedDyadmino isOnBoard]) {
    
      // automatically zoom back in if rack dyadmino moved to board
    _boardZoomedOut ? [self toggleBoardZoomWithTapCentering:NO andCenterLocation:CGPointZero] : nil;
    
      // if rack dyadmino is moved to board, send home recentRack dyadmino
    if (_recentRackDyadmino && _touchedDyadmino != _recentRackDyadmino) {
      
      [self changeColoursAroundDyadmino:_recentRackDyadmino withSign:-1];
      [self sendDyadminoHome:_recentRackDyadmino fromUndo:NO byPoppingIn:NO andSounding:YES andUpdatingBoardBounds:YES];
      
        // or same thing with hovering dyadmino (it will only ever be one or the other)
    } else if (_hoveringDyadmino && _touchedDyadmino != _hoveringDyadmino) {
      [self sendDyadminoHome:_hoveringDyadmino fromUndo:NO byPoppingIn:NO andSounding:YES andUpdatingBoardBounds:YES];
    }
    
      // buttons updated once
    if (!_buttonsUpdatedThisTouch) {
      [self updateTopBarButtons];
      _buttonsUpdatedThisTouch = YES;
    }
  }
  
    // not DRY, but repeats the above, only with touched dyadmino that belongs on board
    // recent rack must be sent home, otherwise chords get messed up
  if ([_touchedDyadmino belongsOnBoard] && [_touchedDyadmino isOnBoard]) {
    [self sendHomeRecentRackDyadminoFromBoardDyadminoMove];
  }
  
    // continue to reset hover count
  [_touchedDyadmino isHovering] ? [_touchedDyadmino changeHoveringStatus:kDyadminoContinuesHovering] : nil;
  
    //  this is the only place that sets dyadmino highlight to YES
    //  dyadmino highlight is reset when sent home or finalised
  if ([_touchedDyadmino belongsInRack] && !_swapMode && !_pivotInProgress) {
      CGPoint dyadminoOffsetPosition = [self addToThisPoint:_currentTouchLocation thisPoint:_touchOffsetVector];
      [_touchedDyadmino adjustHighlightGivenDyadminoOffsetPosition:dyadminoOffsetPosition];
  }
  
    //--------------------------------------------------------------------------
    /// 3b part ii: pivot or move
  
    // if we're currently pivoting, just rotate and return
  if (_pivotInProgress) {
    [self handlePivotOfDyadmino:_hoveringDyadmino];
    return;
  }
  
    // this ensures that pivot guides are not hidden if rack exchange
  if (_touchedDyadmino == _hoveringDyadmino) {
    [_boardField hideAllPivotGuides];
  }
  
    // move the dyadmino!
  _touchedDyadmino.position =
    [self getOffsetForTouchPoint:_currentTouchLocation forDyadmino:_touchedDyadmino];
  
    // move the pivot guide, taking into consideration whether dyadmino is child of board or rack
  CGPoint pivotGuidePosition = [_hoveringDyadmino isOnBoard] ? _hoveringDyadmino.position :
      [self subtractFromThisPoint:_hoveringDyadmino.position thisPoint:_boardField.position];
  [_boardField updatePositionsOfPivotGuidesForDyadminoPosition:pivotGuidePosition];
  
  //--------------------------------------------------------------------------
  /// 3c. dyadmino is just being exchanged in rack
  
    // if it's a rack dyadmino, then while movement is within rack, rearrange dyadminoes
  if (([_touchedDyadmino belongsInRack] && [_touchedDyadmino isInRack]) ||
      _touchedDyadmino.belongsInSwap) {
    
    SnapPoint *rackNode = [self findSnapPointClosestToDyadmino:_touchedDyadmino];
    
    self.playerRackDyadminoes = [_rackField handleRackExchangeOfTouchedDyadmino:_touchedDyadmino
                                     withDyadminoes:self.playerRackDyadminoes
                                 andClosestRackNode:rackNode];
  }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    /// 1. first check whether to even register the touch ended
  
    // kludge way of ensuring that buttonPressed is cancelled upon multiple touches
  
    // this ensures no more than one touch at a time
  UITouch *thisTouch = [touches anyObject];
  _endTouchLocationToMeasureDoubleTap = [self findTouchLocationFromTouches:touches];
  
  if (thisTouch != _currentTouch) {
    [self buttonPressedMakeNil]; // remarkably, it seems both these calls are needed
    return;
  }

  _currentTouch = nil;
  [self endTouchFromTouches:touches];
  [self buttonPressedMakeNil];
}

-(void)endTouchFromTouches:(NSSet *)touches {
  
  if (!_fieldActionInProgress) {
      //--------------------------------------------------------------------------
      /// 2a and b. handle button press and board moved

    SKNode *node = [self nodeAtPoint:[self findTouchLocationFromTouches:touches]];
    
    if (!_touchedDyadmino) { // ensures dyadmino was not placed over button
      if ([node isKindOfClass:[Button class]] || [node.parent isKindOfClass:[Button class]]) {
        Button *button = [node isKindOfClass:[Button class]] ? (Button *)node : (Button *)node.parent;
        if ([button isEnabled]) {
          [self postSoundNotification:kNotificationButtonLifted];
        }

        if (button == _buttonPressed) {
          __weak typeof(self) weakSelf = self;
          [button liftWithAnimation:YES andCompletion:^{
            [weakSelf handleButtonPressed:button];
          }];
        }
        return;
      }
    }

      // board no longer being moved
    if (_boardToBeMovedOrBeingMoved) {
      _boardToBeMovedOrBeingMoved = NO;
      
        // take care of hovering dyadmino
      if (_hoveringDyadminoStaysFixedToBoard) {
        _hoveringDyadmino.tempBoardNode = [self findSnapPointClosestToDyadmino:_hoveringDyadmino];
        [self updateCellsForPlacedDyadmino:_hoveringDyadmino andColour:NO];
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
    
    CGPoint adjustedNewPosition = [_boardField adjustToNewPositionFromBeganLocation:_beganTouchLocation toCurrentLocation:_currentTouchLocation withSwap:_swapMode];
    
    if (_hoveringDyadminoStaysFixedToBoard) {
      _hoveringDyadmino.position = [self addToThisPoint:_hoveringDyadmino.position
                                              thisPoint:[self subtractFromThisPoint:oldBoardPosition
                                                                          thisPoint:adjustedNewPosition]];
      [_boardField updatePositionsOfPivotGuidesForDyadminoPosition:_hoveringDyadmino.position];
    }
  }
}

-(void)toggleBoardZoomWithTapCentering:(BOOL)tapCentering andCenterLocation:(CGPoint)location {

  [self postSoundNotification:kNotificationBoardZoom];
  
  _boardZoomedOut = _boardZoomedOut ? NO : YES;
  _boardField.zoomedOut = _boardZoomedOut;
  
  if (_boardZoomedOut) {
    _boardField.postZoomPosition = _boardField.homePosition;
  } else {

    if (tapCentering) {
      _boardField.postZoomPosition = location;
    }
    
      // ensures that board position is consistent with where view thinks it is, so that there won't be a skip after user moves board
    _boardField.homePosition = _boardField.postZoomPosition;
  }

    // prep board for bounds and position
    // if in replay, only determine cells based on these dyadminoes
  [_boardField determineOutermostCellsBasedOnDyadminoes:(_replayMode ? [self dyadminoesOnBoardThisReplayTurn] : [self allBoardDyadminoesPlusRecentRackDyadmino])];
  [_boardField determineBoardPositionBounds];
  [_boardField repositionCellsForZoomWithSwap:_swapMode];
  
    // resize dyadminoes
  for (Dyadmino *dyadmino in [self allBoardDyadminoesPlusRecentRackDyadmino]) {
    [dyadmino removeActionsAndEstablishNotRotatingIncludingMove:YES];
    dyadmino.isTouchThenHoverResized = NO;
    dyadmino.isZoomResized = _boardZoomedOut;
    [self animateRepositionCellAgnosticDyadmino:dyadmino];
  }
}

-(void)handleUserWantsPivotGuides {
  [_boardField handleUserWantsPivotGuides];
  [_boardField hideAllPivotGuides];
}

#pragma mark - dyadmino methods

-(void)beginTouchOrPivotOfDyadmino:(Dyadmino *)dyadmino {
  
  if (dyadmino == _hoveringDyadmino) {
    [_hoveringDyadmino animateHover:NO];
  }
  
    // record tempReturnOrientation only if it's settled and not hovering
  if (dyadmino != _hoveringDyadmino) {
    dyadmino.tempReturnOrientation = dyadmino.orientation;
    
      // board dyadmino sends recent rack dyadmino home upon touch
      // rack dyadmino will do so upon move out of rack
      // (this needs to come before legal chords are checked, so that its placement on board is included)
    (_hoveringDyadmino && [dyadmino isOnBoard]) ? [self sendDyadminoHome:_hoveringDyadmino fromUndo:NO byPoppingIn:NO andSounding:YES andUpdatingBoardBounds:YES] : nil;
  }
  
    // if it belongs on the board, get the chords that it's a part of
    // this is the only place where self.boardDyadminoBelongsInTheseLegalChords is established
    // this particular formation does not care about recent rack dyadmino
  if ([dyadmino belongsOnBoard] && dyadmino != _hoveringDyadmino) {
    NSSet *formationOfSonorities = [self.myMatch sonoritiesFromPlacingDyadminoID:dyadmino.myID onBottomHexCoord:dyadmino.homeNode.myCell.hexCoord withOrientation:dyadmino.orientation rulingOutRecentRackID:(_recentRackDyadmino ? _recentRackDyadmino.myID : -1)];
    self.legalChordsForHoveringBoardDyadmino = [[SonorityLogic sharedLogic] legalChordSonoritiesFromFormationOfSonorities:formationOfSonorities];
  }
  
  [dyadmino isOnBoard] ? [self updateCellsForRemovedDyadmino:dyadmino andColour:(dyadmino != _hoveringDyadmino && !dyadmino.isRotating)] : nil;
  
  [dyadmino startTouchThenHoverResize];
  
  [self getReadyToMoveCurrentDyadmino:_touchedDyadmino];
  
    // if it's now about to pivot, just get pivot angle
  _pivotInProgress ? [self getReadyToPivotHoveringDyadmino:_hoveringDyadmino] : nil;
  
    // if it's on the board and not already rotating, two possibilities
  if ([_touchedDyadmino isOnBoard] && !_touchedDyadmino.isRotating) {
    
    _uponTouchDyadminoNode = dyadmino.tempBoardNode;
    _uponTouchDyadminoOrientation = dyadmino.orientation;
    
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
  

  _touchOffsetVector = [dyadmino isInRack] ? [self subtractFromThisPoint:_beganTouchLocation thisPoint:dyadmino.position] :
      [self subtractFromThisPoint:_beganTouchLocation
                        thisPoint:[self addToThisPoint:dyadmino.position thisPoint:_boardField.position]];
  
  
    // reset hover count
  [dyadmino isHovering] ? [dyadmino changeHoveringStatus:kDyadminoContinuesHovering] : nil;
  [dyadmino removeActionsAndEstablishNotRotatingIncludingMove:YES];
  
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
    if (([dyadmino belongsInRack] || [dyadmino belongsInSwap]) && ![dyadmino isOnBoard]) {
      
        // ...flip if possible, or send it home
      if (dyadmino.canFlip) {
        [dyadmino animateFlip];
        
      } else {
        [self sendDyadminoHome:dyadmino fromUndo:NO byPoppingIn:NO andSounding:YES
            andUpdatingBoardBounds:(dyadmino == _recentRackDyadmino)];
          // just settles into rack or swap
        [self updateTopBarButtons];
      }
      
        // or if dyadmino is in top bar...
    } else if (dyadmino.isInTopBar) {;
      
        // if it's a board dyadmino
      if ([dyadmino.homeNode isBoardNode]) {
        dyadmino.tempBoardNode = nil;
        
          // it's a rack dyadmino
      } else {
          // moved colorBlendFactor reset here to dyadmino's goHomeToRack method
      }
      
      [self sendDyadminoHome:dyadmino fromUndo:NO byPoppingIn:NO andSounding:YES andUpdatingBoardBounds:YES];
      
        // or if dyadmino is in rack but belongs on board (this seems to work)
    } else if ([dyadmino belongsOnBoard] && [dyadmino isInRack]) {
      dyadmino.tempBoardNode = nil;
      [self removeDyadmino:dyadmino fromParentAndAddToNewParent:_boardField];
      dyadmino.position = [_boardField getOffsetFromPoint:dyadmino.position];
      [_boardField updatePositionsOfPivotGuidesForDyadminoPosition:dyadmino.position];
      [self sendDyadminoHome:dyadmino fromUndo:NO byPoppingIn:NO andSounding:YES andUpdatingBoardBounds:YES];
      
        // otherwise, prepare it for hover
    } else {
      [dyadmino correctZRotationAfterHover];
        // prepareForHover will get called in correctZRotation completion
    }
  }
}

-(void)prepareForHoverThisDyadmino:(Dyadmino *)dyadmino {
  
  if (dyadmino != _touchedDyadmino) {
    _hoveringDyadmino = dyadmino;
    [_hoveringDyadmino animateHover:YES];
    
      // establish the closest board node, without snapping just yet
    dyadmino.tempBoardNode = [self findSnapPointClosestToDyadmino:dyadmino];

      // update cells for placement
    [self updateCellsForPlacedDyadmino:dyadmino andColour:NO];
    
      // start hovering
    [dyadmino removeActionsAndEstablishNotRotatingIncludingMove:YES];
    
    [self checkWhetherToEaseOrKeepHovering:dyadmino];
    
    if (dyadmino.isHovering || dyadmino.continuesToHover) {
      
       // add !_canDoubleTapForDyadminoFlip to have delay after touch ends
      dyadmino.isRotating ? nil : [_boardField hidePivotGuideAndShowPrePivotGuideForDyadmino:dyadmino];
    }
  }
}

-(void)sendDyadminoHome:(Dyadmino *)dyadmino fromUndo:(BOOL)undo byPoppingIn:(BOOL)poppingIn andSounding:(BOOL)sounding andUpdatingBoardBounds:(BOOL)updateBoardBounds {
  
  if (dyadmino != _touchedDyadmino) {
    [self.myDelegate fadeChordMessage];
  }
  
  dyadmino.canFlip = NO;
  
      // reposition if dyadmino is rack dyadmino
  if (dyadmino.parent == _boardField && ([dyadmino belongsInRack] || undo)) {
    CGPoint newPosition = [self addToThisPoint:dyadmino.position thisPoint:_boardField.position];
    [self removeDyadmino:dyadmino fromParentAndAddToNewParent:_rackField];
    dyadmino.position = newPosition;
  }
  
    // otherwise it's a hovering dyadmino
  [self updateCellsForRemovedDyadmino:dyadmino andColour:(dyadmino == _recentRackDyadmino || undo)];
  
    // this is one of two places where board bounds are updated
    // the other is when dyadmino is eased into board node
  
  if (updateBoardBounds) {
    [_boardField layoutBoardCellsAndSnapPointsOfDyadminoes:[self allBoardDyadminoesPlusRecentRackDyadmino]];
  }
  
  [dyadmino endTouchThenHoverResize];
    // this makes nil tempBoardNode
  
  if ([dyadmino belongsInRack] && !undo) {
    _uponTouchDyadminoNode = nil;
    [dyadmino goHomeToRackByPoppingIn:poppingIn andSounding:sounding fromUndo:NO withResize:_boardZoomedOut];
    
  } else if (undo) {
    _uponTouchDyadminoNode = nil;
    [dyadmino goHomeToRackByPoppingIn:poppingIn andSounding:sounding fromUndo:YES withResize:_boardZoomedOut];
    
  } else {
    dyadmino.tempBoardNode = dyadmino.homeNode;
    [dyadmino goHomeToBoardByPoppingIn:poppingIn andSounding:sounding];
  }

    // make nil all pointers
  if (dyadmino == _recentRackDyadmino && [_recentRackDyadmino isInRack]) {
    _recentRackDyadmino = nil;
    _recentRackDyadminoFormsLegalChord = NO;
  };
  
  if (dyadmino == _hoveringDyadmino) {
      // this ensures that pivot guide doesn't disappear if rack exchange
    [_boardField hideAllPivotGuides];
    [_hoveringDyadmino animateHover:NO];
    _hoveringDyadmino = nil;
    
      // don't reset self.boardDyadminoBelongsInTheseLegalChords just yet
      // if there's a currently touched dyadmino that still needs to be compared
    if (!_touchedDyadmino) {
      self.legalChordsForHoveringBoardDyadmino = nil;
    }
  }
  
    // this ensures that dyadmino is properly oriented and positioned before
    // re-updating the cells of its original home node
  if ([dyadmino belongsOnBoard]) {
    dyadmino.orientation = dyadmino.tempReturnOrientation;
    
      // TODO: not sure why colour was set to no before
      // but I set it to yes and now it seems to be fine.
      // keeping this comment here for now just to make absolute sure
    [self updateCellsForPlacedDyadmino:dyadmino andColour:YES];
  }
  
  [self updateTopBarButtons];
}

-(void)sendHomeRecentRackDyadminoFromBoardDyadminoMove {
    // if there's a recent rack dyadmino, send home recentRack dyadmino
  if (_recentRackDyadmino) {
    [self changeColoursAroundDyadmino:_recentRackDyadmino withSign:-1];
    [self sendDyadminoHome:_recentRackDyadmino fromUndo:NO byPoppingIn:NO andSounding:YES andUpdatingBoardBounds:YES];
  }
  
    // buttons updated once
  if (!_buttonsUpdatedThisTouch) {
    [self updateTopBarButtons];
    _buttonsUpdatedThisTouch = YES;
  }
}

-(void)handlePivotOfDyadmino:(Dyadmino *)dyadmino {
  
  CGPoint touchBoardOffset = [_boardField getOffsetFromPoint:_currentTouchLocation];
  
  [_boardField pivotGuidesBasedOnTouchLocation:touchBoardOffset forDyadmino:dyadmino firstTime:NO];
  [dyadmino pivotBasedOnTouchLocation:touchBoardOffset andPivotOnPC:_boardField.pivotOnPC];
}

-(Dyadmino *)assignTouchEndedPointerToDyadmino:(Dyadmino *)dyadmino {
    // rack dyadmino only needs pointer if it's still on board
  if ([dyadmino belongsInRack] && [dyadmino isOnBoard]) {
    _recentRackDyadmino = dyadmino;
  }
  
  _touchedDyadmino = nil;
  return dyadmino;
}

-(void)getReadyToPivotHoveringDyadmino:(Dyadmino *)dyadmino {
  
  [dyadmino removeActionsAndEstablishNotRotatingIncludingMove:YES];
  
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
  [_boardField pivotGuidesBasedOnTouchLocation:touchBoardOffset forDyadmino:dyadmino firstTime:YES];
}

#pragma mark - button methods

-(void)togglePCsUserShaken:(BOOL)userShaken {
  userShaken ? [self postSoundNotification:kNotificationTogglePCs] : nil;
  [[SceneEngine sharedSceneEngine] toggleBetweenLetterAndNumberMode];
}

-(void)handleButtonPressed:(Button *)button {
  
      /// games button
  if (button == _topBar.returnOrStartButton) {
    if (_swapMode) {
      _swapMode = NO;
      [self toggleSwapFieldWithAnimation:YES];
      [self cancelSwappedDyadminoes];
    }
    [self goBackToMainViewController];
    return;
    
      /// pnp button
  } else if (button == _pnpBar.returnOrStartButton) {
    _dyadminoesStationary = NO;

    _pnpBarUp = NO;
    [self togglePnPBarSyncWithRack:YES animated:YES];
    [self toggleCellsAndDyadminoesAlphaAnimated:YES];
    [self afterNewPlayerReady];
  
      /// swap button
  } else if (button == _topBar.swapCancelOrUndoButton &&
             [button confirmSwapCancelOrUndo] == kSwapButton) {
    if (!_swapMode) {
      _swapMode = YES;
      [self toggleSwapFieldWithAnimation:YES];
    }
    
      /// cancel button
  } else if (button == _topBar.swapCancelOrUndoButton &&
             [button confirmSwapCancelOrUndo] == kCancelButton) {
    
      // if in swap mode, cancel swap
    if (_swapMode) {
      _swapMode = NO;
      [self toggleSwapFieldWithAnimation:YES];
      [self cancelSwappedDyadminoes];
      
        // else send dyadmino home
    } else if (_hoveringDyadmino) {
      [self sendDyadminoHome:_hoveringDyadmino fromUndo:NO byPoppingIn:NO andSounding:YES andUpdatingBoardBounds:YES];

        // recent rack dyadmino is sent home
    } else if (_recentRackDyadmino) {
      [self sendDyadminoHome:_recentRackDyadmino fromUndo:NO byPoppingIn:NO andSounding:YES andUpdatingBoardBounds:YES];
    }
    
      /// undo button
  } else if (button == _topBar.swapCancelOrUndoButton &&
             [button confirmSwapCancelOrUndo] == kUndoButton) {
    
    _undoButtonAllowed = NO;
    [self undoLastPlayedDyadmino];
  
      /// play button
  } else if (button == _topBar.passPlayOrDoneButton &&
             [button confirmPassPlayOrDone] == kPlayButton) {
    [self playDyadmino:_recentRackDyadmino];
    
      /// pass or done button
  } else if (button == _topBar.passPlayOrDoneButton &&
             ([button confirmPassPlayOrDone] == kDoneButton || [button confirmPassPlayOrDone] == kPassButton)) {
    if (!_swapMode) {
      if ([self.myMatch sumOfPointsThisTurn] == 0) {
        
          // it's a pass, so confirm with action sheet
        [self presentPassActionSheet];
      } else {
        [self finalisePlayerTurn];
      }
          // finalising a swap
    } else if (_swapMode) {
        // confirm that there's enough dyadminoes in the pile
      NSSet *swapIndexContainer = self.myMatch.swapIndexContainer;
      if (swapIndexContainer.count > self.myMatch.pile.count) {
        
        [self presentNotEnoughInPileActionSheet];
        return;
      } else {
        [self presentSwapActionSheet];
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
      [self updateViewForReplayInReplay:YES start:YES];
      
    } else {
      [self.myMatch leaveReplay];
      [self restoreDyadminoAttributesAfterReplay];
      [self updateViewForReplayInReplay:NO start:NO];
      
        // animate last play, or game results if game ended unless player's turn is already over
      if (_myPlayer == [self.myMatch returnCurrentPlayer]) {
        [self animateRecentlyPlayedDyadminoes];
      }
    }
    return;
    
      // replay buttons
  } else if (button == _replayBottom.firstTurnButton) {
    [self.myMatch first];
    [self updateViewForReplayInReplay:YES start:NO];
  } else if (button == _replayBottom.previousTurnButton) {
    [self.myMatch previous];
    [self updateViewForReplayInReplay:YES start:NO];
  } else if (button == _replayBottom.nextTurnButton) {
    [self.myMatch next];
    [self updateViewForReplayInReplay:YES start:NO];
  } else if (button == _replayBottom.lastTurnButton) {
    [self.myMatch last];
    [self updateViewForReplayInReplay:YES start:NO];
  } else {
    return;
  }
  
  [self updateTopBarLabelsFinalTurn:NO animated:NO];
  [self updateTopBarButtons];
}

-(void)buttonPressedMakeNil {
  [_buttonPressed liftWithAnimation:NO andCompletion:nil];
  _buttonPressed = nil;
}

#pragma mark - match interaction methods

-(void)cancelSwappedDyadminoes {
  _swapMode = NO;
  [self.myMatch removeAllSwaps];
  for (Dyadmino *dyadmino in self.playerRackDyadminoes) {
    if (dyadmino.belongsInSwap) {
      [dyadmino placeInBelongsInSwap:NO];
      [dyadmino goHomeToRackByPoppingIn:NO andSounding:NO fromUndo:NO withResize:NO];
    }
  }
}

-(BOOL)finaliseSwap {
  
  __weak typeof(self) weakSelf = self;
  NSSet *swapIndexContainer = self.myMatch.swapIndexContainer;
    // extra confirmation; this will have been checked when button was done button was first pressed
  if (swapIndexContainer.count <= self.myMatch.pile.count) {
    
    NSMutableArray *toPile = [NSMutableArray new];
    for (Dyadmino *dyadmino in self.playerRackDyadminoes) {
      [dyadmino belongsInSwap] ? [toPile addObject:dyadmino] : nil;
    }
    
      // first take care of views
    for (int i = 0; i < toPile.count; i++) {
      Dyadmino *dyadmino = toPile[i];
      [self removeFromPlayerRackDyadminoes:dyadmino];
      
      SKAction *waitAction = [SKAction waitForDuration:i * kWaitTimeForRackDyadminoPopulate];
      
      SKAction *soundAction = [SKAction runBlock:^{
        [weakSelf postSoundNotification:kNotificationRackExchangeClick];
      }];
      SKAction *moveAction = [SKAction moveToX:0 - _rackField.xIncrementInRack duration:kConstantTime];
      moveAction.timingMode = SKActionTimingEaseOut;
      SKAction *completeAction = [SKAction runBlock:^{
        
        [dyadmino resetForNewMatch];
        if (i == toPile.count - 1) {
          
          [weakSelf updateOrderOfDataDyadsThisTurnToReflectRackOrder];
          
          _swapMode = NO;
          [weakSelf toggleSwapFieldWithAnimation:YES];
          
            // then swap in the logic
          [weakSelf.myMatch swapDyadminoesFromCurrentPlayer];
          
          if ([weakSelf.myMatch returnType] != kPnPGame) {
            [weakSelf populateRackArray];
            [weakSelf refreshRackFieldAndDyadminoesFromUndo:NO withAnimation:YES];
          }
          
            // call this again because animation delays completion
          [weakSelf updateTopBarLabelsFinalTurn:YES animated:NO];
          [weakSelf updateTopBarButtons];
          
          [weakSelf doSomethingSpecial:@"dyadminoes have been swapped."];
        }
      }];
      SKAction *sequence = [SKAction sequence:@[waitAction, soundAction, moveAction, completeAction]];
      [dyadmino removeActionsAndEstablishNotRotatingIncludingMove:YES];
      [dyadmino runAction:sequence withKey:@"swapDyadmino"];
    }
    return YES;
  } else {
    
      // won't get called unless error
    [self updateTopBarLabelsFinalTurn:YES animated:NO];
    [self updateTopBarButtons];
    return NO;
  }
}

-(void)playDyadmino:(Dyadmino *)dyadmino {
  
    // establish that dyadmino is indeed a rack dyadmino placed on the board
  if ([dyadmino belongsInRack] && [dyadmino isOnBoard]) {
    
      // confirm that the dyadmino was successfully played before proceeding with anything else
    DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
    if (![self.myMatch addToHoldingContainer:dataDyad]) {
      NSLog(@"Match failed to add data dyadmino to holding container.");
      abort();
    };
    
      // add chords from this dyadmino to array of chords
    NSSet *sonorities = [self.myMatch sonoritiesFromPlacingDyadminoID:dyadmino.myID onBottomHexCoord:dyadmino.tempBoardNode.myCell.hexCoord withOrientation:dyadmino.orientation rulingOutRecentRackID:-1];
    NSSet *legalChordSonoritiesFormed = [[SonorityLogic sharedLogic] legalChordSonoritiesFromFormationOfSonorities:sonorities];
    
    NSSet *chordSupersets = [[SonorityLogic sharedLogic] sonoritiesInSonorities:legalChordSonoritiesFormed thatAreSupersetsOfSonoritiesInSonorities:self.allBoardChords];

    if (![self.myMatch addToArrayOfChordsAndPointsTheseChordSonorities:legalChordSonoritiesFormed extendedChordSonorities:chordSupersets fromDyadminoID:[dataDyad.myID unsignedIntegerValue]]) {
      NSLog(@"Match failed to add to array of chords.");
      abort();
    } else {
      [self refreshBoardChords];
    }
    
      // change scene values
    [self removeFromPlayerRackDyadminoes:dyadmino];
    [self addToSceneBoardDyadminoes:dyadmino];
    
      // do cleanup, dyadmino's home node is now the board node
    dyadmino.homeNode = dyadmino.tempBoardNode;
    dyadmino.myHexCoord = dyadmino.homeNode.myCell.hexCoord;
    [dyadmino highlightBoardDyadminoWithColour:[self.myMatch colourForPlayer:_myPlayer forLabel:YES light:NO]];
    
      // empty pointers
    _recentRackDyadmino = nil;
    _recentRackDyadminoFormsLegalChord = NO;
    [_hoveringDyadmino animateHover:NO];
    _hoveringDyadmino = nil;
    self.legalChordsForHoveringBoardDyadmino = nil;
    
      // establish data dyadmino properties
    dataDyad.myHexCoord = dyadmino.myHexCoord;
    dataDyad.myOrientation = [NSNumber numberWithUnsignedInteger:dyadmino.orientation];
    
      // show chord message
    NSAttributedString *chordsText = [[SonorityLogic sharedLogic] stringForSonorities:legalChordSonoritiesFormed withInitialString:@"Built " andEndingString:@"."];
    [self.myDelegate showChordMessage:chordsText sign:kChordMessageGood];
  }
  
  [self refreshRackFieldAndDyadminoesFromUndo:NO withAnimation:YES];
  [self recordChangedDataForRackDyadminoes:self.playerRackDyadminoes];
  
  [self updateTopBarLabelsFinalTurn:NO animated:YES];
  [self updateTopBarButtons];
}

-(void)undoLastPlayedDyadmino {
    // remove data dyadmino from holding container
  DataDyadmino *undoneDataDyadmino = [self.myMatch undoDyadminoToHoldingContainer];
  
  if (!undoneDataDyadmino) {
    NSLog(@"Match failed to undo data dyadmino.");
    abort();
    
  } else {
      // remove chords or this dyadmino from array of chords
    if (![self.myMatch undoFromArrayOfChordsAndPointsThisDyadminoID:[undoneDataDyadmino.myID unsignedIntegerValue]]) {
      NSLog(@"Match failed to undo chords for this data dyadmino.");
      abort();
    }
    
      // recalibrate undone dyadmino
    Dyadmino *undoneDyadmino = [self getDyadminoFromDataDyadmino:undoneDataDyadmino];
    undoneDyadmino.tempReturnOrientation = [undoneDataDyadmino returnMyOrientation];
    undoneDyadmino.orientation = [undoneDataDyadmino returnMyOrientation];
    undoneDyadmino.homeNode = nil;
    
      // re-add dyadmino to player rack, remove from scene board, refresh chords
    [self reAddToPlayerRackDyadminoes:undoneDyadmino];
    [self removeFromSceneBoardDyadminoes:undoneDyadmino];
    
    [self recordChangedDataForRackDyadminoes:self.playerRackDyadminoes];
    
      // take care of views
    [self sendDyadminoHome:undoneDyadmino fromUndo:YES byPoppingIn:YES andSounding:NO andUpdatingBoardBounds:YES];
    [self tempStoreForPlayerSceneDataDyadmino:undoneDyadmino];
    
      // do this last to ensure that board layout has been adjusted
    [self refreshBoardChords];
  }
}

-(void)finalisePlayerTurn {
  
  [self updateOrderOfDataDyadsThisTurnToReflectRackOrder];
  
    // no recent rack dyadmino on board
  if (!_recentRackDyadmino) {
    [self tempStoreForPlayerSceneDataDyadminoes]; // for player view
    [self.myMatch recordDyadminoesFromCurrentPlayerWithSwap:NO];
    [self persistChangedBoardDyadminoPositionsAndOrientations]; // for match

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
    
    _dyadminoesStationary = YES;
    [self toggleCellsAndDyadminoesAlphaAnimated:YES];
    
    _pnpBarUp = YES;
    [self togglePnPBarSyncWithRack:YES animated:YES];
    
      // note that prepareRackForNextPlayer and prepareForNewTurn
      // are called in togglePnPBar completion block
      // this is the only place method is called where pnpBarUp is YES
  }
}

-(void)handleEndGame {
  [self updateTopBarLabelsFinalTurn:YES animated:YES];
  
    // FIXME: remove rack dyadminoes here
  NSLog(@"rack dyadminoes should now be removed.");
  
  [self.myDelegate presentFromSceneGameEndedVC];
}

-(void)tempStoreForPlayerSceneDataDyadminoes {
  for (Dyadmino *dyadmino in self.playerRackDyadminoes) {
    
    if (dyadmino != _recentRackDyadmino) { // this should ensure that recent rack dyadmino does not move
      [self tempStoreForPlayerSceneDataDyadmino:dyadmino];
    }
  }
  
  for (Dyadmino *dyadmino in self.boardDyadminoes) {
    [self tempStoreForPlayerSceneDataDyadmino:dyadmino];
  }
}

-(void)tempStoreForPlayerSceneDataDyadmino:(Dyadmino *)dyadmino {
  DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
  
  if ([dyadmino belongsOnBoard]) {
    dataDyad.myHexCoord = dyadmino.homeNode.myCell.hexCoord;
  }
  
  dataDyad.myOrientation = ([dyadmino isOnBoard] && [dyadmino belongsInRack]) ?
      [NSNumber numberWithUnsignedInteger:dyadmino.tempReturnOrientation] :
      [NSNumber numberWithUnsignedInteger:dyadmino.orientation];
  
  dataDyad.myRackOrder = [NSNumber numberWithInteger:dyadmino.myRackOrder];
}

-(void)persistChangedBoardDyadminoPositionsAndOrientations {
    // call this *after* recordDyadminoes to ensure that dataDyad is in match's board
  for (Dyadmino *dyadmino in self.boardDyadminoes) {
    DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
    [self.myMatch persistChangedPositionForBoardDataDyadmino:dataDyad];
  }
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
      [self updateCellsForRemovedDyadmino:_hoveringDyadmino andColour:NO];
      
      _hoveringDyadminoFinishedCorrecting = (_hoveringDyadminoBeingCorrected >= 1) ? 0 : _hoveringDyadminoFinishedCorrecting;
      
    } else if (_hoveringDyadminoFinishedCorrecting == 1) {
      
      if (_hoveringDyadminoFinishedCorrecting >= 1) {
        [self updateCellsForRemovedDyadmino:_hoveringDyadmino andColour:NO];
        _hoveringDyadmino.tempBoardNode = [self findSnapPointClosestToDyadmino:_hoveringDyadmino];
        [self updateCellsForPlacedDyadmino:_hoveringDyadmino andColour:NO];
        
        if (!_canDoubleTapForDyadminoFlip && !_hoveringDyadmino.isRotating) {
          [_boardField hidePivotGuideAndShowPrePivotGuideForDyadmino:_hoveringDyadmino];
        }
        
        _hoveringDyadminoBeingCorrected = (_hoveringDyadminoFinishedCorrecting >= 1) ? 0 : _hoveringDyadminoBeingCorrected;
      }
    }
  }
}

-(void)correctBoardForPositionAfterZoom {
  
  CGFloat zoomFactor = _boardZoomedOut ? kZoomResizeFactor : 1.f;
  CGFloat swapBuffer = _swapMode ? kRackHeight : 0.f; // the height of the swap field
  
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
}

-(void)updateForBoardBeingCorrectedWithinBounds {
  
  if (_fieldActionInProgress) {
    _boardField.homePosition = _boardField.position;

      // method was being returned here, which was preventing the board from correcting its bounds
      // while the replay fields were being toggled. Doesn't seem like a problem to leave return out
//    return;
  }

  CGFloat swapBuffer = _swapMode ? kRackHeight : 0.f; // the height of the swap field
  
    // only prevents board move from touch if it's truly out of bounds
    // it's fine if it's still within the buffer
  _boardBeingCorrectedWithinBounds = ((_boardField.position.x < _boardField.lowestXPos) ||
                                      (_boardField.position.y < _boardField.lowestYPos) ||
                                      (_boardField.position.x > _boardField.highestXPos) ||
                                      (_boardField.position.y > _boardField.highestYPos + swapBuffer)) ? YES : NO;
  
  if (!_boardToBeMovedOrBeingMoved || _boardBeingCorrectedWithinBounds) {
    
    if (_hoveringDyadmino && _boardBeingCorrectedWithinBounds) {
      [_boardField hideAllPivotGuides];
      [self updateCellsForRemovedDyadmino:_hoveringDyadmino andColour:NO];
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
      
    } else {
      alreadyCorrect++;
    }

      // this one is constantly being called even when board is motionless
    if (alreadyCorrect == 4) {

      if (_boardJustShiftedNotCorrected &&
          _hoveringDyadmino && _hoveringDyadmino != _touchedDyadmino) {
        
        _boardJustShiftedNotCorrected = NO;
        [self updateCellsForRemovedDyadmino:_hoveringDyadmino andColour:NO];
        _hoveringDyadmino.tempBoardNode = [self findSnapPointClosestToDyadmino:_hoveringDyadmino];
        [self updateCellsForPlacedDyadmino:_hoveringDyadmino andColour:NO];
        
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
    if (!_canDoubleTapForDyadminoFlip && !_hoveringDyadmino.isRotating) {
      [_boardField hidePivotGuideAndShowPrePivotGuideForDyadmino:_hoveringDyadmino];
    }
  }
}

-(void)updateDyadmino:(Dyadmino *)dyadmino forHover:(CFTimeInterval)currentTime {
  if (!_swapMode) {
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
    
      // 
    if (_hoverTime != 0.f && currentTime > _hoverTime + kAnimateHoverTime) {
      _hoverTime = 0.f;
      
      _uponTouchDyadminoNode = nil;
      [dyadmino changeHoveringStatus:kDyadminoFinishedHovering];
    }
    
    [dyadmino isFinishedHovering] ? [self checkWhetherToEaseOrKeepHovering:dyadmino] : nil;
  }
}

-(void)checkWhetherToEaseOrKeepHovering:(Dyadmino *)dyadmino {
  
      // finish hovering only if placement is legal
  if ([dyadmino isOnBoard] && _touchedDyadmino != dyadmino) {

      // ensures that validation takes place only if placement is uncertain
      // will not get called if returning to homeNode from top bar
    if (dyadmino.tempBoardNode) {
      
        // handle placement results:
        // ease in right away if no error, and if dyadmino was not moved from original spot
      PhysicalPlacementResult placementResult = [self.myMatch validatePhysicallyPlacingDyadminoID:dyadmino.myID withOrientation:dyadmino.orientation onBottomHexCoord:dyadmino.tempBoardNode.myCell.hexCoord];
      
      if (placementResult == kNoError && !(dyadmino.tempBoardNode == _uponTouchDyadminoNode && dyadmino.orientation == _uponTouchDyadminoOrientation)) {
        
  //----------------------------------------------------------------------------
  // permanent or recently played board dyadmino, no illegal sonorities
  //----------------------------------------------------------------------------
        
        NSLog(@"recent rack dyadmino is %lu", (unsigned long)_recentRackDyadmino.myID);
        
        if ([dyadmino belongsOnBoard]) {
          
          NSSet *noRecentRackSonorities = [self.myMatch sonoritiesFromPlacingDyadminoID:dyadmino.myID onBottomHexCoord:dyadmino.tempBoardNode.myCell.hexCoord withOrientation:dyadmino.orientation rulingOutRecentRackID:(_recentRackDyadmino ? _recentRackDyadmino.myID : -1)];
          NSSet *legalChordSonoritiesFormed = [[SonorityLogic sharedLogic] legalChordSonoritiesFromFormationOfSonorities:noRecentRackSonorities];

          id object = [legalChordSonoritiesFormed anyObject];
          
            // if object is not a string, then there's technically no illegal sonorities
          if (![object isKindOfClass:[NSString class]]) {

      //------------------------------------------------------------------------
      // broke existing chords
      //------------------------------------------------------------------------
            
                // but fewer chords does means we've broken existing chords
            if (![[SonorityLogic sharedLogic] setOfLegalChords:self.legalChordsForHoveringBoardDyadmino isSubsetOfSetOfLegalChords:legalChordSonoritiesFormed]) {
              
              NSSet *supersets = [[SonorityLogic sharedLogic] sonoritiesInSonorities:self.legalChordsForHoveringBoardDyadmino thatAreSupersetsOfSonoritiesInSonorities:legalChordSonoritiesFormed];
              
              NSLog(@"legalChordsForHover %@, supersets %@", self.legalChordsForHoveringBoardDyadmino, supersets);
              
              NSAttributedString *chordsText = [[SonorityLogic sharedLogic] stringForSonorities:supersets withInitialString:@"Can't break " andEndingString:@"."];
              
              [self.myDelegate showChordMessage:chordsText sign:kChordMessageBad];
              [dyadmino changeHoveringStatus:kDyadminoContinuesHovering];
              
      //------------------------------------------------------------------------
      // moved board dyadmino created new chords
      //------------------------------------------------------------------------
              
                // extra chords formed means we've just built a new chord
            } else if (![[SonorityLogic sharedLogic] setOfLegalChords:legalChordSonoritiesFormed isSubsetOfSetOfLegalChords:self.legalChordsForHoveringBoardDyadmino]) {
              
              NSSet *chordSupersets = [[SonorityLogic sharedLogic] sonoritiesInSonorities:legalChordSonoritiesFormed thatAreSupersetsOfSonoritiesInSonorities:self.allBoardChords];
              
                // show action sheet if dyadmino was on board before turn
              if ([self.myMatch.board containsObject:[self getDataDyadminoFromDyadmino:dyadmino]]) {
                [self presentNewLegalChordActionSheetWithPoints:[self.myMatch pointsForChordSonorities:legalChordSonoritiesFormed extendedChordSonorities:chordSupersets]];
                _tempChordSonoritiesFromMovedBoardDyadmino = chordSupersets;
                
                NSAttributedString *chordsText = [[SonorityLogic sharedLogic] stringForSonorities:chordSupersets withInitialString:@"Build " andEndingString:@"?"];
                
                [self.myDelegate showChordMessage:chordsText sign:kChordMessageGood];
                [dyadmino changeHoveringStatus:kDyadminoContinuesHovering];
                
                  // otherwise it's a seventh extended from a triad built this turn, so just keep the new chord
              } else {

                NSSet *chordSupersets = [[SonorityLogic sharedLogic] sonoritiesInSonorities:legalChordSonoritiesFormed thatAreSupersetsOfSonoritiesInSonorities:self.allBoardChords];
                
                DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
                
                  // this allows the match to replace the triad recorded from the first time the dyadmino was placed
                if (![self.myMatch addToArrayOfChordsAndPointsTheseChordSonorities:legalChordSonoritiesFormed extendedChordSonorities:chordSupersets fromDyadminoID:[dataDyad.myID unsignedIntegerValue]]) {
                  NSLog(@"Match failed to add to array of chords.");
                  abort();
                } else {
                  [self refreshBoardChords];
                }

                  // update player's temporary score
                [self updateTopBarLabelsFinalTurn:NO animated:YES];
                
                NSAttributedString *chordsText = [[SonorityLogic sharedLogic] stringForSonorities:chordSupersets withInitialString:@"Built " andEndingString:@"."];
                
                [self.myDelegate showChordMessage:chordsText sign:kChordMessageGood];
                [self finishHoveringAfterCheckDyadmino:dyadmino];
              }
              
      //------------------------------------------------------------------------
      // no chords broken or made, perfect!
      //------------------------------------------------------------------------
              
                // just the right amount of chords formed, perfect
            } else {
              [self.myDelegate fadeChordMessage];
              [self finishHoveringAfterCheckDyadmino:dyadmino];
            }
            
  //----------------------------------------------------------------------------
  // permanent or recently played dyadmino, illegal sonorities
  //----------------------------------------------------------------------------
            
              // object is a string, so it's either excess notes, double pcs, or illegal sonority
          } else {
            if ([object isEqualToString:kExcessNotes]) {
              [self.myDelegate showChordMessage:[[NSAttributedString alloc] initWithString:@"Can't have excess notes."] sign:kChordMessageBad];
              
            } else if ([object isEqualToString:kDoublePCs]) {
              [self.myDelegate showChordMessage:[[NSAttributedString alloc] initWithString:@"Can't repeat notes."] sign:kChordMessageBad];
              
                // illegal chords, keep hovering
            } else if ([object isEqualToString:kIllegalSonority]) {
              [self.myDelegate showChordMessage:[[NSAttributedString alloc] initWithString:@"Sonority isn't legal."] sign:kChordMessageBad];
            }
            
            [dyadmino changeHoveringStatus:kDyadminoContinuesHovering];
            [self updateTopBarButtons]; // ensures that buttons are updated if chords are changed after flip
          }
          
  //----------------------------------------------------------------------------
  // rack dyadmino, illegal sonorities
  //----------------------------------------------------------------------------
          
            // rack dyadmino
        } else if ([dyadmino belongsInRack]) {
          
          NSSet *sonorities = [self.myMatch sonoritiesFromPlacingDyadminoID:dyadmino.myID onBottomHexCoord:dyadmino.tempBoardNode.myCell.hexCoord withOrientation:dyadmino.orientation rulingOutRecentRackID:-1];
          NSSet *legalChordSonoritiesFormed = [[SonorityLogic sharedLogic] legalChordSonoritiesFromFormationOfSonorities:sonorities];
          
          NSLog(@"sonorities %@, legalChordSonoritiesFormed %@", sonorities, legalChordSonoritiesFormed);
          
            // totally not DRY
          id object = [legalChordSonoritiesFormed anyObject];
          
            // object is a string, which means it's an illegal sonority of some kind
          if ([object isKindOfClass:[NSString class]]) {
            
            if ([object isEqualToString:kExcessNotes]) {
              _recentRackDyadminoFormsLegalChord = NO;
              [self.myDelegate showChordMessage:[[NSAttributedString alloc] initWithString:@"Can't have excess notes."] sign:kChordMessageBad];
              
            } else if ([object isEqualToString:kDoublePCs]) {
              _recentRackDyadminoFormsLegalChord = NO;
              [self.myDelegate showChordMessage:[[NSAttributedString alloc] initWithString:@"Can't repeat notes."] sign:kChordMessageBad];
              
            } else if ([object isEqualToString:kIllegalSonority]) {
              _recentRackDyadminoFormsLegalChord = NO;
              [self.myDelegate showChordMessage:[[NSAttributedString alloc] initWithString:@"Sonority isn't legal."] sign:kChordMessageBad];
            }
            
  //----------------------------------------------------------------------------
  // rack dyadmino, no illegal sonorities
  //----------------------------------------------------------------------------

      //------------------------------------------------------------------------
      // no new chord made, so it can finish hovering, but it can't be played
      //------------------------------------------------------------------------
            
          } else {
            if (legalChordSonoritiesFormed.count == 0) {
              _recentRackDyadminoFormsLegalChord = NO;
              [self.myDelegate showChordMessage:[[NSAttributedString alloc] initWithString:@"Must build new chord."] sign:kChordMessageBad];

      //------------------------------------------------------------------------
      // new chord made!
      //------------------------------------------------------------------------
              
            } else {
              
                // check whether it's extending a triad into a seventh
              NSSet *chordSupersets = [[SonorityLogic sharedLogic] sonoritiesInSonorities:legalChordSonoritiesFormed thatAreSupersetsOfSonoritiesInSonorities:self.allBoardChords];
              
              _recentRackDyadminoFormsLegalChord = YES;
              NSAttributedString *chordsText = [[SonorityLogic sharedLogic] stringForSonorities:chordSupersets withInitialString:@"Building " andEndingString:@"."];
              [self.myDelegate showChordMessage:chordsText sign:kChordMessageGood];
            }
          }
       
          [self finishHoveringAfterCheckDyadmino:dyadmino];
        }
        
  //----------------------------------------------------------------------------
  // illegal placement, either lone dyadmino or stacked dyadminoes
  //----------------------------------------------------------------------------
        
      } else {
        [dyadmino changeHoveringStatus:kDyadminoContinuesHovering];
        [self updateTopBarButtons]; // ensures that buttons are updated if chords are changed after flip
      }
    }
  }
}

-(void)finishHoveringAfterCheckDyadmino:(Dyadmino *)dyadmino {
  [dyadmino changeHoveringStatus:kDyadminoFinishedHovering];
  if ([dyadmino belongsOnBoard]) {
    
      // this is the only place where a board dyadmino's tempBoardNode becomes its new homeNode
      // this method will record a dyadmino that's already in the match's board
      // this method also gets called if a recently played dyadmino
      // has been moved, but data will not be submitted until the turn is officially done.
    dyadmino.homeNode = dyadmino.tempBoardNode;
    [self tempStoreForPlayerSceneDataDyadmino:dyadmino];
  }
  
    // this is one of two places where board bounds are updated
    // the other is when rack dyadmino is sent home
  [_boardField layoutBoardCellsAndSnapPointsOfDyadminoes:[self allBoardDyadminoesPlusRecentRackDyadmino]];
  
  [_boardField hideAllPivotGuides];
  [dyadmino animateEaseIntoNodeAfterHover];
  [_hoveringDyadmino animateHover:NO];
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
  NSSet *swapIndexContainer = self.myMatch.swapIndexContainer;
    // three main possibilities: game has ended, in game but not player's turn, in game and player's turn
  BOOL gameHasEndedForPlayer = [_myPlayer returnResigned] || [self.myMatch returnGameHasEnded];
  BOOL currentPlayerHasTurn = _myPlayer == [self.myMatch returnCurrentPlayer];
  BOOL thereIsATouchedOrHoveringDyadmino = _touchedDyadmino || _hoveringDyadmino;
  BOOL swapContainerNotEmpty = swapIndexContainer.count > 0;
  
    // this determines whether cancel or undo, so it only cares about rack dyadminoes played
  BOOL noRackDyadminoesPlayedAndNoRecentRackDyadmino = holdingIndexContainer.count == 0 && !_recentRackDyadmino;
  
      // if player has points from moving a board dyadmino, that counts as well
  BOOL noBoardDyadminoesPlayedAndNoRecentRackDyadmino = ([self.myMatch sumOfPointsThisTurn] == 0) && !_recentRackDyadmino;
  
  [_topBar node:_topBar.returnOrStartButton shouldBeEnabled:!_swapMode && !thereIsATouchedOrHoveringDyadmino];
  [_topBar node:_topBar.replayButton shouldBeEnabled:(gameHasEndedForPlayer || !currentPlayerHasTurn || (currentPlayerHasTurn && !_swapMode)) && (turns.count > 0) && !_pnpBarUp];
  [_topBar node:_topBar.swapCancelOrUndoButton shouldBeEnabled:(!gameHasEndedForPlayer && currentPlayerHasTurn) && !_pnpBarUp && _undoButtonAllowed];
  [_topBar node:_topBar.passPlayOrDoneButton shouldBeEnabled:((!gameHasEndedForPlayer && currentPlayerHasTurn) && (!thereIsATouchedOrHoveringDyadmino) && !_pnpBarUp && ((_swapMode && swapContainerNotEmpty) || !_swapMode) && (_swapMode || (!noBoardDyadminoesPlayedAndNoRecentRackDyadmino || (noBoardDyadminoesPlayedAndNoRecentRackDyadmino && [self.myMatch returnType] != kSelfGame))) && (!_recentRackDyadmino || (_recentRackDyadmino && _recentRackDyadminoFormsLegalChord)))];
  [_topBar node:_topBar.optionsButton shouldBeEnabled:(!gameHasEndedForPlayer && (!currentPlayerHasTurn || (currentPlayerHasTurn && !_swapMode))) && !_pnpBarUp];
  
    // FIXME: can be refactored further
  if (_swapMode) {
    [_topBar changeSwapCancelOrUndo:kCancelButton];
    [_topBar changePassPlayOrDone:kDoneButton];

  } else if (thereIsATouchedOrHoveringDyadmino) {
    [_topBar changeSwapCancelOrUndo:kCancelButton];
    [_topBar node:_topBar.swapCancelOrUndoButton shouldBeEnabled:YES];
    [_topBar node:_topBar.replayButton shouldBeEnabled:NO];
    
      // no dyadminoes played, and no recent rack dyadmino
  } else if (noRackDyadminoesPlayedAndNoRecentRackDyadmino) {
    [_topBar changeSwapCancelOrUndo:kSwapButton];
    
      // no pass option in self mode
    if ([self.myMatch returnType] == kSelfGame) {
      [_topBar changePassPlayOrDone:kPlayButton];
    } else {
      
      if (noBoardDyadminoesPlayedAndNoRecentRackDyadmino) {
        [_topBar changePassPlayOrDone:kPassButton];
      } else {
        [_topBar changePassPlayOrDone:kDoneButton];
      }
    }
    
      // a recent rack dyadmino placed on board
     // doesn't matter whether holding container is empty
  } else if (_recentRackDyadmino) {
    [_topBar changeSwapCancelOrUndo:kCancelButton];
    [_topBar changePassPlayOrDone:kPlayButton];
    
      // holding container is not empty, and no recent rack dyadmino
  } else {
    [_topBar changeSwapCancelOrUndo:kUndoButton];
    [_topBar changePassPlayOrDone:kDoneButton];
  }
}

-(void)updateReplayButtons {
  NSArray *turns = self.myMatch.turns;
  BOOL zeroTurns = turns.count <= 1;
  BOOL firstTurn = [self.myMatch returnReplayTurn] == 1;
  BOOL lastTurn = [self.myMatch returnReplayTurn] == turns.count;
  
  [_replayBottom node:_replayBottom.firstTurnButton shouldBeEnabled:!zeroTurns && !firstTurn];
  [_replayBottom node:_replayBottom.previousTurnButton shouldBeEnabled:!zeroTurns && !firstTurn];
  [_replayBottom node:_replayBottom.nextTurnButton shouldBeEnabled:!zeroTurns && !lastTurn];
  [_replayBottom node:_replayBottom.lastTurnButton shouldBeEnabled:!zeroTurns && !lastTurn];
}

-(NSString *)updatePnPLabelForNewPlayer {
  Player *currentPlayer = [self.myMatch returnCurrentPlayer];
  
  return kIsIPhone ?
      [NSString stringWithFormat:@"%@,\nit's your turn!", currentPlayer.playerName] :
      [NSString stringWithFormat:@"%@, it's your turn!", currentPlayer.playerName];
}

#pragma mark - field animation methods

-(void)toggleCellsAndDyadminoesAlphaAnimated:(BOOL)animated {
    // also toggle alpha of board's zoomed in background node
  
    // if dyadminoes already hollowed, just return
  if (_dyadminoesStationary == _dyadminoesHollowed) {
    return;
  }
  
  CGFloat desiredCellAlpha = _dyadminoesStationary ? 0.f : 1.f;
  SKAction *fadeCellAlpha = [SKAction fadeAlphaTo:desiredCellAlpha duration:kConstantTime];
  for (Cell *cell in _boardField.allCells) {
    animated ? [cell.cellNode runAction:fadeCellAlpha withKey:@"fadeCellAlpha"] : [cell.cellNode setAlpha:desiredCellAlpha];
  }
  
  CGFloat desiredDyadminoAlpha = _dyadminoesStationary ? 0.5f : 1.f;
  SKAction *fadeDyadminoAlpha = [SKAction fadeAlphaTo:desiredDyadminoAlpha duration:kConstantTime]; // a little faster than field move
  for (Dyadmino *dyadmino in [self allBoardDyadminoesPlusRecentRackDyadmino]) {
    animated ? [dyadmino runAction:fadeDyadminoAlpha withKey:@"fadeDyadminoAlpha"] : [dyadmino setAlpha:desiredDyadminoAlpha];
  }
  
    // confirm that dyadminoes reflect whether they should be stationary
  _dyadminoesHollowed = _dyadminoesStationary;
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
  
  _fieldActionInProgress = YES;
  if (_pnpBarUp) {
    
    [self.myDelegate barOrRackLabel:kPnPWaitingLabel show:YES toFade:NO withText:[self updatePnPLabelForNewPlayer] andColour:[self.myMatch colourForPlayer:[self.myMatch returnCurrentPlayer] forLabel:YES light:NO]];
    
    _pnpBar.hidden = NO;
    CGFloat yPosition = CGPointZero.y;

    void (^pnpCompletion)(void) = ^void(void) {
      _fieldActionInProgress = NO;
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
        _fieldActionInProgress = NO;
      };

      pnpCompletion = ^void(void) {
        _pnpBar.hidden = YES;
        [weakSelf toggleRackGoOut:NO completion:completion];
      };

    } else {
      pnpCompletion = ^void(void) {
        _fieldActionInProgress = NO;
        _pnpBar.hidden = YES;
      };
    }
    
    [_pnpBar toggleToYPosition:yPosition goOut:YES completion:pnpCompletion withKey:@"togglePnpBar"];
    [self.myDelegate animatePnPLabelGoOut:YES];
  }
}

-(void)toggleReplayFields {
  
    // technically, this will never actually get called
    // because replay button is not highlighted when dyadmino is hovering
  if (_hoveringDyadmino) {
    [self sendDyadminoHome:_hoveringDyadmino fromUndo:NO byPoppingIn:NO andSounding:YES andUpdatingBoardBounds:YES];
  }
  
    // cells will toggle faster than replayBars moves
  _dyadminoesStationary = _replayMode;
  [self toggleCellsAndDyadminoesAlphaAnimated:YES];
  [self postSoundNotification:kNotificationToggleBarOrField];
  
  _fieldActionInProgress = YES;
  
  if (_replayMode) {
      // scene views
    _replayTop.hidden = NO;
    _replayBottom.hidden = NO;
    
    __weak typeof(self) weakSelf = self;
    
    CGFloat topYPosition = self.frame.size.height - kTopBarHeight;
    void (^replayCompletion)(void) = ^void(void) {
      _fieldActionInProgress = NO;
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
        _fieldActionInProgress = NO;
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
        _fieldActionInProgress = NO;
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
  _dyadminoesStationary = _swapMode;
  [self toggleCellsAndDyadminoesAlphaAnimated:YES]; // only animate if board zoomed in
  
  [self postSoundNotification:kNotificationToggleBarOrField];
  
  if (!_swapMode) {
    _fieldActionInProgress = YES;
    
      // swap field action
    
    CGFloat desiredX = -self.frame.size.width;
    void (^swapCompletion)(void) = ^void(void) {
      _fieldActionInProgress = NO;
      _swapField.hidden = YES;
    };
    
    [_swapField toggleToXPosition:desiredX goOut:YES completion:swapCompletion withKey:@"toggleSwap"];
    
      // board action
      // FIXME: when board is moved to top in swap mode, board goes down, then pops back up
    CGFloat swapBuffer = (_boardField.position.y > _boardField.highestYPos) ? _boardField.highestYPos : _boardField.position.y - (kRackHeight / 2);
      
    SKAction *moveBoardAction = [SKAction moveToY:swapBuffer duration:kConstantTime];
    [_boardField runAction:moveBoardAction withKey:@"boardMoveFromSwap"];

  } else {
    _fieldActionInProgress = YES;
    _swapField.hidden = NO;
    _swapField.position = CGPointMake(self.frame.size.width, kRackHeight);
    
      // swap field action
    
    void (^swapCompletion)(void) = ^void(void) {
      _fieldActionInProgress = NO;
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
  [self.myMatch addToSwapDataDyadmino:dataDyad];
}

-(void)removeDataDyadminoFromSwapContainerForDyadmino:(Dyadmino *)dyadmino {
  DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
  [self.myMatch removeFromSwapDataDyadmino:dataDyad];
}

-(void)updateOrderOfDataDyadsThisTurnToReflectRackOrder {
  
  for (NSInteger i = 0; i < self.playerRackDyadminoes.count; i++) {
    Dyadmino *dyadmino = self.playerRackDyadminoes[i];
    DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
    
    dataDyad.myOrientation = [NSNumber numberWithUnsignedInteger:dyadmino.orientation];
    dataDyad.myRackOrder = [NSNumber numberWithInteger:i];
    
    if ([_myPlayer thisTurnContainsDataDyadmino:dataDyad] &&
        ![self.myMatch swapContainerContainsDataDyadmino:dataDyad]) {
      
      [_myPlayer removeFromThisTurnsDataDyadmino:dataDyad];
      [_myPlayer insertInThisTurnsDataDyadmino:dataDyad atIndex:i];
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

-(void)updateCellsForPlacedDyadmino:(Dyadmino *)dyadmino andColour:(BOOL)colour {
  if (!dyadmino.isRotating) {
    
    SnapPoint *snapPoint = dyadmino.tempBoardNode ? dyadmino.tempBoardNode : dyadmino.homeNode;
    
      // update hexCoord of board dyadmino
    dyadmino.myHexCoord = snapPoint.myCell.hexCoord;
    [_boardField updateCellsForDyadmino:dyadmino placedOnBoardNode:snapPoint andColour:colour];
    
    [self.myMatch updateCellsForPlacedDyadminoID:dyadmino.myID pc1:dyadmino.pc1 pc2:dyadmino.pc2 orientation:dyadmino.orientation onBottomCellHexCoord:snapPoint.myCell.hexCoord];
  }
}

-(void)updateCellsForRemovedDyadmino:(Dyadmino *)dyadmino andColour:(BOOL)colour {
  if (!dyadmino.isRotating) {
    if (dyadmino.homeNode) {
      
        // update hexCoord of board dyadmino
      SnapPoint *snapPoint = dyadmino.homeNode;
      dyadmino.myHexCoord = snapPoint.myCell.hexCoord;
    }
    
    [_boardField updateCellsForDyadmino:dyadmino removedFromBoardNode:(dyadmino.tempBoardNode ? dyadmino.tempBoardNode : dyadmino.homeNode) andColour:colour];
    
    [self.myMatch updateCellsForRemovedDyadminoID:dyadmino.myID pc1:dyadmino.pc1 pc2:dyadmino.pc2 orientation:dyadmino.orientation fromBottomCellHexCoord:(dyadmino.tempBoardNode ? dyadmino.tempBoardNode.myCell.hexCoord : dyadmino.homeNode.myCell.hexCoord)];
  }
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
  
  [tempDataDyadSet addObjectsFromArray:[self.myMatch dataDyadsInIndexContainer:_myPlayer.dataDyadminoIndexesThisTurn]];
  
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
  
  if (_pivotInProgress || (!_swapMode && _currentTouchLocation.y - _touchOffsetVector.y >= kRackHeight &&
      _currentTouchLocation.y - _touchOffsetVector.y < self.frame.size.height - kTopBarHeight)) {
    [self removeDyadmino:dyadmino fromParentAndAddToNewParent:_boardField];
    [dyadmino placeInTopBar:NO];
    
      // it's in swap
  } else if (_swapMode && _currentTouchLocation.y - _touchOffsetVector.y > kRackHeight) {
    [dyadmino placeInBelongsInSwap:YES];
    [self addDataDyadminoToSwapContainerForDyadmino:dyadmino];
    
    [dyadmino placeInTopBar:NO];

    // if in rack field, doesn't matter if it's in swap
  } else if (_currentTouchLocation.y - _touchOffsetVector.y <= kRackHeight) {
    [self removeDyadmino:dyadmino fromParentAndAddToNewParent:_rackField];
    [dyadmino placeInBelongsInSwap:NO];
    [self removeDataDyadminoFromSwapContainerForDyadmino:dyadmino];
    [dyadmino placeInTopBar:NO];

      // else it's in the top bar, but this is a clumsy workaround, so be careful!
  } else if (!_swapMode && _currentTouchLocation.y - _touchOffsetVector.y >=
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
      if ([dyadmino isOnBoard] && !_swapMode) {
        
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

-(SnapPoint *)findSnapPointClosestToDyadmino:(Dyadmino *)dyadmino {
  id arrayOrSetToSearch;
  
  if ([self isFirstDyadmino:dyadmino]) {
    Cell *homeCell = dyadmino.tempBoardNode.myCell;
    switch (dyadmino.orientation) {
      case kPC1atTwelveOClock:
      case kPC1atSixOClock:
        return homeCell.boardSnapPointTwelveOClock;
        break;
      case kPC1atTwoOClock:
      case kPC1atEightOClock:
        return homeCell.boardSnapPointTwoOClock;
        break;
      case kPC1atFourOClock:
      case kPC1atTenOClock:
        return homeCell.boardSnapPointTenOClock;
        break;
    }
  }
  
  if (!_swapMode && [dyadmino isOnBoard]) {
    if (dyadmino.orientation == kPC1atTwelveOClock || dyadmino.orientation == kPC1atSixOClock) {
      arrayOrSetToSearch = _boardField.snapPointsTwelveOClock;
    } else if (dyadmino.orientation == kPC1atTwoOClock || dyadmino.orientation == kPC1atEightOClock) {
      arrayOrSetToSearch = _boardField.snapPointsTwoOClock;
    } else if (dyadmino.orientation == kPC1atFourOClock || dyadmino.orientation == kPC1atTenOClock) {
      arrayOrSetToSearch = _boardField.snapPointsTenOClock;
    }
    
  } else if ([dyadmino isInRack] || dyadmino.belongsInSwap) {
    arrayOrSetToSearch = _rackField.rackNodes;
  }
  
    // get the closest snapPoint
  SnapPoint *closestSnapPoint;
  CGFloat shortestDistance = self.frame.size.height;
  
  for (SnapPoint *snapPoint in arrayOrSetToSearch) {
      CGFloat thisDistance = [self getDistanceFromThisPoint:dyadmino.position
                                                toThisPoint:snapPoint.position];
      if (thisDistance < shortestDistance) {
        shortestDistance = thisDistance;
        closestSnapPoint = snapPoint;
      }
    }
  
  return closestSnapPoint;
}

-(void)removeDyadmino:(Dyadmino *)dyadmino fromParentAndAddToNewParent:(SKSpriteNode *)newParent {
  if (dyadmino && newParent && dyadmino.parent != newParent) {
    [dyadmino removeFromParent];
    [newParent addChild:dyadmino];
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
      
      NSUInteger playerOrder = [[self.myMatch.turns[[self.myMatch returnReplayTurn] - 1] objectForKey:kTurnPlayer] unsignedIntegerValue];
      turnPlayer = [self.myMatch playerForIndex:playerOrder];
      colour = [self.myMatch colourForPlayer:turnPlayer forLabel:YES light:NO];

    } else {
      if ([self.myMatch returnGameHasEnded]) {
        turnOrResultsText = [self.myMatch endGameResultsText];
        colour = [SKColor whiteColor];
          // just say it was the last play, no turn number
      } else {
        turnOrResultsText = [self.myMatch turnTextLastPlayed:YES];
        
        NSUInteger playerOrder = [[self.myMatch.turns[[self.myMatch returnReplayTurn] - 1] objectForKey:kTurnPlayer] unsignedIntegerValue];
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
  
    // dyadminoes do not lose their homeNodes or tempNodes
  NSSet *holdingContainerAndRecentRackDyadminoes = [self allTurnDyadminoesPlusRecentRackDyadmino];
  for (Dyadmino *dyadmino in [self allBoardDyadminoesPlusRecentRackDyadmino]) {
    
      // hide player turn dyadminoes
    if ([holdingContainerAndRecentRackDyadminoes containsObject:dyadmino]) {
      [self animateScaleForReplayOfDyadmino:dyadmino toShrink:YES];
      
    } else {
      dyadmino.preReplayHexCoord = dyadmino.myHexCoord;
      dyadmino.preReplayOrientation = dyadmino.orientation;
      dyadmino.preReplayTempOrientation = dyadmino.tempReturnOrientation;
    }
  }
}

-(void)restoreDyadminoAttributesAfterReplay {
  
  NSSet *holdingContainerAndRecentRackDyadminoes = [self allTurnDyadminoesPlusRecentRackDyadmino];
  for (Dyadmino *dyadmino in [self allBoardDyadminoesPlusRecentRackDyadmino]) {
    
      // show player turn dyadminoes
    if ([holdingContainerAndRecentRackDyadminoes containsObject:dyadmino]) {
      [self animateScaleForReplayOfDyadmino:dyadmino toShrink:NO];
      
    } else {
      dyadmino.myHexCoord = dyadmino.preReplayHexCoord;
      dyadmino.orientation = dyadmino.preReplayOrientation;
      dyadmino.tempReturnOrientation = dyadmino.preReplayTempOrientation;
    }
  }
}

-(void)updateViewForReplayInReplay:(BOOL)inReplay start:(BOOL)start {

  [self updateBoardForReplayInReplay:inReplay start:start];
  [self showTurnInfoOrGameResultsForReplay:inReplay];
  inReplay ? [self updateReplayButtons] : nil;
}

-(void)updateBoardForReplayInReplay:(BOOL)inReplay start:(BOOL)start {
  
  NSMutableSet *dyadminoesOnBoardUpToThisPoint = inReplay ? [NSMutableSet new] :
      [NSMutableSet setWithSet:[self allBoardDyadminoesPlusRecentRackDyadmino]];
  
    // match already knows the turn number
    // get player and dyadminoes for this turn
  Player *turnPlayer;
  NSArray *turnDataDyadminoIndexes;
  if (inReplay) {
    NSUInteger playerOrder = [[self.myMatch.turns[[self.myMatch returnReplayTurn] - 1] objectForKey:kTurnPlayer] unsignedIntegerValue];
    turnPlayer = [self.myMatch playerForIndex:playerOrder];
    turnDataDyadminoIndexes = [self.myMatch.turns[[self.myMatch returnReplayTurn] - 1] objectForKey:kTurnDyadminoes];
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
      [self animateScaleForReplayOfDyadmino:dyadmino toShrink:YES];
      
    } else {
          // animate growage
      [self animateScaleForReplayOfDyadmino:dyadmino toShrink:NO];
      
        // highlight dyadminoes played on this turn
      [turnDataDyadminoIndexes containsObject:dataDyad.myID] ? [dyadmino highlightBoardDyadminoWithColour:[self.myMatch colourForPlayer:turnPlayer forLabel:YES light:NO]] : [dyadmino unhighlightOutOfPlay];
      
        // if leaving replay, properties have already been reset
      if (inReplay) {
          // get position and orientation attrivutes
        dyadmino.myHexCoord = [dataDyad getHexCoordForTurn:[self.myMatch returnReplayTurn]];
        dyadmino.orientation = [dataDyad getOrientationForTurn:[self.myMatch returnReplayTurn]];
        dyadmino.tempReturnOrientation = dyadmino.orientation;
      }
      
        // position dyadmino
      if (inReplay) {
        [self animateRepositionCellAgnosticDyadmino:dyadmino];
        [dyadminoesOnBoardUpToThisPoint addObject:dyadmino];
      } else {
        [dyadmino goHomeToBoardByPoppingIn:NO andSounding:NO];
      }
    }
  }

  [_boardField determineOutermostCellsBasedOnDyadminoes:dyadminoesOnBoardUpToThisPoint];
  [_boardField determineBoardPositionBounds];
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

-(void)animateRepositionCellAgnosticDyadmino:(Dyadmino *)dyadmino {

    // between .4 and .6
  CGFloat random = ((arc4random() % 100) / 100.f * 0.2) + 0.4f;
  
  CGPoint reposition = [Cell positionCellAgnosticDyadminoGivenHexOrigin:_boardField.hexOrigin andHexCoord:dyadmino.myHexCoord andOrientation:dyadmino.orientation andResize:_boardZoomedOut];
  SKAction *repositionAction = [SKAction moveTo:reposition duration:kConstantTime * random];
  SKAction *completeAction = [SKAction runBlock:^{
    dyadmino.zPosition = kZPositionBoardRestingDyadmino;
  }];
  SKAction *sequenceAction = [SKAction sequence:@[repositionAction, completeAction]];
  
  [dyadmino removeActionForKey:@"replayAction"];
  dyadmino.zPosition = kZPositionBoardReplayAnimatedDyadmino;
  [dyadmino runAction:sequenceAction withKey:@"replayAction"];
  [dyadmino selectAndPositionSprites];
}

-(void)animateScaleForReplayOfDyadmino:(Dyadmino *)dyadmino toShrink:(BOOL)shrink {
    // no animation if dyadmino is already at the desired scale

    // between .4 and .6
  CGFloat random = ((arc4random() % 100) / 100.f * 0.2) + 0.4f;
  
  if (shrink) {
    SKAction *shrinkAction = [SKAction scaleTo:0.f duration:kConstantTime * random];
    SKAction *hideAction = [SKAction runBlock:^{
      dyadmino.hidden = YES;
      dyadmino.zPosition = kZPositionBoardRestingDyadmino;
    }];
    SKAction *sequence = [SKAction sequence:@[shrinkAction, hideAction]];
    
    dyadmino.zPosition = kZPositionBoardReplayAnimatedDyadmino;
    [dyadmino removeActionForKey:@"replayShrink"];
    [dyadmino runAction:sequence withKey:@"replayShrink"];
    
  } else {
    SKAction *growAction = [SKAction scaleTo:1.f duration:kConstantTime * 0.5f];
    SKAction *completeAction = [SKAction runBlock:^{
      dyadmino.zPosition = kZPositionBoardRestingDyadmino;
    }];
    SKAction *sequence = [SKAction sequence:@[growAction, completeAction]];
    dyadmino.hidden = NO;
    dyadmino.zPosition = kZPositionBoardReplayAnimatedDyadmino;
    [dyadmino removeActionForKey:@"replayGrow"];
    [dyadmino runAction:sequence withKey:@"replayGrow"];
  }
}

#pragma mark - action sheet methods

-(void)doSomethingSpecial:(NSString *)specialThing {
    // FIXME: eventually show a screen of some kind
  /*
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:specialThing delegate:self cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
  actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
  [actionSheet showInView:self.view];
   */
}

-(void)presentNewLegalChordActionSheetWithPoints:(NSUInteger)points {
  
    // returns if action sheet is already showing
  if (!_boardDyadminoActionSheetShown) {
    NSString *playString = [NSString stringWithFormat:@"Are you sure? Building this chord cannot be undone. You will gain %lu %@.", (unsigned long)points, ((points == 1) ? @"point" : @"points")];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:playString delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Build" otherButtonTitles:nil, nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    actionSheet.tag = 4;
    [actionSheet showInView:self.view];
    _boardDyadminoActionSheetShown = YES;
  }
}

-(void)presentPassActionSheet {
  NSString *passString = ([self.myMatch returnType] == kSelfGame) ?
    @"Are you sure? Passing once in solo mode ends the game." :
    @"Are you sure? This will count as your turn.";
  
  NSString *buttonText = ([self.myMatch returnType] == kSelfGame) ? @"End game" : @"Pass";
  
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:passString delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:buttonText otherButtonTitles:nil, nil];
  actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
  actionSheet.tag = 1;
  [actionSheet showInView:self.view];
}

-(void)presentNotEnoughInPileActionSheet {
  NSString *notEnoughString = @"There aren't enough dyadminoes left in the pile.";

  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:notEnoughString delegate:self cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
  actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
  [actionSheet showInView:self.view];
}

-(void)presentSwapActionSheet {
  
  NSString *swapString = ([self.myMatch returnType] == kSelfGame) ? @"Are you sure you want to swap?" : @"Are you sure? This will count as your turn.";
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:swapString delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Swap" otherButtonTitles:nil, nil];
  actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
  actionSheet.tag = 2;
  [actionSheet showInView:self.view];
}

-(void)presentResignActionSheet {
  
  NSString *resignString;
  GameType type = [self.myMatch returnType];
  if (type == kSelfGame) {
    resignString = @"Are you sure you want to end the game?";
  } else if (type == kPnPGame || type == kGCFriendGame) {
    resignString = @"Are you sure you want to resign?";
  } else if (type == kGCRandomGame) {
    resignString = @"Are you sure? This will count as a loss in Game Center.";
  }
  
  NSString *buttonText = (type == kSelfGame) ? @"End game" : @"Resign";
  
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:resignString delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:buttonText otherButtonTitles:nil, nil];
  actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
  actionSheet.tag = 3;
  [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *buttonText = [actionSheet buttonTitleAtIndex:buttonIndex];
  
      // pass button
  if (actionSheet.tag == 1 && ([buttonText isEqualToString:@"Pass"] || [buttonText isEqualToString:@"End game"])) {
    [self finalisePlayerTurn];
    
      // swap button
  } else if (actionSheet.tag == 2) {
    
      // swap
    if ([buttonText isEqualToString:@"Swap"]) {
      [self finaliseSwap];
      
        // because of swap animation, updating topBar labels and buttons must be delayed
        // and thus will be called in finaliseSwap; so just return at this point
      return;
      
        // cancel swap
    } else if ([buttonText isEqualToString:@"Cancel"]) {
      if (_swapMode) {
        _swapMode = NO;
        [self toggleSwapFieldWithAnimation:YES];
        [self cancelSwappedDyadminoes];
      }
      [self updateTopBarButtons];
      return;
    }
    
      // resign button
  } else if (actionSheet.tag == 3 && ![buttonText isEqualToString:@"Cancel"]) {
    [self.myMatch resignPlayer:_myPlayer];

      // board dyadmino forms new chord
  } else if (actionSheet.tag == 4) {
    _boardDyadminoActionSheetShown = NO;
    if ([buttonText isEqualToString:@"Cancel"]) {
      [self sendDyadminoHome:_hoveringDyadmino fromUndo:NO byPoppingIn:NO andSounding:YES andUpdatingBoardBounds:YES];
      
    } else {
      
      NSSet *chordSupersets = [[SonorityLogic sharedLogic] sonoritiesInSonorities:_tempChordSonoritiesFromMovedBoardDyadmino thatAreSupersetsOfSonoritiesInSonorities:self.allBoardChords];
      
        // add to array of chords, this cannot be undone since it's not from rack
      if (![self.myMatch addToArrayOfChordsAndPointsTheseChordSonorities:_tempChordSonoritiesFromMovedBoardDyadmino extendedChordSonorities:chordSupersets fromDyadminoID:-1]) { // -1 indicates that match recognises this as a board dyadmino
        NSLog(@"Match failed to add to array of chords.");
        abort();
      } else {
        
        [self refreshBoardChords];
        NSAttributedString *chordsText = [[SonorityLogic sharedLogic] stringForSonorities:_tempChordSonoritiesFromMovedBoardDyadmino withInitialString:@"Built " andEndingString:@"."];
        
        [self.myDelegate showChordMessage:chordsText sign:kChordMessageGood];
      }
      
      [self finishHoveringAfterCheckDyadmino:_hoveringDyadmino];
    }
  _tempChordSonoritiesFromMovedBoardDyadmino = nil;
  }
  
  [self updateTopBarLabelsFinalTurn:YES animated:NO];
  [self updateTopBarButtons];
}

#pragma mark - delegate methods

  // called from rack exchange
-(void)recordChangedDataForRackDyadminoes:(NSArray *)rackArray {
  for (int i = 0; i < rackArray.count; i++) {
    if ([rackArray[i] isKindOfClass:[Dyadmino class]]) {
      Dyadmino *dyadmino = (Dyadmino *)rackArray[i];
      dyadmino.myRackOrder = i;
      [self tempStoreForPlayerSceneDataDyadmino:dyadmino];
    }
  }
}

-(BOOL)isFirstDyadmino:(Dyadmino *)dyadmino {
  BOOL firstDyadmino = (self.boardDyadminoes.count == 1 && dyadmino == [self.boardDyadminoes anyObject] && !_recentRackDyadmino);
  return firstDyadmino;
}

-(BOOL)isFirstAndOnlyDyadminoID:(NSUInteger)dyadminoID {
  Dyadmino *dyadmino = [self getDyadminoFromDataDyadmino:[self.myMatch dataDyadminoForIndex:dyadminoID]];
  BOOL firstDyadmino = (self.boardDyadminoes.count == 1 && dyadmino == [self.boardDyadminoes anyObject] && !_recentRackDyadmino);
  return firstDyadmino;
}

-(void)changeColoursAroundDyadmino:(Dyadmino *)dyadmino withSign:(NSInteger)sign {
  [_boardField changeColoursAroundDyadmino:dyadmino withSign:sign];
}

-(UIColor *)pivotColourForCurrentPlayerLight:(BOOL)light {
  return [self.myMatch colourForPlayer:_myPlayer forLabel:NO light:light];
}

-(BOOL)sonority:(NSSet *)sonority containsNote:(NSDictionary *)note {
  return [[SonorityLogic sharedLogic] sonority:sonority containsNote:note];
}

-(void)allowUndoButton {
  _undoButtonAllowed = YES;
  [self updateTopBarButtons];
}

-(BOOL)actionSheetShown {
  return _boardDyadminoActionSheetShown;
}

-(void)toggleFieldActionInProgress:(BOOL)actionInProgress {
  _fieldActionInProgress = actionInProgress;
}

-(NSAttributedString *)stringForSonorities:(NSSet *)sonorities withInitialString:(NSString *)initialString andEndingString:(NSString *)endingString {
  return [[SonorityLogic sharedLogic] stringForSonorities:sonorities withInitialString:initialString andEndingString:endingString];
}

-(BOOL)sonority:(NSSet *)smaller IsSubsetOfSonority:(NSSet *)larger {
  return [[SonorityLogic sharedLogic] sonority:smaller IsSubsetOfSonority:larger];
}

#pragma mark - debugging methods

-(void)toggleDebugMode {
  
  _hoveringDyadmino ? [self sendDyadminoHome:_hoveringDyadmino fromUndo:NO byPoppingIn:YES andSounding:NO andUpdatingBoardBounds:YES] : nil;
  
//  for (Label *rackLabel in _topBar.playerRackLabels) {
//    [_topBar node:rackLabel shouldBeEnabled:_debugMode];
//  }

  for (Dyadmino *dyadmino in [self allBoardDyadminoesPlusRecentRackDyadmino]) {
    dyadmino.hidden = _debugMode;
  }
  
  for (Cell *cell in _boardField.allCells) {
    if ([cell isKindOfClass:[Cell class]]) {
      cell.hexCoordLabel.hidden = !_debugMode;
      cell.pcLabel.hidden = !_debugMode;
    }
  }
  
//  for (int i = 0; i < kMaxNumPlayers; i++) {
//    Player *player = (i <= self.myMatch.players.count - 1) ? [self.myMatch playerForIndex:i] : nil;
//    Label *rackLabel = _topBar.playerRackLabels[i];
//    [_topBar updateLabel:_topBar.playerRackLabels[i] withText:[[player.dataDyadminoIndexesThisTurn valueForKey:@"stringValue"] componentsJoinedByString:@", "] andColour:nil];
//    player ? nil : [_topBar node:rackLabel shouldBeEnabled:NO];
//  }
  
//  NSString *pileText = [NSString stringWithFormat:@"in pile: %@", [[self.myMatch.pile valueForKey:kDyadminoIDKey] componentsJoinedByString:@", "]];
//  NSMutableArray *tempBoard = [NSMutableArray arrayWithArray:[self.myMatch.board allObjects]];
//  NSString *boardText = [NSString stringWithFormat:@"on board: %@", [[tempBoard valueForKey:kDyadminoIDKey] componentsJoinedByString:@", "]];
//  NSString *holdingContainerText = [NSString stringWithFormat:@"in holding container: %@", [[self.myMatch.holdingIndexContainer valueForKey:@"stringValue"] componentsJoinedByString:@", "]];
//  NSString *swapContainerText = [NSString stringWithFormat:@"in swap container: %@", [[[self.myMatch.swapIndexContainer allObjects] valueForKey:@"stringValue"] componentsJoinedByString:@", "]];
  
//  [_topBar updateLabel:_topBar.pileDyadminoesLabel withText:pileText andColour:nil];
//  [_topBar updateLabel:_topBar.boardDyadminoesLabel withText:boardText andColour:nil];
//  [_topBar updateLabel:_topBar.holdingContainerLabel withText:holdingContainerText andColour:nil];
//  [_topBar updateLabel:_topBar.swapContainerLabel withText:swapContainerText andColour:nil];
  
  [self updateTopBarLabelsFinalTurn:NO animated:NO];
  [self updateTopBarButtons];
  [self logRackDyadminoes];
  
  NSLog(@"match's occupied cells is %@", self.myMatch.occupiedCells);
  NSLog(@"scene's board chords are %@", self.allBoardChords);
  NSSet *set = [self.myMatch sonoritiesFromPlacingDyadminoID:_recentRackDyadmino.myID onBottomHexCoord:_recentRackDyadmino.tempBoardNode.myCell.hexCoord withOrientation:_recentRackDyadmino.orientation rulingOutRecentRackID:-1];
  NSLog(@"sonorities is %@", set);

  for (DataCell *dataCell in self.myMatch.occupiedCells) {
    NSLog(@"cell with pc: %lu, dyadmino: %lu, hex: %li, %li", (unsigned long)dataCell.myPC, (unsigned long)dataCell.myDyadminoID, (long)dataCell.hexCoord.x, (long)dataCell.hexCoord.y);
  }
}

-(void)logRackDyadminoes {
  NSLog(@"dataDyads are:  %@", [[_myPlayer.dataDyadminoIndexesThisTurn valueForKey:@"stringValue"] componentsJoinedByString:@", "]);
  NSLog(@"Dyadminoes are: %@", [[self.playerRackDyadminoes valueForKey:@"name"] componentsJoinedByString:@", "]);
  NSLog(@"holdingCon is:  %@", [[self.myMatch.holdingIndexContainer valueForKey:@"stringValue"] componentsJoinedByString:@", "]);
  NSLog(@"swapContainer:  %@", [[[self.myMatch.swapIndexContainer allObjects] valueForKey:@"stringValue"] componentsJoinedByString:@", "]);
  NSLog(@"rackDyad order: %@", [[self.playerRackDyadminoes valueForKey:@"myRackOrder"] componentsJoinedByString:@", "]);
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

/*
 -(void)handleDeviceOrientationChange:(UIDeviceOrientation)deviceOrientation {
 if ([self.mySceneEngine rotateDyadminoesBasedOnDeviceOrientation:deviceOrientation]) {
 [self postSoundNotification:kNotificationDeviceOrientation];
 }
 
 [_topBar rotateButtonsBasedOnDeviceOrientation:deviceOrientation];
 [_replayTop rotateButtonsBasedOnDeviceOrientation:deviceOrientation];
 [_replayBottom rotateButtonsBasedOnDeviceOrientation:deviceOrientation];
 }
 */
