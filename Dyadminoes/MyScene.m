//
//  MyScene.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/20/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "MyScene.h"
#import "GameEngine.h"
#import "Dyadmino.h"
#import "NSObject+Helper.h"
#import "SnapNode.h"
#import "Player.h"
#import "FieldNode.h"
#import "BoardNode.h"
#import "TopBar.h"

@interface MyScene () <FieldNodeDelegate>
@end

  // TODO: put board cells on their own sprite nodes
  // TODO: board cells need coordinates

  // after do board coordinates
  // TODO: put initial dyadmino on board
  // TODO: board nodes expand outward, don't establish them at first
  // TODO: check nodes to ensure that dyadminoes do not conflict on board, do not finish hovering if there's a conflict

  // easy fixes
  // FIXME: pivot touch should be measured against pc face, not dyadmino center;
  // establish this in selectDyadmino method, and then calculate distance in touchesMoved
  // to decide whether to pivot on that move; distance between pc face and dyadmino center is 21.1
  // (can probably calculate this from texture image)
  // FIXME: zPosition is based on parent node, add sprites to board when in play.
  // (otherwise, a hovering board dyadmino might still be below a resting rack dyadmino)

  // FIXME: make sure board dyadmino returns to its original spot and orientation if ended in rack;
  // this might only happen right now because legality isn't being checked
  // FIXME: make second tap of double tap to rotate hovering dyadmino times out after certain amount of time

  // leisurely TODOs
  // TODO: have animation between rotation frames
  // TODO: make bouncier animations
  // TODO: make dyadmino sent home shrink then reappear in rack
  // TODO: pivot guides
  // TODO: background cells more colourful

  // leave alone for now until better information about how Game Center works
  // TODO: make so that player, not dyadmino, knows about pcMode

@implementation MyScene {
  
    // sprites and nodes
  FieldNode *_rackField;
  FieldNode *_swapField;
  BoardNode *_boardField;
  TopBar *_topBar;
  SKNode *_touchNode;

    // touches
  UITouch *_currentTouch;
  CGPoint _beganTouchLocation;
  CGPoint _currentTouchLocation;
  CGPoint _touchOffsetVector;
  CGPoint _boardShiftedAfterEachTouch;
  
    // bools and modes
  BOOL _swapMode;
  BOOL _rackExchangeInProgress;
  BOOL _dyadminoSnappedIntoMovement;
  BOOL _swapFieldActionInProgress;
  BOOL _boardBeingMoved;
  
    // pointers
  Dyadmino *_currentlyTouchedDyadmino;
  Dyadmino *_recentRackDyadmino;
  Dyadmino *_hoveringButNotTouchedDyadmino;
  SKSpriteNode *_buttonPressed;

    // hover and pivot properties
  BOOL _pivotInProgress;
  CFTimeInterval _hoverTime;
  
    // temporary
  SKLabelNode *_testLabelNode;
  
    // eventually move this to GameEngine, so it can add to dyadmino
  SKNode *_pivotGuide;
}

#pragma mark - init methods

-(id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    self.name = @"myScene";
    self.ourGameEngine = [GameEngine new];
    self.myPlayer = [self.ourGameEngine getAssignedAsPlayer];
    _rackExchangeInProgress = NO;
    _buttonPressed = nil;
  }
  return self;
}

-(void)didMoveToView:(SKView *)view {
  [self layoutBoard];
  [self layoutSwapField];
  [self layoutTopBar];
  [self layoutOrRefreshRackFieldAndDyadminoes];
}

#pragma mark - layout methods

-(void)layoutBoard {
  self.backgroundColor = [SKColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];

  _boardField = [[BoardNode alloc] initWithColor:kSkyBlue
                                        andSize:CGSizeMake(self.frame.size.width, self.frame.size.height)
                                 andAnchorPoint:CGPointZero
                                    andPosition:CGPointZero
                                   andZPosition:kZPositionBoard];
  [self addChild:_boardField];
  [_boardField layoutBoardCellsAndNodes];
}

-(void)layoutSwapField {
    // initial instantiation of swap field sprite
  _swapField = [[FieldNode alloc] initWithFieldNodeType:kFieldNodeSwap
                                              andColour:[SKColor lightGrayColor]
                                                andSize:CGSizeMake(self.frame.size.width, kRackHeight)
                                         andAnchorPoint:CGPointZero
                                            andPosition:CGPointZero
                                           andZPosition:kZPositionSwapField
                                               andBoard:_boardField];
  _swapField.delegate = self;
  [self addChild:_swapField];
  
    // initially sets swap mode
  _swapMode = NO;
  _swapField.hidden = YES;
}

-(void)layoutTopBar {
    // background
  _topBar = [[TopBar alloc] initWithColor:kDarkBlue
                                  andSize:CGSizeMake(self.frame.size.width, kTopBarHeight)
                           andAnchorPoint:CGPointZero
                              andPosition:CGPointMake(0, self.frame.size.height - kTopBarHeight)
                             andZPosition:kZPositionTopBar];
  [_topBar populateWithButtons];
  [_topBar populateWithLabels];
  [self addChild:_topBar];
  [self updatePileCountLabel];
}

