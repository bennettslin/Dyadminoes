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

@interface MyScene () <FieldNodeDelegate>
@end

  // next step
  // TODO: implement swap, and make it so that adding dyadminoes in board automatically adds rack nodes

  // TODO: put board cells on their own sprite nodes
  // TODO: board cells need coordinates

  // after do board coordinates
  // TODO: put initial dyadmino on board
  // TODO: board nodes expand outward, don't establish them at first
  // TODO: check nodes to ensure that dyadminoes do not conflict on board, do not finish hovering if there's a conflict

  // FIXME: zPosition is based on parent node, so will have to change parent nodes when dyadmino moves from rack to board

  // low priority
  // TODO: have animation between rotation frames
  // TODO: make bouncier animations
  // TODO: make dyadmino sent home shrink then reappear in rack
  // TODO: have reset dyadmino rotate animation back to rack

  // leave alone for now until better information about how Game Center works
  // TODO: make so that player, not dyadmino, knows about pcMode

@implementation MyScene {

    // sprites and nodes
  FieldNode *_rackFieldSprite;
  FieldNode *_swapFieldSprite;
  SKNode *_touchNode;

    // arrays to keep track of sprites and nodes
  NSMutableSet *_boardNodesToSearch;
  NSMutableSet *_boardNodesTwelveAndSix;
  NSMutableSet *_boardNodesTwoAndEight;
  NSMutableSet *_boardNodesFourAndTen;
  NSMutableSet *_buttonNodes;

    // buttons
  SKSpriteNode *_togglePCModeButton;
  SKSpriteNode *_swapButton;
  SKSpriteNode *_doneButton;

    // touches
  CGPoint _beganTouchLocation;
  CGPoint _currentTouchLocation;
  CGPoint _offsetTouchVector;
  
    // bools and modes
  BOOL _swapMode;
  BOOL _rackExchangeInProgress;
  BOOL _dyadminoSnappedIntoMovement;
  
    // pointers
  Dyadmino *_currentlyTouchedDyadmino;
  Dyadmino *_recentRackDyadmino;
  Dyadmino *_hoveringButNotTouchedDyadmino;
  SKSpriteNode *_buttonPressed;

    // hover and pivot properties
  CGPoint _preHoverDyadminoPosition;
  BOOL pivotInProgress;
  CGFloat _initialPivotAngle;
  NSUInteger _prePivotDyadminoOrientation;
  CFTimeInterval _hoverTime;
  
    // temporary
  SKLabelNode *_pileCountLabel;
  SKLabelNode *_messageLabel;
  SKSpriteNode *_logButton;
  SKLabelNode *_logLabel;
}

-(id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    self.ourGameEngine = [GameEngine new];
    self.myPlayer = [self.ourGameEngine getAssignedAsPlayer];
    
//    _rackNodes = [[NSMutableArray alloc] initWithCapacity:kNumDyadminoesInRack];
    _buttonNodes = [NSMutableSet new];
    _boardNodesTwelveAndSix = [NSMutableSet new];
    _boardNodesTwoAndEight = [NSMutableSet new];
    _boardNodesFourAndTen = [NSMutableSet new];
    _rackExchangeInProgress = NO;
    _buttonPressed = nil;
  }
  return self;
}

-(void)didMoveToView:(SKView *)view {
  [self layoutBoard];
  [self layoutOrToggleSwapField];
  [self layoutTopBarAndButtons];
  [self layoutOrRefreshRackField];
  [self populateOrRefreshRackWithDyadminoes];
}

#pragma mark - layout views

