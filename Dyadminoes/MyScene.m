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

@interface MyScene ()
@end

  // FIXME: bug where after drag one dyadmino,
  // last dyadmino doesn't return to node, just rests right there
  // maybe just in simulator?

  // easy to do
  // TODO: implement swap, and make it reset dyadminoes on board, but only up until number in pile

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
  // TODO: have reset dyadmino rotate animation back to rack

  // leave alone for now until better information about how Game Center works
  // TODO: make so that player, not dyadmino, knows about pcMode


@implementation MyScene {
  
    // constants
  CGFloat _xIncrementInRack;
  
    // sprites and nodes
  SKSpriteNode *_rackFieldSprite;
  SKNode *_touchNode;

    // arrays to keep track of sprites and nodes
  NSMutableArray *_rackNodes;
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
  SKSpriteNode *_buttonPressed; // pointer to button that was pressed
  BOOL _rackExchangeInProgress;
  BOOL _dyadminoSnappedIntoMovement;
  Dyadmino *_currentlyTouchedDyadmino;
  Dyadmino *_recentRackDyadmino;
  Dyadmino *_recentBoardDyadmino;
  Dyadmino *_recentDyadmino;
  
    // hover and pivot properties
  DyadminoHoveringStatus _dyadminoHoveringStatus;
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
    
    _rackNodes = [[NSMutableArray alloc] initWithCapacity:kNumDyadminoesInRack];
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
  [self layoutTopBarAndButtons];
  [self layoutRackField];
  [self populateOrRepopulateRackWithDyadminoes];
}

#pragma mark - layout views

