//
//  MyScene.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/20/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "MyScene.h"
#import "Pile.h"
#import "Dyadmino.h"
#import "NSObject+Helper.h"
#import "SnapNode.h"

@interface MyScene ()
@end

  // easy to do
  // TODO: make labelnode that shows number of dyadminoes in pile
  // TODO: make it so that dyadmino reset works for dyadminos on board (make method to get correct orientation from node name)
  // TODO: implement swap, and make it reset dyadminoes on board, but only up until number in pile

  // next step
  // TODO: put board cells on their own sprite nodes
  // TODO: board cells need coordinates

  // after do board coordinates
  // TODO: check rack nodes to ensure that dyadminoes do not conflict on board, do not finish hovering if there's a conflict

  // low priority
  // TODO: make rack exchange not so sensitive on top and bottoms of rack
  // TODO: implement all okay to make sure after crazy stuff, all dyadminoes on rack are normal
  // TODO: have animation between rotation frames
  // TODO: have reset dyadmino rotate animation back to rack


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
//  UITouch *_onlyTouch; // ensures only one touch at a time
  SKSpriteNode *_buttonPressed; // pointer to button that was pressed
  BOOL _rackExchangeInProgress;
  BOOL _dyadminoSnappedIntoMovement;
  Dyadmino *_currentlyTouchedDyadmino;
  Dyadmino *_recentlyTouchedDyadmino;
  BOOL _allOkay; // makes sure everything is in its right place
  
    // hover and pivot properties
  DyadminoHoveringStatus _dyadminoHoveringStatus;
  CGPoint _preHoverDyadminoPosition;
  BOOL _hoverPivotInProgress;
  CGFloat _initialPivotAngle;
  NSUInteger _prePivotDyadminoOrientation;
}

-(id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    self.myPile = [[Pile alloc] init];
//    _dyadminoesOnBoard = [NSMutableArray new];
    [self.myPile populateOrCompletelySwapOutPlayer1Rack];
    _rackNodes = [[NSMutableArray alloc] initWithCapacity:kNumDyadminoesInRack];
    _buttonNodes = [NSMutableSet new];
    _boardNodesTwelveAndSix = [NSMutableSet new];
    _boardNodesTwoAndEight = [NSMutableSet new];
    _boardNodesFourAndTen = [NSMutableSet new];
    _rackExchangeInProgress = NO;
    _buttonPressed = nil;
    _dyadminoHoveringStatus = kDyadminoNoHoverStatus;
    _allOkay = YES;
  }
  return self;
}

-(void)didMoveToView:(SKView *)view {
  
  [self layoutBoard];
  [self layoutTopBar];
  [self layoutRackField];
  [self populateOrRepopulateRackWithDyadminoes];
}

#pragma mark - layout views

