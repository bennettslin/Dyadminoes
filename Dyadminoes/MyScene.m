//
//  MyScene.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/20/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "MyScene.h"
#import "SceneViewController.h"
#import "SceneEngine.h"
#import "Dyadmino.h"
#import "NSObject+Helper.h"
#import "SnapPoint.h"
#import "Player.h"
#import "Rack.h"
#import "Board.h"
#import "Bar.h"
#import "Cell.h"
#import "Button.h"
#import "Label.h"
#import "Match.h"
#import "DataDyadmino.h"
#import "SoundEngine.h"

#define kBackgroundBoardColour [SKColor darkGrayColor]

@interface MyScene () <FieldNodeDelegate, DyadminoDelegate, BoardDelegate, UIActionSheetDelegate, MatchDelegate>

  // the dyadminoes that the player sees
@property (strong, nonatomic) NSArray *playerRackDyadminoes;
@property (strong, nonatomic) NSSet *boardDyadminoes; // contains holding container dyadminoes

@end

@implementation MyScene {
  
    // sprites and nodes
  Rack *_rackField;
  Rack *_swapField;
  Bar *_replayBottom;
  Board *_boardField;
  SKSpriteNode *_boardCover;
  Bar *_topBar;
  Bar *_replayTop;
  SKNode *_touchNode;
  Bar *_PnPTop;
  Bar *_PnPBottom;

    // touches
  UITouch *_currentTouch;
  CGPoint _beganTouchLocation;
  CGPoint _currentTouchLocation;
  CGPoint _endTouchLocationToMeasureDoubleTap;
  CGPoint _touchOffsetVector;
  
    // bools and modes
  BOOL _replayMode;
  BOOL _swapMode;
  BOOL _rackExchangeInProgress;
  BOOL _fieldActionInProgress;
  BOOL _boardToBeMovedOrBeingMoved;
  BOOL _boardBeingCorrectedWithinBounds;
  BOOL _canDoubleTapForBoardZoom;
  BOOL _canDoubleTapForDyadminoFlip;
  BOOL _hoveringDyadminoToStayFixedWhileBoardMoves;
  BOOL _boardJustShiftedNotCorrected;
  BOOL _boardZoomedOut;
  BOOL _buttonsUpdatedThisTouch;
  
  SnapPoint *_uponTouchDyadminoNode;
  DyadminoOrientation _uponTouchDyadminoOrientation;
  
  SKSpriteNode *_soundedDyadminoFace;
  NSUInteger _hoveringDyadminoBeingCorrected;
  NSUInteger _hoveringDyadminoFinishedCorrecting;
  CFTimeInterval _doubleTapTime;
  
    // pointers
  Dyadmino *_touchedDyadmino;
  Dyadmino *_recentRackDyadmino;
  Dyadmino *_hoveringDyadmino;
  Button *_buttonPressed;

    // hover and pivot properties
  BOOL _pivotInProgress;
  CFTimeInterval _hoverTime;
  
    // test
  BOOL _debugMode;
  
  Player *_myPlayer;
}

#pragma mark - init methods

-(id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    self.backgroundColor = kBackgroundBoardColour;
    self.name = @"scene";
    self.mySoundEngine = [[SoundEngine alloc] init];
    self.mySceneEngine = [[SceneEngine alloc] init];
    [self addChild:self.mySoundEngine];
    
    NSLog(@"layout static scene assets");
    [self layoutBoard];
    [self repositionBoardField];
    [self layoutBoardCover];
    [self layoutSwapField];
    [self layoutReplayFields];
    [self layoutTopBar];
  }
  return self;
}

-(void)loadAfterNewMatchRetrieved {
  [self.mySoundEngine removeAllActions];
  
  _rackExchangeInProgress = NO;
  _buttonPressed = nil;
  _hoveringDyadminoBeingCorrected = 0;
  _hoveringDyadminoFinishedCorrecting = 1;
  _boardZoomedOut = NO;
  _buttonsUpdatedThisTouch = NO;
  _currentTouch = nil;
  _replayMode = NO;
  _swapMode = NO;
  _fieldActionInProgress = NO;
  _boardToBeMovedOrBeingMoved = NO;
  _boardBeingCorrectedWithinBounds = NO;
  _canDoubleTapForBoardZoom = NO;
  _canDoubleTapForDyadminoFlip = NO;
  _hoveringDyadminoToStayFixedWhileBoardMoves = NO;
  _boardJustShiftedNotCorrected = NO;
  _uponTouchDyadminoNode = nil;
  _soundedDyadminoFace = nil;
  _touchedDyadmino = nil;
  _recentRackDyadmino = nil;
  _hoveringDyadmino = nil;
  _pivotInProgress = NO;
  
  _myPlayer = self.myMatch.currentPlayer;
  self.myMatch.delegate = self;
  self.myMatch.replayCounter = self.myMatch.turns.count;
}

-(void)didMoveToView:(SKView *)view {
  
    // ensures that match's board dyadminoes are reset
  [self.myMatch lastOrLeaveReplay];
  
  [self populateRackArray];
  [self populateBoardSet];
  
    // this only needs the board dyadminoes to determine the board's cells ranges
    // this populates the board cells
  [self repositionBoardField];
  [_boardField layoutBoardCellsAndSnapPointsOfDyadminoes:self.boardDyadminoes forZoom:NO];
  [self populateBoardWithDyadminoes];
  
  [self updateTopBarLabelsFinalTurn:NO animated:NO];
  
    // solo mode
  _topBar.resignButton.name = (self.myMatch.type == kSelfGame) ? @"end game" : @"resign";
  [_topBar.resignButton changeName];
  [self updateTopBarButtons];
  
  if (self.myMatch.type == kPnPGame) {
    [self layoutPnPFields];
  }
  [self layoutOrRefreshRackFieldAndDyadminoesFromUndo:NO withAnimation:NO];
  
  [self animateRecentlyPlayedDyadminoes];
  [self showTurnInfoOrGameResultsForReplay:NO];
    // not for first version
//  [self handleDeviceOrientationChange:[UIDevice currentDevice].orientation];
}

-(void)willMoveFromView:(SKView *)view {
  
  NSLog(@"will move from view");
  if (_debugMode) {
    _debugMode = NO;
    [self toggleDebugMode];
  }
  
  self.boardDyadminoes = [NSSet new];
  self.playerRackDyadminoes = @[];
  
  for (SKNode *node in _boardField.children) {
    if ([node isKindOfClass:[Dyadmino class]]) {
      Dyadmino *dyadmino = (Dyadmino *)node;
      [self updateCellsForRemovedDyadmino:dyadmino andColour:YES];
      [dyadmino resetForNewMatch];
      [dyadmino removeFromParent];
    }
  }
  
  [_boardField resetForNewMatch];
  
  for (Dyadmino *dyadmino in _rackField.children) {
    if ([dyadmino isKindOfClass:[Dyadmino class]]) {
      [dyadmino resetForNewMatch];
      [dyadmino removeFromParent];
    }
  }
}

#pragma mark - layout methods

-(void)populateRackArray {
    // keep player's order and orientation of dyadminoes until turn is submitted
  
  NSMutableArray *tempDyadminoArray = [[NSMutableArray alloc] initWithCapacity:_myPlayer.dataDyadminoesThisTurn.count];
  
  for (DataDyadmino *dataDyad in _myPlayer.dataDyadminoesThisTurn) {
      // only add if it's not in the holding container
      // if it is, then don't add because holding container is added to board set instead
    if (![self.myMatch.holdingContainer containsObject:dataDyad]) {
      Dyadmino *dyadmino = (Dyadmino *)self.mySceneEngine.allDyadminoes[dataDyad.myID - 1];
      dyadmino.myHexCoord = dataDyad.myHexCoord;
      dyadmino.orientation = dataDyad.myOrientation;
      dyadmino.myRackOrder = dataDyad.myRackOrder;
//      NSLog(@"this rack order is %i", dyadmino.myRackOrder);
        // not the best place to set tempReturnOrientation for dyadmino
      dyadmino.tempReturnOrientation = dyadmino.orientation;
      
      [dyadmino selectAndPositionSprites];
      [tempDyadminoArray addObject:dyadmino];
    }
  }
  
    // make sure dyadminoes are sorted
  NSSortDescriptor *sortByRackOrder = [[NSSortDescriptor alloc] initWithKey:@"myRackOrder" ascending:YES];
  self.playerRackDyadminoes = [tempDyadminoArray sortedArrayUsingDescriptors:@[sortByRackOrder]];
}

-(void)populateBoardSet {
  
    // board must enumerate over both board and holding container dyadminoes
  NSMutableSet *tempDataEnumerationSet = [NSMutableSet setWithSet:self.myMatch.board];
  [tempDataEnumerationSet addObjectsFromArray:self.myMatch.holdingContainer];
  
  NSMutableSet *tempSet = [[NSMutableSet alloc] initWithCapacity:tempDataEnumerationSet.count];
  
  for (DataDyadmino *dataDyad in tempDataEnumerationSet) {
    Dyadmino *dyadmino = (Dyadmino *)self.mySceneEngine.allDyadminoes[dataDyad.myID - 1];
    dyadmino.myHexCoord = dataDyad.myHexCoord;
    dyadmino.orientation = dataDyad.myOrientation;
    dyadmino.myRackOrder = -1; // signifies it's not in rack
      // not the best place to set tempReturnOrientation here either
    dyadmino.tempReturnOrientation = dyadmino.orientation;
    
    if (![tempSet containsObject:dyadmino]) {
      
      [dyadmino selectAndPositionSprites];
      [tempSet addObject:dyadmino];
    }
  }
  self.boardDyadminoes = [NSSet setWithSet:tempSet];
}

-(void)layoutBoard {
  
  NSLog(@"frame width %.2f, height %.2f", self.frame.size.width, self.frame.size.height);
  CGSize size = CGSizeMake(self.frame.size.width,
                           (self.frame.size.height - kTopBarHeight - kRackHeight));

  _boardField = [[Board alloc] initWithColor:[SKColor clearColor] andSize:size];
  _boardField.delegate = self;
  [self addChild:_boardField];
}

-(void)repositionBoardField {
    // home position is changed with board movement, but origin never changes
  CGPoint homePosition = CGPointMake(self.frame.size.width * 0.5,
                                     (self.frame.size.height + kRackHeight - kTopBarHeight) * 0.5);
  [_boardField repositionBoardWithHomePosition:homePosition andOrigin:(CGPoint)homePosition];
}

-(void)layoutBoardCover {
    // call this method *after* board has been laid out
  _boardCover = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:_boardField.size];
  _boardCover.name = @"boardCover";
  _boardCover.anchorPoint = CGPointMake(0.5, 0.5);
  _boardCover.position = _boardField.homePosition;
  _boardCover.zPosition = kZPositionBoardCoverHidden;
  _boardCover.alpha = kBoardCoverAlpha;
  _boardCover.hidden = YES;
  [self addChild:_boardCover];
}

-(void)populateBoardWithDyadminoes {
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
    [_boardField addChild:dyadmino];
  }
}

-(void)layoutSwapField {
    // initial instantiation of swap field sprite
  _swapField = [[Rack alloc] initWithBoard:_boardField
                                 andColour:kGold
                                   andSize:CGSizeMake(self.frame.size.width, kRackHeight)
                            andAnchorPoint:CGPointZero
                               andPosition:CGPointZero
                              andZPosition:kZPositionSwapField];
  _swapField.name = @"swap";
  [self addChild:_swapField];
  
    // initially sets swap mode
  _swapMode = NO;
  _swapField.hidden = YES;
}

