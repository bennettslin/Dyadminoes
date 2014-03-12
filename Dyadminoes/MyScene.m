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

  // easy to do
  // TODO: implement swap, and make it reset dyadminoes on board, but only up until number in pile
  // FIXME: zPosition is based on parent node, so will have to change parent nodes when dyadmino moves from rack to board

  // TODO: make tap on hover dyadmino rotate three ways

  // FIXME: something weird with dyadmino orientation

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

  // FIXME: bug where after drag one dyadmino,
  // last dyadmino doesn't return to node, just rests right there
  // maybe this just happens in simulator? So far on phone it doesn't happen

@implementation MyScene {

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
  BOOL _everythingInItsRightPlace;
  
    // hover and pivot properties
  Dyadmino *_currentlyHoveringDyadmino;
  CGPoint _preHoverDyadminoPosition;
  BOOL _hoverPivotInProgress;
  CGFloat _initialPivotAngle;
  NSUInteger _prePivotDyadminoOrientation;
  
    // temporary
  SKLabelNode *_pileCountLabel;
  SKLabelNode *_messageLabel;
  BOOL _boardRotate;
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
    _swapFieldSprite.size = CGSizeMake(self.frame.size.width, kPlayerRackHeight);
    _swapFieldSprite.anchorPoint = CGPointZero;
    _swapFieldSprite.position = CGPointMake(0, kPlayerRackHeight);
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
  _swapButton.position = CGPointMake(125.f, buttonYPosition);
  _swapButton.zPosition = kZPositionTopBarButton;
  [topBar addChild:_swapButton];
  [_buttonNodes addObject:_swapButton];
  
  _doneButton = [[SKSpriteNode alloc] initWithColor:[UIColor greenColor] size:buttonSize];
  _doneButton.position = CGPointMake(200.f, buttonYPosition);
  _doneButton.zPosition = kZPositionTopBarButton;
  [topBar addChild:_doneButton];
  [_buttonNodes addObject:_doneButton];
  [self disableButton:_doneButton];
  
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
    [self logThisDyadmino:dyadmino];
    
      // establish it as our currently touched dyadmino
    _currentlyTouchedDyadmino = dyadmino;
    _currentlyTouchedDyadmino.withinSection =
      [self determineCurrentSectionOfDyadmino:_currentlyTouchedDyadmino];
    [_currentlyTouchedDyadmino removeAllActions];
    [_currentlyTouchedDyadmino resetModesAndStates];
    
      // actively disable done button only when rack dyadmino is in play, not board dyadmino
    if (_currentlyTouchedDyadmino.homeNode.snapNodeType == kSnapNodeRack) {
      [self disableButton:_doneButton];
    }
    
      // various prep
    [_currentlyTouchedDyadmino hoverHighlight];
    
    if (_currentlyTouchedDyadmino.withinSection == kDyadminoWithinRack) {
      _currentlyTouchedDyadmino.canRotateWithThisTouch = YES;
    }
    _offsetTouchVector = [self fromThisPoint:_beganTouchLocation subtractThisPoint:_currentlyTouchedDyadmino.position];
    _currentlyTouchedDyadmino.zPosition = kZPositionHoveredDyadmino;
    //--------------------------------------------------------------------------
    
        // B. else if current dyadmino is the same as recently touched one
    if (_currentlyTouchedDyadmino == _recentDyadmino ||
        _currentlyTouchedDyadmino == _recentBoardDyadmino ||
        _currentlyTouchedDyadmino == _recentRackDyadmino) {
      
          // C. if it's now about to pivot, then get pivot angle
      if (_hoverPivotInProgress) {
        _initialPivotAngle = [self findAngleInDegreesFromThisPoint:_currentTouchLocation
                                                         toThisPoint:_currentlyTouchedDyadmino.position];

          // C. otherwise it's not pivoting, so...
      } else if (!_currentlyTouchedDyadmino.isRotating) {
        
          // D. if it's on the board...
        if (_currentlyTouchedDyadmino.withinSection == kDyadminoWithinBoard) {

            // E. it's either hovering, in which case make it rotate, if possible
          if (_currentlyHoveringDyadmino.hoveringStatus == kDyadminoHovering
              && _currentlyHoveringDyadmino.canRotateWithThisTouch) {
            
            [_currentlyTouchedDyadmino resetModesAndStates];
            [_currentlyTouchedDyadmino animateRotate];
              // E. it's not hovering, so make it hover
          } else {
            
            _currentlyHoveringDyadmino.hoveringStatus = kDyadminoHovering;
            _currentlyTouchedDyadmino.canRotateWithThisTouch = YES;
          }
        }
      }
    }
  }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [self logThisDyadmino:_currentlyTouchedDyadmino];
  
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
  
  if (_currentlyHoveringDyadmino.hoveringStatus == kDyadminoHovering) {
    _currentlyTouchedDyadmino.canRotateWithThisTouch = NO;
  }
  
    // now, if we're currently pivoting, just rotate and return
  if (_hoverPivotInProgress) {
    CGFloat thisAngle = [self findAngleInDegreesFromThisPoint:_currentTouchLocation
                                                  toThisPoint:_currentlyTouchedDyadmino.position];
    CGFloat sextantChange = [self getSextantChangeFromThisAngle:thisAngle toThisAngle:_initialPivotAngle];
    [_currentlyTouchedDyadmino orientBasedOnSextantChange:sextantChange];
    return;
  }
    //--------------------------------------------------------------------------
  
    // A. determine whether to snap out, or keep moving if already snapped out
  if (_dyadminoSnappedIntoMovement ||
      (!_dyadminoSnappedIntoMovement && [self getDistanceFromThisPoint:reverseOffsetPoint
      toThisPoint:_currentlyTouchedDyadmino.tempReturnNode.position] > kDistanceForSnapOut)) {
      // if so, do initial setup; its current node now has no dyadmino, and it can no longer rotate
    _dyadminoSnappedIntoMovement = YES;
    
//    NSLog(@"is this being called in snap movement");
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
        exchangedDyadmino.homeNode = _currentlyTouchedDyadmino.homeNode;
        
          // take care of state change and animation of exchanged dyadmino, as long as it's not on the board
        if (exchangedDyadmino.withinSection == kDyadminoWithinRack) {
          exchangedDyadmino.tempReturnNode = _currentlyTouchedDyadmino.homeNode;
          exchangedDyadmino.zPosition = kZPositionRackMovedDyadmino;
          [exchangedDyadmino resetModesAndStates];
          [exchangedDyadmino animateConstantSpeedMoveDyadminoToPoint:_currentlyTouchedDyadmino.homeNode.position];
          exchangedDyadmino.zPosition = kZPositionRackRestingDyadmino;
        }
      }
        // continues exchange, or if just returning back to its own rack node
      _currentlyTouchedDyadmino.tempReturnNode = rackNode;
      _currentlyTouchedDyadmino.homeNode = rackNode;
    }
  }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [self logThisDyadmino:_currentlyTouchedDyadmino];
  
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
  
  if (!_currentlyTouchedDyadmino.isRotating) {
    [self finishBusinessWithCurrentHoveringDyadmino];
  }
  
    // end by making sure everything is in its proper place
  _everythingInItsRightPlace = NO;
}