-(void)layoutOrRefreshRackFieldAndDyadminoes {
  if (!_rackField) {
    _rackField = [[FieldNode alloc] initWithFieldNodeType:kFieldNodeRack
                                                andColour:kFieldPurple
                                                  andSize:CGSizeMake(self.frame.size.width, kRackHeight)
                                           andAnchorPoint:CGPointZero
                                              andPosition:CGPointZero
                                             andZPosition:kZPositionRackField
                                                 andBoard:_boardField];
    _rackField.delegate = self;
    [self addChild:_rackField];
  }
  [_rackField layoutOrRefreshNodesWithCount:self.myPlayer.dyadminoesInRack.count];
  [_rackField repositionDyadminoes:self.myPlayer.dyadminoesInRack];
}

#pragma mark - touch methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
    // this ensures no more than one touch at a time
  if (!_currentTouch) {
    _currentTouch = [touches anyObject];
  } else {
    return;
  }
    
  if (_swapFieldActionInProgress) {
    return;
  }
  
    // get touch location and touched node
  _beganTouchLocation = [self findTouchLocationFromTouches:touches];
  _currentTouchLocation = _beganTouchLocation;
  _touchNode = [self nodeAtPoint:_currentTouchLocation];
  NSLog(@"touchNode is %@ and has parent %@", _touchNode.name, _touchNode.parent.name);
  
    //--------------------------------------------------------------------------

    // if it's a dyadmino, dyadmino will not be nil
  Dyadmino *dyadmino = [self selectDyadminoFromTouchNode:_touchNode
                                           andTouchPoint:_currentTouchLocation];
  
    // if pivot not in progress, or pivot in progress but dyadmino is not close enough
  if (!_pivotInProgress || (_pivotInProgress && !dyadmino)) {
    
      // if board is touched, then it's being moved
    if (_touchNode.parent == _boardField && ![_touchNode isKindOfClass:[Dyadmino class]]) {
      _boardBeingMoved = YES;
      _boardShiftedAfterEachTouch = [self fromThisPoint:_beganTouchLocation subtractThisPoint:_boardField.position];
      return;
    }
  }
  
    // if it's a button, take care of it when touch ended
  if ([_topBar.buttonNodes containsObject:_touchNode]) {
    _buttonPressed = (SKSpriteNode *)_touchNode;
      // TODO: make distinction of button pressed better, of course
    _buttonPressed.alpha = 0.3f;
    return;
  }
    //--------------------------------------------------------------------------
  
    // otherwise, if it's a dyadmino
  if (dyadmino && !dyadmino.isRotating && !_currentlyTouchedDyadmino) {
    [dyadmino startTouchThenHoverResize];
    
    // safeguard against nuttiness
//    dyadmino.myTouch = [touches anyObject];
    [self handleBeginTouchOfDyadmino:dyadmino];
  }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  
    // this ensures no more than one touch at a time
  UITouch *thisTouch = [touches anyObject];
  if (thisTouch != _currentTouch) {
    return;
  }
  
    // safeguard against nuttiness