-(void)layoutTopBarAndButtons {
    // background
  SKSpriteNode *topBar = [SKSpriteNode spriteNodeWithColor:[SKColor blueColor]
                                                      size:CGSizeMake(self.frame.size.width, kTopBarHeight)];
  topBar.anchorPoint = CGPointZero;
  topBar.position = CGPointMake(0, self.frame.size.height - kTopBarHeight);
  [self addChild:topBar];
  
  CGSize buttonSize = CGSizeMake(50.f, 50.f);
  CGFloat buttonYPosition = 30.f;
  
  _togglePCModeButton = [[SKSpriteNode alloc] initWithColor:[UIColor greenColor] size:buttonSize];
  _togglePCModeButton.position = CGPointMake(50.f, buttonYPosition);
  [topBar addChild:_togglePCModeButton];
//  SKLabelNode *toggleLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
//  toggleLabel.text = @"toggle pc";
//  toggleLabel.fontSize = 10.f;
//  [_togglePCModeButton addChild:toggleLabel];
  [_buttonNodes addObject:_togglePCModeButton];
  
  _swapButton = [[SKSpriteNode alloc] initWithColor:[UIColor greenColor] size:buttonSize];
  _swapButton.position = CGPointMake(125.f, buttonYPosition);
  [topBar addChild:_swapButton];
//  SKLabelNode *swapLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
//  swapLabel.text = @"swap";
//  swapLabel.fontSize = 10.f;
//  [_swapButton addChild:swapLabel];
  [_buttonNodes addObject:_swapButton];
  
  _doneButton = [[SKSpriteNode alloc] initWithColor:[UIColor greenColor] size:buttonSize];
  _doneButton.position = CGPointMake(200.f, buttonYPosition);
  [topBar addChild:_doneButton];
//  SKLabelNode *doneLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
//  doneLabel.text = @"done";
//  doneLabel.fontSize = 10.f;
//  [_doneButton addChild:doneLabel];
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
      CGFloat xPadding = 5.4f;
      CGFloat yPadding = xPadding * 0.48f;
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

-(void)layoutRackField {
    // initial instantiation of rack field sprite
  if (!_rackFieldSprite) {
    _rackFieldSprite = [SKSpriteNode spriteNodeWithColor:[SKColor purpleColor]
                                                        size:CGSizeMake(self.frame.size.width, kPlayerRackHeight)];
    _rackFieldSprite.anchorPoint = CGPointZero;
    _rackFieldSprite.position = CGPointMake(0, 0);
    [self addChild:_rackFieldSprite];
  }
    //--------------------------------------------------------------------------
  
    // margins will vary based on number of dyadminoes in rack
  CGFloat xEdgeMargin = 12.f + (16.f * (6 - self.myPlayer.dyadminoesInRack.count));
  _xIncrementInRack = (self.frame.size.width - (2 * xEdgeMargin)) / (self.myPlayer.dyadminoesInRack.count * 2); // right now it's 24.666
  
    // initial layout of rack nodes
  if (_rackNodes.count == 0) {
    for (int i = 0; i < self.myPlayer.dyadminoesInRack.count; i++) {
      SnapNode *rackNode = [[SnapNode alloc] initWithSnapNodeType:kSnapNodeRack];
      rackNode.position = CGPointMake(xEdgeMargin + _xIncrementInRack + (2 * _xIncrementInRack * i), kPlayerRackHeight / 2);
      rackNode.name = [NSString stringWithFormat:@"rackNode %i", i];
      [_rackFieldSprite addChild:rackNode];
      [_rackNodes addObject:rackNode];
    }
    //--------------------------------------------------------------------------
    
      //layout after pile depletion
  } else {
      // ensure rackNode count matches dyadminoesInRack count
    while (_rackNodes.count > self.myPlayer.dyadminoesInRack.count) {
      [_rackNodes removeObject:[_rackNodes lastObject]];
    }
      // then reposition
    for (SnapNode *rackNode in _rackNodes) {
      NSUInteger index = [_rackNodes indexOfObject:rackNode];
      CGPoint newPosition = CGPointMake(xEdgeMargin + _xIncrementInRack + (2 * _xIncrementInRack * index), kPlayerRackHeight / 2);
      rackNode.position = newPosition;
      rackNode.name = [NSString stringWithFormat:@"rackNode %i", index];
    }
  }
}

  // pile already knows where its dyadminoes are,
  // this method just places them where they belong
  // FIXME: doesn't currently take into account number of dyadminoes in pile
-(void)populateOrRepopulateRackWithDyadminoes {
  for (int i = 0; i < self.myPlayer.dyadminoesInRack.count; i++) {
    Dyadmino *dyadmino = self.myPlayer.dyadminoesInRack[i];
    SnapNode *rackNode = _rackNodes[i];
    
      // setup dyadmino and rackNode
    dyadmino.homeNode = rackNode;
    dyadmino.tempReturnNode = rackNode;
    dyadmino.withinSection = kDyadminoWithinRack;
    rackNode.currentDyadmino = dyadmino;
    
    if ([_rackFieldSprite.children containsObject:dyadmino]) {
        // dyadmino is already on rack, just has to animate to new position if not already there
      if (!CGPointEqualToPoint(dyadmino.position, dyadmino.homeNode.position)) {
        [self animateConstantSpeedMoveDyadmino:dyadmino toThisPoint:dyadmino.homeNode.position];
      }
    } else {
        // dyadmino is *not* already on rack, must add offscreen first, then animate
      dyadmino.position = CGPointMake(self.frame.size.width + _xIncrementInRack, dyadmino.homeNode.position.y);
      [_rackFieldSprite addChild:dyadmino];
      [self animateConstantSpeedMoveDyadmino:dyadmino toThisPoint:dyadmino.homeNode.position];
    }
  }
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
  
  NSLog(@"touches began");
  [self logRecentAndCurrentDyadmino];
  NSLog(@"hovering status is %i", _dyadminoHoveringStatus);
  
    // A. touched node is a dyadmino, or close enough to one, depending on certain criteria...
  Dyadmino *dyadmino = [self selectDyadminoFromTouchNode:_touchNode andTouchPoint:_currentTouchLocation];
  
  if (dyadmino) {
      // establish it as our currently touched dyadmino
    _currentlyTouchedDyadmino = dyadmino;
    _currentlyTouchedDyadmino.withinSection = [self determineCurrentSectionOfDyadmino:_currentlyTouchedDyadmino];
    [self resetAllAnimationsOnDyadmino:_currentlyTouchedDyadmino];
    
      // actively disable done button only when rack dyadmino is in play, not board dyadmino
    if (_currentlyTouchedDyadmino.homeNode.snapNodeType == kSnapNodeRack) {
      [self disableButton:_doneButton];
    }
    
      // show that dyadmino is hovering
    [_currentlyTouchedDyadmino hoverHighlight];
    //--------------------------------------------------------------------------

      // B. if current dyadmino is not the most recent one
    if (_currentlyTouchedDyadmino != _recentDyadmino) {
      NSLog(@"current dyadmino is not recent dyadmino");
      [self logRecentAndCurrentDyadmino];
      NSLog(@"recent dyadmino in section %i", _recentDyadmino.withinSection);
      if (_recentDyadmino.withinSection == kDyadminoWithinBoard) {

        NSLog(@"recent dyadmino is on board");
          // if it's hovering, finish hovering
        if (_dyadminoHoveringStatus == kDyadminoHovering) {
          _dyadminoHoveringStatus = kDyadminoFinishedHovering;
        }
        
          // reset the recent board dyadmino
        [self sendHomeThisDyadmino:_recentBoardDyadmino];
        
          // and reset the recent rack dyadmino
        if (_currentlyTouchedDyadmino.homeNode.snapNodeType == kSnapNodeRack) {
          NSLog(@"is this being called?");
          [self sendHomeThisDyadmino:_recentRackDyadmino];
        } else if (_currentlyTouchedDyadmino.homeNode.snapNodeType != kSnapNodeRack) {
          [self sendTempReturnThisDyadmino:_recentRackDyadmino];
        }
      }

    //--------------------------------------------------------------------------
      
        // B. else if current dyadmino is the same as recently touched one
    } else if (_currentlyTouchedDyadmino == _recentDyadmino ||
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
      if (rackNode) {
        if (rackNode.currentDyadmino != _currentlyTouchedDyadmino &&
            [self.myPlayer.dyadminoesInRack containsObject:rackNode.currentDyadmino] &&
            [self.myPlayer.dyadminoesInRack containsObject:_currentlyTouchedDyadmino]) {
          
            // ensure that results of rack exchange are reflected in array
          NSUInteger touchedDyadminoIndex = [self.myPlayer.dyadminoesInRack indexOfObject:_currentlyTouchedDyadmino];
          NSUInteger rackDyadminoIndex = [self.myPlayer.dyadminoesInRack indexOfObject:rackNode.currentDyadmino];
          [self.myPlayer.dyadminoesInRack exchangeObjectAtIndex:touchedDyadminoIndex withObjectAtIndex:rackDyadminoIndex];
          
            // dyadminoes exchange rack nodes, and vice versa
          _currentlyTouchedDyadmino.homeNode.currentDyadmino = rackNode.currentDyadmino; // 1
          rackNode.currentDyadmino.tempReturnNode = _currentlyTouchedDyadmino.homeNode; // 2
          rackNode.currentDyadmino.homeNode = _currentlyTouchedDyadmino.homeNode; // 3
          
            // animate movement of dyadmino being pushed under and over
          rackNode.currentDyadmino.zPosition = 99;
          [self animateConstantSpeedMoveDyadmino:rackNode.currentDyadmino
                                     toThisPoint:_currentlyTouchedDyadmino.homeNode.position];
          rackNode.currentDyadmino.zPosition = 100;
        }
          // continues exchange, or if just returning back to its own rack node
        rackNode.currentDyadmino = _currentlyTouchedDyadmino; // 4
        _currentlyTouchedDyadmino.tempReturnNode = rackNode; // 5
        _currentlyTouchedDyadmino.homeNode = rackNode; // all 6 done!
      }
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
  NSLog(@"current dyadmino within section %i", _currentlyTouchedDyadmino.withinSection);
  
    // assign current dyadmino to correct recent dyadmino pointer
  if (_currentlyTouchedDyadmino.homeNode.snapNodeType != kSnapNodeRack) {
    _recentBoardDyadmino = _currentlyTouchedDyadmino;
  } else {
    _recentRackDyadmino = _currentlyTouchedDyadmino;
  }
  _recentDyadmino = _currentlyTouchedDyadmino;
  [self logRecentAndCurrentDyadmino];
  
    // cleanup
  _hoverPivotInProgress = NO;
  _offsetTouchVector = CGPointMake(0, 0);
  _dyadminoSnappedIntoMovement = NO;
    //--------------------------------------------------------------------------

      // A. if it's in the top bar or the rack (doesn't matter whether it's a board or rack dyadmino)
  if (_currentlyTouchedDyadmino.withinSection == kDyadminoWithinRack ||
      _currentlyTouchedDyadmino.withinSection == kDyadminoWithinTopBar) {
    
        // B. first, if it can still rotate, do so
    if (_currentlyTouchedDyadmino.canRotateWithThisTouch && !_currentlyTouchedDyadmino.isRotating) {
      [self animateRotateDyadmino:_currentlyTouchedDyadmino];
      
        // B. otherwise, it did move, so return it to its homeNode
    } else {
      _currentlyTouchedDyadmino.tempReturnNode = _currentlyTouchedDyadmino.homeNode;
      [self orientThisDyadmino:_currentlyTouchedDyadmino bySnapNode:_currentlyTouchedDyadmino.homeNode];
      _currentlyTouchedDyadmino.homeNode.currentDyadmino = _currentlyTouchedDyadmino;
      [self animateConstantTimeMoveDyadmino:_currentlyTouchedDyadmino
                                toThisPoint:_currentlyTouchedDyadmino.homeNode.position];
      _currentlyTouchedDyadmino.zPosition = 100;
    }
    [_currentlyTouchedDyadmino inPlayUnhighlight];
    //--------------------------------------------------------------------------
    
      // A. else if dyadmino is on the board
  } else {
      // establish the closest board node, without snapping just yet
    SnapNode *boardNode = [self findSnapNodeClosestToDyadmino:_currentlyTouchedDyadmino];
    
      // B. if dyadmino is a rack dyadmino
    if (_currentlyTouchedDyadmino.homeNode.snapNodeType == kSnapNodeRack) {
      
        // FIXME: C. check to see if this is a legal move
        // (as long as it doesn't conflict with other dyadminoes, not important if it scores points)
      if (TRUE) {
        
          // FIXME: eventually move enable done button method to the one that validates that it scores points
        [self enableButton:_doneButton];
        boardNode.currentDyadmino = _currentlyTouchedDyadmino;
        _currentlyTouchedDyadmino.tempReturnNode = boardNode;
        [self animateHoverAndFinishedStatusOfDyadmino:_currentlyTouchedDyadmino];
        
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
        boardNode.currentDyadmino = _currentlyTouchedDyadmino;
        _currentlyTouchedDyadmino.tempReturnNode = boardNode;
        _currentlyTouchedDyadmino.homeNode = boardNode;
        [self animateHoverAndFinishedStatusOfDyadmino:_currentlyTouchedDyadmino];
        
        // C. not a legal move, so keep hovering in place
      } else {
          // do this
      }
    }
  }
    //--------------------------------------------------------------------------
  _currentlyTouchedDyadmino = nil;
    // end by making sure everything is in its proper place
  [self ensureEverythingInProperPlaceAfterTouchEnds];
}

#pragma mark - button methods

-(void)handleButtonPressed {
    // swap dyadminoes
  if (_buttonPressed == _swapButton) {
    NSLog(@"swap");
      // FIXME: swap functionality is now broken because previous dyadminoes are not removed from rackFieldSprite
      //    [self populateOrRepopulateRackWithDyadminoes];
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
        _recentRackDyadmino.homeNode.currentDyadmino = nil;
        
          // no dyadmino placed in rack, need to recalibrate rack
        if (![self.ourGameEngine putDyadminoFromCommonPileIntoRackOfPlayer:self.myPlayer]) {
          [self layoutRackField];
        }
        
        [self populateOrRepopulateRackWithDyadminoes];
        
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
    [self animateSlowerConstantTimeMoveDyadmino:_recentDyadmino
                                    toThisPoint:_recentDyadmino.tempReturnNode.position];
    _recentDyadmino.canRotateWithThisTouch = NO;
    _dyadminoHoveringStatus = kDyadminoNoHoverStatus;
  }
}

-(void)updateRack {
}

-(void)updateBoard {
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
//    [dyadmino hoverUnhighlight]; // lastThingIDid
    [dyadmino inPlayUnhighlight];
    [self orientThisDyadmino:dyadmino bySnapNode:dyadmino.homeNode];
    if (dyadmino.withinSection == kDyadminoWithinBoard) {
      dyadmino.zPosition = 99;
      [self animateConstantSpeedMoveDyadmino:dyadmino toThisPoint:dyadmino.homeNode.position];
    }
    dyadmino.tempReturnNode = dyadmino.homeNode;
    dyadmino.homeNode.currentDyadmino = dyadmino;
    dyadmino.zPosition = 100;
  }
}

-(void)sendTempReturnThisDyadmino:(Dyadmino *)dyadmino {
  if (dyadmino) {
//    [dyadmino inPlayUnhighlight];
    [self orientThisDyadmino:dyadmino bySnapNode:dyadmino.tempReturnNode];
    if (dyadmino.withinSection == kDyadminoWithinBoard) {
      dyadmino.zPosition = 99;
      [self animateConstantSpeedMoveDyadmino:dyadmino toThisPoint:dyadmino.tempReturnNode.position];
    }
    dyadmino.zPosition = 100;
  }
}

-(void)resetAllAnimationsOnDyadmino:(Dyadmino *)dyadmino {
//  NSLog(@"reset animation!");
  [dyadmino removeAllActions];
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
      SnapNode *rackNode = _rackNodes[index];
      if (!CGPointEqualToPoint(dyadmino.position, rackNode.position)) {
        [self animateConstantSpeedMoveDyadmino:dyadmino toThisPoint:rackNode.position];
        rackNode.currentDyadmino = dyadmino;
        dyadmino.tempReturnNode = rackNode;
        dyadmino.homeNode = rackNode;
        [self orientThisDyadmino:dyadmino bySnapNode:dyadmino.homeNode];
        [dyadmino hoverUnhighlight];
      }
        // else if dyadmino is on board
//    } else {
//      if (!CGPointEqualToPoint(dyadmino.position, dyadmino.tempReturnNode.position)) {
//        [self animateConstantSpeedMoveDyadmino:dyadmino toThisPoint:dyadmino.tempReturnNode.position];
//        dyadmino.tempReturnNode.currentDyadmino = dyadmino;
//      }
//    }
    }
  }
}