-(void)layoutOrToggleSwapField {
    // initial instantiation of swap field sprite
  if (!_swapFieldSprite) {
    _swapFieldSprite = [[FieldNode alloc] initWithWidth:self.frame.size.width andSnapNodeType:kSnapNodeSwap];
    _swapFieldSprite.delegate = self;
    _swapFieldSprite.color = [SKColor lightGrayColor];
    _swapFieldSprite.size = CGSizeMake(self.frame.size.width, kRackHeight);
    _swapFieldSprite.anchorPoint = CGPointZero;
    _swapFieldSprite.position = CGPointMake(0, kRackHeight);
    _swapFieldSprite.zPosition = kZPositionSwapField;
    [self addChild:_swapFieldSprite];
    [_swapFieldSprite layoutOrRefreshFieldWithCount:1];
    _swapMode = YES;
  }
  
    // FIXME: make better animation
    // otherwise toggle
  if (_swapMode) {
    _swapFieldSprite.hidden = YES;
    _swapMode = NO;
  } else {
    _swapFieldSprite.hidden = NO;
    _swapMode = YES;
  }
}

-(void)layoutTopBarAndButtons {
    // background
  SKSpriteNode *topBar = [SKSpriteNode spriteNodeWithColor:[SKColor blueColor]
                                                      size:CGSizeMake(self.frame.size.width, kTopBarHeight)];
  topBar.anchorPoint = CGPointZero;
  topBar.position = CGPointMake(0, self.frame.size.height - kTopBarHeight);
  topBar.zPosition = kZPositionTopBar;
  [self addChild:topBar];
  
  CGSize buttonSize = CGSizeMake(50.f, 50.f);
  CGFloat buttonYPosition = 30.f;
  
  _togglePCModeButton = [[SKSpriteNode alloc] initWithColor:[UIColor orangeColor] size:buttonSize];
  _togglePCModeButton.position = CGPointMake(50.f, buttonYPosition);
  _togglePCModeButton.zPosition = kZPositionTopBarButton;
  [topBar addChild:_togglePCModeButton];
  [_buttonNodes addObject:_togglePCModeButton];
  
  _swapButton = [[SKSpriteNode alloc] initWithColor:[UIColor yellowColor] size:buttonSize];
  _swapButton.position = CGPointMake(100.f, buttonYPosition);
  _swapButton.zPosition = kZPositionTopBarButton;
  [topBar addChild:_swapButton];
  [_buttonNodes addObject:_swapButton];
  
  _doneButton = [[SKSpriteNode alloc] initWithColor:[UIColor greenColor] size:buttonSize];
  _doneButton.position = CGPointMake(150.f, buttonYPosition);
  _doneButton.zPosition = kZPositionTopBarButton;
  [topBar addChild:_doneButton];
  [_buttonNodes addObject:_doneButton];
  [self disableButton:_doneButton];
  
  _logButton = [[SKSpriteNode alloc] initWithColor:[UIColor purpleColor] size:buttonSize];
  _logButton.position = CGPointMake(200.f, buttonYPosition);
  _logButton.zPosition = kZPositionTopBarButton;
  [topBar addChild:_logButton];
  [_buttonNodes addObject:_logButton];
  
  _pileCountLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Neue"];
  _pileCountLabel.text = [NSString stringWithFormat:@"pile %lu", (unsigned long)[self.ourGameEngine getCommonPileCount]];
  _pileCountLabel.fontSize = 14.f;
  _pileCountLabel.position = CGPointMake(275, buttonYPosition);
  _pileCountLabel.zPosition = kZPositionTopBarLabel;
  [topBar addChild:_pileCountLabel];
  
  _messageLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Neue"];
  _messageLabel.fontSize = 14.f;
  _messageLabel.color = [UIColor whiteColor];
  _messageLabel.position = CGPointMake(50, -buttonYPosition);
  _messageLabel.zPosition = kZPositionMessage;
  [topBar addChild:_messageLabel];
  
  _logLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Neue"];
  _logLabel.fontSize = 14.f;
  _logLabel.color = [UIColor whiteColor];
  _logLabel.position = CGPointMake(50, -buttonYPosition * 2);
  _logLabel.zPosition = kZPositionMessage;
  [topBar addChild:_logLabel];
}