//  if (_currentlyTouchedDyadmino && _currentlyTouchedDyadmino.myTouch != [touches anyObject]) {
//    return;
//  }

    // if the touch started on a button, do nothing and return
  if (_buttonPressed) {
    SKNode *node = [self nodeAtPoint:[self findTouchLocationFromTouches:touches]];

    if (node == _buttonPressed) {
      _buttonPressed.alpha = 0.3f;
      return;
    } else {
      _buttonPressed.alpha = 1.f;
      return;
    }
  }
  
    // for both board and dyadmino movement
  _currentTouchLocation = [self findTouchLocationFromTouches:touches];
  
    // if board being moved, handle and return
  if (_boardBeingMoved) {
    _boardField.position = [self fromThisPoint:_currentTouchLocation subtractThisPoint:_boardShiftedAfterEachTouch];
    _boardShiftedAfterEachTouch = [self fromThisPoint:_currentTouchLocation subtractThisPoint:_boardField.position];
    return;
  }

    // nothing happens if there is no current dyadmino
  if (!_currentlyTouchedDyadmino) {
    return;
  }
  
  if (_swapFieldActionInProgress) {
    return;
  }
  
    //--------------------------------------------------------------------------
  
    // continue to reset hover count
  if ([_currentlyTouchedDyadmino isHovering]) {
    [_currentlyTouchedDyadmino keepHovering];
  }
  
    // this is the only place that sets dyadmino highlight
    // dyadmino highlight is reset when sent home or finalised
  if ([_currentlyTouchedDyadmino belongsInRack] && !_swapMode) {
    [_currentlyTouchedDyadmino adjustHighlightIntoPlay];
  }
  
    //--------------------------------------------------------------------------
  
    // update currently touched dyadmino's section
  [self determineCurrentSectionOfDyadmino:_currentlyTouchedDyadmino];

    // if we're currently pivoting, just rotate and return
  if (_pivotInProgress) {
    [_currentlyTouchedDyadmino pivotBasedOnLocation:_currentTouchLocation];
    return;
  }
  
    // if it moved at all, it can no longer flip
  _currentlyTouchedDyadmino.canFlip = NO;
  
    // if rack dyadmino is moved to board, send home recentRack dyadmino
  if ([_currentlyTouchedDyadmino belongsInRack] &&
      [_currentlyTouchedDyadmino isOnBoard] &&
      _currentlyTouchedDyadmino != _recentRackDyadmino) {
    [self sendDyadminoHome:_recentRackDyadmino byPoppingIn:YES];
  }
  
    //--------------------------------------------------------------------------
  
    // A. determine whether to snap out, or keep moving if already snapped out
    // refer to proper snap node
  SnapNode *snapNode;
  if ([_currentlyTouchedDyadmino belongsInRack] || [_currentlyTouchedDyadmino belongsInSwap]) {
    snapNode = _currentlyTouchedDyadmino.tempBoardNode;
  } else {
    snapNode = _currentlyTouchedDyadmino.homeNode;
  }
  
  CGPoint reverseOffsetPoint = [self fromThisPoint:_currentTouchLocation subtractThisPoint:_touchOffsetVector];
  
  if (_dyadminoSnappedIntoMovement ||
      (!_dyadminoSnappedIntoMovement && [self getDistanceFromThisPoint:reverseOffsetPoint
      toThisPoint:snapNode.position] > kDistanceForSnapOut)) {
      // if so, do initial setup; its current node now has no dyadmino, and it can no longer rotate
    _dyadminoSnappedIntoMovement = YES;

      // now move it
    if (_currentlyTouchedDyadmino.parent == _boardField) {
      _currentlyTouchedDyadmino.position =
        [self fromThisPoint:reverseOffsetPoint subtractThisPoint:_boardField.position];
    } else {
      _currentlyTouchedDyadmino.position = reverseOffsetPoint;
    }
    
    //--------------------------------------------------------------------------
    
      // if it's a rack dyadmino, then while movement is within rack, rearrange dyadminoes
    if (([_currentlyTouchedDyadmino belongsInRack] || [_currentlyTouchedDyadmino belongsInSwap]) &&
        ([_currentlyTouchedDyadmino isInRack] || [_currentlyTouchedDyadmino isInSwap])) {
      SnapNode *rackNode = [self findSnapNodeClosestToDyadmino:_currentlyTouchedDyadmino];
      
      [_rackField handleRackExchangeOfTouchedDyadmino:_currentlyTouchedDyadmino
                                             withDyadminoes:(NSMutableArray *)self.myPlayer.dyadminoesInRack
                                         andClosestRackNode:rackNode];
    }
  }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    // this ensures no more than one touch at a time
  UITouch *thisTouch = [touches anyObject];
  if (thisTouch != _currentTouch) {
    return;
  }
  _currentTouch = nil;
  
  if (_swapFieldActionInProgress) {
    return;
  }
  
    // safeguard against nuttiness
//  if (_currentlyTouchedDyadmino && _currentlyTouchedDyadmino.myTouch != [touches anyObject]) {
//    return;
//  }
  
    // handle button that was pressed, ensure that touch is still on button when it ends
  if (_buttonPressed) {
    SKNode *node = [self nodeAtPoint:[self findTouchLocationFromTouches:touches]];
    if (node == _buttonPressed) {
      [self handleButtonPressed];
    }
    _buttonPressed.alpha = 1.f;
    _buttonPressed = nil;
    return;
  }
  
    // board no longer being moved
  if (_boardBeingMoved) {
    _boardBeingMoved = NO;
  }
  
    // nothing happens if there is no current dyadmino
  if (!_currentlyTouchedDyadmino) {
    return;
  }
    //--------------------------------------------------------------------------
  
  [self determineCurrentSectionOfDyadmino:_currentlyTouchedDyadmino];
  Dyadmino *dyadmino = [self assignCurrentDyadminoToPointer];
  
    // cleanup
  _pivotInProgress = NO;
  _touchOffsetVector = CGPointZero;
  _dyadminoSnappedIntoMovement = NO;

    // ensures we're not disrupting a rotating animation
  if (!dyadmino.isRotating) {
    
      // if dyadmino belongs in rack and *isn't* on board...
    if (([dyadmino belongsInRack] || [dyadmino belongsInSwap]) && ![dyadmino isOnBoard]) {
      
        // if it's in swap field...
        // this doesn't change the dyadmino's home node, it just changes
        // its status; rack will recognise this status and position dyadmino
        // in same x position, but with heightened yPosition as if it's on rack
      
        // this is the only place that belongsInSwap is set
        // as long as it's not in the rack, it's in the swap
      if (_swapMode && ![dyadmino isInRack]) {
        dyadmino.belongsInSwap = YES;
      } else {
        dyadmino.belongsInSwap = NO;
      }
      
          // ...flip if possible, or send it home
      if (dyadmino.canFlip) {
        [dyadmino animateFlip];
      } else {
        [self sendDyadminoHome:dyadmino byPoppingIn:NO];
      }

        // else prepare it for hover
    } else {
      _hoveringButNotTouchedDyadmino = dyadmino;
      [_hoveringButNotTouchedDyadmino startHovering];
      [self prepareTouchEndedDyadminoForHover];
    }
  }
}