#pragma mark - animation methods

-(void)animateConstantTimeMoveDyadmino:(Dyadmino *)dyadmino toThisPoint:(CGPoint)point {
  [self resetAllAnimationsOnDyadmino:dyadmino];
  SKAction *moveAction = [SKAction moveTo:point duration:kConstantTime];
  [dyadmino runAction:moveAction];
}

-(void)animateSlowerConstantTimeMoveDyadmino:(Dyadmino *)dyadmino toThisPoint:(CGPoint)point {
  [self resetAllAnimationsOnDyadmino:dyadmino];
  SKAction *snapAction = [SKAction moveTo:point duration:kSlowerConstantTime];
  [dyadmino runAction:snapAction];
}

-(void)animateConstantSpeedMoveDyadmino:(Dyadmino *)dyadmino toThisPoint:(CGPoint)point {
  [self resetAllAnimationsOnDyadmino:dyadmino];
  CGFloat distance = [self getDistanceFromThisPoint:dyadmino.position toThisPoint:point];
  SKAction *snapAction = [SKAction moveTo:point duration:kConstantSpeed * distance];
  [dyadmino runAction:snapAction];
}

-(void)animateRotateDyadmino:(Dyadmino *)dyadmino {
  [self resetAllAnimationsOnDyadmino:dyadmino];
  dyadmino.isRotating = YES;
  
  SKAction *nextFrame = [SKAction runBlock:^{
    dyadmino.orientation = (dyadmino.orientation + 1) % 6;
    [dyadmino selectAndPositionSprites];
  }];
  SKAction *waitTime = [SKAction waitForDuration:kRotateWait];
  SKAction *finishAction;
  SKAction *completeAction;
  
    // rack rotation
  if (dyadmino.withinSection == kDyadminoWithinRack) {
    finishAction = [SKAction runBlock:^{
      [dyadmino hoverUnhighlight];
      dyadmino.zPosition = 100;
      dyadmino.isRotating = NO;
    }];
    completeAction = [SKAction sequence:@[nextFrame, waitTime, nextFrame, waitTime, nextFrame, finishAction]];
    
      // just to ensure that dyadmino is back in its rack position
    dyadmino.position = dyadmino.homeNode.position;
    
  } else if (dyadmino.withinSection == kDyadminoWithinBoard) {
    finishAction = [SKAction runBlock:^{
      [dyadmino selectAndPositionSprites];
      dyadmino.zPosition = 100;
      dyadmino.isRotating = NO;
      dyadmino.tempReturnOrientation = dyadmino.orientation;
    }];
    completeAction = [SKAction sequence:@[nextFrame, finishAction]];
  }
  
  [dyadmino runAction:completeAction];
}