-(void)layoutTopBar {
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
  SKLabelNode *toggleLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
  toggleLabel.text = @"toggle pc";
  toggleLabel.fontSize = 10.f;
  [_togglePCModeButton addChild:toggleLabel];
  [_buttonNodes addObject:_togglePCModeButton];
  
  _swapButton = [[SKSpriteNode alloc] initWithColor:[UIColor greenColor] size:buttonSize];
  _swapButton.position = CGPointMake(125.f, buttonYPosition);
  [topBar addChild:_swapButton];
  SKLabelNode *swapLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
  swapLabel.text = @"swap";
  swapLabel.fontSize = 10.f;
  [_swapButton addChild:swapLabel];
  [_buttonNodes addObject:_swapButton];
  
  _doneButton = [[SKSpriteNode alloc] initWithColor:[UIColor greenColor] size:buttonSize];
  _doneButton.position = CGPointMake(200.f, buttonYPosition);
  [topBar addChild:_doneButton];
  SKLabelNode *doneLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
  doneLabel.text = @"done";
  doneLabel.fontSize = 10.f;
  [_doneButton addChild:doneLabel];
  [_buttonNodes addObject:_doneButton];
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
  _rackFieldSprite = [SKSpriteNode spriteNodeWithColor:[SKColor purpleColor]
                                                      size:CGSizeMake(self.frame.size.width, kPlayerRackHeight)];
  _rackFieldSprite.anchorPoint = CGPointZero;
  _rackFieldSprite.position = CGPointMake(0, 0);
  [self addChild:_rackFieldSprite];
  
  CGFloat xEdgeMargin = 12.f;
  _xIncrementInRack = (self.frame.size.width - (2 * xEdgeMargin)) / (kNumDyadminoesInRack * 2); // right now it's 24.666
  
  for (int i = 0; i < [self.myPile.dyadminoesInPlayer1Rack count]; i++) {
    SnapNode *rackNode = [[SnapNode alloc] initWithSnapNodeType:kSnapNodeRack];
    rackNode.position = CGPointMake(xEdgeMargin + _xIncrementInRack + (2 * _xIncrementInRack * i), kPlayerRackHeight / 2);
    rackNode.name = [NSString stringWithFormat:@"rackNode %i", i];
    [_rackFieldSprite addChild:rackNode];
    [_rackNodes addObject:rackNode];
  }
    // calls this once, the first time
  [self.myPile populateOrCompletelySwapOutPlayer1Rack];
}

  // pile already knows where its dyadminoes are,
  // this method just places them where they belong