-(void)layoutBoard {
  self.backgroundColor = [SKColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
  
  for (int i = 0; i < 6; i++) {
    for (int j = 0; j < 30; j++) {
      SKSpriteNode *blankCell = [SKSpriteNode spriteNodeWithImageNamed:@"blankSpace"];
      blankCell.name = @"blankCell";
      blankCell.zPosition = kZPositionBoardCell;
      CGFloat xOffset = 0; // for odd rows
      
        // TODO: continue to tweak these numbers
      CGFloat xPadding = 5.35f;
      CGFloat yPadding = xPadding * 0.485f;
      CGFloat nodePadding = 0.4f * xPadding;
      
      if (j % 2 == 0) {
        xOffset = blankCell.size.width * 0.75f + xPadding;
      }
      
        // add blank cell
      blankCell.anchorPoint = CGPointMake(0.5, 0.5);
      blankCell.position = CGPointMake(i * (blankCell.size.width * 1.5f + 2.f * xPadding) + xOffset, j * (blankCell.size.height / 2.f + yPadding));
      [self addChild:blankCell];
      
        // add board nodes
      SnapNode *boardNodeTwelveAndSix = [[SnapNode alloc] initWithSnapNodeType:kSnapNodeBoardTwelveAndSix];
      SnapNode *boardNodeTwoAndEight = [[SnapNode alloc] initWithSnapNodeType:kSnapNodeBoardTwoAndEight];
      SnapNode *boardNodeFourAndTen = [[SnapNode alloc] initWithSnapNodeType:kSnapNodeBoardFourAndTen];
      boardNodeTwelveAndSix.position = [self addThisPoint:blankCell.position toThisPoint:CGPointMake(0.f, 19.5f)];
      boardNodeTwoAndEight.position = [self addThisPoint:blankCell.position toThisPoint:CGPointMake(kBoardDiagonalX + nodePadding, kBoardDiagonalY)];
      boardNodeFourAndTen.position = [self addThisPoint:blankCell.position toThisPoint:CGPointMake(-kBoardDiagonalX - nodePadding, kBoardDiagonalY)];
      boardNodeTwelveAndSix.zPosition = kZPositionBoardNode;
      boardNodeTwoAndEight.zPosition = kZPositionBoardNode;
      boardNodeFourAndTen.zPosition = kZPositionBoardNode;
      
      boardNodeTwelveAndSix.name = @"board 12-6";
      boardNodeTwoAndEight.name = @"board 2-8";
      boardNodeFourAndTen.name = @"board 4-10";
      
      [self addChild:boardNodeTwelveAndSix];
      [self addChild:boardNodeTwoAndEight];
      [self addChild:boardNodeFourAndTen];
      
      [_boardNodesTwelveAndSix addObject:boardNodeTwelveAndSix];
      [_boardNodesTwoAndEight addObject:boardNodeTwoAndEight];
      [_boardNodesFourAndTen addObject:boardNodeFourAndTen];
      
        // for testing purposes only
      if (i == 2 && j == 15) {
        SKLabelNode *testLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        testLabelNode.position = blankCell.position;
        testLabelNode.text = @"C";
        testLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        [self addChild:testLabelNode];
      }
    }
  }
}

-(void)layoutOrRefreshRackField {
  if (!_rackFieldSprite) {
    _rackFieldSprite = [[FieldNode alloc] initWithWidth:self.frame.size.width andSnapNodeType:kSnapNodeRack];
    _rackFieldSprite.delegate = self;
    _rackFieldSprite.color = [SKColor purpleColor];
    _rackFieldSprite.size = CGSizeMake(self.frame.size.width, kRackHeight);
    _rackFieldSprite.anchorPoint = CGPointZero;
    _rackFieldSprite.position = CGPointMake(0, 0);
    _rackFieldSprite.zPosition = kZPositionRackField;
    [self addChild:_rackFieldSprite];
  }
  [_rackFieldSprite layoutOrRefreshFieldWithCount:self.myPlayer.dyadminoesInRack.count];
}

-(void)populateOrRefreshRackWithDyadminoes {
  [_rackFieldSprite populateOrRefreshWithDyadminoes:self.myPlayer.dyadminoesInRack];
}

#pragma mark - touch methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//  NSLog(@"touches began");
  
    // get touch location and touched node
  _beganTouchLocation = [self findTouchLocationFromTouches:touches];
  _currentTouchLocation = _beganTouchLocation;
  _touchNode = [self nodeAtPoint:_currentTouchLocation];

    // if it's a button, take care of it when touch ended
  if ([_buttonNodes containsObject:_touchNode]) {
    _buttonPressed = (SKSpriteNode *)_touchNode;
    return;
  }
    //--------------------------------------------------------------------------
  
    // if it's a dyadmino...
  Dyadmino *dyadmino = [self selectDyadminoFromTouchNode:_touchNode
                                           andTouchPoint:_currentTouchLocation];
  if (dyadmino && !dyadmino.isRotating && !_currentlyTouchedDyadmino) {
    [dyadmino startTouchThenHoverResize];
    
    // safeguard against nuttiness
    dyadmino.myTouch = [touches anyObject];
    [self handleBeginTouchOfDyadmino:dyadmino];
  }
}