-(void)finishBusinessWithCurrentHoveringDyadmino {
  
  _currentlyTouchedDyadmino.withinSection = [self determineCurrentSectionOfDyadmino:_currentlyTouchedDyadmino];
  
    // assign current dyadmino to correct recent dyadmino pointer
  if (_currentlyTouchedDyadmino.homeNode.snapNodeType != kSnapNodeRack) {
    _recentBoardDyadmino = _currentlyTouchedDyadmino;
    _recentDyadmino = _currentlyTouchedDyadmino;
      // if current dyadmino ends within rack
      // then don't record it as the most recent rack dyadmino
  } else if (_currentlyTouchedDyadmino.withinSection != kDyadminoWithinRack) {
    _recentRackDyadmino = _currentlyTouchedDyadmino;
    _recentDyadmino = _currentlyTouchedDyadmino;
  }
  Dyadmino *endTouchDyadmino = _currentlyTouchedDyadmino;
  _currentlyTouchedDyadmino = nil;
  
    // cleanup
  _hoverPivotInProgress = NO;
  _offsetTouchVector = CGPointMake(0, 0);
  _dyadminoSnappedIntoMovement = NO;
    //--------------------------------------------------------------------------

    // A. if it's in the top bar or the rack (doesn't matter whether it's a board or rack dyadmino)
  if (endTouchDyadmino.withinSection == kDyadminoWithinRack ||
      endTouchDyadmino.withinSection == kDyadminoWithinTopBar) {
    
      // B. first, if it can still rotate, do so
    if (endTouchDyadmino.canRotateWithThisTouch) {
      [endTouchDyadmino resetModesAndStates];
      [endTouchDyadmino animateRotate];
      
        // B. otherwise, it did move, so return it to its homeNode
    } else {
      endTouchDyadmino.tempReturnNode = endTouchDyadmino.homeNode;
      [endTouchDyadmino orientBySnapNode:endTouchDyadmino.homeNode];
      [endTouchDyadmino resetModesAndStates];
      [endTouchDyadmino animateConstantTimeMoveToPoint:endTouchDyadmino.homeNode.position];
      [endTouchDyadmino setToHomeZPosition];
    }
    [endTouchDyadmino inPlayUnhighlight];
      //--------------------------------------------------------------------------
    
      // A. else if dyadmino is on the board
  } else {
      // establish the closest board node, without snapping just yet
    SnapNode *boardNode = [self findSnapNodeClosestToDyadmino:endTouchDyadmino];
    
    if ([self validateLegalityOfPlacementOfThisDyadmino:endTouchDyadmino]) {
      
      if (endTouchDyadmino.homeNode.snapNodeType == kSnapNodeRack) {
        [self enableButton:_doneButton];
      } else {
        endTouchDyadmino.homeNode = boardNode;
      }
      
      [endTouchDyadmino prepareStateForHoverWithBoardNode:boardNode];
      
    } else {
        // method to return to original place
    }
  }
}

  // FIXME: obviously, this must work