-(void)populateOrRepopulateRackWithDyadminoes {
  for (int i = 0; i < [self.myPile.dyadminoesInPlayer1Rack count]; i++) {
    Dyadmino *dyadmino = self.myPile.dyadminoesInPlayer1Rack[i];
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

-(void)toggleBetweenLetterAndNumberMode {
  for (Dyadmino *dyadmino in self.myPile.allDyadminoes) {
    if (dyadmino.pcMode == kPCModeLetter) {
      dyadmino.pcMode = kPCModeNumber;
    } else {
      dyadmino.pcMode = kPCModeLetter;
    }
    [dyadmino selectAndPositionSprites];
  }
}

#pragma mark - touch methods

-(void)handleButtonPressed {
    // swap dyadminoes
  if (_buttonPressed == _swapButton) {
    
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
    
      // TODO: eventually disable done button completely when move isn't legal
    if (!_currentlyTouchedDyadmino &&
        _dyadminoHoveringStatus != kDyadminoHovering) {
      
      if (_recentlyTouchedDyadmino.withinSection == kDyadminoWithinBoard) {
          // dyadmino's home node is currently the rack node; do cleanup
        _recentlyTouchedDyadmino.homeNode.currentDyadmino = nil;
        [self.myPile playFromPlayer1RackOntoBoard:_recentlyTouchedDyadmino];
        [self.myPile putDyadminoIntoPlayer1RackFromCommonPile];
        [self populateOrRepopulateRackWithDyadminoes];
        
          // dyadmino's home node is now the board node
        _recentlyTouchedDyadmino.homeNode = _recentlyTouchedDyadmino.tempReturnNode;
        _recentlyTouchedDyadmino = nil;
      };
      return;
    }
  }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  _allOkay = NO;
  if (TRUE) {
    _beganTouchLocation = [self findTouchLocationFromTouches:touches];
    _currentTouchLocation = _beganTouchLocation;
    _touchNode = [self nodeAtPoint:_currentTouchLocation];

      // touched a button
    if ([_buttonNodes containsObject:_touchNode]) {
      _buttonPressed = (SKSpriteNode *)_touchNode;
      return;
    }
    
      // dyadmino call
    Dyadmino *dyadmino = [self selectDyadminoFromTouchNode:_touchNode andTouchPoint:_currentTouchLocation];
    if (dyadmino) {
      _currentlyTouchedDyadmino = dyadmino;
      [dyadmino highlightAndRepositionDyadmino];
      _currentlyTouchedDyadmino.withinSection = [self determineCurrentSectionOfDyadmino:_currentlyTouchedDyadmino];

        // current dyadmino is different than recent, so reset the recently touched dyadmino
      if (_currentlyTouchedDyadmino != _recentlyTouchedDyadmino) {
        if (_recentlyTouchedDyadmino.withinSection == kDyadminoWithinBoard) {
            // reset recently touched dyadmino if it's on board
          if (_dyadminoHoveringStatus == kDyadminoHovering) {
            _dyadminoHoveringStatus = kDyadminoFinishedHovering;
            [self sendHomeThisDyadmino:_recentlyTouchedDyadmino];
          } else {
            [self sendHomeThisDyadmino:_recentlyTouchedDyadmino];
          }
        }
        if (_currentlyTouchedDyadmino.withinSection == kDyadminoWithinRack) {
          _currentlyTouchedDyadmino.canRotateWithThisTouch = YES;
        }
        
          // current dyadmino is same as recent
      } else if (_currentlyTouchedDyadmino == _recentlyTouchedDyadmino) {
        
          // if pivoting
        if (_hoverPivotInProgress) {
            // calculate degrees between touch point and dyadmino position
          _initialPivotAngle = [self findAngleInDegreesFromThisPoint:_currentTouchLocation
                                                         toThisPoint:_recentlyTouchedDyadmino.position];
            // otherwise, do this if we're not in mid-flip
        } else if (!_currentlyTouchedDyadmino.isRotating) {
          if (_currentlyTouchedDyadmino.withinSection == kDyadminoWithinBoard) {
            if (_dyadminoHoveringStatus == kDyadminoHovering &&
                _currentlyTouchedDyadmino.canRotateWithThisTouch == YES) { // hovering, make it rotate if possible
              [self animateRotateDyadmino:_currentlyTouchedDyadmino];
            } else { // not hovering, make it hover
              _dyadminoHoveringStatus = kDyadminoHovering;
              _currentlyTouchedDyadmino.canRotateWithThisTouch = YES;
            }
          } else if (_currentlyTouchedDyadmino.withinSection == kDyadminoWithinRack) {
            _currentlyTouchedDyadmino.canRotateWithThisTouch = YES;
          }
        }
      }
      _offsetTouchVector = [self fromThisPoint:_beganTouchLocation subtractThisPoint:_currentlyTouchedDyadmino.position];
      _currentlyTouchedDyadmino.zPosition = 101;
      _recentlyTouchedDyadmino = nil; // no need to keep pointer to recently touched dyadmino, if there's now a current dyadmino
    }
  }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if (TRUE) {
  
      // button pressed, do nothing
    if (_buttonPressed) {
        // make button highlighted if still pressed
      return;
    }
    
    if (_currentlyTouchedDyadmino) {
      _currentTouchLocation = [self findTouchLocationFromTouches:touches];
      _currentlyTouchedDyadmino.withinSection = [self determineCurrentSectionOfDyadmino:_currentlyTouchedDyadmino];
      
      if (_dyadminoHoveringStatus == kDyadminoHovering) {
        _currentlyTouchedDyadmino.canRotateWithThisTouch = NO;
      }
      
        // different altogether if we're in hover pivoting mode
      if (_hoverPivotInProgress) {
        CGFloat thisAngle = [self findAngleInDegreesFromThisPoint:_currentTouchLocation toThisPoint:_currentlyTouchedDyadmino.position];
        CGFloat sextantChange = [self getSextantChangeFromThisAngle:thisAngle toThisAngle:_initialPivotAngle];
        [self orientDyadmino:_currentlyTouchedDyadmino basedOnSextantChange:sextantChange];
        return;
      }

        // determine whether to snap out, or keep moving if already snapped out
      CGPoint reverseOffsetPoint = [self fromThisPoint:_currentTouchLocation subtractThisPoint:_offsetTouchVector];
      if (_dyadminoSnappedIntoMovement || (!_dyadminoSnappedIntoMovement &&
          [self getDistanceFromThisPoint:reverseOffsetPoint
                             toThisPoint:_currentlyTouchedDyadmino.tempReturnNode.position] > kDistanceForSnapOut)) {
        _dyadminoSnappedIntoMovement = YES;
        _currentlyTouchedDyadmino.tempReturnNode.currentDyadmino = nil;
        _currentlyTouchedDyadmino.position = [self fromThisPoint:_currentTouchLocation subtractThisPoint:_offsetTouchVector];
        _currentlyTouchedDyadmino.canRotateWithThisTouch = NO;
        
          // rearranges rack dyadminoes (*does* matter whether it came from rack or board)
          // this requires x increment between rack slots, so a method must be called
          // to ensure that this increment changes when number of rack slots change
        if (_currentlyTouchedDyadmino.withinSection == kDyadminoWithinRack) {
          SnapNode *rackNode = [self findSnapNodeClosestToDyadmino:_currentlyTouchedDyadmino];
          if (rackNode) {
            if (rackNode.currentDyadmino != _currentlyTouchedDyadmino &&
                [self.myPile.dyadminoesInPlayer1Rack containsObject:rackNode.currentDyadmino] &&
                [self.myPile.dyadminoesInPlayer1Rack containsObject:_currentlyTouchedDyadmino]) { // exchanging two dyadminoes
              NSUInteger touchedDyadminoIndex = [self.myPile.dyadminoesInPlayer1Rack indexOfObject:_currentlyTouchedDyadmino];
              NSUInteger rackDyadminoIndex = [self.myPile.dyadminoesInPlayer1Rack indexOfObject:rackNode.currentDyadmino];
              [self.myPile.dyadminoesInPlayer1Rack exchangeObjectAtIndex:touchedDyadminoIndex withObjectAtIndex:rackDyadminoIndex];
              
              _currentlyTouchedDyadmino.homeNode.currentDyadmino = rackNode.currentDyadmino;
              rackNode.currentDyadmino.tempReturnNode = _currentlyTouchedDyadmino.homeNode;
              rackNode.currentDyadmino.homeNode = _currentlyTouchedDyadmino.homeNode;
              
                // animate movement of dyadmino being pushed over
              rackNode.currentDyadmino.zPosition = 99;

              [self animateConstantSpeedMoveDyadmino:rackNode.currentDyadmino toThisPoint:_currentlyTouchedDyadmino.homeNode.position];
              rackNode.currentDyadmino.zPosition = 100;
            }
            rackNode.currentDyadmino = _currentlyTouchedDyadmino;
            _currentlyTouchedDyadmino.tempReturnNode = rackNode;
            _currentlyTouchedDyadmino.homeNode = rackNode;
          }
        }
      }
    }
  }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (TRUE) {
      // handle button pressed
    if (_buttonPressed) {
//      CGPoint touchLocation = [self findTouchLocationFromTouches:touches];
        // FIXME: this should ensure that the touch is still on the button when it's released
      if (TRUE) {
        [self handleButtonPressed];
      }
      _buttonPressed = nil;
      return;
    }
    
    if (_currentlyTouchedDyadmino) {
      _recentlyTouchedDyadmino = _currentlyTouchedDyadmino;
      _recentlyTouchedDyadmino.withinSection = [self determineCurrentSectionOfDyadmino:_recentlyTouchedDyadmino];
      _currentlyTouchedDyadmino = nil;
        // cleanup
      _hoverPivotInProgress = NO;
      _offsetTouchVector = CGPointMake(0, 0);
      _dyadminoSnappedIntoMovement = NO;

          // if it's in the top bar, have it return to its place in the rack as well
      if (_recentlyTouchedDyadmino.withinSection == kDyadminoWithinRack ||
          _recentlyTouchedDyadmino.withinSection == kDyadminoWithinTopBar) {
        
          // if it can rack rotate, this means it never moved from its original touch position...
        if (_recentlyTouchedDyadmino.canRotateWithThisTouch && !_recentlyTouchedDyadmino.isRotating) {
          [self animateRotateDyadmino:_recentlyTouchedDyadmino];
        } else { // ...otherwise, it did move, and now it must return to its temporary node
          [self orientToRackThisDyadmino:_recentlyTouchedDyadmino];
          [self animateConstantTimeMoveDyadmino:_recentlyTouchedDyadmino
                                    toThisPoint:_recentlyTouchedDyadmino.tempReturnNode.position];
          _recentlyTouchedDyadmino.zPosition = 100;
          [_recentlyTouchedDyadmino unhighlightAndRepositionDyadmino];
        }
        // no need to remember it if it's on the rack
        _recentlyTouchedDyadmino = nil;
        
      } else { // dyadmino is on board
         // establishes the closest board node, without snapping just yet
        SnapNode *boardNode = [self findSnapNodeClosestToDyadmino:_recentlyTouchedDyadmino];
        if (boardNode) {
          if (_recentlyTouchedDyadmino.tempReturnNode != boardNode &&
              boardNode.currentDyadmino != _recentlyTouchedDyadmino) {
            
            _recentlyTouchedDyadmino.tempReturnNode.currentDyadmino = nil;
            boardNode.currentDyadmino = _recentlyTouchedDyadmino;
            _recentlyTouchedDyadmino.tempReturnNode = boardNode;
          }
        }
          // hover animation
        [self animateHoverAndFinishedStatusOfRecentlyTouchedDyadmino];
      }
    }
  }
}

#pragma mark - update

-(void)update:(CFTimeInterval)currentTime {

  if (!_allOkay) {
    
  }
  
    // always check to see if recently touched dyadmino finishes hovering
  if (_dyadminoHoveringStatus == kDyadminoFinishedHovering) {
    _dyadminoHoveringStatus = kDyadminoNoHoverStatus;
    [self animateSlowerConstantTimeMoveDyadmino:_recentlyTouchedDyadmino
                                    toThisPoint:_recentlyTouchedDyadmino.tempReturnNode.position];
    _recentlyTouchedDyadmino.canRotateWithThisTouch = NO;
    [_recentlyTouchedDyadmino unhighlightAndRepositionDyadmino];
  }
  
  
}

-(void)updateRack {
}

-(void)updateBoard {
}

-(void)sendHomeThisDyadmino:(Dyadmino *)dyadmino {
  if (dyadmino) {
    [dyadmino unhighlightAndRepositionDyadmino];
    if (dyadmino.homeNode.snapNodeType == kSnapNodeRack) {
      [self orientToRackThisDyadmino:dyadmino];
    }
    [self resetAllAnimationsOnDyadmino:dyadmino];
    if (dyadmino.withinSection == kDyadminoWithinBoard) {
//      NSLog(@"within board part called");
      dyadmino.zPosition = 99;
      dyadmino.tempReturnNode.currentDyadmino = nil;
      [self animateConstantSpeedMoveDyadmino:dyadmino toThisPoint:dyadmino.homeNode.position];
    }
//    NSLog(@"outside within board part called");
    dyadmino.tempReturnNode = dyadmino.homeNode;
    dyadmino.homeNode.currentDyadmino = dyadmino;
    dyadmino.zPosition = 100;
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
      [dyadmino unhighlightAndRepositionDyadmino];
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
    }];
    completeAction = [SKAction sequence:@[nextFrame, finishAction]];
  }
  
  [dyadmino runAction:completeAction];
}