-(void)handleBeginTouchOfDyadmino:(Dyadmino *)dyadmino {
  _currentlyTouchedDyadmino = dyadmino;
  [self determineCurrentSectionOfDyadmino:_currentlyTouchedDyadmino];
  _offsetTouchVector = [self fromThisPoint:_beganTouchLocation
                         subtractThisPoint:_currentlyTouchedDyadmino.position];

    // reset hover count
  if ([_currentlyTouchedDyadmino isHovering]) {
    [_currentlyTouchedDyadmino keepHovering];
  }

  [_currentlyTouchedDyadmino removeActionsAndEstablishNotRotating];

    //--------------------------------------------------------------------------
  
    // FIXME: this is kind of buggy
    // actively disable done button only when rack dyadmino is in play, not board dyadmino
  if ([_currentlyTouchedDyadmino belongsInRack]) {
    [self disableButton:_doneButton];
  }
  
    // if it's still in the rack, it can still rotate
  if ([_currentlyTouchedDyadmino isInRack]) {
    _currentlyTouchedDyadmino.canFlip = YES;
  }
  
    // various prep
  _currentlyTouchedDyadmino.zPosition = kZPositionHoveredDyadmino;
  
    //--------------------------------------------------------------------------
  
    // if it's now about to pivot, just get pivot angle
  if (pivotInProgress) {
    _initialPivotAngle = [self findAngleInDegreesFromThisPoint:_currentTouchLocation
                                                   toThisPoint:_currentlyTouchedDyadmino.position];
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

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  
    // safeguard against nuttiness
  if (_currentlyTouchedDyadmino && _currentlyTouchedDyadmino.myTouch != [touches anyObject]) {
    return;
  }

    // if the touch started on a button, do nothing and return
  if (_buttonPressed) {
      // TODO: make button highlighted if still pressed
    return;
  }
  
    // nothing happens if there is no current dyadmino
  if (!_currentlyTouchedDyadmino) {
    return;
  }
  
    // continue to reset hover count
  if ([_currentlyTouchedDyadmino isHovering]) {
    [_currentlyTouchedDyadmino keepHovering];
  }
  
    // this is the only place that sets dyadmino highlight
    // dyadmino highlight is reset when sent home or finalised
  if ([_currentlyTouchedDyadmino belongsInRack] &&
      _currentlyTouchedDyadmino.position.y < kRackHeight &&
      _currentlyTouchedDyadmino.position.y >= kRackHeight - kHeightGapToHighlightIntoPlay) {
    if (_currentlyTouchedDyadmino.position.y > kRackHeight - kHeightGapToHighlightIntoPlay) {
      _currentlyTouchedDyadmino.colorBlendFactor =
      (_currentlyTouchedDyadmino.position.y + kHeightGapToHighlightIntoPlay - kRackHeight) *
      kDyadminoColorBlendFactor / kHeightGapToHighlightIntoPlay;
    }
  }
    //--------------------------------------------------------------------------
  
    // get touch location and update currently touched dyadmino's section
    // if hovering, currently touched dyadmino is also being moved, so it can no longer rotate
  _currentTouchLocation = [self findTouchLocationFromTouches:touches];
  CGPoint reverseOffsetPoint = [self fromThisPoint:_currentTouchLocation subtractThisPoint:_offsetTouchVector];
  [self determineCurrentSectionOfDyadmino:_currentlyTouchedDyadmino];

    // if it's a rack dyadmino, highlight when it's in board
  if ([_currentlyTouchedDyadmino belongsInRack]) {
    
    if ([_currentlyTouchedDyadmino isInRack]) {
//      [_currentlyTouchedDyadmino unhighlightOutOfPlay];
    } else {
        // it's now in play
//      [_currentlyTouchedDyadmino highlightIntoPlay];
      
        // reset previous dyadminoes
      if (_currentlyTouchedDyadmino != _recentRackDyadmino) {
        [self sendDyadminoHome:_recentRackDyadmino];
      }
    }
  }
    //--------------------------------------------------------------------------
  
    // if it moved at all, it can no longer flip
  _currentlyTouchedDyadmino.canFlip = NO;

    // now, if we're currently pivoting, just rotate and return
  if (pivotInProgress) {
    CGFloat thisAngle = [self findAngleInDegreesFromThisPoint:_currentTouchLocation
                                                  toThisPoint:_currentlyTouchedDyadmino.position];
    CGFloat sextantChange = [self getSextantChangeFromThisAngle:thisAngle toThisAngle:_initialPivotAngle];
    [_currentlyTouchedDyadmino orientBasedOnSextantChange:sextantChange];
    return;
  }
    //--------------------------------------------------------------------------
  
    // A. determine whether to snap out, or keep moving if already snapped out
    // refer to proper snap node
  SnapNode *snapNode;
  if ([_currentlyTouchedDyadmino belongsInRack]) {
    snapNode = _currentlyTouchedDyadmino.tempBoardNode;
  } else {
    snapNode = _currentlyTouchedDyadmino.homeNode;
  }
  
  if (_dyadminoSnappedIntoMovement ||
      (!_dyadminoSnappedIntoMovement && [self getDistanceFromThisPoint:reverseOffsetPoint
      toThisPoint:snapNode.position] > kDistanceForSnapOut)) {
      // if so, do initial setup; its current node now has no dyadmino, and it can no longer rotate
    _dyadminoSnappedIntoMovement = YES;

      // now move it
    _currentlyTouchedDyadmino.position =
    [self fromThisPoint:_currentTouchLocation subtractThisPoint:_offsetTouchVector];
    
    //--------------------------------------------------------------------------
    
      // if it's a rack dyadmino, then while movement is within rack, rearrange dyadminoes
    if ([_currentlyTouchedDyadmino belongsInRack] && [_currentlyTouchedDyadmino isInRack]) {
      [self handleRackExchangeOfCurrentDyadmino];
    }
  }
}

-(void)handleRackExchangeOfCurrentDyadmino {
  SnapNode *rackNode = [self findSnapNodeClosestToDyadmino:_currentlyTouchedDyadmino];
    // just a precaution
  if (rackNode != _currentlyTouchedDyadmino.homeNode) {
    NSUInteger rackNodesIndex = [_rackFieldSprite.rackNodes indexOfObject:rackNode];
    NSUInteger touchedDyadminoIndex = [self.myPlayer.dyadminoesInRack indexOfObject:_currentlyTouchedDyadmino];
    Dyadmino *exchangedDyadmino = [self.myPlayer.dyadminoesInRack objectAtIndex:rackNodesIndex];
    
      // just a precaution
    if (_currentlyTouchedDyadmino != exchangedDyadmino) {
      [self.myPlayer.dyadminoesInRack exchangeObjectAtIndex:touchedDyadminoIndex withObjectAtIndex:rackNodesIndex];
    }
      // dyadminoes exchange rack nodes, and vice versa
    exchangedDyadmino.homeNode = _currentlyTouchedDyadmino.homeNode;
    
      // take care of state change and animation of exchanged dyadmino, as long as it's not on the board
    if (!exchangedDyadmino.tempBoardNode) {
      exchangedDyadmino.zPosition = kZPositionRackMovedDyadmino;
      [exchangedDyadmino animateConstantSpeedMoveDyadminoToPoint:exchangedDyadmino.homeNode.position];
      exchangedDyadmino.zPosition = kZPositionRackRestingDyadmino;
    }
  }
    // continues exchange, or if just returning back to its own rack node
  _currentlyTouchedDyadmino.homeNode = rackNode;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  
    // safeguard against nuttiness
  if (_currentlyTouchedDyadmino && _currentlyTouchedDyadmino.myTouch != [touches anyObject]) {
    return;
  }
  
    // handle button that was pressed
  if (_buttonPressed) {
      // FIXME: this should ensure that the touch is still on the button when it's released
    if (TRUE) {
      [self handleButtonPressed];
    }
    _buttonPressed = nil;
    return;
  }
  
    // nothing happens if there is no current dyadmino
  if (!_currentlyTouchedDyadmino) {
    return;
  }
    //--------------------------------------------------------------------------
  
  [self determineCurrentSectionOfDyadmino:_currentlyTouchedDyadmino];
  Dyadmino *dyadmino = [self assignCurrentDyadminoToPointer];
  
    // cleanup
  pivotInProgress = NO;
  _offsetTouchVector = CGPointMake(0, 0);
  _dyadminoSnappedIntoMovement = NO;

    // ensures we're not disrupting a rotating animation
  if (!dyadmino.isRotating) {
    
      // if dyadmino belongs in rack and *isn't* on board...
      // ...flip if possible, or send it home
      // and end by making sure everything is in its proper place
    if ([dyadmino belongsInRack] && ![dyadmino isOnBoard]) {
      if (dyadmino.canFlip) {
        [dyadmino animateFlip];
      } else {
        [self sendDyadminoHome:dyadmino];
      }

        // else prepare it for hover
    } else {
      _hoveringButNotTouchedDyadmino = dyadmino;
      [_hoveringButNotTouchedDyadmino startHovering];
      [self prepareTouchEndedDyadminoForHover];
    }
  }
}

-(void)sendDyadminoHome:(Dyadmino *)dyadmino {
  [dyadmino goHome];
  [dyadmino endTouchThenHoverResize];
  dyadmino.withinSection = kDyadminoWithinRack;
  if (dyadmino == _recentRackDyadmino && [_recentRackDyadmino isInRack]) {
    _recentRackDyadmino = nil;
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
    if ([self validateLegalityOfPlacementOfDyadmino:_hoveringButNotTouchedDyadmino onBoardNode:boardNode]) {
      _hoveringButNotTouchedDyadmino.tempBoardNode = boardNode;
      
        // enable done button if it's a rack dyadmino
      if ([_hoveringButNotTouchedDyadmino belongsInRack]) {
        [self enableButton:_doneButton];
      }
      
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

    [self sendDyadminoHome:_hoveringButNotTouchedDyadmino];
  }
}

  // FIXME: obviously, this must work
-(BOOL)validateLegalityOfPlacementOfDyadmino:(Dyadmino *)dyadmino onBoardNode:(SnapNode *)boardNode {
  if ([dyadmino belongsInRack]) {
    // (as long as it doesn't conflict with other dyadminoes, not important if it scores points)
  } else {
    // (doesn't conflict with other dyadminoes, *and* doesn't break musical rules)
  }
  return YES;
}

#pragma mark - button methods

-(void)handleButtonPressed {
    // swap dyadminoes
  if (_buttonPressed == _swapButton) {
    [self layoutOrToggleSwapField];
    return;
  }
  
    // toggle between letter and number symbols
  if (_buttonPressed == _togglePCModeButton) {
    [self toggleBetweenLetterAndNumberMode];
    return;
  }
  
    // submits move
  if (_buttonPressed == _doneButton) {
    [self finaliseThisTurn];
  }
  
    // logs
  if (_buttonPressed == _logButton) {
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

-(void)finaliseThisTurn {
    // FIXME: this one won't be necessary once disable button is enabled and disabled
  
  if (!_currentlyTouchedDyadmino &&
      _hoveringButNotTouchedDyadmino.hoveringStatus != kDyadminoHovering) {
    
      // establish that dyadmino is indeed a rack dyadmino, placed on the board
    if ([_recentRackDyadmino belongsInRack] && [_recentRackDyadmino isOnBoard]) {
      
        // this if statement just confirms that the dyadmino was successfully played
        // before proceeding with anything else
      if ([self.ourGameEngine playOnBoardThisDyadmino:_recentRackDyadmino fromRackOfPlayer:self.myPlayer]) {
        
          // interact with game engine
          // no dyadmino placed in rack, need to recalibrate rack
        if (![self.ourGameEngine putDyadminoFromCommonPileIntoRackOfPlayer:self.myPlayer]) {
          [self layoutOrRefreshRackField];
        }
        
        [self populateOrRefreshRackWithDyadminoes];
        
          // update views
        [self updatePileCountLabel];
        [self updateMessageLabelWithString:@"done"];
        [self disableButton:_doneButton];
        
          // do cleanup, dyadmino's home node is now the board node
        _recentRackDyadmino.homeNode = _recentRackDyadmino.tempBoardNode;
        [_recentRackDyadmino unhighlightOutOfPlay];
        _recentRackDyadmino = nil;
      }
    }
  }
}

  // FIXME: make this better
-(void)enableButton:(SKSpriteNode *)button {
  button.color = [UIColor greenColor];
}

-(void)disableButton:(SKSpriteNode *)button {
  button.color = [UIColor redColor];
}

#pragma mark - update

-(void)update:(CFTimeInterval)currentTime {

    // temporary
  if (_hoverTime != 0.f) {
    [self updateLogLabelWithString:[NSString stringWithFormat:@"%.2f", kAnimateHoverTime - (currentTime - _hoverTime)]];
  } else {
    [self updateLogLabelWithString:@""];
  }
  if (_currentlyTouchedDyadmino) {
    [self updateLogLabelWithString:_currentlyTouchedDyadmino.name];
  }
  
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
  }
}

-(void)updatePileCountLabel {
  _pileCountLabel.text = [NSString stringWithFormat:@"pile %i", [self.ourGameEngine getCommonPileCount]];
}

-(void)updateLogLabelWithString:(NSString *)string {
  _logLabel.text = string;
}

-(void)updateMessageLabelWithString:(NSString *)string {
  _messageLabel.text = string;
  SKAction *wait = [SKAction waitForDuration:2.f];
  SKAction *fadeColor = [SKAction colorizeWithColor:[UIColor clearColor] colorBlendFactor:1.f duration:0.5f];
  SKAction *finishAnimation = [SKAction runBlock:^{
    _messageLabel.text = @"";
    _messageLabel.color = [UIColor whiteColor];
  }];
  SKAction *sequence = [SKAction sequence:@[wait, fadeColor, finishAnimation]];
  [_messageLabel runAction:sequence];
}

#pragma mark - helper methods

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self touchesEnded:touches withEvent:event];
}

-(DyadminoWithinSection)determineCurrentSectionOfDyadmino:(Dyadmino *)dyadmino {
    // TODO: this method should probably be a little more sophisticated than this...
  
  DyadminoWithinSection withinSection;
  if (dyadmino.position.y < kRackHeight) {
    dyadmino.withinSection = kDyadminoWithinRack;
    withinSection = kDyadminoWithinRack;
  } else if (dyadmino.position.y >= kRackHeight &&
             dyadmino.position.y < self.frame.size.height - kTopBarHeight) {
    dyadmino.withinSection = kDyadminoWithinBoard;
    withinSection = kDyadminoWithinBoard;
  } else { // if (_dyadminoBeingTouched.position.y >= self.frame.size.height - kTopBarHeight)
    dyadmino.withinSection = kDyadminoWithinTopBar;
    withinSection = kDyadminoWithinTopBar;
  }
  return withinSection;
}

-(CGPoint)findTouchLocationFromTouches:(NSSet *)touches {
  CGPoint uiTouchLocation = [[touches anyObject] locationInView:self.view];
  return CGPointMake(uiTouchLocation.x, self.frame.size.height - uiTouchLocation.y);
}

-(Dyadmino *)selectDyadminoFromTouchNode:(SKNode *)touchNode andTouchPoint:(CGPoint)touchPoint {
    // pointer to determine last dyadmino, depending on
    // whether moving board dyadmino while rack dyadmino is in play

    // if we're in hovering mode...
  if ([_hoveringButNotTouchedDyadmino isHovering]) {
    
      // if touch point is close enough, just rotate
    if ([self getDistanceFromThisPoint:touchPoint toThisPoint:_hoveringButNotTouchedDyadmino.position] <
        kDistanceForTouchingHoveringDyadmino) {
//      _hoveringButNotTouchedDyadmino.canFlip = YES;
      return _hoveringButNotTouchedDyadmino;
      
        // otherwise, we're pivoting
    } else {
      pivotInProgress = YES;
      _hoveringButNotTouchedDyadmino.prePivotDyadminoOrientation = _hoveringButNotTouchedDyadmino.orientation;
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
  } else {
    return nil;
  }
    
    // second restriction is that touch point is close enough based on following criteria:
    // if dyadmino is on board, not hovering and thus locked in a node...
  [self determineCurrentSectionOfDyadmino:dyadmino];
  if ([dyadmino isOnBoard]) {
    if ([self getDistanceFromThisPoint:touchPoint toThisPoint:dyadmino.position] <
        kDistanceForTouchingLockedDyadmino) {
      return dyadmino;
    }
      // if dyadmino is in rack...
  } else if ([dyadmino isInRack]) {
    if ([self getDistanceFromThisPoint:touchPoint toThisPoint:dyadmino.position] <
        _rackFieldSprite.xIncrementInRack) {
      return dyadmino;
    }
  }
    // otherwise, not close enough
  return nil;
}

-(SnapNode *)findSnapNodeClosestToDyadmino:(Dyadmino *)dyadmino {
  id arrayOrSetToSearch;
  
    // figure out which array of nodes to search
  if ([dyadmino isInRack]) {
    arrayOrSetToSearch = _rackFieldSprite.rackNodes;
  } else if ([dyadmino isOnBoard]) {
    if (dyadmino.orientation == kPC1atTwelveOClock || dyadmino.orientation == kPC1atSixOClock) {
      arrayOrSetToSearch = _boardNodesTwelveAndSix;
    } else if (dyadmino.orientation == kPC1atTwoOClock || dyadmino.orientation == kPC1atEightOClock) {
      arrayOrSetToSearch = _boardNodesTwoAndEight;
    } else if (dyadmino.orientation == kPC1atFourOClock || dyadmino.orientation == kPC1atTenOClock) {
      arrayOrSetToSearch = _boardNodesFourAndTen;
    }
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

#pragma mark - debugging methods

-(void)logRecentAndCurrentDyadminoes {
  NSString *hoveringString = [NSString stringWithFormat:@"hovering not touched %@", [_hoveringButNotTouchedDyadmino logThisDyadmino]];
  NSString *recentRackString = [NSString stringWithFormat:@"recent rack %@", [_recentRackDyadmino logThisDyadmino]];
  NSString *currentString = [NSString stringWithFormat:@"current %@", [_currentlyTouchedDyadmino logThisDyadmino]];
//  NSString *recentString = [NSString stringWithFormat:@"recent %@", [self logThisDyadmino:_recentDyadmino]];
  NSLog(@"%@, %@, %@", hoveringString, currentString, recentRackString);
  
  for (Dyadmino *dyadmino in self.myPlayer.dyadminoesInRack) {
    NSLog(@"%@ is in homeNode %@, tempReturn %@", dyadmino.name, dyadmino.homeNode.name, dyadmino.tempBoardNode.name);
  }
  
  for (SnapNode *rackNode in _rackFieldSprite.rackNodes) {
    NSLog(@"%@ is in %.1f, %.1f", rackNode.name, rackNode.position.x, rackNode.position.y);
  }
  
//  NSLog(@"rack array knows %@", self.myPlayer.dyadminoesInRack);
}

@end