#pragma mark - touch procedure methods

-(void)handleBeginTouchOfDyadmino:(Dyadmino *)dyadmino {
  _currentlyTouchedDyadmino = dyadmino;
  [self determineCurrentSectionOfDyadmino:_currentlyTouchedDyadmino];
  
  if (dyadmino.parent == _rackField) {
    _touchOffsetVector = [self fromThisPoint:_beganTouchLocation
                           subtractThisPoint:_currentlyTouchedDyadmino.position];
  } else {
    CGPoint boardOffsetPoint = [self addThisPoint:_currentlyTouchedDyadmino.position toThisPoint:_boardField.position];
    _touchOffsetVector = [self fromThisPoint:_beganTouchLocation subtractThisPoint:boardOffsetPoint];
  }
  
    // reset hover count
  if ([_currentlyTouchedDyadmino isHovering]) {
    [_currentlyTouchedDyadmino keepHovering];
  }
  
  [_currentlyTouchedDyadmino removeActionsAndEstablishNotRotating];
  
    //--------------------------------------------------------------------------
  
    // if it's still in the rack, it can still rotate
  if ([_currentlyTouchedDyadmino isInRack] || [_currentlyTouchedDyadmino isInSwap]) {
    _currentlyTouchedDyadmino.canFlip = YES;
  }
  
    // various prep
  _currentlyTouchedDyadmino.zPosition = kZPositionHoveredDyadmino;
  
    //--------------------------------------------------------------------------
  
    // if it's now about to pivot, just get pivot angle
  if (_pivotInProgress) {
    _currentlyTouchedDyadmino.initialPivotAngle = [self findAngleInDegreesFromThisPoint:_currentTouchLocation
                                                                            toThisPoint:_currentlyTouchedDyadmino.position];
    [_currentlyTouchedDyadmino determinePivotOnPC];
    return;
  }
  
    // if it's on the board and not already rotating, two possibilities
  if ([_currentlyTouchedDyadmino isOnBoard] && !_currentlyTouchedDyadmino.isRotating) {
    
      // 1. it's not hovering, so make it hover
    if (!_currentlyTouchedDyadmino.canFlip) {
      _currentlyTouchedDyadmino.canFlip = YES;
      
        // 2. it's already hovering, so tap inside to flip
    } else {
      [_currentlyTouchedDyadmino animateFlip];
    }
  }
}

-(Dyadmino *)assignCurrentDyadminoToPointer {
    // rack dyadmino only needs pointer if it's still on board
  if ([_currentlyTouchedDyadmino belongsInRack] && [_currentlyTouchedDyadmino isOnBoard]) {
    _recentRackDyadmino = _currentlyTouchedDyadmino;
  }
  
  Dyadmino *dyadmino = _currentlyTouchedDyadmino;
  _currentlyTouchedDyadmino = nil;
  return dyadmino;
}

-(void)prepareTouchEndedDyadminoForHover {
  
  if ([_hoveringButNotTouchedDyadmino isOnBoard]) {
    
      // establish the closest board node, without snapping just yet
    SnapNode *boardNode = [self findSnapNodeClosestToDyadmino:_hoveringButNotTouchedDyadmino];
    
      // if valid placement
    if ([self validateLegalityOfDyadmino:_hoveringButNotTouchedDyadmino onBoardNode:boardNode]) {
      _hoveringButNotTouchedDyadmino.tempBoardNode = boardNode;
      
        // change to new board node if it's a board dyadmino
      if ([_hoveringButNotTouchedDyadmino belongsOnBoard]) {
        _hoveringButNotTouchedDyadmino.homeNode = boardNode;
      }
      
        //      [_hoveringButNotTouchedDyadmino prepareStateForHoverWithBoardNode:boardNode];
      [_hoveringButNotTouchedDyadmino removeActionsAndEstablishNotRotating];
      [_hoveringButNotTouchedDyadmino startHovering];
      
    } else {
        // method to return to original place
    }
    
      // if it's in the top bar or the rack (doesn't matter whether it's a board or rack dyadmino)
  } else {
    
      // if it can still rotate, do so
    
    [self sendDyadminoHome:_hoveringButNotTouchedDyadmino byPoppingIn:NO];
  }
}

#pragma mark - button methods