-(void)animateHoverAndFinishedStatusOfRecentlyTouchedDyadmino {
  [self resetAllAnimationsOnDyadmino:_recentlyTouchedDyadmino];
  _dyadminoHoveringStatus = kDyadminoHovering;
  SKAction *dyadminoHover = [SKAction waitForDuration:kAnimateHoverTime];
  SKAction *dyadminoFinishStatus = [SKAction runBlock:^{
    _recentlyTouchedDyadmino.zPosition = 100;
    _dyadminoHoveringStatus = kDyadminoFinishedHovering;
    [_recentlyTouchedDyadmino unhighlightAndRepositionDyadmino];
  }];
  SKAction *actionSequence = [SKAction sequence:@[dyadminoHover, dyadminoFinishStatus]];
  [_recentlyTouchedDyadmino runAction:actionSequence];
}

-(void)resetAllAnimationsOnDyadmino:(Dyadmino *)dyadmino {
  [dyadmino removeAllActions];
  if (_dyadminoHoveringStatus == kDyadminoHovering) {
    _dyadminoHoveringStatus = kDyadminoFinishedHovering;
  }
  dyadmino.isRotating = NO;
}

#pragma mark - helper methods

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self touchesEnded:touches withEvent:event];
}

-(DyadminoWithinSection)determineCurrentSectionOfDyadmino:(Dyadmino *)dyadmino {
  if (dyadmino.position.y < kPlayerRackHeight) {
    return kDyadminoWithinRack;
  } else if (dyadmino.position.y >= kPlayerRackHeight &&
             dyadmino.position.y < self.frame.size.height - kTopBarHeight) {
    return kDyadminoWithinBoard;
  } else { // if (_dyadminoBeingTouched.position.y >= self.frame.size.height - kTopBarHeight)
    return kDyadminoWithinTopBar;
  }
}