-(void)layoutReplayFields {
    // initial position is beyond screen
  _replayTop = [[Bar alloc] initWithColor:kReplayTopColour andSize:CGSizeMake(self.frame.size.width, kTopBarHeight) andAnchorPoint:CGPointZero andPosition:CGPointMake(0, self.frame.size.height) andZPosition:kZPositionReplayTop];
  _replayTop.name = @"replayTop";
  [self addChild:_replayTop];
  
  _replayBottom = [[Bar alloc] initWithColor:kReplayBottomColour andSize:CGSizeMake(self.frame.size.width, kRackHeight) andAnchorPoint:CGPointZero andPosition:CGPointMake(0, -kRackHeight) andZPosition:kZPositionReplayBottom];
  _replayBottom.name = @"replayBottom";
  [self addChild:_replayBottom];
  
  [_replayTop populateWithTopReplayButtonsAndLabels];
  [_replayBottom populateWithBottomReplayButtons];
  
  _replayMode = NO;
  _replayTop.hidden = YES;
  _replayBottom.hidden = YES;
}

-(void)layoutPnPFields {
    // FIXME: use own constants, not replay field constants
  _PnPTop = [[Bar alloc] initWithColor:kReplayTopColour andSize:CGSizeMake(self.frame.size.width, kTopBarHeight) andAnchorPoint:CGPointZero andPosition:CGPointMake(0, self.frame.size.height) andZPosition:kZPositionReplayTop];
  _replayTop.name = @"PnPTop";
  [self addChild:_PnPTop];
  
  _PnPBottom = [[Bar alloc] initWithColor:kReplayBottomColour andSize:CGSizeMake(self.frame.size.width, kRackHeight) andAnchorPoint:CGPointZero andPosition:CGPointMake(0, -kRackHeight) andZPosition:kZPositionReplayBottom];
  _replayBottom.name = @"PnPBottom";
  [self addChild:_PnPBottom];

  [_PnPTop populateWithTopPnPButtons];
  [_PnPBottom populateWithBottomPnPButtons];

  _PnPTop.hidden = YES;
  _PnPBottom.hidden = YES;
}

-(void)layoutTopBar {

  _topBar = [[Bar alloc] initWithColor:kBarBrown
                                  andSize:CGSizeMake(self.frame.size.width, kTopBarHeight)
                           andAnchorPoint:CGPointZero
                              andPosition:CGPointMake(0, self.frame.size.height - kTopBarHeight)
                             andZPosition:kZPositionTopBar];
  _topBar.name = @"topBar";
  [_topBar populateWithTopBarButtons];
  [_topBar populateWithTopBarLabels];
  [self addChild:_topBar];
  
  _topBar.pileDyadminoesLabel.hidden = YES;
  _topBar.boardDyadminoesLabel.hidden = YES;
  _topBar.holdingContainerLabel.hidden = YES;
  _topBar.swapContainerLabel.hidden = YES;
}

-(void)layoutOrRefreshRackFieldAndDyadminoesFromUndo:(BOOL)undo withAnimation:(BOOL)animation {
  
  if (!_rackField) {
    _rackField = [[Rack alloc] initWithBoard:_boardField
                                   andColour:kPianoBlack
                                     andSize:CGSizeMake(self.frame.size.width, kRackHeight)
                              andAnchorPoint:CGPointZero
                                 andPosition:CGPointZero
                                andZPosition:kZPositionRackField];
    _rackField.delegate = self;
    _rackField.name = @"rack";
    [self addChild:_rackField];
  }
  [_rackField layoutOrRefreshNodesWithCount:self.playerRackDyadminoes.count];
  [_rackField repositionDyadminoes:self.playerRackDyadminoes fromUndo:undo withAnimation:animation];
  
  for (Dyadmino *dyadmino in self.playerRackDyadminoes) {
    dyadmino.delegate = self;
  }
}

-(void)handleDeviceOrientationChange:(UIDeviceOrientation)deviceOrientation {
  if ([self.mySceneEngine rotateDyadminoesBasedOnDeviceOrientation:deviceOrientation]) {
    [self.mySoundEngine soundDeviceOrientation];
  }
  
  NSLog(@"view frame size is %.2f, %.2f", self.view.frame.size.width, self.view.frame.size.height);
  
  [_topBar rotateButtonsBasedOnDeviceOrientation:deviceOrientation];
  [_replayTop rotateButtonsBasedOnDeviceOrientation:deviceOrientation];
  [_replayBottom rotateButtonsBasedOnDeviceOrientation:deviceOrientation];
}

-(void)handlePinchGestureWithScale:(CGFloat)scale andVelocity:(CGFloat)velocity {
  NSLog(@"pinch scale %.2f, velocity %.2f", scale, velocity);
    // tweak these numbers
  if ((scale < .8f && !_boardZoomedOut) || (scale > 1.25f && _boardZoomedOut)) {
    [self toggleBoardZoom];
  }
}