-(void)handleButtonPressed {
  
    // swap dyadminoes
  if (_buttonPressed == _topBar.swapButton) {
    if (!_swapMode) {
      [self toggleSwapField];
    }
    
  } else if (_buttonPressed == _topBar.togglePCModeButton) {
    [self toggleBetweenLetterAndNumberMode];
    
  } else if (_buttonPressed == _topBar.playDyadminoButton) {
    [self playDyadmino];
    
  } else if (_buttonPressed == _topBar.cancelButton) {
    if (_swapMode) {
      [self cancelSwappedDyadminoes];
      [self toggleSwapField];
    }
    
  } else if (_buttonPressed == _topBar.doneTurnButton) {
    if (!_swapMode) {
      [self finalisePlayerTurn];
    } else if (_swapMode) {
      if ([self finaliseSwap]) {
        [self toggleSwapField];
      }
    }
    
  } else if (_buttonPressed == _topBar.logButton) {
    [self logRecentAndCurrentDyadminoes];
  }
}

-(void)toggleBetweenLetterAndNumberMode {
  
    // FIXME: will this affect other player's view of dyadminoes?
  for (Dyadmino *dyadmino in self.ourGameEngine.allDyadminoes) {
    if (dyadmino.pcMode == kPCModeLetter) {
      dyadmino.pcMode = kPCModeNumber;
    } else {
      dyadmino.pcMode = kPCModeLetter;
    }
    [dyadmino selectAndPositionSprites];
  }
}

-(void)toggleSwapField {
    // TODO: move animations at some point
    // FIXME: make better animation
    // otherwise toggle
  if (_swapMode) { // swap mode on, so turn off
    _swapFieldActionInProgress = YES;
    
    SKAction *moveAction = [SKAction moveTo:CGPointMake(0.f, 0.f) duration:kConstantTime];
    SKAction *completionAction = [SKAction runBlock:^{
      _swapFieldActionInProgress = NO;
      _swapField.hidden = YES;
      _swapMode = NO;
      [_boardField hideBoardCover];
    }];
    SKAction *sequenceAction = [SKAction sequence:@[moveAction, completionAction]];
    [_swapField runAction:sequenceAction];
    
  } else { // swap mode off, turn on
    _swapFieldActionInProgress = YES;
    
    _swapField.hidden = NO;
    SKAction *moveAction = [SKAction moveTo:CGPointMake(0.f, kRackHeight) duration:kConstantTime];
    SKAction *completionAction = [SKAction runBlock:^{
      _swapFieldActionInProgress = NO;
      _swapMode = YES;
      [_boardField revealBoardCover];
    }];
    SKAction *sequenceAction = [SKAction sequence:@[moveAction, completionAction]];
    [_swapField runAction:sequenceAction];
  }
}

#pragma mark - engine methods

-(BOOL)validateLegalityOfDyadmino:(Dyadmino *)dyadmino onBoardNode:(SnapNode *)boardNode {
    // FIXME: obviously, this must work
  if ([dyadmino belongsInRack]) {
      // (as long as it doesn't conflict with other dyadminoes, not important if it scores points)
  } else {
      // (doesn't conflict with other dyadminoes, *and* doesn't break musical rules)
  }
  return YES;
}

-(void)cancelSwappedDyadminoes {
  for (Dyadmino *dyadmino in self.myPlayer.dyadminoesInRack) {
    if (dyadmino.belongsInSwap) {
      dyadmino.belongsInSwap = NO;
      [dyadmino goHomeByPoppingIn:NO];
    }
  }
}

-(BOOL)finaliseSwap {
  NSMutableArray *toPile = [NSMutableArray new];
  
  for (Dyadmino *dyadmino in self.myPlayer.dyadminoesInRack) {
    if (dyadmino.belongsInSwap) {
      [toPile addObject:dyadmino];
    }
  }
  
    // if swapped dyadminoes is greater than pile count, cancel
  if (toPile.count > [self.ourGameEngine getCommonPileCount]) {
    [self updateMessageLabelWithString:@"This is more than the pile count"];
    return NO;
    
      // else, proceed with swap
  } else {

      // first take care of views
    for (Dyadmino *dyadmino in toPile) {
      dyadmino.belongsInSwap = NO;
      
        // TODO: this should be a better animation
        // dyadmino is already a child of rackField,
        // so no need to send dyadmino home through myScene's sendDyadmino method
      [dyadmino goHomeByPoppingIn:NO];
//      [self sendDyadminoHome:dyadmino byPoppingIn:NO];
      [dyadmino removeFromParent];
    }
    
      // then swap in the logic
    [self.ourGameEngine swapTheseDyadminoes:toPile fromPlayer:self.myPlayer];
    
    [self layoutOrRefreshRackFieldAndDyadminoes];
      // update views
    [self updatePileCountLabel];
    [self updateMessageLabelWithString:@"swapped!"];
    return YES;
  }
}