-(BOOL)validateLegalityOfPlacementOfThisDyadmino:(Dyadmino *)dyadmino {
  if (dyadmino.homeNode.snapNodeType == kSnapNodeRack) {
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
      _currentlyHoveringDyadmino.hoveringStatus != kDyadminoHovering) {
    
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
  if (_currentlyTouchedDyadmino.hoveringStatus == kDyadminoHovering) {
    _currentlyHoveringDyadmino = _currentlyTouchedDyadmino;
  }
  
    // send recent rack dyadmino home if another rack dyadmino is taken out of rack
  if (_currentlyTouchedDyadmino.homeNode.snapNodeType == kSnapNodeRack &&
      _currentlyTouchedDyadmino != _recentRackDyadmino &&
      _currentlyTouchedDyadmino.withinSection == kDyadminoWithinBoard &&
      _recentRackDyadmino.tempReturnNode.snapNodeType != kSnapNodeRack) {
    
    [_recentRackDyadmino goHome];
  }
  
    // finish hovering
  if (_recentDyadmino.withinSection != kDyadminoWithinRack &&
      _currentlyHoveringDyadmino.hoveringStatus == kDyadminoFinishedHovering &&
      _currentlyTouchedDyadmino != _recentDyadmino) {
    [_recentDyadmino resetModesAndStates];
    [_recentDyadmino animateSlowerConstantTimeMoveToPoint:_recentDyadmino.tempReturnNode.position];
    _recentDyadmino.canRotateWithThisTouch = NO;
    _currentlyHoveringDyadmino.hoveringStatus = kDyadminoNoHoverStatus;
  }
  
    // everything in its right place
  if (!_everythingInItsRightPlace) {
    _everythingInItsRightPlace = [self putEverythingInItsRightPlace];
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

-(BOOL)putEverythingInItsRightPlace {
  for (Dyadmino *dyadmino in self.myPlayer.dyadminoesInRack) {
      // if dyadmino is in rack
    if (dyadmino.withinSection == kDyadminoWithinRack) {
        // get index of dyadmino based on position in array
      NSUInteger index = [self.myPlayer.dyadminoesInRack indexOfObject:dyadmino];
        // get proper rackNode based on this index
      SnapNode *rackNode = _rackFieldSprite.rackNodes[index];
      if (!CGPointEqualToPoint(dyadmino.position, rackNode.position)) {
        [dyadmino resetModesAndStates];
        [dyadmino animateConstantSpeedMoveDyadminoToPoint:rackNode.position];
        dyadmino.tempReturnNode = rackNode;
        dyadmino.homeNode = rackNode;
      }
      [dyadmino hoverUnhighlight];
      [dyadmino orientBySnapNode:dyadmino.homeNode];
    }
  }
  return YES;
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
  if (_currentlyHoveringDyadmino.hoveringStatus == kDyadminoHovering) {
    
      // if touch point is close enough, just rotate
    if ([self getDistanceFromThisPoint:touchPoint toThisPoint:_recentDyadmino.position] <
        kDistanceForTouchingHoveringDyadmino) {
      return _recentDyadmino;
      
        // otherwise, we're pivoting
    } else {
      _hoverPivotInProgress = YES;
      _prePivotDyadminoOrientation = _recentDyadmino.orientation;
      [_recentDyadmino removeAllActions];
      [_recentDyadmino resetModesAndStates];
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
    NSLog(@"%@, orientation %i, tempOrientation %i", dyadmino.name, dyadmino.orientation, dyadmino.tempReturnOrientation);
    
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
