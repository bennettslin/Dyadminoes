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

  // FIXME: bug where after drag one dyadmino,
  // last dyadmino doesn't return to node, just rests right there
  // maybe this just happens in simulator? So far on phone it doesn't happen

  // easy to do
  // TODO: implement swap, and make it reset dyadminoes on board, but only up until number in pile
  // TODO: enum for zPosition

  // next step
  // TODO: put board cells on their own sprite nodes
  // TODO: board cells need coordinates

  // after do board coordinates
  // TODO: put initial dyadmino on board
  // TODO: board nodes expand outward, don't establish them at first
  // TODO: check rack nodes to ensure that dyadminoes do not conflict on board, do not finish hovering if there's a conflict

  // low priority
  // TODO: make rack exchange not so sensitive on top and bottoms of rack
  // TODO: still problem with some dyadminoes staying highlighted after going nuts
  // TODO: have animation between rotation frames
  // TODO: make bouncier animations
  // TODO: have reset dyadmino rotate animation back to rack

  // leave alone for now until better information about how Game Center works
  // TODO: make so that player, not dyadmino, knows about pcMode


@implementation MyScene {
  
    // constants
//  CGFloat _xIncrementInRack;
  
    // sprites and nodes
  FieldNode *_rackFieldSprite;
  FieldNode *_swapFieldSprite;
  SKNode *_touchNode;

    // arrays to keep track of sprites and nodes
//  NSMutableArray *_rackNodes;
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
  SKSpriteNode *_buttonPressed; // pointer to button that was pressed
  BOOL _rackExchangeInProgress;
  BOOL _dyadminoSnappedIntoMovement;
  Dyadmino *_currentlyTouchedDyadmino;
  Dyadmino *_recentRackDyadmino;
  Dyadmino *_recentBoardDyadmino;
  Dyadmino *_recentDyadmino;
  
    // hover and pivot properties
  DyadminoHoveringStatus _dyadminoHoveringStatus;
  Dyadmino *_currentlyHoveringDyadmino;
  CGPoint _preHoverDyadminoPosition;
  BOOL _hoverPivotInProgress;
//  BOOL _moveBoardDyadminoWhileRackDyadminoInPlay;
  CGFloat _initialPivotAngle;
  NSUInteger _prePivotDyadminoOrientation;
  
    // temporary
  SKLabelNode *_pileCountLabel;
  SKLabelNode *_messageLabel;
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
    _dyadminoHoveringStatus = kDyadminoNoHoverStatus;
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
    _swapFieldSprite.size = CGSizeMake(self.frame.size.width, kPlayerRackHeight);
    _swapFieldSprite.anchorPoint = CGPointZero;
    _swapFieldSprite.position = CGPointMake(0, kPlayerRackHeight);
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
  [self addChild:topBar];
  
  CGSize buttonSize = CGSizeMake(50.f, 50.f);
  CGFloat buttonYPosition = 30.f;
  
  _togglePCModeButton = [[SKSpriteNode alloc] initWithColor:[UIColor orangeColor] size:buttonSize];
  _togglePCModeButton.position = CGPointMake(50.f, buttonYPosition);
  [topBar addChild:_togglePCModeButton];
  [_buttonNodes addObject:_togglePCModeButton];
  
  _swapButton = [[SKSpriteNode alloc] initWithColor:[UIColor yellowColor] size:buttonSize];
  _swapButton.position = CGPointMake(125.f, buttonYPosition);
  [topBar addChild:_swapButton];
  [_buttonNodes addObject:_swapButton];
  
  _doneButton = [[SKSpriteNode alloc] initWithColor:[UIColor greenColor] size:buttonSize];
  _doneButton.position = CGPointMake(200.f, buttonYPosition);
  [topBar addChild:_doneButton];
  [_buttonNodes addObject:_doneButton];
  [self disableButton:_doneButton];
  
  _pileCountLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Neue"];
  _pileCountLabel.text = [NSString stringWithFormat:@"pile %lu", (unsigned long)[self.ourGameEngine getCommonPileCount]];
  _pileCountLabel.fontSize = 14.f;
  _pileCountLabel.position = CGPointMake(275, buttonYPosition);
  [topBar addChild:_pileCountLabel];
  
  _messageLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Neue"];
  _messageLabel.fontSize = 14.f;
  _messageLabel.color = [UIColor whiteColor];
  _messageLabel.position = CGPointMake(50, -buttonYPosition);
  [topBar addChild:_messageLabel];
}