-(void)animateHoverAndFinishedStatusOfDyadmino:(Dyadmino *)dyadmino {
  [self resetAllAnimationsOnDyadmino:dyadmino];
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
      [self resetAllAnimationsOnDyadmino:_recentDyadmino];
      return _recentDyadmino;
    }
  }
  
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
        _xIncrementInRack) {
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
    arrayOrSetToSearch = _rackNodes;
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

-(void)logRecentAndCurrentDyadmino {
  NSString *recentBoardString = [NSString stringWithFormat:@"recent board %@", [self logThisDyadmino:_recentBoardDyadmino]];
  NSString *recentRackString = [NSString stringWithFormat:@"recent rack %@", [self logThisDyadmino:_recentRackDyadmino]];
  NSString *currentString = [NSString stringWithFormat:@"current %@", [self logThisDyadmino:_currentlyTouchedDyadmino]];
  NSString *recentString = [NSString stringWithFormat:@"recent %@", [self logThisDyadmino:_recentDyadmino]];
  NSLog(@"%@, %@, %@, %@", currentString, recentRackString, recentBoardString, recentString);
  
//  for (SnapNode *rackNode in _rackNodes) {
//    NSLog(@"%@ contains %@", rackNode.name, [self logThisDyadmino:rackNode.currentDyadmino]);
//  }
}

-(NSString *)logThisDyadmino:(Dyadmino *)dyadmino {
  if (dyadmino) {
    DyadminoWithinSection thisSection = [self determineCurrentSectionOfDyadmino:dyadmino];
    NSString *tempString = [NSString stringWithFormat:@"dmno %i, %i in sec. %i",
            dyadmino.pc1, dyadmino.pc2, thisSection];
    NSString *tempString2 = [NSString stringWithFormat:@"homeNode is %i type, tempReturnNode is %i type, tempReturnOrientation is %i",
                             dyadmino.homeNode.snapNodeType, dyadmino.tempReturnNode.snapNodeType, dyadmino.tempReturnOrientation];
    NSLog(@"%@", tempString);
    NSLog(@"%@", tempString2);
    return tempString;
  } else {
    return @"dyadmino doesn't exist";
  }
}

@end