-(CGPoint)findTouchLocationFromTouches:(NSSet *)touches {
  CGPoint uiTouchLocation = [[touches anyObject] locationInView:self.view];
  return CGPointMake(uiTouchLocation.x, self.frame.size.height - uiTouchLocation.y);
}

-(Dyadmino *)selectDyadminoFromTouchNode:(SKNode *)touchNode andTouchPoint:(CGPoint)touchPoint {
  
    // if we're in hovering mode...
  if (_dyadminoHoveringStatus == kDyadminoHovering) {
    
      // if touch point is close enough, just rotate
    if ([self getDistanceFromThisPoint:touchPoint toThisPoint:_recentlyTouchedDyadmino.position] <
        kDistanceForTouchingHoveringDyadmino) {
      return _recentlyTouchedDyadmino;
      
        // otherwise, we're pivoting
    } else {
      _hoverPivotInProgress = YES;
      _prePivotDyadminoOrientation = _recentlyTouchedDyadmino.orientation;
      [self resetAllAnimationsOnDyadmino:_recentlyTouchedDyadmino];
      return _recentlyTouchedDyadmino;
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
  if ([self determineCurrentSectionOfDyadmino:dyadmino] == kDyadminoWithinBoard) {
    if ([self getDistanceFromThisPoint:touchPoint toThisPoint:dyadmino.position] <
        kDistanceForTouchingLockedDyadmino) {
      return dyadmino;
    }
      // if dyadmino is in rack...
  } else if ([self determineCurrentSectionOfDyadmino:dyadmino] == kDyadminoWithinRack) {
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

-(void)orientToRackThisDyadmino:(Dyadmino *)dyadmino {
  if (dyadmino.orientation <= 1 || dyadmino.orientation >= 5) {
    dyadmino.orientation = 0;
  } else {
    dyadmino.orientation = 3;
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
  NSString *recentString = [NSString stringWithFormat:@"recent %@", [self logThisDyadmino:_recentlyTouchedDyadmino]];
  NSString *currentString = [NSString stringWithFormat:@"current %@", [self logThisDyadmino:_currentlyTouchedDyadmino]];
  NSLog(@"%@, %@", recentString, currentString);
  
  for (SnapNode *rackNode in _rackNodes) {
    NSLog(@"%@ contains %@", rackNode.name, [self logThisDyadmino:rackNode.currentDyadmino]);
  }
}

-(NSString *)logThisDyadmino:(Dyadmino *)dyadmino {
  if (dyadmino) {
    DyadminoWithinSection thisSection = [self determineCurrentSectionOfDyadmino:dyadmino];
    return [NSString stringWithFormat:@"dyadmino %i, %i in section %i",
            dyadmino.pc1, dyadmino.pc2, thisSection];
  } else {
    return @"dyadmino doesn't exist";
  }
}


@end