-(void)layoutBoard {
  self.backgroundColor = [SKColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
  
  for (int i = 0; i < 6; i++) {
    for (int j = 0; j < 30; j++) {
      SKSpriteNode *blankCell = [SKSpriteNode spriteNodeWithImageNamed:@"blankSpace"];
      blankCell.name = @"blankCell";
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
    _rackFieldSprite.size = CGSizeMake(self.frame.size.width, kPlayerRackHeight);
    _rackFieldSprite.anchorPoint = CGPointZero;
    _rackFieldSprite.position = CGPointMake(0, 0);
    [self addChild:_rackFieldSprite];
  }
  [_rackFieldSprite layoutOrRefreshFieldWithCount:self.myPlayer.dyadminoesInRack.count];
}

-(void)populateOrRefreshRackWithDyadminoes {
  [_rackFieldSprite populateOrRefreshWithDyadminoes:self.myPlayer.dyadminoesInRack];
}

#pragma mark - touch methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // get touch location and touched node
  _beganTouchLocation = [self findTouchLocationFromTouches:touches];
  _currentTouchLocation = _beganTouchLocation;
  _touchNode = [self nodeAtPoint:_currentTouchLocation];

    // A. if touched node is a button, take care of it when touch ended
  if ([_buttonNodes containsObject:_touchNode]) {
    _buttonPressed = (SKSpriteNode *)_touchNode;
    return;
  }
    //--------------------------------------------------------------------------
  
    // A. touched node is a dyadmino, or close enough to one, depending on certain criteria...
  Dyadmino *dyadmino = [self selectDyadminoFromTouchNode:_touchNode andTouchPoint:_currentTouchLocation];
  
  if (dyadmino) {
      // establish it as our currently touched dyadmino
    _currentlyTouchedDyadmino = dyadmino;
    _currentlyTouchedDyadmino.withinSection = [self determineCurrentSectionOfDyadmino:_currentlyTouchedDyadmino];
    [_currentlyTouchedDyadmino removeAllActions];
    [self resetModesAndStatesForDyadmino:_currentlyTouchedDyadmino];
    
      // actively disable done button only when rack dyadmino is in play, not board dyadmino
    if (_currentlyTouchedDyadmino.homeNode.snapNodeType == kSnapNodeRack) {
      [self disableButton:_doneButton];
    }
    
      // show that dyadmino is hovering
    [_currentlyTouchedDyadmino hoverHighlight];
    //--------------------------------------------------------------------------

      // B. if current dyadmino is not the most recent one
    if (_currentlyTouchedDyadmino != _recentBoardDyadmino &&
        _currentlyTouchedDyadmino != _recentRackDyadmino &&
        _currentlyTouchedDyadmino != _recentBoardDyadmino) {
      if (_recentDyadmino.withinSection == kDyadminoWithinBoard) {
          // if it's hovering, finish hovering
        if (_dyadminoHoveringStatus == kDyadminoHovering) {
          _dyadminoHoveringStatus = kDyadminoFinishedHovering;
        }
        
          // reset the recent board dyadmino
        [self sendHomeThisDyadmino:_recentBoardDyadmino];
        
          // and reset the recent rack dyadmino
        if (_currentlyTouchedDyadmino.homeNode.snapNodeType == kSnapNodeRack) {
          [self sendHomeThisDyadmino:_recentRackDyadmino];
        } else if (_currentlyTouchedDyadmino.homeNode.snapNodeType != kSnapNodeRack) {
          [self sendTempReturnThisDyadmino:_recentRackDyadmino];
        }
      }

    //--------------------------------------------------------------------------
      
    }
    
        // B. else if current dyadmino is the same as recently touched one
    if (_currentlyTouchedDyadmino == _recentDyadmino ||
               _currentlyTouchedDyadmino == _recentBoardDyadmino ||
               _currentlyTouchedDyadmino == _recentRackDyadmino) {
      
          // C. if it's now about to pivot
      if (_hoverPivotInProgress) {
          // calculate degrees between touch point and dyadmino position
        _initialPivotAngle = [self findAngleInDegreesFromThisPoint:_currentTouchLocation
                                                         toThisPoint:_currentlyTouchedDyadmino.position];

          // C. otherwise it's not pivoting, so...
      } else if (!_currentlyTouchedDyadmino.isRotating) {
          // D. if it's on the board...
        if (_currentlyTouchedDyadmino.withinSection == kDyadminoWithinBoard) {
            // E. it's either hovering, in which case make it rotate, if possible
          if (_dyadminoHoveringStatus == kDyadminoHovering &&
              _currentlyTouchedDyadmino.canRotateWithThisTouch == YES) {
            [self resetModesAndStatesForDyadmino:_currentlyTouchedDyadmino];
            [self animateRotateDyadmino:_currentlyTouchedDyadmino];
              // E. it's not hovering, so make it hover
          } else {
            _dyadminoHoveringStatus = kDyadminoHovering;
            _currentlyTouchedDyadmino.canRotateWithThisTouch = YES;
          }
        }
      }
    }
    //--------------------------------------------------------------------------
    
      // cleanup
    if (_currentlyTouchedDyadmino.homeNode.snapNodeType == kDyadminoWithinRack) {
      _currentlyTouchedDyadmino.canRotateWithThisTouch = YES;
    }
    _offsetTouchVector = [self fromThisPoint:_beganTouchLocation subtractThisPoint:_currentlyTouchedDyadmino.position];
    _currentlyTouchedDyadmino.zPosition = 101;
  }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // if the touch started on a button, do nothing and return
  if (_buttonPressed) {
      // TODO: make button highlighted if still pressed
    return;
  }
  
    // nothing happens if there is no current dyadmino
  if (!_currentlyTouchedDyadmino) {
    return;
  }
    //--------------------------------------------------------------------------
  
    // get touch location and update currently touched dyadmino's section
    // if hovering, currently touched dyadmino is also being moved, so it can no longer rotate
  _currentTouchLocation = [self findTouchLocationFromTouches:touches];
  CGPoint reverseOffsetPoint = [self fromThisPoint:_currentTouchLocation subtractThisPoint:_offsetTouchVector];
  _currentlyTouchedDyadmino.withinSection = [self determineCurrentSectionOfDyadmino:_currentlyTouchedDyadmino];

    // highlight depending whether it's a rack dyadmino, and it's within board
  if (_currentlyTouchedDyadmino.homeNode.snapNodeType == kSnapNodeRack) {
    if (_currentlyTouchedDyadmino.withinSection == kSnapNodeRack) {
      [_currentlyTouchedDyadmino inPlayUnhighlight];
    } else {
      [_currentlyTouchedDyadmino inPlayHighlight];
    }
  }
    //--------------------------------------------------------------------------
  
  if (_dyadminoHoveringStatus == kDyadminoHovering) {
    _currentlyTouchedDyadmino.canRotateWithThisTouch = NO;
  }
  
    // now, if we're currently pivoting, just rotate and return
  if (_hoverPivotInProgress) {
    CGFloat thisAngle = [self findAngleInDegreesFromThisPoint:_currentTouchLocation
                                                  toThisPoint:_currentlyTouchedDyadmino.position];
    CGFloat sextantChange = [self getSextantChangeFromThisAngle:thisAngle toThisAngle:_initialPivotAngle];
    [self orientDyadmino:_currentlyTouchedDyadmino basedOnSextantChange:sextantChange];
    return;
  }
    //--------------------------------------------------------------------------
  
    // A. determine whether to snap out, or keep moving if already snapped out
  if (_dyadminoSnappedIntoMovement ||
      (!_dyadminoSnappedIntoMovement && [self getDistanceFromThisPoint:reverseOffsetPoint
      toThisPoint:_currentlyTouchedDyadmino.tempReturnNode.position] > kDistanceForSnapOut)) {
      // if so, do initial setup; its current node now has no dyadmino, and it can no longer rotate
    _dyadminoSnappedIntoMovement = YES;
    _currentlyTouchedDyadmino.canRotateWithThisTouch = NO;
    
      // now move it, and we're done!
    _currentlyTouchedDyadmino.position =
    [self fromThisPoint:_currentTouchLocation subtractThisPoint:_offsetTouchVector];
    //--------------------------------------------------------------------------
    
      // B. if it's a rack dyadmino, then while movement is within rack, rearrange dyadminoes
    if (_currentlyTouchedDyadmino.homeNode.snapNodeType == kSnapNodeRack &&
        _currentlyTouchedDyadmino.withinSection == kDyadminoWithinRack) {
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
        exchangedDyadmino.tempReturnNode = _currentlyTouchedDyadmino.homeNode;
        exchangedDyadmino.homeNode = _currentlyTouchedDyadmino.homeNode;
        
          // animate movement of dyadmino being pushed under and over
        exchangedDyadmino.zPosition = 99;
        [self resetModesAndStatesForDyadmino:exchangedDyadmino];
        [self animateConstantSpeedMoveDyadmino:exchangedDyadmino
                                   toThisPoint:_currentlyTouchedDyadmino.homeNode.position];
        exchangedDyadmino.zPosition = 100;
      }
        // continues exchange, or if just returning back to its own rack node
      _currentlyTouchedDyadmino.tempReturnNode = rackNode;
      _currentlyTouchedDyadmino.homeNode = rackNode;
    }
  }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // handle button that was pressed
  if (_buttonPressed) {
//      CGPoint touchLocation = [self findTouchLocationFromTouches:touches];
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
  
  _currentlyTouchedDyadmino.withinSection = [self determineCurrentSectionOfDyadmino:_currentlyTouchedDyadmino];
  
    // assign current dyadmino to correct recent dyadmino pointer
  if (_currentlyTouchedDyadmino.homeNode.snapNodeType != kSnapNodeRack) {
    _recentBoardDyadmino = _currentlyTouchedDyadmino;
  } else {
    _recentRackDyadmino = _currentlyTouchedDyadmino;
  }
  _recentDyadmino = _currentlyTouchedDyadmino;
  
    // cleanup
  _hoverPivotInProgress = NO;
  _offsetTouchVector = CGPointMake(0, 0);
  _dyadminoSnappedIntoMovement = NO;
  _currentlyTouchedDyadmino = nil;
    //--------------------------------------------------------------------------

      // A. if it's in the top bar or the rack (doesn't matter whether it's a board or rack dyadmino)
  if (_recentDyadmino.withinSection == kDyadminoWithinRack ||
      _recentDyadmino.withinSection == kDyadminoWithinTopBar) {
    
        // B. first, if it can still rotate, do so
    if (_recentDyadmino.canRotateWithThisTouch && !_recentDyadmino.isRotating) {
      [self resetModesAndStatesForDyadmino:_recentDyadmino];
      [self animateRotateDyadmino:_recentDyadmino];
      
        // B. otherwise, it did move, so return it to its homeNode
    } else {
      _recentDyadmino.tempReturnNode = _recentDyadmino.homeNode;
      [self orientThisDyadmino:_recentDyadmino bySnapNode:_recentDyadmino.homeNode];
      [self resetModesAndStatesForDyadmino:_recentDyadmino];
      [self animateConstantTimeMoveDyadmino:_recentDyadmino
                                toThisPoint:_recentDyadmino.homeNode.position];
      _recentDyadmino.zPosition = 100;
    }
    [_recentDyadmino inPlayUnhighlight];
    //--------------------------------------------------------------------------
    
      // A. else if dyadmino is on the board
  } else {
      // establish the closest board node, without snapping just yet
    SnapNode *boardNode = [self findSnapNodeClosestToDyadmino:_recentDyadmino];
    
      // B. if dyadmino is a rack dyadmino
    if (_recentDyadmino.homeNode.snapNodeType == kSnapNodeRack) {
      
        // FIXME: C. check to see if this is a legal move
        // (as long as it doesn't conflict with other dyadminoes, not important if it scores points)
      if (TRUE) {
        
          // FIXME: eventually move enable done button method to the one that validates that it scores points
        [self enableButton:_doneButton];
        _recentDyadmino.tempReturnNode = boardNode;
        [self resetModesAndStatesForDyadmino:_recentDyadmino];
        [self animateHoverAndFinishedStatusOfDyadmino:_recentDyadmino];
        
          // C. otherwise it's not a legal move, keep hovering in place
      } else {
          // do this
      }
    //--------------------------------------------------------------------------
      
        // B. if dyadmino is a board dyadmino
    } else {
        // FIXME: C. check to see if this is a legal move
        // (doesn't conflict with other dyadminoes, *and* doesn't break musical rules)
      if (TRUE) {
        _recentDyadmino.tempReturnNode = boardNode;
        _recentDyadmino.homeNode = boardNode;
        [self resetModesAndStatesForDyadmino:_recentDyadmino];
        [self animateHoverAndFinishedStatusOfDyadmino:_recentDyadmino];
        
        // C. not a legal move, so keep hovering in place
      } else {
          // do this
      }
    }
  }
    //--------------------------------------------------------------------------
  
    // end by making sure everything is in its proper place
  [self ensureEverythingInProperPlaceAfterTouchEnds];
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
    [self validateAndFinaliseThisTurn];
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

-(void)validateAndFinaliseThisTurn {
    // FIXME: this one won't be necessary once disable button is enabled and disabled
  if (!_currentlyTouchedDyadmino &&
      _dyadminoHoveringStatus != kDyadminoHovering) {
    
      // establish that dyadmino is indeed a rack dyadmino, placed on the board
    if (_recentRackDyadmino.homeNode.snapNodeType == kSnapNodeRack &&
        _recentRackDyadmino.withinSection == kDyadminoWithinBoard) {
      
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
        _recentRackDyadmino.homeNode = _recentRackDyadmino.tempReturnNode;
        [_recentRackDyadmino inPlayUnhighlight];
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
    // always check to see if hovering dyadmino finishes hovering
  if (_dyadminoHoveringStatus == kDyadminoFinishedHovering &&
      _currentlyTouchedDyadmino != _recentDyadmino) {
    [self resetModesAndStatesForDyadmino:_recentDyadmino];
    [self animateSlowerConstantTimeMoveDyadmino:_recentDyadmino
                                    toThisPoint:_recentDyadmino.tempReturnNode.position];
    _recentDyadmino.canRotateWithThisTouch = NO;
    _dyadminoHoveringStatus = kDyadminoNoHoverStatus;
  }
}

-(void)updatePileCountLabel {
  _pileCountLabel.text = [NSString stringWithFormat:@"pile %i", [self.ourGameEngine getCommonPileCount]];
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

-(void)sendHomeThisDyadmino:(Dyadmino *)dyadmino {
  if (dyadmino) {
    [dyadmino inPlayUnhighlight];
    [self orientThisDyadmino:dyadmino bySnapNode:dyadmino.homeNode];
    if (dyadmino.withinSection == kDyadminoWithinBoard) {
      dyadmino.zPosition = 99;
      [self resetModesAndStatesForDyadmino:dyadmino];
      [self animateConstantSpeedMoveDyadmino:dyadmino toThisPoint:dyadmino.homeNode.position];
    }
    dyadmino.tempReturnNode = dyadmino.homeNode;
    dyadmino.zPosition = 100;
  }
}

-(void)sendTempReturnThisDyadmino:(Dyadmino *)dyadmino {
  if (dyadmino) {
//    [dyadmino inPlayUnhighlight];
    [self orientThisDyadmino:dyadmino bySnapNode:dyadmino.tempReturnNode];
    if (dyadmino.withinSection == kDyadminoWithinBoard) {
      dyadmino.zPosition = 99;
      [self resetModesAndStatesForDyadmino:dyadmino];
      [self animateConstantSpeedMoveDyadmino:dyadmino toThisPoint:dyadmino.tempReturnNode.position];
    }
    dyadmino.zPosition = 100;
  }
}

-(void)resetModesAndStatesForDyadmino:(Dyadmino *)dyadmino {
  if (_dyadminoHoveringStatus == kDyadminoHovering) {
    _dyadminoHoveringStatus = kDyadminoFinishedHovering;
  }
  dyadmino.isRotating = NO;
}

-(void)ensureEverythingInProperPlaceAfterTouchEnds {
  for (Dyadmino *dyadmino in self.myPlayer.dyadminoesInRack) {
      // if dyadmino is in rack
    if (dyadmino.withinSection == kDyadminoWithinRack) {
        // get index of dyadmino based on position in array
      NSUInteger index = [self.myPlayer.dyadminoesInRack indexOfObject:dyadmino];
        // get proper rackNode based on this index
      SnapNode *rackNode = _rackFieldSprite.rackNodes[index];
      if (!CGPointEqualToPoint(dyadmino.position, rackNode.position)) {
        [self resetModesAndStatesForDyadmino:dyadmino];
        [self animateConstantSpeedMoveDyadmino:dyadmino toThisPoint:rackNode.position];
        dyadmino.tempReturnNode = rackNode;
        dyadmino.homeNode = rackNode;
        [self orientThisDyadmino:dyadmino bySnapNode:dyadmino.homeNode];
        [dyadmino hoverUnhighlight];
      }
    }
  }
}

#pragma mark - animation methods

-(void)animateHoverAndFinishedStatusOfDyadmino:(Dyadmino *)dyadmino {
  [dyadmino removeAllActions];
  _dyadminoHoveringStatus = kDyadminoHovering;
  SKAction *dyadminoHover = [SKAction waitForDuration:kAnimateHoverTime];
  SKAction *dyadminoFinishStatus = [SKAction runBlock:^{
    dyadmino.zPosition = 100;
    [dyadmino hoverUnhighlight];
    dyadmino.tempReturnOrientation = dyadmino.orientation;
    _dyadminoHoveringStatus = kDyadminoFinishedHovering;
  }];
  SKAction *actionSequence = [SKAction sequence:@[dyadminoHover, dyadminoFinishStatus]];
  [dyadmino runAction:actionSequence];
}

#pragma mark - helper methods

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self touchesEnded:touches withEvent:event];
}

-(DyadminoWithinSection)determineCurrentSectionOfDyadmino:(Dyadmino *)dyadmino {
  DyadminoWithinSection withinSection;
  if (dyadmino.position.y < kPlayerRackHeight) {
    withinSection = kDyadminoWithinRack;
  } else if (dyadmino.position.y >= kPlayerRackHeight &&
             dyadmino.position.y < self.frame.size.height - kTopBarHeight) {
    withinSection = kDyadminoWithinBoard;
  } else { // if (_dyadminoBeingTouched.position.y >= self.frame.size.height - kTopBarHeight)
    withinSection = kDyadminoWithinTopBar;
  }
//  NSLog(@"dyadmino within section %i", dyadmino.withinSection);
  return withinSection;
}

-(CGPoint)findTouchLocationFromTouches:(NSSet *)touches {
  CGPoint uiTouchLocation = [[touches anyObject] locationInView:self.view];
  return CGPointMake(uiTouchLocation.x, self.frame.size.height - uiTouchLocation.y);
}

-(Dyadmino *)selectDyadminoFromTouchNode:(SKNode *)touchNode andTouchPoint:(CGPoint)touchPoint {
    // pointer to determine last dyadmino, depending on
    // whether moving board dyadmino while rack dyadmino is in play
//  Dyadmino *lastDyadmino = [self lastDyadminoBasedOnMoveBoardWhileRackInPlay];

    // if we're in hovering mode...
  if (_dyadminoHoveringStatus == kDyadminoHovering) {
    
      // if touch point is close enough, just rotate
    if ([self getDistanceFromThisPoint:touchPoint toThisPoint:_recentDyadmino.position] <
        kDistanceForTouchingHoveringDyadmino) {
      return _recentDyadmino;
      
        // otherwise, we're pivoting
    } else {
      _hoverPivotInProgress = YES;
      _prePivotDyadminoOrientation = _recentDyadmino.orientation;
      [_recentDyadmino removeAllActions];
      [self resetModesAndStatesForDyadmino:_recentDyadmino];
      return _recentDyadmino;
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
  DyadminoWithinSection thisSection = [self determineCurrentSectionOfDyadmino:dyadmino];
  if (thisSection == kDyadminoWithinBoard) {
    if ([self getDistanceFromThisPoint:touchPoint toThisPoint:dyadmino.position] <
        kDistanceForTouchingLockedDyadmino) {
      return dyadmino;
    }
      // if dyadmino is in rack...
  } else if (thisSection == kDyadminoWithinRack) {
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
  if (dyadmino.withinSection == kDyadminoWithinRack) {
    arrayOrSetToSearch = _rackFieldSprite.rackNodes;
  } else if (dyadmino.withinSection == kDyadminoWithinBoard) {
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

-(void)orientThisDyadmino:(Dyadmino *)dyadmino bySnapNode:(SnapNode *)snapNode {
  switch (snapNode.snapNodeType) {
//    case kSnapNodeBoardTwelveAndSix:
//      dyadmino.orientation = 0;
//      break;
//    case kSnapNodeBoardTwoAndEight:
//      dyadmino.orientation = 1;
//      break;
//    case kSnapNodeBoardFourAndTen:
//      dyadmino.orientation = 2;
//      break;
    case kSnapNodeRack:
      if (dyadmino.orientation <= 1 || dyadmino.orientation >= 5) {
        dyadmino.orientation = 0;
      } else {
        dyadmino.orientation = 3;
      }
      break;
    default: // snapNode is on board
      dyadmino.orientation = dyadmino.tempReturnOrientation;
  }
  [dyadmino selectAndPositionSprites];
}

-(void)orientDyadmino:(Dyadmino *)dyadmino basedOnSextantChange:(CGFloat)sextantChange {
  for (NSUInteger i = 0; i < 12; i++) {
    if (sextantChange >= 0.f + i && sextantChange < 1.f + i) {
      NSUInteger dyadminoOrientationShouldBe = (_prePivotDyadminoOrientation + i) % 6;
      if (dyadmino.orientation == dyadminoOrientationShouldBe) {
        return;
      } else {
        dyadmino.orientation = dyadminoOrientationShouldBe;
        
          // or else put this in an animation
        [dyadmino selectAndPositionSprites];
        return;
      }
    }
  }
}

#pragma mark - debugging methods

-(void)logRecentAndCurrentDyadminoes {
  NSString *recentBoardString = [NSString stringWithFormat:@"recent board %@", [self logThisDyadmino:_recentBoardDyadmino]];
  NSString *recentRackString = [NSString stringWithFormat:@"recent rack %@", [self logThisDyadmino:_recentRackDyadmino]];
  NSString *currentString = [NSString stringWithFormat:@"current %@", [self logThisDyadmino:_currentlyTouchedDyadmino]];
  NSString *recentString = [NSString stringWithFormat:@"recent %@", [self logThisDyadmino:_recentDyadmino]];
  NSLog(@"%@, %@, %@, %@", currentString, recentRackString, recentBoardString, recentString);
}

-(NSString *)logThisDyadmino:(Dyadmino *)dyadmino {
  if (dyadmino) {
    DyadminoWithinSection thisSection = [self determineCurrentSectionOfDyadmino:dyadmino];
    NSString *tempString = [NSString stringWithFormat:@"dmno %i, %i in sec. %i",
            dyadmino.pc1, dyadmino.pc2, thisSection];
//    NSString *tempString2 = [NSString stringWithFormat:@"homeNode is %i type, tempReturnNode is %i type, tempReturnOrientation is %i",
//                             dyadmino.homeNode.snapNodeType, dyadmino.tempReturnNode.snapNodeType, dyadmino.tempReturnOrientation];
//    NSLog(@"%@", tempString);
//    NSLog(@"%@", tempString2);
    return tempString;
  } else {
    return @"dyadmino doesn't exist";
  }
}

@end