-(void)playDyadmino {
    // establish that dyadmino is indeed a rack dyadmino placed on the board
  if ([_recentRackDyadmino belongsInRack] && [_recentRackDyadmino isOnBoard]) {
    
      // confirm that the dyadmino was successfully played before proceeding with anything else
    if ([self.ourGameEngine playOnBoardThisDyadmino:_recentRackDyadmino fromRackOfPlayer:self.myPlayer]) {
      
        // do cleanup, dyadmino's home node is now the board node
      _recentRackDyadmino.homeNode = _recentRackDyadmino.tempBoardNode;
      [_recentRackDyadmino unhighlightOutOfPlay];
      _recentRackDyadmino = nil;
      _hoveringButNotTouchedDyadmino = nil;
    }
  }
  [self layoutOrRefreshRackFieldAndDyadminoes];
}

-(void)finalisePlayerTurn {
    // no recent rack dyadmino on board
  if (!_recentRackDyadmino) {
    while ([self.ourGameEngine getCommonPileCount] >= 1 && self.myPlayer.dyadminoesInRack.count < 6) {
      [self.ourGameEngine putDyadminoFromPileIntoRackOfPlayer:self.myPlayer];
    }

  [self layoutOrRefreshRackFieldAndDyadminoes];
  
    // update views
  [self updatePileCountLabel];
  [self updateMessageLabelWithString:@"done"];
  }
}

#pragma mark - update and reset methods

-(void)update:(CFTimeInterval)currentTime {

    // FIXME: this was the reason for the pause in the beginning
    // when dyadmino is forst placed on board, but I'm not sure why
//  if (_hoverTime != 0.f) {
//    [self updateLogLabelWithString:[NSString stringWithFormat:@"%.2f", kAnimateHoverTime - (currentTime - _hoverTime)]];
//  } else {
//    [self updateLogLabelWithString:@""];
//  }
  
  if ([_hoveringButNotTouchedDyadmino isHovering]) {
    if (_hoverTime == 0.f) {
      _hoverTime = currentTime;
    }
  }
  
    // reset hover time if continues to hover
  if ([_hoveringButNotTouchedDyadmino continuesToHover]) {
    _hoverTime = currentTime;
    _hoveringButNotTouchedDyadmino.hoveringStatus = kDyadminoHovering;
  }
  
  if (_hoverTime != 0.f && currentTime > _hoverTime + kAnimateHoverTime) {
    _hoverTime = 0.f;
    
      // finish status
    [_hoveringButNotTouchedDyadmino setToHomeZPosition];
    [_hoveringButNotTouchedDyadmino finishHovering];
    _hoveringButNotTouchedDyadmino.tempReturnOrientation = _hoveringButNotTouchedDyadmino.orientation;
  }
  

    // ease into node after hovering
  if ([_hoveringButNotTouchedDyadmino isOnBoard] &&
      [_hoveringButNotTouchedDyadmino isFinishedHovering] &&
      _currentlyTouchedDyadmino != _hoveringButNotTouchedDyadmino) {
    [_hoveringButNotTouchedDyadmino animateEaseIntoNodeAfterHover];
    _hoveringButNotTouchedDyadmino = nil;
  }
    //--------------------------------------------------------------------------

    // handle buttons
    // TODO: if button enabling and disabling are animated, change this
  
    // while *not* in swap mode...
  if (!_swapMode) {
    [_topBar disableButton:_topBar.cancelButton];
    
        // these are the criteria by which play and done button is enabled
    if ([_recentRackDyadmino belongsInRack] && [_recentRackDyadmino isOnBoard] &&
        ![_hoveringButNotTouchedDyadmino isHovering] &&
        (_currentlyTouchedDyadmino == nil || [_currentlyTouchedDyadmino isInRack])) {
      [_topBar enableButton:_topBar.playDyadminoButton];
      [_topBar disableButton:_topBar.doneTurnButton];
    } else {
      [_topBar disableButton:_topBar.playDyadminoButton];
      [_topBar enableButton:_topBar.doneTurnButton];
    }
    
      // ...these are the criteria by which swap button is enabled
      // swap button cannot have any rack dyadminoes on board
    if (_currentlyTouchedDyadmino || _recentRackDyadmino) {
      [_topBar disableButton:_topBar.swapButton];
    } else {
      [_topBar enableButton:_topBar.swapButton];
    }
    
      // if in swap mode, cancel button cancels swap, done button finalises swap
  } else if (_swapMode) {
    [_topBar enableButton:_topBar.cancelButton];
    [_topBar enableButton:_topBar.doneTurnButton];
    [_topBar disableButton:_topBar.swapButton];
  }
}

-(void)updatePileCountLabel {
  _topBar.pileCountLabel.text = [NSString stringWithFormat:@"pile %lu", (unsigned long)[self.ourGameEngine getCommonPileCount]];
}

-(void)sendDyadminoHome:(Dyadmino *)dyadmino byPoppingIn:(BOOL)poppingIn {
  [dyadmino goHomeByPoppingIn:poppingIn];
  [dyadmino endTouchThenHoverResize];
  
  if (dyadmino.belongsInSwap) {
    dyadmino.withinSection = kWithinSwap;
  } else {
    dyadmino.withinSection = kWithinRack;
  }
  
  [self removeDyadmino:dyadmino fromParentAndAddToNewParent:_rackField];
  if (dyadmino == _recentRackDyadmino && [_recentRackDyadmino isInRack]) {
    _recentRackDyadmino = nil;
  }
}