#pragma mark - touch methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /// 1. first, make sure there's only one current touch
  
  if (!_currentTouch) {
    _currentTouch = [touches anyObject];
  } else {
    
      // handles ending previous touch
    [self endTouchFromTouches:nil];
    _currentTouch = [touches anyObject];
  }
    
  if (_fieldActionInProgress) {
    return;
  }
  
    //--------------------------------------------------------------------------
    /// 2. next, register the touch and decide what to do with it
  
    // get touch location and touched node
  _beganTouchLocation = [self findTouchLocationFromTouches:touches];
  _currentTouchLocation = _beganTouchLocation;
  _touchNode = [self nodeAtPoint:_currentTouchLocation];
  NSLog(@"%@, zPosition %.2f", _touchNode.name, _touchNode.zPosition);

    //--------------------------------------------------------------------------
    /// 3a. button pressed
  
    // if it's a button, take care of it when touch ended
  if ([_touchNode isKindOfClass:[Button class]]) {
    
      // sound of button tapped
    [self.mySoundEngine soundButton:YES];
    _buttonPressed = (Button *)_touchNode;
      // TODO: make distinction of button pressed better, of course
    _buttonPressed.alpha = 0.3f;
    return;
  }
  
    //--------------------------------------------------------------------------
    /// 3b. dyadmino touched
  
    // dyadmino is not registered if face is touched
  Dyadmino *dyadmino = [self selectDyadminoFromTouchPoint:_currentTouchLocation];
  
  if (!_canDoubleTapForDyadminoFlip && ([dyadmino isOnBoard] || ![dyadmino isRotating])) {
    
        // register sound if dyadmino tapped
    if (!_replayMode && dyadmino && !_swapMode && !_pivotInProgress) { // not sure if not being in swapMode is necessary
      if (!_boardZoomedOut || (_boardZoomedOut && [dyadmino isInRack])) {
        [self.mySoundEngine soundTouchedDyadmino:dyadmino plucked:YES];
      }
      
        // register sound if face tapped
    } else {
      
      SKSpriteNode *face = [self selectFaceFromTouchPoint:_currentTouchLocation];
      if (face && face.parent != _hoveringDyadmino && !_pivotInProgress) {
        if ([face.parent isKindOfClass:[Dyadmino class]]) {
          Dyadmino *faceParent = (Dyadmino *)face.parent;
          if (!_replayMode || (_replayMode && [faceParent isOnBoard])) {
            if (!_boardZoomedOut || (_boardZoomedOut && [faceParent isInRack])) {
              [self.mySoundEngine soundTouchedDyadminoFace:face plucked:YES];
              _soundedDyadminoFace = face;
            }
          }
        }
      }
    }
  }
  
  if (!_replayMode && dyadmino && !dyadmino.isRotating && !_touchedDyadmino && (!_boardZoomedOut || [dyadmino isInRack])) {
    _touchedDyadmino = dyadmino;
//    NSLog(@"begin touch or pivot of dyadmino");
    [self beginTouchOrPivotOfDyadmino:dyadmino];
  
    //--------------------------------------------------------------------------
    /// 3c. board about to be moved
  
    // if pivot not in progress, or pivot in progress but dyadmino is not close enough
    // then the board is touched and being moved
  } else if (!_pivotInProgress || (_pivotInProgress && !_touchedDyadmino)) {
    if (_touchNode == _boardField || _touchNode == _boardCover ||
        (_touchNode.parent == _boardField && (![_touchNode isKindOfClass:[Dyadmino class]] || _boardZoomedOut)) ||
        (_touchNode.parent.parent == _boardField && (![_touchNode.parent isKindOfClass:[Dyadmino class]] || _boardZoomedOut))) { // cell label, this one is necessary only for testing purposes
      
      if (_canDoubleTapForBoardZoom && !_hoveringDyadmino) {
        if ([self getDistanceFromThisPoint:_beganTouchLocation toThisPoint:_endTouchLocationToMeasureDoubleTap] < kDistanceToDoubleTap) {
          [self toggleBoardZoom];
        }
      }
      NSLog(@"board to be moved or being moved");
      _boardToBeMovedOrBeingMoved = YES;
      _canDoubleTapForBoardZoom = YES;
      
        // check to see if hovering dyadmino should stay with board or not
      if (_hoveringDyadmino) {
        [_boardField hideAllPivotGuides];
        _hoveringDyadminoToStayFixedWhileBoardMoves = NO;
        if ([_boardField validatePlacingDyadmino:_hoveringDyadmino onBoardNode:_hoveringDyadmino.tempBoardNode] != kNoError) {
          _hoveringDyadminoToStayFixedWhileBoardMoves = YES;
          NSLog(@"update cells for removed called from touches began");
          [self updateCellsForRemovedDyadmino:_hoveringDyadmino andColour:NO];
        }
      }

      return;
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
    _buttonPressed.alpha = (node == _buttonPressed) ? 0.3f : 1.f;
    return;
  }
  
    // register no touches moved while field is being toggled
  if (_fieldActionInProgress) {
    return;
  }
  
    //--------------------------------------------------------------------------
    /// 2. next, update the touch location

  _currentTouchLocation = [self findTouchLocationFromTouches:touches];
  
    // if touch hits a dyadmino face, sound and continue...
  if (!_boardToBeMovedOrBeingMoved && !_touchedDyadmino) {
    SKSpriteNode *face = [self selectFaceFromTouchPoint:_currentTouchLocation];
    
    if (face && face.parent != _hoveringDyadmino) {
      if ([face.parent isKindOfClass:[Dyadmino class]]) {
        Dyadmino *faceParent = (Dyadmino *)face.parent;
        if (!_replayMode || (_replayMode && [faceParent isOnBoard])) {
          if (!_soundedDyadminoFace) {
            [self.mySoundEngine soundTouchedDyadminoFace:face plucked:NO];
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
//  NSLog(@"determine current section from touches moved");
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
    
      // zoom back in
    if (_boardZoomedOut) {
      [self toggleBoardZoom];
    }
    
      // if rack dyadmino is moved to board, send home recentRack dyadmino
    if (_recentRackDyadmino && _touchedDyadmino != _recentRackDyadmino) {
      
      [self changeColoursAroundDyadmino:_recentRackDyadmino withSign:-1];
      [self sendDyadminoHome:_recentRackDyadmino fromUndo:NO byPoppingIn:YES andSounding:NO andUpdatingBoardBounds:YES];
      
        // or same thing with hovering dyadmino (it will only ever be one or the other)
    } else if (_hoveringDyadmino && _touchedDyadmino != _hoveringDyadmino) {
      [self sendDyadminoHome:_hoveringDyadmino fromUndo:NO byPoppingIn:YES andSounding:NO andUpdatingBoardBounds:YES];
    }
      // buttons updated once
    if (!_buttonsUpdatedThisTouch) {
      [self updateTopBarButtons];
      _buttonsUpdatedThisTouch = YES;
    }
  }
  
    // continue to reset hover count
  if ([_touchedDyadmino isHovering]) {
    [_touchedDyadmino keepHovering];
  }
  
    // take care of highlighting as it moves between rack and dyadmino
  if ([_touchedDyadmino belongsInRack] && !_swapMode && !_pivotInProgress) {
    /*
      this is the only place that sets dyadmino highlight to YES
      dyadmino highlight is reset when sent home or finalised
     */
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
  
  //--------------------------------------------------------------------------
  /// 3c. dyadmino is just being exchanged in rack
  
    // if it's a rack dyadmino, then while movement is within rack, rearrange dyadminoes
  if (([_touchedDyadmino belongsInRack] && [_touchedDyadmino isInRack]) ||
      [_touchedDyadmino isOrBelongsInSwap]) {
    
    SnapPoint *rackNode = [self findSnapPointClosestToDyadmino:_touchedDyadmino];
    
    self.playerRackDyadminoes = [_rackField handleRackExchangeOfTouchedDyadmino:_touchedDyadmino
                                     withDyadminoes:self.playerRackDyadminoes
                                 andClosestRackNode:rackNode];
  }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    /// 1. first check whether to even register the touch ended

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
  if (_fieldActionInProgress) {
    return;
  }
  
    //--------------------------------------------------------------------------
    /// 2a and b. handle button pressed or board moved
  
    // handle button that was pressed, ensure that touch is still on button when it ends
  if (_buttonPressed && touches) {
    SKNode *node = [self nodeAtPoint:[self findTouchLocationFromTouches:touches]];
    if (node == _buttonPressed) {
      
        // sound of button release
      [self.mySoundEngine soundButton:NO];
      [self handleButtonPressed];
    }
    _buttonPressed.alpha = 1.f;
    _buttonPressed = nil;
    return;
  }
  
    // board no longer being moved
  if (_boardToBeMovedOrBeingMoved) {
    _boardToBeMovedOrBeingMoved = NO;
    
      // take care of hovering dyadmino
    if (_hoveringDyadminoToStayFixedWhileBoardMoves) {
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
//  NSLog(@"determine currect section from end touch from touches");
  [self determineCurrentSectionOfDyadmino:_touchedDyadmino];
  Dyadmino *dyadmino = [self assignTouchEndedPointerToDyadmino:_touchedDyadmino];
  
  [self handleTouchEndOfDyadmino:dyadmino];
  
    // cleanup
  _pivotInProgress = NO;
  _touchOffsetVector = CGPointZero;
  _soundedDyadminoFace = nil;
  _buttonsUpdatedThisTouch = NO;
}

#pragma mark - board methods

-(void)moveBoard {
  
    // if board isn't being corrected within bounds
  if (!_boardBeingCorrectedWithinBounds) {
      // first get new board position, after applying touch offset
    CGPoint touchOffset = [self subtractFromThisPoint:_beganTouchLocation thisPoint:_currentTouchLocation];
    CGPoint newPosition = [self subtractFromThisPoint:_boardField.homePosition thisPoint:touchOffset];
    
    CGFloat newX = newPosition.x;
    CGFloat newY = newPosition.y;
    
    CGFloat swapBuffer = 0.f;
    if (_swapMode) {
      swapBuffer = kRackHeight; // the height of the swap field
    }
    
    if (newPosition.y < _boardField.lowestYPos) {
      newY = _boardField.lowestYPos;
    } else if (newPosition.y > (_boardField.highestYPos + swapBuffer)) {
      newY = _boardField.highestYPos + swapBuffer;
    }
    
    if (newPosition.x < _boardField.lowestXPos) {
      newX = _boardField.lowestXPos;
    } else if (newPosition.x > _boardField.highestXPos) {
      newX = _boardField.highestXPos;
    }
    
    CGPoint adjustedNewPosition = CGPointMake(newX, newY);
    
    if (_hoveringDyadminoToStayFixedWhileBoardMoves) {
      _hoveringDyadmino.position = [self addToThisPoint:_hoveringDyadmino.position
                                              thisPoint:[self subtractFromThisPoint:_boardField.position
                                                                          thisPoint:adjustedNewPosition]];
    }
    
      // move board to new position
    _boardField.position = adjustedNewPosition;
    
      // move home position to board position, after applying touch offset
    _boardField.homePosition = [self addToThisPoint:_boardField.position thisPoint:touchOffset];
  }
}

-(void)toggleBoardZoom {
//  NSLog(@"board zoomed");
  if (_hoveringDyadmino) {
    [self sendDyadminoHome:_hoveringDyadmino fromUndo:NO byPoppingIn:YES andSounding:NO  andUpdatingBoardBounds:NO];
  }
  
  _boardZoomedOut = _boardZoomedOut ? NO : YES;
  
    // need genuine board centering method
  [_boardField repositionCellsAndDyadminoesForZoomOut:_boardZoomedOut];
  [self updateBoardBoundsAndLayoutCells:YES forZoom:_boardZoomedOut];
  [self updateForBoardBeingCorrectedWithinBoundsForZoom:YES];
  
    // same as for board dyadminoes
  if (_recentRackDyadmino) {
    
      // these ensure that dyadmino is placed properly when flipped right before board zooms out
    [_recentRackDyadmino removeActionsAndEstablishNotRotating];
    _recentRackDyadmino.isTouchThenHoverResized = NO;
    
    _recentRackDyadmino.isZoomResized = _recentRackDyadmino.isZoomResized ? NO : YES;
    _recentRackDyadmino.position = _recentRackDyadmino.tempBoardNode.position;
    [_recentRackDyadmino selectAndPositionSprites];
  }
  
    // resize dyadminoes
  for (Dyadmino *dyadmino in self.boardDyadminoes) {

    [dyadmino removeActionsAndEstablishNotRotating];
    dyadmino.isTouchThenHoverResized = NO;
    dyadmino.isZoomResized = dyadmino.isZoomResized ? NO : YES;
    dyadmino.position = dyadmino.tempBoardNode.position;
    [dyadmino selectAndPositionSprites];
  }
  
  [self.mySoundEngine soundBoardZoom];
}

#pragma mark - dyadmino methods

-(void)beginTouchOrPivotOfDyadmino:(Dyadmino *)dyadmino {
  
  if ([dyadmino isOnBoard]) {
    NSLog(@"update cells for removed dyadmino from begin touch");
    if (dyadmino != _hoveringDyadmino && ![dyadmino isRotating]) {
      [self updateCellsForRemovedDyadmino:dyadmino andColour:YES];
    } else {
      [self updateCellsForRemovedDyadmino:dyadmino andColour:NO];
    }
  }
  
    // record tempReturnOrientation only if it's settled and not hovering
  if (dyadmino != _hoveringDyadmino) {
    dyadmino.tempReturnOrientation = dyadmino.orientation;
    
      // board dyadmino sends recent rack dyadmino home upon touch
      // rack dyadmino will do so upon move out of rack
    if (_hoveringDyadmino && [dyadmino isOnBoard]) {
      NSLog(@"send dyadmino home if hovering dyadmino");
      [self sendDyadminoHome:_hoveringDyadmino fromUndo:NO byPoppingIn:YES andSounding:NO  andUpdatingBoardBounds:YES];
    }
  }
  
  [dyadmino startTouchThenHoverResize];
  
  [self getReadyToMoveCurrentDyadmino:_touchedDyadmino];
  
    // if it's now about to pivot, just get pivot angle
  if (_pivotInProgress) {
    [self getReadyToPivotHoveringDyadmino:_hoveringDyadmino];
  }
  
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
    }
  }
}

-(void)getReadyToMoveCurrentDyadmino:(Dyadmino *)dyadmino {
//  NSLog(@"determine current section from get ready to move");
//  [self determineCurrentSectionOfDyadmino:dyadmino];
  
  if ([dyadmino isInRack]) {
    _touchOffsetVector = [self subtractFromThisPoint:_beganTouchLocation thisPoint:dyadmino.position];
  } else {
    CGPoint boardOffsetPoint = [self addToThisPoint:dyadmino.position thisPoint:_boardField.position];
    _touchOffsetVector = [self subtractFromThisPoint:_beganTouchLocation thisPoint:boardOffsetPoint];
  }
  
    // reset hover count
  if ([dyadmino isHovering]) {
    [dyadmino keepHovering];
  }
  
  [dyadmino removeActionsAndEstablishNotRotating];
  
    //--------------------------------------------------------------------------
  
    // if it's still in the rack, it can still rotate
  if ([dyadmino isInRack] || [dyadmino isOrBelongsInSwap]) {
    dyadmino.canFlip = YES;
  }
  
    // various prep
  dyadmino.zPosition = kZPositionHoveredDyadmino;
}

-(void)handleTouchEndOfDyadmino:(Dyadmino *)dyadmino {
    // ensures we're not disrupting a rotating animation
  if (!dyadmino.isRotating) {
    
      // if dyadmino belongs in rack (or swap) and *isn't* on board...
    if (([dyadmino belongsInRack] || [dyadmino belongsInSwap]) && ![dyadmino isOnBoard]) {
//      NSLog(@"touch ended of dyadmino belong in rack");
        // ...flip if possible, or send it home
      if (dyadmino.canFlip) {
        [dyadmino animateFlip];
      } else {
//        NSLog(@"handle touch end of dyadmino and send dyadmino home");
        if (dyadmino == _recentRackDyadmino) {
          [self sendDyadminoHome:dyadmino fromUndo:NO byPoppingIn:NO andSounding:YES  andUpdatingBoardBounds:YES];
        } else { // dyadmino never left rack, or is hovering
          [self sendDyadminoHome:dyadmino fromUndo:NO byPoppingIn:NO andSounding:YES  andUpdatingBoardBounds:NO];
        }
          // just settles into rack or swap
        [self updateTopBarButtons];
//        [self soundDyadminoSettleClick];
      }
      
        // or if dyadmino is in top bar...
    } else if ([dyadmino isInTopBar]) {;
      
        // if it's a board dyadmino
      if ([dyadmino.homeNode isBoardNode]) {
        dyadmino.tempBoardNode = nil;
        
          // it's a rack dyadmino
      } else {
        dyadmino.colorBlendFactor = 0.f;
      }
      
      [self sendDyadminoHome:dyadmino fromUndo:NO byPoppingIn:NO andSounding:YES  andUpdatingBoardBounds:YES];
      
        // or if dyadmino is in rack but belongs on board (this seems to work)
    } else if ([dyadmino belongsOnBoard] && [dyadmino isInRack]) {
      dyadmino.tempBoardNode = nil;
      [self removeDyadmino:dyadmino fromParentAndAddToNewParent:_boardField];
      dyadmino.position = [_boardField getOffsetFromPoint:dyadmino.position];
      [self sendDyadminoHome:dyadmino fromUndo:NO byPoppingIn:NO andSounding:YES  andUpdatingBoardBounds:YES];
      
        // otherwise, prepare it for hover
    } else {
      [self prepareForHoverThisDyadmino:dyadmino];
    }
  }
}

-(void)prepareForHoverThisDyadmino:(Dyadmino *)dyadmino {
  if (dyadmino != _touchedDyadmino) {
    _hoveringDyadmino = dyadmino;
    
      // establish the closest board node, without snapping just yet
    dyadmino.tempBoardNode = [self findSnapPointClosestToDyadmino:dyadmino];

      // update cells for placement
    [self updateCellsForPlacedDyadmino:dyadmino andColour:NO];
    
      // start hovering
    [dyadmino removeActionsAndEstablishNotRotating];
    
  //  NSLog(@"prepare for hover, check");
    [self checkWhetherToEaseOrKeepHovering:dyadmino afterTouchJustEnded:YES];
    
  //  NSLog(@"prepare for hover");
    if (dyadmino.isHovering || dyadmino.continuesToHover) {
  //    NSLog(@"dyadmino hovering status is %i", dyadmino.hoveringStatus);
      if (!_canDoubleTapForDyadminoFlip && ![dyadmino isRotating]) {
        [_boardField hidePivotGuideAndShowPrePivotGuideForDyadmino:dyadmino];
      }
    }
  }
}

//-(void)settleBackRackDyadmino:(Dyadmino *)dyadmino {
//  [dyadmino endTouchThenHoverResize];
//  _uponTouchDyadminoNode = nil;
//  [dyadmino goHomeToRackByPoppingIn:NO fromUndo:NO];
//  [self updateTopBarButtons];
//  NSLog(@"recent rack dyadmino is %@, hovering dyadmino is %@", _recentRackDyadmino.name, _hoveringDyadmino.name);
//}

-(void)sendDyadminoHome:(Dyadmino *)dyadmino fromUndo:(BOOL)undo byPoppingIn:(BOOL)poppingIn andSounding:(BOOL)sounding andUpdatingBoardBounds:(BOOL)updateBoardBounds {
  
      // reposition if dyadmino is rack dyadmino
  if (dyadmino.parent == _boardField && ([dyadmino belongsInRack] || undo)) {
    CGPoint newPosition = [self addToThisPoint:dyadmino.position thisPoint:_boardField.position];
    [self removeDyadmino:dyadmino fromParentAndAddToNewParent:_rackField];
    dyadmino.position = newPosition;
  }
  
  if (dyadmino == _recentRackDyadmino || undo) {
    [self updateCellsForRemovedDyadmino:dyadmino andColour:YES];
  } else { // otherwise it's a hovering dyadmino
//  NSLog(@"update cells for removed dyadmino called from send dyadmino home");
    [self updateCellsForRemovedDyadmino:dyadmino andColour:NO];
  }
  
    // this is one of two places where board bounds are updated
    // the other is when dyadmino is eased into board node
  if (updateBoardBounds) {
    NSLog(@"update board bounds from send dyadmino home");
    [self updateBoardBoundsAndLayoutCells:YES forZoom:NO];
  }
  
  [dyadmino endTouchThenHoverResize];
    // this makes nil tempBoardNode
  
  if ([dyadmino belongsInRack] && !undo) {
    _uponTouchDyadminoNode = nil;
    [dyadmino goHomeToRackByPoppingIn:poppingIn andSounding:sounding fromUndo:NO];
  } else if (undo) {
    _uponTouchDyadminoNode = nil;
    [dyadmino goHomeToRackByPoppingIn:poppingIn andSounding:sounding fromUndo:YES];
    
  } else {
    dyadmino.tempBoardNode = dyadmino.homeNode;
    [dyadmino goHomeToBoardByPoppingIn:poppingIn andSounding:sounding];
  }

    // this ensures that pivot guide doesn't disappear if rack exchange
  if (dyadmino == _hoveringDyadmino) {
    [_boardField hideAllPivotGuides];
  }
  
    // make nil all pointers
  if (dyadmino == _recentRackDyadmino && [_recentRackDyadmino isInRack]) {
    _recentRackDyadmino = nil;
  }
  if (dyadmino == _hoveringDyadmino) {
    _hoveringDyadmino = nil;
  }
  
    // this ensures that dyadmino is properly oriented and positioned before
    // re-updating the cells of its original home node
  if ([dyadmino belongsOnBoard]) {
    dyadmino.orientation = dyadmino.tempReturnOrientation;
    [self updateCellsForPlacedDyadmino:dyadmino andColour:NO];
  }
  
  [self updateTopBarButtons];
}

-(void)sendDyadminoToBoardNode:(Dyadmino *)dyadmino {
    // cells will be updated in callback
  [dyadmino animatePopBackIntoBoardNode];
  if (dyadmino == _hoveringDyadmino) {
    _hoveringDyadmino = nil;
  }
}

-(void)handlePivotOfDyadmino:(Dyadmino *)dyadmino {
  
  CGPoint touchBoardOffset = [_boardField getOffsetFromPoint:_currentTouchLocation];
  
  [_boardField pivotGuidesBasedOnTouchLocation:touchBoardOffset forDyadmino:dyadmino];
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
  
  [dyadmino removeActionsAndEstablishNotRotating];
  
    // this section just determines which pc to pivot on
    // it's not relevant after dyadmino is moved
  CGPoint touchBoardOffset = [_boardField getOffsetFromPoint:_beganTouchLocation];
  dyadmino.initialPivotAngle = [self findAngleInDegreesFromThisPoint:touchBoardOffset
                                                         toThisPoint:dyadmino.position];
  
  dyadmino.prePivotDyadminoOrientation = dyadmino.orientation;
  dyadmino.initialPivotPosition = dyadmino.position;
  [_boardField determinePivotOnPCForDyadmino:dyadmino];
  [dyadmino determinePivotAroundPointBasedOnPivotOnPC:_boardField.pivotOnPC];
  [_boardField pivotGuidesBasedOnTouchLocation:touchBoardOffset forDyadmino:dyadmino];
}

#pragma mark - view controller methods

-(void)goBackToMainViewController {
  
  [self.delegate backToMainMenu];
}

#pragma mark - button methods

-(void)deviceShaken {
  [self.mySoundEngine soundPCToggle];
  [self.mySceneEngine toggleBetweenLetterAndNumberMode];
}

-(void)handleButtonPressed {
  
      /// games button
  if (_buttonPressed == _topBar.returnButton) {
    [self goBackToMainViewController];
    return;
    
      /// replay button
  } else if (_buttonPressed == _topBar.replayButton || _buttonPressed == _replayTop.returnButton) {
    _replayMode = _replayMode ? NO : YES;
    [self toggleReplayFields];
    if (_replayMode) {
      [self showTurnInfoOrGameResultsForReplay:YES];
      [self updateReplayButtons];
    } else {
        // reset match's board
      [self.myMatch lastOrLeaveReplay];
    }
    return;
    
      /// swap button
  } else if (_buttonPressed == _topBar.swapCancelOrUndoButton &&
             [_buttonPressed confirmSwapCancelOrUndo] == kSwapButton) {
    if (!_swapMode) {
      [self toggleSwapField];
      _swapMode = YES;
      [self.myMatch resetHoldingContainer];
    }
    
      /// cancel button
  } else if (_buttonPressed == _topBar.swapCancelOrUndoButton &&
             [_buttonPressed confirmSwapCancelOrUndo] == kCancelButton) {
    
      // if in swap mode, cancel swap
    if (_swapMode) {
      [self toggleSwapField];
      [self cancelSwappedDyadminoes];
      
        // else send dyadmino home
    } else if (_hoveringDyadmino) {
      [self sendDyadminoHome:_hoveringDyadmino fromUndo:NO byPoppingIn:YES andSounding:NO  andUpdatingBoardBounds:YES];

        // recent rack dyadmino is sent home
    } else if (_recentRackDyadmino) {
      [self sendDyadminoHome:_recentRackDyadmino fromUndo:NO byPoppingIn:YES andSounding:NO  andUpdatingBoardBounds:YES];
    }
    
      /// undo button
  } else if (_buttonPressed == _topBar.swapCancelOrUndoButton &&
             [_buttonPressed confirmSwapCancelOrUndo] == kUndoButton) {
    
    [self undoLastPlayedDyadmino];
  
      /// play button
  } else if (_buttonPressed == _topBar.passPlayOrDoneButton &&
             [_buttonPressed confirmPassPlayOrDone] == kPlayButton) {
    [self playDyadmino:_recentRackDyadmino];
    
      /// pass or done button
  } else if (_buttonPressed == _topBar.passPlayOrDoneButton &&
             ([_buttonPressed confirmPassPlayOrDone] == kDoneButton || [_buttonPressed confirmPassPlayOrDone] == kPassButton)) {
    if (!_swapMode) {
      if (self.myMatch.holdingContainer.count == 0) {
          // it's a pass, so confirm with action sheet
        [self presentPassActionSheet];
      } else {
        [self finalisePlayerTurn];
      }
          // finalising a swap
    } else if (_swapMode) {
        // confirm that there's enough dyadminoes in the pile
      if (self.myMatch.swapContainer.count > self.myMatch.pile.count) {
        [_topBar flashLabelNamed:@"message" withText:@"There aren't enough dyadminoes left in the pile." andColour:nil];
        return;
      } else {
        [self presentSwapActionSheet];
      }
    }
    
      /// debug button
  } else if (_buttonPressed == _topBar.debugButton) {
    _debugMode = _debugMode ? NO : YES;
    [self toggleDebugMode];
    
      /// resign button
  } else if (_buttonPressed == _topBar.resignButton) {
    [self presentResignActionSheet];
    
      // replay buttons
  } else if (_buttonPressed == _replayBottom.firstTurnButton) {
    [self.myMatch first];
    [self showTurnInfoOrGameResultsForReplay:YES];
    [self updateReplayButtons];
  } else if (_buttonPressed == _replayBottom.previousTurnButton) {
    [self.myMatch previous];
    [self showTurnInfoOrGameResultsForReplay:YES];
    [self updateReplayButtons];
  } else if (_buttonPressed == _replayBottom.nextTurnButton) {
    [self.myMatch next];
    [self showTurnInfoOrGameResultsForReplay:YES];
    [self updateReplayButtons];
  } else if (_buttonPressed == _replayBottom.lastTurnButton) {
    [self.myMatch lastOrLeaveReplay];
    [self showTurnInfoOrGameResultsForReplay:YES];
    [self updateReplayButtons];
  
  } else {
    return;
  }
  
    // return to bypass updating labels and buttons
  [self updateTopBarLabelsFinalTurn:NO animated:NO];
  [self updateTopBarButtons];
}

#pragma mark - match interaction methods

-(void)undoLastPlayedDyadmino {
    // remove data dyadmino from holding container
  DataDyadmino *undoneDataDyadmino = [self.myMatch undoDyadminoToHoldingContainer];
  Dyadmino *undoneDyadmino = (Dyadmino *)self.mySceneEngine.allDyadminoes[undoneDataDyadmino.myID - 1];
  undoneDyadmino.tempReturnOrientation = undoneDataDyadmino.myOrientation;
  undoneDyadmino.orientation = undoneDataDyadmino.myOrientation;
  undoneDyadmino.myRackOrder = self.playerRackDyadminoes.count;
  undoneDyadmino.homeNode = nil;
  
    // re-add dyadmino to player rack
  NSMutableArray *tempRackArray = [NSMutableArray arrayWithArray:self.playerRackDyadminoes];
  [tempRackArray addObject:undoneDyadmino];
  self.playerRackDyadminoes = [NSArray arrayWithArray:tempRackArray];
  NSMutableSet *tempBoardSet = [NSMutableSet setWithSet:self.boardDyadminoes];
  [tempBoardSet removeObject:undoneDyadmino];
  self.boardDyadminoes = [NSSet setWithSet:tempBoardSet];
  
    // take care of views
  [self sendDyadminoHome:undoneDyadmino fromUndo:YES byPoppingIn:YES andSounding:NO  andUpdatingBoardBounds:YES];
  [self persistDataForDyadmino:undoneDyadmino];
}

-(void)recordChangedDataForRackDyadminoes:(NSMutableArray *)rackArray {
  for (int i = 0; i < rackArray.count; i++) {
    if ([rackArray[i] isKindOfClass:[Dyadmino class]]) {
      Dyadmino *dyadmino = (Dyadmino *)rackArray[i];
      dyadmino.myRackOrder = i;
      [self persistDataForDyadmino:dyadmino];
    }
  }
}

-(void)persistDataForDyadmino:(Dyadmino *)dyadmino {
  DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
  if ([dyadmino belongsOnBoard]) {
    dataDyad.myHexCoord = dyadmino.homeNode.myCell.hexCoord;
  }
  
//  dataDyad.myHexCoord = dyadmino.myHexCoord;
  if ([dyadmino isOnBoard] && [dyadmino belongsInRack]) {
    dataDyad.myOrientation = dyadmino.tempReturnOrientation;
  } else {
    dataDyad.myOrientation = dyadmino.orientation;
  }
  dataDyad.myRackOrder = dyadmino.myRackOrder;
}

-(void)persistAllSceneDataDyadminoes {
  for (Dyadmino *dyadmino in self.playerRackDyadminoes) {
    [self persistDataForDyadmino:dyadmino];
  }
  
  for (Dyadmino *dyadmino in self.boardDyadminoes) {
    [self persistDataForDyadmino:dyadmino];
  }
}

-(void)cancelSwappedDyadminoes {
  _swapMode = NO;
  [self.myMatch.swapContainer removeAllObjects];
  [self.myMatch resetHoldingContainer];
  for (Dyadmino *dyadmino in self.playerRackDyadminoes) {
    if (dyadmino.belongsInSwap) {
      dyadmino.belongsInSwap = NO;
      [dyadmino goHomeToRackByPoppingIn:NO andSounding:NO fromUndo:NO];
    }
  }
}

-(BOOL)finaliseSwap {
  NSMutableArray *toPile = [NSMutableArray new];
  
  for (Dyadmino *dyadmino in self.playerRackDyadminoes) {
    if ([dyadmino belongsInSwap]) {
      [toPile addObject:dyadmino];
    }
  }

    // extra confirmation; this will have been checked when button was done button was first pressed
  if (self.myMatch.swapContainer.count <= self.myMatch.pile.count) {
      // first take care of views
    for (Dyadmino *dyadmino in toPile) {
      dyadmino.belongsInSwap = NO;
      
        // TODO: this should be a better animation
        // dyadmino is already a child of rackField,
        // so no need to send dyadmino home through myScene's sendDyadmino method
      [dyadmino goHomeToRackByPoppingIn:NO andSounding:NO fromUndo:NO];
      [dyadmino removeFromParent];
    }
    
      // then swap in the logic
    [self.myMatch swapDyadminoesFromCurrentPlayer];
    [self populateRackArray];
    [self layoutOrRefreshRackFieldAndDyadminoesFromUndo:NO withAnimation:YES];
    [_topBar flashLabelNamed:@"log" withText:@"Swapped!" andColour:nil];
    return YES;
  }
  return NO;
}

-(void)playDyadmino:(Dyadmino *)dyadmino {
    // establish that dyadmino is indeed a rack dyadmino placed on the board
  if ([dyadmino belongsInRack] && [dyadmino isOnBoard]) {
    
      // confirm that the dyadmino was successfully played before proceeding with anything else
    DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
    [self.myMatch addToHoldingContainer:dataDyad];
    [self removeFromPlayerRackDyadminoes:dyadmino];
    [self addToSceneBoardDyadminoes:dyadmino];
    
      // do cleanup, dyadmino's home node is now the board node
    dyadmino.homeNode = dyadmino.tempBoardNode;
    dyadmino.myHexCoord = dyadmino.homeNode.myCell.hexCoord;
    [dyadmino highlightBoardDyadminoWithColour:[self.myMatch colourForPlayer:_myPlayer]];
    
      // empty pointers
    _recentRackDyadmino = nil;
    _hoveringDyadmino = nil;
    
      // establish data dyadmino properties
    dataDyad.myHexCoord = dyadmino.myHexCoord;
    dataDyad.myOrientation = dyadmino.orientation;
  }
  [_topBar flashLabelNamed:@"gameAvatar" withText:@"C major triad!" andColour:nil];
  [self layoutOrRefreshRackFieldAndDyadminoesFromUndo:NO withAnimation:YES];
  [self updateTopBarLabelsFinalTurn:NO animated:YES];
  [self updateTopBarButtons];
}

-(void)finalisePlayerTurn {
    // no recent rack dyadmino on board
  if (!_recentRackDyadmino) {
    [self persistAllSceneDataDyadminoes];
    [self.myMatch recordDyadminoesFromPlayer:_myPlayer withSwap:NO];

    [self populateRackArray];
    [self layoutOrRefreshRackFieldAndDyadminoesFromUndo:NO withAnimation:YES];
    
      // update views
    [self updateTopBarLabelsFinalTurn:YES animated:YES];
    [self updateTopBarButtons];
    [_topBar flashLabelNamed:@"log" withText:@"Turn done!" andColour:nil];
    
    if (self.myMatch.type == kSelfGame) {
      [self animateRecentlyPlayedDyadminoes];
    }
    
    [self showTurnInfoOrGameResultsForReplay:NO];
  }
}

-(void)handleSwitchToNextPlayer {
  NSString *nextPlayer = [NSString stringWithFormat:@"Waiting for %@ to play.", self.myMatch.currentPlayer.playerName];
  [_topBar flashLabelNamed:@"message" withText:nextPlayer andColour:[self.myMatch colourForPlayer:self.myMatch.currentPlayer]];
}

-(void)handleEndGame {
  NSString *resultsText = [self.myMatch endGameResultsText];
  [_topBar flashLabelNamed:@"message" withText:resultsText andColour:nil];
}

#pragma mark - realtime update methods

-(void)update:(CFTimeInterval)currentTime {
  
  [self updateForDoubleTap:currentTime];
  if (_hoveringDyadmino) {
    [self updateDyadmino:_hoveringDyadmino forHover:currentTime];
  }
  
    // snap back somewhat from board bounds
    // TODO: this works, but it feels jumpy
  [self updateForBoardBeingCorrectedWithinBoundsForZoom:NO];
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
    _canDoubleTapForDyadminoFlip = NO;
    _hoveringDyadmino.canFlip = NO;
    _doubleTapTime = 0.f;
  }
}

-(void)updateForHoveringDyadminoBeingCorrectedWithinBounds {
  if (![_hoveringDyadmino isRotating] && !_boardToBeMovedOrBeingMoved &&
      !_boardBeingCorrectedWithinBounds && !_boardJustShiftedNotCorrected &&
      _hoveringDyadmino && _hoveringDyadmino != _touchedDyadmino &&
      ![_hoveringDyadmino isInRack] && ![_hoveringDyadmino isInTopBar]) {
    
    CGFloat xLowLimit = -_boardField.position.x;
    CGFloat xHighLimit = self.view.frame.size.width - _boardField.position.x;
    
    CGFloat thisDistance;
    CGFloat distanceDivisor = 5.333f; // tweak this number if desired
    CGFloat dyadminoBuffer;
    
    switch (_hoveringDyadmino.orientation) {
      case kPC1atTwelveOClock:
      case kPC1atSixOClock:
        dyadminoBuffer = kDyadminoFaceWideRadius * 1.5;
        break;
        
      default: // all other cases
        dyadminoBuffer = kDyadminoFaceWideDiameter * 1.5;
        break;
    }
    
    if (_hoveringDyadmino.position.x - dyadminoBuffer < xLowLimit) {
      _hoveringDyadminoBeingCorrected++;
      thisDistance = 1.f + (xLowLimit - (_hoveringDyadmino.position.x - dyadminoBuffer)) / distanceDivisor;
      _hoveringDyadmino.position = CGPointMake(_hoveringDyadmino.position.x + thisDistance, _hoveringDyadmino.position.y);
      
    } else if (_hoveringDyadmino.position.x + dyadminoBuffer > xHighLimit) {
      _hoveringDyadminoBeingCorrected++;
      thisDistance = 1.f + ((_hoveringDyadmino.position.x + dyadminoBuffer) - xHighLimit) / distanceDivisor;
      _hoveringDyadmino.position = CGPointMake(_hoveringDyadmino.position.x - thisDistance, _hoveringDyadmino.position.y);
      
    } else {
      _hoveringDyadminoFinishedCorrecting++;
    }
    

      // only goes through one time
    if (_hoveringDyadminoBeingCorrected == 1) {
      [_boardField hideAllPivotGuides];
      NSLog(@"update cells for removed dyadmino called from update for hovering dyadmino being corrected");
      [self updateCellsForRemovedDyadmino:_hoveringDyadmino andColour:NO];
      _hoveringDyadminoFinishedCorrecting = 0;
      
    } else if (_hoveringDyadminoFinishedCorrecting == 1) {
      [self updateCellsForRemovedDyadmino:_hoveringDyadmino andColour:NO];
      _hoveringDyadmino.tempBoardNode = [self findSnapPointClosestToDyadmino:_hoveringDyadmino];
      NSLog(@"update cells for removed dyadmino called from update for hovering dyadmino being corrected, finished correcting");
      [self updateCellsForPlacedDyadmino:_hoveringDyadmino andColour:NO];
      NSLog(@"update for hovering");
      if (!_canDoubleTapForDyadminoFlip && ![_hoveringDyadmino isRotating]) {
        [_boardField hidePivotGuideAndShowPrePivotGuideForDyadmino:_hoveringDyadmino];
      }
      _hoveringDyadminoBeingCorrected = 0;
    }
  }
}

-(void)updateForBoardBeingCorrectedWithinBoundsForZoom:(BOOL)zoom {
  
  if (_fieldActionInProgress) {
    _boardField.homePosition = _boardField.position;
    return;
  }
  
  CGFloat swapBuffer = 0.f;
  if (_swapMode) {
    swapBuffer = kRackHeight; // the height of the swap field
  }
  
    // only prevents board move from touch if it's truly out of bounds
    // it's fine if it's still within the buffer
  if (_boardField.position.x < _boardField.lowestXPos) {
    _boardBeingCorrectedWithinBounds = YES;
  }
  if (_boardField.position.y < _boardField.lowestYPos) {
    _boardBeingCorrectedWithinBounds = YES;
  }
  if (_boardField.position.x > _boardField.highestXPos) {
    _boardBeingCorrectedWithinBounds = YES;
  }
  if (_boardField.position.y > _boardField.highestYPos + swapBuffer) {
    _boardBeingCorrectedWithinBounds = YES;
  }
  
  if (!_boardToBeMovedOrBeingMoved || _boardBeingCorrectedWithinBounds) {
    
    if (_hoveringDyadmino && _boardBeingCorrectedWithinBounds) {
      [_boardField hideAllPivotGuides];
      NSLog(@"update cells for removed dyadmino called from update for board being corrected within bounds, hovering dyadmino removed");
      [self updateCellsForRemovedDyadmino:_hoveringDyadmino andColour:NO];
    }
    
    CGFloat thisDistance;
      // this number can be tweaked, but it seems fine for now
    CGFloat distanceDivisor = 8.f;
    
      // this establishes when board is no longer being corrected within bounds
    NSUInteger alreadyCorrect = 0;

    CGFloat lowestXBuffer = _boardField.lowestXPos + kDyadminoFaceWideRadius;
    CGFloat lowestYBuffer = _boardField.lowestYPos + kDyadminoFaceRadius;
    CGFloat highestXBuffer = _boardField.highestXPos - kDyadminoFaceWideRadius;
    CGFloat highestYBuffer = _boardField.highestYPos - kDyadminoFaceRadius + swapBuffer;
    
      // this way when the board is being corrected,
      // it doesn't jump afterwards
    if (_boardToBeMovedOrBeingMoved) {
      _beganTouchLocation = _currentTouchLocation;
    }
  
      // establishes the board is being shifted away from hard edge, not as a correction
    
    if (_boardField.position.x < lowestXBuffer) {
      _boardJustShiftedNotCorrected = YES;
      thisDistance = zoom ?
        lowestXBuffer - _boardField.position.x :
        1.f + (lowestXBuffer - _boardField.position.x) / distanceDivisor;
      _boardField.position = CGPointMake(_boardField.position.x + thisDistance, _boardField.position.y);
      _boardField.homePosition = _boardField.position;
      
      if (_hoveringDyadminoToStayFixedWhileBoardMoves) {
        _hoveringDyadmino.position = CGPointMake(_hoveringDyadmino.position.x - thisDistance, _hoveringDyadmino.position.y);
      }
      
    } else {
      alreadyCorrect++;
    }
    
    if (_boardField.position.y < lowestYBuffer) {
      _boardJustShiftedNotCorrected = YES;
      thisDistance = zoom ?
        lowestYBuffer - _boardField.position.y :
        1.f + (lowestYBuffer - _boardField.position.y) / distanceDivisor;
      _boardField.position = CGPointMake(_boardField.position.x, _boardField.position.y + thisDistance);
      _boardField.homePosition = _boardField.position;
      
      if (_hoveringDyadminoToStayFixedWhileBoardMoves) {
        _hoveringDyadmino.position = CGPointMake(_hoveringDyadmino.position.x, _hoveringDyadmino.position.y - thisDistance);
      }
      
    } else {
      alreadyCorrect++;
    }

    if (_boardField.position.x > highestXBuffer) {
      _boardJustShiftedNotCorrected = YES;
      thisDistance = zoom ?
        _boardField.position.x - highestXBuffer :
        1.f + (_boardField.position.x - highestXBuffer) / distanceDivisor;
      _boardField.position = CGPointMake(_boardField.position.x - thisDistance, _boardField.position.y);
      _boardField.homePosition = _boardField.position;
      
      if (_hoveringDyadminoToStayFixedWhileBoardMoves) {
        _hoveringDyadmino.position = CGPointMake(_hoveringDyadmino.position.x + thisDistance, _hoveringDyadmino.position.y);
      }
      
    } else {
      alreadyCorrect++;
    }

    if (_boardField.position.y > highestYBuffer) {
      _boardJustShiftedNotCorrected = YES;
      thisDistance = zoom ?
        _boardField.position.y - highestYBuffer :
        1.f + (_boardField.position.y - highestYBuffer) / distanceDivisor;
      _boardField.position = CGPointMake(_boardField.position.x, _boardField.position.y - thisDistance);
      _boardField.homePosition = _boardField.position;
      
      if (_hoveringDyadminoToStayFixedWhileBoardMoves) {
        _hoveringDyadmino.position = CGPointMake(_hoveringDyadmino.position.x, _hoveringDyadmino.position.y + thisDistance);
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
          if (!_canDoubleTapForDyadminoFlip && ![_hoveringDyadmino isRotating]) {
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
  if (_hoveringDyadmino && _hoveringDyadminoBeingCorrected == 0 && !_touchedDyadmino && !_currentTouch && !_boardBeingCorrectedWithinBounds && !_boardJustShiftedNotCorrected && ![_boardField.children containsObject:_boardField.prePivotGuide]) {
    if (!_canDoubleTapForDyadminoFlip && ![_hoveringDyadmino isRotating]) {
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
      dyadmino.hoveringStatus = kDyadminoHovering;
    }
    
      // 
    if (_hoverTime != 0.f && currentTime > _hoverTime + kAnimateHoverTime) {
      _hoverTime = 0.f;
      
      _uponTouchDyadminoNode = nil;
      [dyadmino finishHovering];
    }
    
    if ([dyadmino isFinishedHovering]) {
      [self checkWhetherToEaseOrKeepHovering:dyadmino afterTouchJustEnded:NO];
    }
  }
}

  // touch just ended doesn't really make a difference
-(void)checkWhetherToEaseOrKeepHovering:(Dyadmino *)dyadmino afterTouchJustEnded:(BOOL)touchJustEnded {
  
    // if finished hovering
  if ([dyadmino isOnBoard] && _touchedDyadmino != dyadmino) {
    
      // finish hovering only if placement is legal
    if (dyadmino.tempBoardNode) { // ensures that validation takes place only if placement is uncertain
                                  // will not get called if returning to homeNode from top bar
      PhysicalPlacementResult placementResult = [_boardField validatePlacingDyadmino:dyadmino
                                                                         onBoardNode:dyadmino.tempBoardNode];
      
        // handle placement results:
        // ease in right away because no error, and dyadmino was not moved from original spot
      if (placementResult == kNoError && !(dyadmino.tempBoardNode == _uponTouchDyadminoNode && dyadmino.orientation == _uponTouchDyadminoOrientation)) {
        [dyadmino finishHovering];
        if ([dyadmino belongsOnBoard]) {
          
            // this is the only place where a board dyadmino's tempBoardNode becomes its new homeNode
            // this method will record a dyadmino that's already in the match's board
            // this method also gets called if a recently played dyadmino
            // has been moved, but data will not be submitted until the turn is officially done.
          [self persistDataForDyadmino:dyadmino];
          dyadmino.homeNode = dyadmino.tempBoardNode;
        }
        
          // this is one of two places where board bounds are updated
          // the other is when rack dyadmino is sent home
        NSLog(@"updateBoardBounds called from check whether to ease");
        [self updateBoardBoundsAndLayoutCells:YES forZoom:NO];
        
        [_boardField hideAllPivotGuides];
        [dyadmino animateEaseIntoNodeAfterHover];
        _hoveringDyadmino = nil;
        [self updateTopBarButtons];
      } else {
        [dyadmino keepHovering];
        
            // lone dyadmino
        if (placementResult == kErrorLoneDyadmino) {
          [_topBar flashLabelNamed:@"message" withText:@"no lone dyadminoes!" andColour:nil];
          
            // stacked dyadminoes
        } else if (placementResult == kErrorStackedDyadminoes) {
          [_topBar flashLabelNamed:@"message" withText:@"can't stack dyadminoes!" andColour:nil];
        }
      }
    }
  }
}

#pragma mark - update label and button methods

-(void)updateTopBarLabelsFinalTurn:(BOOL)finalTurn animated:(BOOL)animated {
  
    // show turn count and pile left if game has not ended
    NSString *pileLeftText = self.myMatch.gameHasEnded ? @"" : [NSString stringWithFormat:@"in pile: %lu",
                                                          (unsigned long)self.myMatch.pile.count];
  NSString *turnText = self.myMatch.gameHasEnded ? @"" : [NSString stringWithFormat:@"turn %i", self.myMatch.turns.count + 1];
  
  [_topBar updateLabelNamed:@"turnCount" withText:turnText andColour:nil];
  [_topBar updateLabelNamed:@"pileCount" withText:pileLeftText andColour:nil];
  
  for (int i = 0; i < 4; i++) {
    
    Player *player = (i <= self.myMatch.players.count - 1) ? self.myMatch.players[i] : nil;
    Label *nameLabel = _topBar.playerNameLabels[i];
    Label *scoreLabel = _topBar.playerScoreLabels[i];
    Label *rackLabel = _topBar.playerRackLabels[i];
  
    if (!player) {
      if (nameLabel.parent) {
        [nameLabel removeFromParent];
      }
      if (scoreLabel.parent) {
        [scoreLabel removeFromParent];
      }
      if (rackLabel.parent) {
        [rackLabel removeFromParent];
      }
    } else {
      
      [_topBar updateLabelNamed:nameLabel.name withText:player.playerName andColour:nil];
      
        // static player colours
      if (player.resigned && self.myMatch.type != kSelfGame) {
        nameLabel.fontColor = [SKColor darkGrayColor];
      } else {
        nameLabel.fontColor = [self.myMatch colourForPlayer:player];
      }
      
        // FIXME: this will show match results
      if (!self.myMatch.gameHasEnded && player == self.myMatch.currentPlayer) {
        nameLabel.fontColor = [SKColor whiteColor];
      } else if (self.myMatch.gameHasEnded && [self.myMatch.wonPlayers containsObject:player]) {
        nameLabel.fontColor = [SKColor blackColor];
      }
      
      NSString *scoreText;
        
      if (player == _myPlayer && self.myMatch.tempScore > 0) {
        scoreText = [NSString stringWithFormat:@"%lu + %lu", (unsigned long)player.playerScore, (unsigned long)self.myMatch.tempScore];
      } else {
        scoreText = [NSString stringWithFormat:@"%lu", (unsigned long)player.playerScore];
      }
      
      if (player == _myPlayer && (finalTurn || self.myMatch.tempScore > 0)) {
          // upon final turn, score is animated
        if (animated) {
          [_topBar afterPlayUpdateScoreLabel:scoreLabel withText:scoreText];
        } else {
          [_topBar updateLabelNamed:scoreLabel.name withText:scoreText andColour:nil];
        }
        
      } else {
        [_topBar updateLabelNamed:scoreLabel.name withText:scoreText andColour:nil];
      }
      
      [_topBar updateLabelNamed:rackLabel.name withText:[[player.dataDyadminoesThisTurn valueForKey:kDyadminoIDKey] componentsJoinedByString:@", "] andColour:nil];
    }
  }
  
  NSString *pileText = [NSString stringWithFormat:@"in pile: %@", [[self.myMatch.pile valueForKey:kDyadminoIDKey] componentsJoinedByString:@", "]];
  NSMutableArray *tempBoard = [NSMutableArray arrayWithArray:[self.myMatch.board allObjects]];
  NSString *boardText = [NSString stringWithFormat:@"on board: %@", [[tempBoard valueForKey:kDyadminoIDKey] componentsJoinedByString:@", "]];
  NSString *holdingContainerText = [NSString stringWithFormat:@"in holding container: %@", [[self.myMatch.holdingContainer valueForKey:kDyadminoIDKey] componentsJoinedByString:@", "]];
  NSString *swapContainerText = [NSString stringWithFormat:@"in swap container: %@", [[self.myMatch.swapContainer valueForKey:kDyadminoIDKey] componentsJoinedByString:@", "]];
  
  [_topBar updateLabelNamed:_topBar.pileDyadminoesLabel.name withText:pileText andColour:nil];
  [_topBar updateLabelNamed:_topBar.boardDyadminoesLabel.name withText:boardText andColour:nil];
  [_topBar updateLabelNamed:_topBar.holdingContainerLabel.name withText:holdingContainerText andColour:nil];
  [_topBar updateLabelNamed:_topBar.swapContainerLabel.name withText:swapContainerText andColour:nil];
}

-(void)updateTopBarButtons {
    // three main possibilities
    // 1. Game has ended for player...
  if (_myPlayer.resigned || self.myMatch.gameHasEnded) {
    [_topBar enableButton:_topBar.returnButton];
    [_topBar enableButton:_topBar.replayButton];
    [_topBar disableButton:_topBar.swapCancelOrUndoButton];
    [_topBar disableButton:_topBar.passPlayOrDoneButton];
    [_topBar disableButton:_topBar.resignButton];
    
      //2. Still in game but not player's turn
  } else if (_myPlayer != self.myMatch.currentPlayer) {

    [_topBar enableButton:_topBar.returnButton];
    [_topBar enableButton:_topBar.replayButton];
    [_topBar disableButton:_topBar.swapCancelOrUndoButton];
    [_topBar disableButton:_topBar.passPlayOrDoneButton];
    [_topBar enableButton:_topBar.resignButton];
    
      // 2. Player's turn
  } else if (_myPlayer == self.myMatch.currentPlayer) {
    
      // 2a. swap mode
    if (_swapMode) {
      [_topBar enableButton:_topBar.returnButton];
      [_topBar disableButton:_topBar.replayButton];
      [_topBar enableButton:_topBar.swapCancelOrUndoButton]; // cancel
        if (self.myMatch.swapContainer.count > 0) {
      [_topBar enableButton:_topBar.passPlayOrDoneButton]; // done
      } else {
        [_topBar disableButton:_topBar.passPlayOrDoneButton];
      }
      [_topBar disableButton:_topBar.resignButton];
      
      [_topBar changeSwapCancelOrUndo:kCancelButton];
      [_topBar changePassPlayOrDone:kDoneButton];

        // 2b. not swap mode
    } else {
      [_topBar enableButton:_topBar.returnButton];
      [_topBar enableButton:_topBar.replayButton];
      [_topBar enableButton:_topBar.swapCancelOrUndoButton];
      [_topBar enableButton:_topBar.passPlayOrDoneButton];
      [_topBar enableButton:_topBar.resignButton];
      
        // any touched or hovering dyadmino
      if ((_touchedDyadmino) || (_hoveringDyadmino)) {
        [_topBar changeSwapCancelOrUndo:kCancelButton];
        [_topBar disableButton:_topBar.passPlayOrDoneButton];
        
          // no dyadminoes played, and no recent rack dyadmino
      } else if (self.myMatch.holdingContainer.count == 0 && !_recentRackDyadmino) {
        [_topBar changeSwapCancelOrUndo:kSwapButton];
        
          // no pass option in self mode
        if (self.myMatch.type == kSelfGame) {
          [_topBar disableButton:_topBar.passPlayOrDoneButton];
        } else {
          [_topBar changePassPlayOrDone:kPassButton];
        }
          // a recent rack dyadmino placed on board
      } else if (_recentRackDyadmino) { // doesn't matter whether holding container is empty
        [_topBar changeSwapCancelOrUndo:kCancelButton];
        [_topBar changePassPlayOrDone:kPlayButton];
        
        // holding container is not empty, and no recent rack dyadmino
      } else {
        [_topBar changeSwapCancelOrUndo:kUndoButton];
        [_topBar changePassPlayOrDone:kDoneButton];
      }
    }
  }
    // no point in replay button if first turn
  if (self.myMatch.turns.count == 0) {
    [_topBar disableButton:_topBar.replayButton];
  }
}

-(void)updateReplayButtons {
  if (self.myMatch.replayCounter == 1) {
    [_replayBottom disableButton:_replayBottom.firstTurnButton];
    [_replayBottom disableButton:_replayBottom.previousTurnButton];
    [_replayBottom enableButton:_replayBottom.nextTurnButton];
    [_replayBottom enableButton:_replayBottom.lastTurnButton];
  } else if (self.myMatch.replayCounter == self.myMatch.turns.count) {
    [_replayBottom enableButton:_replayBottom.firstTurnButton];
    [_replayBottom enableButton:_replayBottom.previousTurnButton];
    [_replayBottom disableButton:_replayBottom.nextTurnButton];
    [_replayBottom disableButton:_replayBottom.lastTurnButton];
  } else {
    [_replayBottom enableButton:_replayBottom.firstTurnButton];
    [_replayBottom enableButton:_replayBottom.previousTurnButton];
    [_replayBottom enableButton:_replayBottom.nextTurnButton];
    [_replayBottom enableButton:_replayBottom.lastTurnButton];
  }
}

#pragma mark - field animation methods

-(void)toggleReplayFields {
  NSLog(@"toggle replay fields");
  
    self.myMatch.replayCounter = self.myMatch.turns.count;
    // it's in replay mode (opposite of toggle swap field)
  if (_replayMode) {
    [self.mySoundEngine soundSwapFieldSwoosh];
    _fieldActionInProgress = YES;
    
    _replayTop.hidden = NO;
    _replayBottom.hidden = NO;
    SKAction *topMoveAction = [SKAction moveToY:self.frame.size.height - kTopBarHeight duration:kConstantTime];
    SKAction *topCompleteAction = [SKAction runBlock:^{
      _fieldActionInProgress = NO;
      _rackField.hidden = YES;
      _topBar.hidden = YES;
    }];
    SKAction *topSequenceAction = [SKAction sequence:@[topMoveAction, topCompleteAction]];
    [_replayTop runAction:topSequenceAction];
    
    SKAction *bottomMoveAction = [SKAction moveToY:CGPointZero.y duration:kConstantTime];
    [_replayBottom runAction:bottomMoveAction];
    
      // it's not in replay mode
  } else {
    [self.mySoundEngine soundSwapFieldSwoosh];
    _fieldActionInProgress = YES;
    
    _rackField.hidden = NO;
    _topBar.hidden = NO;
    
      // animate last play, or game results if game ended
    [self animateRecentlyPlayedDyadminoes];
    [self showTurnInfoOrGameResultsForReplay:NO];
    
    SKAction *topMoveAction = [SKAction moveToY:self.frame.size.height duration:kConstantTime];
    SKAction *topCompleteAction = [SKAction runBlock:^{
      _fieldActionInProgress = NO;
      _replayTop.hidden = YES;
    }];
    SKAction *topSequenceAction = [SKAction sequence:@[topMoveAction, topCompleteAction]];
    [_replayTop runAction:topSequenceAction];
    
    SKAction *bottomMoveAction = [SKAction moveToY:-kRackHeight duration:kConstantTime];
    SKAction *bottomCompleteAction = [SKAction runBlock:^{
      _replayBottom.hidden = YES;
    }];
    SKAction *bottomSequenceAction = [SKAction sequence:@[bottomMoveAction, bottomCompleteAction]];
    [_replayBottom runAction:bottomSequenceAction];
  }
}

-(void)toggleSwapField {
    // TODO: move animations at some point
    // FIXME: make better animation
    // otherwise toggle
  if (_swapMode) { // swap mode on, so turn off
    [self.mySoundEngine soundSwapFieldSwoosh];
    _fieldActionInProgress = YES;
    
    SKAction *moveAction = [SKAction moveToY:0.f duration:kConstantTime];
    SKAction *completionAction = [SKAction runBlock:^{
      _fieldActionInProgress = NO;
      _swapField.hidden = YES;
      [self hideBoardCover];
    }];
    SKAction *sequenceAction = [SKAction sequence:@[moveAction, completionAction]];
    [_swapField runAction:sequenceAction];
    
    if (_boardField.position.y > _boardField.highestYPos) {
      CGFloat swapBuffer = _boardField.position.y - _boardField.highestYPos;
      SKAction *moveBoardAction = [SKAction moveToY:_boardField.position.y - swapBuffer duration:kConstantTime];
      [_boardField runAction:moveBoardAction];
    }
    
  } else { // swap mode off, turn on
    [self.mySoundEngine soundSwapFieldSwoosh];
    _fieldActionInProgress = YES;
    
    _swapField.hidden = NO;
    SKAction *moveAction = [SKAction moveToY:kRackHeight duration:kConstantTime];
    SKAction *completionAction = [SKAction runBlock:^{
      _fieldActionInProgress = NO;
      [self revealBoardCover];
    }];
    SKAction *sequenceAction = [SKAction sequence:@[moveAction, completionAction]];
    [_swapField runAction:sequenceAction];
    SKAction *moveBoardAction = [SKAction moveToY:_boardField.position.y + kRackHeight duration:kConstantTime];
    [_boardField runAction:moveBoardAction];
  }
}

-(void)revealBoardCover {
    // TODO: make this animated
  _boardCover.hidden = NO;
  _boardCover.zPosition = kZPositionBoardCover;
}

-(void)hideBoardCover {
  _boardCover.hidden = YES;
  _boardCover.zPosition = kZPositionBoardCoverHidden;
}

#pragma mark - match helper methods

-(void)addDataDyadminoToSwapContainerForDyadmino:(Dyadmino *)dyadmino {
  DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
  if (![self.myMatch.swapContainer containsObject:dataDyad]) {
    [self.myMatch.swapContainer addObject:dataDyad];
  }
}

-(void)removeDataDyadminoFromSwapContainerForDyadmino:(Dyadmino *)dyadmino {
  DataDyadmino *dataDyad = [self getDataDyadminoFromDyadmino:dyadmino];
  if ([self.myMatch.swapContainer containsObject:dataDyad]) {
    [self.myMatch.swapContainer removeObject:dataDyad];
  }
}

-(void)animateRecentlyPlayedDyadminoes {
  
    // this is also in populateBoardSet method, but repeated code can't be helped
  NSDictionary *lastTurn = (NSDictionary *)[self.myMatch.turns lastObject];
  Player *lastPlayer = (Player *)[lastTurn valueForKey:@"player"];
  NSArray *lastContainer = (NSArray *)[lastTurn valueForKey:@"container"];
  
    // board must enumerate over both board and holding container dyadminoes
  NSMutableSet *tempDataEnumerationSet = [NSMutableSet setWithSet:self.myMatch.board];
  [tempDataEnumerationSet addObjectsFromArray:self.myMatch.holdingContainer];
  
    // animate last played only if current player does not have dyadminoes in holding container
//  BOOL animateLastPlayedDyadminoes = self.myMatch.holdingContainer.count == 0 ? YES : NO;
  
  for (DataDyadmino *dataDyad in tempDataEnumerationSet) {
    Dyadmino *dyadmino = (Dyadmino *)self.mySceneEngine.allDyadminoes[dataDyad.myID - 1];
  
    // either animate last played dyadminoes, or highlight dyadminoes currently in holding container
//    if (animateLastPlayedDyadminoes) {
    if ([lastContainer containsObject:dataDyad]) {
      [dyadmino animateDyadminoesRecentlyPlayedWithColour:[self.myMatch colourForPlayer:lastPlayer]];
    }
//    } else {
    if ([self.myMatch.holdingContainer containsObject:dataDyad]) {
      [dyadmino highlightBoardDyadminoWithColour:[self.myMatch colourForPlayer:_myPlayer]];
    }
//    }
  }
}

#pragma mark - board helper methods

-(void)updateCellsForPlacedDyadmino:(Dyadmino *)dyadmino andColour:(BOOL)colour {
//  NSLog(@"update cells for placed dyadmino");
  if (![dyadmino isRotating]) {
    dyadmino.tempBoardNode ?
      [_boardField updateCellsForDyadmino:dyadmino placedOnBoardNode:dyadmino.tempBoardNode andColour:colour] :
      [_boardField updateCellsForDyadmino:dyadmino placedOnBoardNode:dyadmino.homeNode andColour:colour];
  }
}

-(void)updateCellsForRemovedDyadmino:(Dyadmino *)dyadmino andColour:(BOOL)colour {
  NSLog(@"update cells for removed dyadmino");
  if (![dyadmino isRotating]) {
    dyadmino.tempBoardNode ?
      [_boardField updateCellsForDyadmino:dyadmino removedFromBoardNode:dyadmino.tempBoardNode andColour:colour] :
      [_boardField updateCellsForDyadmino:dyadmino removedFromBoardNode:dyadmino.homeNode andColour:colour];
  }
}

-(void)updateBoardBoundsAndLayoutCells:(BOOL)layoutCells forZoom:(BOOL)zoom {
  
  NSLog(@"updateBoardBounds called");
  NSMutableSet *dyadminoesOnBoard = [NSMutableSet setWithSet:self.boardDyadminoes];

    // add dyadmino to set if dyadmino is a recent rack dyadmino
  if ([_recentRackDyadmino isOnBoard] && ![dyadminoesOnBoard containsObject:_recentRackDyadmino]) {
    [dyadminoesOnBoard addObject:_recentRackDyadmino];
  }
  
  if (layoutCells) {
    [_boardField layoutBoardCellsAndSnapPointsOfDyadminoes:dyadminoesOnBoard forZoom:zoom];
  }
  
//  [_topBar flashLabelNamed:@"log" withText:[NSString stringWithFormat:@"cells: top %i, right %i, bottom %i, left %i",
//                                             _boardField.cellsTop - 0, _boardField.cellsRight - 0, _boardField.cellsBottom + 0, _boardField.cellsLeft + 0]];
}

#pragma mark - touch helper methods

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self touchesEnded:touches withEvent:event];
}

-(CGPoint)findTouchLocationFromTouches:(NSSet *)touches {
  CGPoint uiTouchLocation = [[touches anyObject] locationInView:self.view];
  return CGPointMake(uiTouchLocation.x, self.frame.size.height - uiTouchLocation.y);
}

#pragma mark - dyadmino helper methods

-(DataDyadmino *)getDataDyadminoFromDyadmino:(Dyadmino *)dyadmino {
  
  NSMutableSet *tempDataDyadSet = [NSMutableSet setWithSet:self.myMatch.board];
  [tempDataDyadSet addObjectsFromArray:_myPlayer.dataDyadminoesThisTurn];

  for (DataDyadmino *dataDyad in tempDataDyadSet) {
    if (dataDyad.myID == dyadmino.myID) {
      return dataDyad;
    }
  }
  
  return nil;
}

-(void)determineCurrentSectionOfDyadmino:(Dyadmino *)dyadmino {
    // this the ONLY place that determines current section of dyadmino
    // this is the ONLY place that sets dyadmino's belongsInSwap to YES
  
    // if it's pivoting, it's on the board, period
    // it's also on board, if not in swap and above rack and below top bar
  if (_pivotInProgress || (!_swapMode && _currentTouchLocation.y - _touchOffsetVector.y >= kRackHeight &&
      _currentTouchLocation.y - _touchOffsetVector.y < self.frame.size.height - kTopBarHeight)) {
//    NSLog(@"it's on the board");
    [self removeDyadmino:dyadmino fromParentAndAddToNewParent:_boardField];
    dyadmino.isInTopBar = NO;
    
      // it's in swap
  } else if (_swapMode && _currentTouchLocation.y - _touchOffsetVector.y > kRackHeight) {
    dyadmino.belongsInSwap = YES;
    [self addDataDyadminoToSwapContainerForDyadmino:dyadmino];
    
    dyadmino.isInTopBar = NO;

    // if in rack field, doesn't matter if it's in swap
  } else if (_currentTouchLocation.y - _touchOffsetVector.y <= kRackHeight) {
    [self removeDyadmino:dyadmino fromParentAndAddToNewParent:_rackField];
    dyadmino.belongsInSwap = NO;
    [self removeDataDyadminoFromSwapContainerForDyadmino:dyadmino];
    dyadmino.isInTopBar = NO;

      // else it's in the top bar, but this is a clumsy workaround, so be careful!
  } else if (!_swapMode && _currentTouchLocation.y - _touchOffsetVector.y >=
             self.frame.size.height - kTopBarHeight) {
    dyadmino.isInTopBar = YES;
  }
}

-(CGPoint)getOffsetForTouchPoint:(CGPoint)touchPoint forDyadmino:(Dyadmino *)dyadmino {
  return dyadmino.parent == _boardField ?
    [_boardField getOffsetForPoint:touchPoint withTouchOffset:_touchOffsetVector] :
    [self subtractFromThisPoint:touchPoint thisPoint:_touchOffsetVector];
}

-(SKSpriteNode *)selectFaceFromTouchPoint:(CGPoint)touchPoint {
  NSArray *touchNodes = [self nodesAtPoint:touchPoint];
  for (SKSpriteNode *touchNode in touchNodes) {
    if ([touchNode.parent isKindOfClass:[Dyadmino class]]) {
      Dyadmino *dyadmino = (Dyadmino *)touchNode.parent;
      CGPoint relToDyadmino = [self addToThisPoint:touchNode.position thisPoint:dyadmino.position];

      if (dyadmino && [dyadmino isOnBoard] && !_swapMode) {
        
          // accommodate the fact that dyadmino's position is now relative to board
        CGPoint relToBoardPoint = [_boardField getOffsetFromPoint:touchPoint];
        if ([self getDistanceFromThisPoint:relToBoardPoint toThisPoint:relToDyadmino] < kDistanceForTouchingFace) {
          return touchNode;
        }
          // if dyadmino is in rack...
      } else if (dyadmino && ([dyadmino isInRack] || [dyadmino isOrBelongsInSwap])) {
        if ([self getDistanceFromThisPoint:touchPoint toThisPoint:relToDyadmino] < kDistanceForTouchingFace) {
          return touchNode;
        }
      }
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
      } else if (dyadmino && ([dyadmino isInRack] || [dyadmino isOrBelongsInSwap])) {
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
    
  } else if ([dyadmino isInRack] || [dyadmino isOrBelongsInSwap]) {
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

#pragma mark - replay and turn methods

-(void)showTurnInfoOrGameResultsForReplay:(BOOL)replay {
  if (self.myMatch.turns.count > 0) {
    
    // if game has ended, give results
    NSString *turnOrResultsText;
    SKColor *colour;
    
      // FIXME: refactor to make more efficient
    if (replay) {
      turnOrResultsText = [self.myMatch turnTextLastPlayed:NO];
      Player *turnPlayer = [self.myMatch.turns[self.myMatch.replayCounter - 1] objectForKey:@"player"];
      colour = [self.myMatch colourForPlayer:turnPlayer];
      
    } else if (!replay && self.myMatch.gameHasEnded) {
      turnOrResultsText = [self.myMatch endGameResultsText];
      
        // just say it was the last play, no turn number
    } else {
      turnOrResultsText = [self.myMatch turnTextLastPlayed:YES];
      Player *turnPlayer = [self.myMatch.turns[self.myMatch.replayCounter - 1] objectForKey:@"player"];
      colour = [self.myMatch colourForPlayer:turnPlayer];
    }
    
    if (replay) {
      [_replayTop updateLabelNamed:@"status" withText:turnOrResultsText andColour:colour];
    } else {
      [_topBar flashLabelNamed:@"message" withText:turnOrResultsText andColour:colour];
    }
  }
}

#pragma mark - undo manager

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
  if ([self.boardDyadminoes containsObject:dyadmino]) {
    NSMutableSet *tempSet = [NSMutableSet setWithSet:self.boardDyadminoes];
    [tempSet removeObject:dyadmino];
    self.boardDyadminoes = [NSSet setWithSet:tempSet];
  }
}

#pragma mark - action sheet methods

-(void)presentPassActionSheet {
  NSString *passString = (self.myMatch.type == kSelfGame) ?
    @"Are you sure? Passing once in solo mode ends the game." :
    @"Are you sure? This will count as your turn.";
  
  NSString *buttonText = (self.myMatch.type == kSelfGame) ? @"End game" : @"Pass";
  
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:passString delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:buttonText otherButtonTitles:nil, nil];
  actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
  actionSheet.tag = 1;
  [actionSheet showInView:self.view];
}

-(void)presentSwapActionSheet {
  
  NSString *swapString = (self.myMatch.type == kSelfGame) ? @"Are you sure you want to swap?" : @"Are you sure? This will count as your turn.";
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:swapString delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Swap" otherButtonTitles:nil, nil];
  actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
  [actionSheet showInView:self.view];
}

-(void)presentResignActionSheet {
  
  
  NSString *resignString;
  
  if (self.myMatch.type == kSelfGame) {
    resignString = @"Are you sure you want to end the game?";
  } else if (self.myMatch.type == kPnPGame) {
    resignString = @"Are you sure you want to resign?";
  } else if (self.myMatch.type == kGCGame) {
    resignString = @"Are you sure? This will count as a loss in Game Center.";
  }
  
  NSString *buttonText = (self.myMatch.type == kSelfGame) ? @"End game" : @"Resign";
  
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:resignString delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:buttonText otherButtonTitles:nil, nil];
  actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
  actionSheet.tag = 3;
  [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *buttonText = [actionSheet buttonTitleAtIndex:buttonIndex];
  
    // resign button
  if (actionSheet.tag == 3 && ([buttonText isEqualToString:@"Resign"] || [buttonText isEqualToString:@"End game"])) {
    [self.myMatch resignPlayer:_myPlayer];
    
      // pass button
  } else if (actionSheet.tag == 1 && ([buttonText isEqualToString:@"Pass"] || [buttonText isEqualToString:@"End game"])) {
    [self finalisePlayerTurn];
  } else if ([buttonText isEqualToString:@"Swap"]) {
    
      // will swap if successful, if not, message will be flashed in finaliseSwap method
    if ([self finaliseSwap]) {
      [self toggleSwapField];
      _swapMode = NO;
    } else {
      
      return;
    }
    
      // cancel swap
  } else if ([buttonText isEqualToString:@"Cancel"]) {
    if (_swapMode) {
      [self toggleSwapField];
      [self cancelSwappedDyadminoes];
    }
    [self updateTopBarButtons];
    return;
  }
  
  [self updateTopBarLabelsFinalTurn:YES animated:NO];
  [self updateTopBarButtons];
}

#pragma mark - delegate methods

-(BOOL)isFirstDyadmino:(Dyadmino *)dyadmino {
  return (self.boardDyadminoes.count == 1 && dyadmino == [self.boardDyadminoes anyObject] && !_recentRackDyadmino) ? YES : NO;
}

-(void)soundRackExchangedDyadmino:(Dyadmino *)dyadmino {
    // this will be a click clack sound
  [self.mySoundEngine soundRackExchangedDyadmino];
}

  // these methods might be different later, so keep them separate
-(void)soundDyadminoPivotClick {
  [self.mySoundEngine soundPivotClickedDyadmino];
}

-(void)soundDyadminoSettleClick {
  NSLog(@"delegate called to sound dyadmino settle click");
  [self.mySoundEngine soundSettledDyadmino];
}

-(void)soundDyadminoSuck {
  [self.mySoundEngine soundSuckedDyadmino];
}

-(void)changeColoursAroundDyadmino:(Dyadmino *)dyadmino withSign:(NSInteger)sign {
  [_boardField changeColoursAroundDyadmino:dyadmino withSign:sign];
}

#pragma mark - debugging methods

-(void)toggleDebugMode {
  
  if (_debugMode) {
    _topBar.pileDyadminoesLabel.hidden = NO;
    _topBar.pileDyadminoesLabel.zPosition = kZPositionTopBarLabel;
    _topBar.boardDyadminoesLabel.hidden = NO;
    _topBar.boardDyadminoesLabel.zPosition = kZPositionTopBarLabel;
    _topBar.holdingContainerLabel.hidden = NO;
    _topBar.holdingContainerLabel.zPosition = kZPositionTopBarLabel;
    _topBar.swapContainerLabel.hidden = NO;
    _topBar.swapContainerLabel.zPosition = kZPositionTopBarLabel;
    
    for (Dyadmino *dyadmino in self.boardDyadminoes) {
      dyadmino.hidden = YES;
    }
    _recentRackDyadmino.hidden = YES;
    
  } else {
    _topBar.pileDyadminoesLabel.hidden = YES;
    _topBar.pileDyadminoesLabel.zPosition = -1000;
    _topBar.boardDyadminoesLabel.hidden = YES;
    _topBar.pileDyadminoesLabel.zPosition = -1000;
    _topBar.holdingContainerLabel.hidden = YES;
    _topBar.holdingContainerLabel.zPosition = -1000;
    _topBar.swapContainerLabel.hidden = YES;
    _topBar.swapContainerLabel.zPosition = -1000;
    
    for (Dyadmino *dyadmino in self.boardDyadminoes) {
      dyadmino.hidden = NO;
    }
    _recentRackDyadmino.hidden = NO;
  }
  
  for (Cell *cell in _boardField.allCells) {
    if ([cell isKindOfClass:[Cell class]]) {
      cell.hexCoordLabel.hidden = (_debugMode) ? NO : YES;
      cell.pcLabel.hidden = (_debugMode) ? NO : YES;
    }
  }

  [self updateTopBarLabelsFinalTurn:NO animated:NO];
  [self updateTopBarButtons];
}

@end