-(void)updateLogLabelWithString:(NSString *)string {
  _topBar.logLabel.text = string;
}

-(void)updateMessageLabelWithString:(NSString *)string {
  [_topBar.messageLabel removeAllActions];
  _topBar.messageLabel.text = string;
  SKAction *wait = [SKAction waitForDuration:2.f];
  SKAction *fadeColor = [SKAction colorizeWithColor:[UIColor clearColor] colorBlendFactor:1.f duration:0.5f];
  SKAction *finishAnimation = [SKAction runBlock:^{
    _topBar.messageLabel.text = @"";
    _topBar.messageLabel.color = [UIColor whiteColor];
  }];
  SKAction *sequence = [SKAction sequence:@[wait, fadeColor, finishAnimation]];
  [_topBar.messageLabel runAction:sequence];
}

#pragma mark - helper methods

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self touchesEnded:touches withEvent:event];
}

-(CGPoint)findTouchLocationFromTouches:(NSSet *)touches {
  CGPoint uiTouchLocation = [[touches anyObject] locationInView:self.view];
  return CGPointMake(uiTouchLocation.x, self.frame.size.height - uiTouchLocation.y);
}

-(DyadminoWithinSection)determineCurrentSectionOfDyadmino:(Dyadmino *)dyadmino {
  
    // initially make this the dyadmino's previous within section,
    // then change based on new criteria
  DyadminoWithinSection withinSection = dyadmino.withinSection;
  
  if (_swapMode && _currentTouchLocation.y - _touchOffsetVector.y > kRackHeight) {
      // if dyadmino is in swap, its parent is the rack, and stays as such
    dyadmino.withinSection = kWithinSwap;
    withinSection = kWithinSwap;

    // if in rack field, doesn't matter if it's in swap
  } else if (_currentTouchLocation.y - _touchOffsetVector.y <= kRackHeight) {
    [self removeDyadmino:dyadmino fromParentAndAddToNewParent:_rackField];
    dyadmino.withinSection = kWithinRack;
    withinSection = kWithinRack;

      // if not in swap, it's in board when above rack and below top bar
  } else if (!_swapMode &&
             _currentTouchLocation.y - _touchOffsetVector.y >= kRackHeight &&
             _currentTouchLocation.y - _touchOffsetVector.y < self.frame.size.height - kTopBarHeight) {
    [self removeDyadmino:dyadmino fromParentAndAddToNewParent:_boardField];
    dyadmino.withinSection = kWithinBoard;
    withinSection = kWithinBoard;
    
      // else it's nowhere legal
  } else {
    dyadmino.withinSection = kWithinNowhereLegal;
    withinSection = kWithinNowhereLegal;
  }
  
  return withinSection;
}

-(Dyadmino *)selectDyadminoFromTouchNode:(SKNode *)touchNode andTouchPoint:(CGPoint)touchPoint {
    // pointer to determine last dyadmino, depending on
    // whether moving board dyadmino while rack dyadmino is in play

    // if we're in hovering mode...
  if ([_hoveringButNotTouchedDyadmino isHovering]) {
    
      // accommodate if it's on board
    CGPoint relativeToBoardPoint = touchPoint;
    if (_hoveringButNotTouchedDyadmino.parent == _boardField) {
      relativeToBoardPoint = [self fromThisPoint:touchPoint subtractThisPoint:_boardField.position];
    }
    
      // if touch point is close enough, just rotate
    if ([self getDistanceFromThisPoint:relativeToBoardPoint toThisPoint:_hoveringButNotTouchedDyadmino.position] <
        kDistanceForTouchingHoveringDyadmino) {
      return _hoveringButNotTouchedDyadmino;
 
        // otherwise, we're pivoting, so establish that
    } else if ([self getDistanceFromThisPoint:relativeToBoardPoint toThisPoint:_hoveringButNotTouchedDyadmino.position] <
            kMaxDistanceForPivot) {
      _pivotInProgress = YES;
      
      _hoveringButNotTouchedDyadmino.prePivotDyadminoOrientation = _hoveringButNotTouchedDyadmino.orientation;
        // this is reset to zero only after eased into place
      if (CGPointEqualToPoint(_hoveringButNotTouchedDyadmino.prePivotPosition, CGPointZero)) {
        _hoveringButNotTouchedDyadmino.prePivotPosition = _hoveringButNotTouchedDyadmino.position;
      }
      
      [_hoveringButNotTouchedDyadmino removeActionsAndEstablishNotRotating];
      return _hoveringButNotTouchedDyadmino;
    }
  }
    //--------------------------------------------------------------------------
  
    // otherwise, first restriction is that the node being touched is the dyadmino
  Dyadmino *dyadmino;
  if ([touchNode isKindOfClass:[Dyadmino class]]) {
    dyadmino = (Dyadmino *)touchNode;
  } else if ([touchNode.parent isKindOfClass:[Dyadmino class]]) {
    dyadmino = (Dyadmino *)touchNode.parent;
  } else if ([touchNode.parent.parent isKindOfClass:[Dyadmino class]]) {
    dyadmino = (Dyadmino *)touchNode.parent.parent;
  } else {
    return nil;
  }
    
    // second restriction is that touch point is close enough based on following criteria:
    // if dyadmino is on board, not hovering and thus locked in a node, and we're not in swap mode...
  [self determineCurrentSectionOfDyadmino:dyadmino];
  

  if ([dyadmino isOnBoard] && !_swapMode) {

      // accommodate the fact that dyadmino's position is now relative to board
    CGPoint relativeToBoardPoint = [self fromThisPoint:touchPoint subtractThisPoint:_boardField.position];
    if ([self getDistanceFromThisPoint:relativeToBoardPoint toThisPoint:dyadmino.position] <
        kDistanceForTouchingLockedDyadmino) {
      return dyadmino;
    }
      // if dyadmino is in rack...
  } else if ([dyadmino isInRack] || [dyadmino isInSwap]) {
    if ([self getDistanceFromThisPoint:touchPoint toThisPoint:dyadmino.position] <
        _rackField.xIncrementInRack) {
      return dyadmino;
    }
  }
  
    // otherwise, dyadmino is not close enough
  return nil;
}

-(SnapNode *)findSnapNodeClosestToDyadmino:(Dyadmino *)dyadmino {
  id arrayOrSetToSearch;
  
if (!_swapMode && [dyadmino isOnBoard]) {
    if (dyadmino.orientation == kPC1atTwelveOClock || dyadmino.orientation == kPC1atSixOClock) {
      arrayOrSetToSearch = _boardField.boardNodesTwelveAndSix;
    } else if (dyadmino.orientation == kPC1atTwoOClock || dyadmino.orientation == kPC1atEightOClock) {
      arrayOrSetToSearch = _boardField.boardNodesTwoAndEight;
    } else if (dyadmino.orientation == kPC1atFourOClock || dyadmino.orientation == kPC1atTenOClock) {
      arrayOrSetToSearch = _boardField.boardNodesFourAndTen;
    }
    
  } else if ([dyadmino isInRack] || [dyadmino isInSwap]) {
    arrayOrSetToSearch = _rackField.rackNodes;
  }
  
    // get the closest snapNode
  SnapNode *closestSnapnode;
  CGFloat shortestDistance = self.frame.size.height;
  
  for (SnapNode *snapNode in arrayOrSetToSearch) {
    CGFloat thisDistance = [self getDistanceFromThisPoint:dyadmino.position toThisPoint:snapNode.position];
    if (thisDistance < shortestDistance) {
      shortestDistance = thisDistance;
      closestSnapnode = snapNode;
    }
  }
  return closestSnapnode;
}

-(void)removeDyadmino:(Dyadmino *)dyadmino fromParentAndAddToNewParent:(SKSpriteNode *)newParent {
  if (dyadmino && newParent && dyadmino.parent != newParent) {
    [dyadmino removeFromParent];
    [newParent addChild:dyadmino];
  }
}

#pragma mark - debugging methods

-(void)logRecentAndCurrentDyadminoes {
  NSString *hoveringString = [NSString stringWithFormat:@"hovering not touched %@", [_hoveringButNotTouchedDyadmino logThisDyadmino]];
  NSString *recentRackString = [NSString stringWithFormat:@"recent rack %@", [_recentRackDyadmino logThisDyadmino]];
  NSString *currentString = [NSString stringWithFormat:@"current %@", [_currentlyTouchedDyadmino logThisDyadmino]];
  NSLog(@"%@, %@, %@", hoveringString, currentString, recentRackString);
  
  for (Dyadmino *dyadmino in self.myPlayer.dyadminoesInRack) {
    NSLog(@"%@ has homeNode %@, tempReturn %@, is child of %@, belongs in swap %i, and is at %.2f, %.2f and child of %@", dyadmino.name, dyadmino.homeNode.name, dyadmino.tempBoardNode.name, dyadmino.parent.name, dyadmino.belongsInSwap, dyadmino.position.x, dyadmino.position.y, dyadmino.parent.name);
  }
  
  
  NSLog(@"rack dyadmino on board is at %.2f, %.2f and child of %@", _recentRackDyadmino.position.x, _recentRackDyadmino.position.y, _recentRackDyadmino.parent.name);
  
//  for (SnapNode *snapNode in _rackField.rackNodes) {
//    NSLog(@"%@ is in position %.1f, %.1f", snapNode.name, snapNode.position.x, snapNode.position.y);
//  }
  
  _boardField.position = CGPointZero;
  _boardShiftedAfterEachTouch = CGPointZero;
  
  if (_recentRackDyadmino) {
    [_recentRackDyadmino.pivotGuide removeFromParent];
    [_recentRackDyadmino addChild:_recentRackDyadmino.pivotGuide];
  }
}

@end
