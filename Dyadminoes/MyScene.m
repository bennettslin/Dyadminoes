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
  SKSpriteNode *_playDyadminoButton;
  SKSpriteNode *_doneTurnButton;

    // touches
  CGPoint _beganTouchLocation;
  CGPoint _currentTouchLocation;
  CGPoint _offsetTouchVector;
  
    // bools and modes
  BOOL _swapMode;
  BOOL _rackExchangeInProgress;
  BOOL _dyadminoSnappedIntoMovement;
  BOOL _swapFieldActionInProgress;
  
    // pointers
  Dyadmino *_currentlyTouchedDyadmino;
  Dyadmino *_recentRackDyadmino;
  Dyadmino *_hoveringButNotTouchedDyadmino;
  SKSpriteNode *_buttonPressed;

    // hover and pivot properties
  BOOL pivotInProgress;
  CFTimeInterval _hoverTime;
  
    // temporary
  SKLabelNode *_pileCountLabel;
  SKLabelNode *_messageLabel;
  SKSpriteNode *_logButton;
  SKLabelNode *_logLabel;
}

#pragma mark - init methods

-(id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    self.ourGameEngine = [GameEngine new];
    self.myPlayer = [self.ourGameEngine getAssignedAsPlayer];
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
  [self layoutSwapField];
  [self layoutTopBar];
  [self layoutOrRefreshRackField];
  [self populateOrRefreshRackWithDyadminoes];
}

#pragma mark - layout methods

-(void)layoutSwapField {
  // initial instantiation of swap field sprite
  _swapFieldSprite = [[FieldNode alloc] initWithWidth:self.frame.size.width andFieldNodeType:kFieldNodeSwap];
  _swapFieldSprite.delegate = self;
  _swapFieldSprite.color = [SKColor lightGrayColor];
  _swapFieldSprite.size = CGSizeMake(self.frame.size.width, kRackHeight);
  _swapFieldSprite.anchorPoint = CGPointZero;
//  _swapFieldSprite.position = CGPointMake(0.f, 0.f);
  _swapFieldSprite.zPosition = kZPositionSwapField;
  [self addChild:_swapFieldSprite];
//  [_swapFieldSprite layoutOrRefreshNodesWithCount:0.f];
  
    // initially sets swap mode
  _swapMode = NO;
  _swapFieldSprite.hidden = YES;
}

-(void)layoutTopBar {
    // background
  SKSpriteNode *topBar = [SKSpriteNode spriteNodeWithColor:[SKColor darkGrayColor]
                                                      size:CGSizeMake(self.frame.size.width, kTopBarHeight)];
  topBar.anchorPoint = CGPointZero;
  topBar.position = CGPointMake(0, self.frame.size.height - kTopBarHeight);
  topBar.zPosition = kZPositionTopBar;
  [self addChild:topBar];
  
  [self populateTopBarWithButtons:topBar];
  [self populateTopBarWithLabels:topBar];
}

-(void)populateTopBarWithButtons:(SKSpriteNode *)topBar {
  CGFloat buttonWidth = 45.f;
  CGSize buttonSize = CGSizeMake(buttonWidth, 50.f);
  CGFloat buttonYPosition = 30.f;
  
  _togglePCModeButton = [[SKSpriteNode alloc] initWithColor:[UIColor orangeColor] size:buttonSize];
  _togglePCModeButton.position = CGPointMake(buttonWidth, buttonYPosition);
  _togglePCModeButton.zPosition = kZPositionTopBarButton;
  [topBar addChild:_togglePCModeButton];
  [_buttonNodes addObject:_togglePCModeButton];
  
  _swapButton = [[SKSpriteNode alloc] initWithColor:[UIColor yellowColor] size:buttonSize];
  _swapButton.position = CGPointMake(buttonWidth * 2, buttonYPosition);
  _swapButton.zPosition = kZPositionTopBarButton;
  [topBar addChild:_swapButton];
  [_buttonNodes addObject:_swapButton];
  
  _playDyadminoButton = [[SKSpriteNode alloc] initWithColor:[UIColor greenColor] size:buttonSize];
  _playDyadminoButton.position = CGPointMake(buttonWidth * 3, buttonYPosition);
  _playDyadminoButton.zPosition = kZPositionTopBarButton;
  [topBar addChild:_playDyadminoButton];
  [_buttonNodes addObject:_playDyadminoButton];
  [self disableButton:_playDyadminoButton];
  
  _doneTurnButton = [[SKSpriteNode alloc] initWithColor:[UIColor blueColor] size:buttonSize];
  _doneTurnButton.position = CGPointMake(buttonWidth * 4, buttonYPosition);
  _doneTurnButton.zPosition = kZPositionTopBarButton;
  [topBar addChild:_doneTurnButton];
  [_buttonNodes addObject:_doneTurnButton];
  [self disableButton:_doneTurnButton];
  
  _logButton = [[SKSpriteNode alloc] initWithColor:[UIColor purpleColor] size:buttonSize];
  _logButton.position = CGPointMake(buttonWidth * 5, buttonYPosition);
  _logButton.zPosition = kZPositionTopBarButton;
  [topBar addChild:_logButton];
  [_buttonNodes addObject:_logButton];
}

-(void)populateTopBarWithLabels:(SKSpriteNode *)topBar {
  CGFloat labelYPosition = 30.f;
  
  _pileCountLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Neue"];
  _pileCountLabel.text = [NSString stringWithFormat:@"pile %lu", (unsigned long)[self.ourGameEngine getCommonPileCount]];
  _pileCountLabel.fontSize = 14.f;
  _pileCountLabel.position = CGPointMake(275, -labelYPosition);
  _pileCountLabel.zPosition = kZPositionTopBarLabel;
  [topBar addChild:_pileCountLabel];
  
  _messageLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Neue"];
  _messageLabel.fontSize = 14.f;
  _messageLabel.color = [UIColor whiteColor];
  _messageLabel.position = CGPointMake(50, -labelYPosition);
  _messageLabel.zPosition = kZPositionMessage;
  [topBar addChild:_messageLabel];
  
  _logLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Neue"];
  _logLabel.fontSize = 14.f;
  _logLabel.color = [UIColor whiteColor];
  _logLabel.position = CGPointMake(50, -labelYPosition * 2);
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
      CGFloat yPadding = xPadding * .5f; // this is 2.59
      CGFloat nodePadding = 0.5f * xPadding; // 0.5f is definitely correct
      
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
      
      boardNodeTwelveAndSix.position = [self addThisPoint:blankCell.position
                                              toThisPoint:CGPointMake(0.f, 19.5f)];
      boardNodeTwoAndEight.position = [self addThisPoint:blankCell.position
                                             toThisPoint:CGPointMake(kBoardDiagonalX + nodePadding, kBoardDiagonalY)];
      boardNodeFourAndTen.position = [self addThisPoint:blankCell.position
                                            toThisPoint:CGPointMake(-kBoardDiagonalX - nodePadding, kBoardDiagonalY)];
      
      boardNodeTwelveAndSix.name = @"board 12-6";
      boardNodeTwoAndEight.name = @"board 2-8";
      boardNodeFourAndTen.name = @"board 4-10";
      
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
    _rackFieldSprite = [[FieldNode alloc] initWithWidth:self.frame.size.width andFieldNodeType:kFieldNodeRack];
    _rackFieldSprite.delegate = self;
    _rackFieldSprite.color = [SKColor purpleColor];
    _rackFieldSprite.size = CGSizeMake(self.frame.size.width, kRackHeight);
    _rackFieldSprite.anchorPoint = CGPointZero;
    _rackFieldSprite.position = CGPointMake(0, 0);
    _rackFieldSprite.zPosition = kZPositionRackField;
    [self addChild:_rackFieldSprite];
  }
  [_rackFieldSprite layoutOrRefreshNodesWithCount:self.myPlayer.dyadminoesInRack.count];
}

-(void)populateOrRefreshRackWithDyadminoes {
  [_rackFieldSprite repositionDyadminoes:self.myPlayer.dyadminoesInRack];
}

#pragma mark - touch methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
  if (_swapFieldActionInProgress) {
    return;
  }
  
    // get touch location and touched node
  _beganTouchLocation = [self findTouchLocationFromTouches:touches];
  _currentTouchLocation = _beganTouchLocation;
  _touchNode = [self nodeAtPoint:_currentTouchLocation];

    // if it's a button, take care of it when touch ended
  if ([_buttonNodes containsObject:_touchNode]) {
    _buttonPressed = (SKSpriteNode *)_touchNode;
      // TODO: make distinction of button pressed better, of course
    _buttonPressed.alpha = 0.3f;
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

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  
    // safeguard against nuttiness
  if (_currentlyTouchedDyadmino && _currentlyTouchedDyadmino.myTouch != [touches anyObject]) {
    return;
  }

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
  
    // get touch location and update currently touched dyadmino's section
    // if hovering, currently touched dyadmino is also being moved, so it can no longer rotate
  _currentTouchLocation = [self findTouchLocationFromTouches:touches];
  CGPoint reverseOffsetPoint = [self fromThisPoint:_currentTouchLocation subtractThisPoint:_offsetTouchVector];
  [self determineCurrentSectionOfDyadmino:_currentlyTouchedDyadmino];

    // if we're currently pivoting, just rotate and return
  if (pivotInProgress) {
    [_currentlyTouchedDyadmino pivotBasedOnLocation:_currentTouchLocation];
    return;
  }
  
  
    // if it moved at all, it can no longer flip
  _currentlyTouchedDyadmino.canFlip = NO;
  
    // if rack dyadmino is moved to board, send home recentRack dyadmino
  if ([_currentlyTouchedDyadmino belongsInRack] &&
      [_currentlyTouchedDyadmino isOnBoard] &&
      _currentlyTouchedDyadmino != _recentRackDyadmino) {
    [self sendDyadminoHome:_recentRackDyadmino];
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
    if (([_currentlyTouchedDyadmino belongsInRack] || [_currentlyTouchedDyadmino belongsInSwap]) &&
        ([_currentlyTouchedDyadmino isInRack] || [_currentlyTouchedDyadmino isInSwap])) {
      SnapNode *rackNode = [self findSnapNodeClosestToDyadmino:_currentlyTouchedDyadmino];
      
      [_rackFieldSprite handleRackExchangeOfTouchedDyadmino:_currentlyTouchedDyadmino
                                             withDyadminoes:(NSMutableArray *)self.myPlayer.dyadminoesInRack
                                         andClosestRackNode:rackNode];
    }
  }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  
  if (_swapFieldActionInProgress) {
    return;
  }
  
    // safeguard against nuttiness
  if (_currentlyTouchedDyadmino && _currentlyTouchedDyadmino.myTouch != [touches anyObject]) {
    return;
  }
  
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
//        NSLog(@"about to flip");
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

#pragma mark - touch procedure methods

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
  
    // if it's still in the rack, it can still rotate
  if ([_currentlyTouchedDyadmino isInRack] || [_currentlyTouchedDyadmino isInSwap]) {
    _currentlyTouchedDyadmino.canFlip = YES;
  }
  
    // various prep
  _currentlyTouchedDyadmino.zPosition = kZPositionHoveredDyadmino;
  
    //--------------------------------------------------------------------------
  
    // if it's now about to pivot, just get pivot angle
  if (pivotInProgress) {
    _currentlyTouchedDyadmino.initialPivotAngle = [self findAngleInDegreesFromThisPoint:_currentTouchLocation
                                                                            toThisPoint:_currentlyTouchedDyadmino.position];
    [_currentlyTouchedDyadmino determinePivotOnPC];
      //    NSLog(@"initial pivot angle is %f, pivot on pc %i", _initialPivotAngle, _pivotOnPC);
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
    
    [self sendDyadminoHome:_hoveringButNotTouchedDyadmino];
  }
}

#pragma mark - game logic methods

  // FIXME: obviously, this must work
-(BOOL)validateLegalityOfDyadmino:(Dyadmino *)dyadmino onBoardNode:(SnapNode *)boardNode {
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
    [self toggleSwapField];
    return;
  }
  
    // toggle between letter and number symbols
  if (_buttonPressed == _togglePCModeButton) {
    [self toggleBetweenLetterAndNumberMode];
    return;
  }
  
    // submits play
  if (_buttonPressed == _playDyadminoButton) {
    [self playDyadmino];
  }
  
    // submits turn
  if (_buttonPressed == _doneTurnButton) {
    [self finalisePlayerTurn];
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

-(void)toggleSwapField {
  
    // FIXME: make better animation
    // otherwise toggle
  if (_swapMode) { // swap mode on, so turn off
    _swapFieldActionInProgress = YES;
    
    SKAction *moveAction = [SKAction moveTo:CGPointMake(0.f, 0.f) duration:kConstantTime];
    SKAction *completionAction = [SKAction runBlock:^{
      _swapFieldActionInProgress = NO;
      _swapFieldSprite.hidden = YES;
      _swapMode = NO;
    }];
    SKAction *sequenceAction = [SKAction sequence:@[moveAction, completionAction]];
    [_swapFieldSprite runAction:sequenceAction];
    
  } else { // swap mode off, turn on
    _swapFieldActionInProgress = YES;
    
    _swapFieldSprite.hidden = NO;
    SKAction *moveAction = [SKAction moveTo:CGPointMake(0.f, kRackHeight) duration:kConstantTime];
    SKAction *completionAction = [SKAction runBlock:^{
      _swapFieldActionInProgress = NO;
      _swapMode = YES;
    }];
    SKAction *sequenceAction = [SKAction sequence:@[moveAction, completionAction]];
    [_swapFieldSprite runAction:sequenceAction];
  }
}

-(void)cancelSwap {
  
}

-(void)finaliseSwap {
  
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
  [self layoutOrRefreshRackField];
  [self populateOrRefreshRackWithDyadminoes];
}

-(void)finalisePlayerTurn {
    // no recent rack dyadmino on board
  while ([self.ourGameEngine getCommonPileCount] >= 1 && self.myPlayer.dyadminoesInRack.count < 6) {
    [self.ourGameEngine putDyadminoFromCommonPileIntoRackOfPlayer:self.myPlayer];
  }

  [self layoutOrRefreshRackField];
  [self populateOrRefreshRackWithDyadminoes];
  
    // update views
  [self updatePileCountLabel];
  [self updateMessageLabelWithString:@"done"];
}

  // FIXME: make this better
-(void)enableButton:(SKSpriteNode *)button {
  button.hidden = NO;
}

-(void)disableButton:(SKSpriteNode *)button {
  button.hidden = YES;
}

#pragma mark - update and reset methods

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
    //--------------------------------------------------------------------------

    // handle buttons
    // TODO: if button enabling and disabling are animated, change this
  
    // while *not* in swap mode...
  if (!_swapMode) {
    
        // these are the criteria by which play and done button is enabled
    if ([_recentRackDyadmino belongsInRack] && [_recentRackDyadmino isOnBoard] &&
        ![_hoveringButNotTouchedDyadmino isHovering] &&
        (_currentlyTouchedDyadmino == nil || [_currentlyTouchedDyadmino isInRack])) {
      [self enableButton:_playDyadminoButton];
      [self disableButton:_doneTurnButton];
    } else {
      [self disableButton:_playDyadminoButton];
      [self enableButton:_doneTurnButton];
    }
    
      // ...these are the criteria by which swap button is enabled
      // swap button cannot have any rack dyadminoes on board
    if (_currentlyTouchedDyadmino || _recentRackDyadmino) {
      [self disableButton:_swapButton];
    } else {
      [self enableButton:_swapButton];
    }
    
      // if in swap mode, swap button cancels swap, done button finalises swap
  } else {
    [self enableButton:_swapButton];
    [self enableButton:_doneTurnButton];
  }
}

-(void)updatePileCountLabel {
  _pileCountLabel.text = [NSString stringWithFormat:@"pile %lu", (unsigned long)[self.ourGameEngine getCommonPileCount]];
}

-(void)sendDyadminoHome:(Dyadmino *)dyadmino {
  [dyadmino goHome];
  [dyadmino endTouchThenHoverResize];
  
  if (dyadmino.belongsInSwap) {
    dyadmino.withinSection = kWithinSwap;
  } else {
    dyadmino.withinSection = kWithinRack;
  }
  
  if (dyadmino == _recentRackDyadmino && [_recentRackDyadmino isInRack]) {
    _recentRackDyadmino = nil;
  }
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

-(CGPoint)findTouchLocationFromTouches:(NSSet *)touches {
  CGPoint uiTouchLocation = [[touches anyObject] locationInView:self.view];
  return CGPointMake(uiTouchLocation.x, self.frame.size.height - uiTouchLocation.y);
}

-(DyadminoWithinSection)determineCurrentSectionOfDyadmino:(Dyadmino *)dyadmino {
    // TODO: this method should probably be a little more sophisticated than this...
  
  DyadminoWithinSection withinSection;
  
  if (_swapMode && dyadmino.position.y >= kRackHeight && dyadmino.position.y < kRackHeight * 2) {
    dyadmino.withinSection = kWithinSwap;
    withinSection = kWithinSwap;

  } else if (dyadmino.position.y < kRackHeight) {
    dyadmino.withinSection = kWithinRack;
    withinSection = kWithinRack;
    
  } else if (!_swapMode && dyadmino.position.y >= kRackHeight &&
             dyadmino.position.y < self.frame.size.height - kTopBarHeight) {
    dyadmino.withinSection = kWithinBoard;
    withinSection = kWithinBoard;
    
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
    
      // if touch point is close enough, just rotate
    if ([self getDistanceFromThisPoint:touchPoint toThisPoint:_hoveringButNotTouchedDyadmino.position] <
        kDistanceForTouchingHoveringDyadmino) {
      return _hoveringButNotTouchedDyadmino;
 
        // otherwise, we're pivoting
    } else {
      pivotInProgress = YES;
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
  } else {
    return nil;
  }
    
    // second restriction is that touch point is close enough based on following criteria:
    // if dyadmino is on board, not hovering and thus locked in a node, and we're not in swap mode...
  [self determineCurrentSectionOfDyadmino:dyadmino];
  if ([dyadmino isOnBoard] && !_swapMode) {
    if ([self getDistanceFromThisPoint:touchPoint toThisPoint:dyadmino.position] <
        kDistanceForTouchingLockedDyadmino) {
      return dyadmino;
    }
      // if dyadmino is in rack...
  } else if ([dyadmino isInRack] || [dyadmino isInSwap]) {
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
  
if (!_swapMode && [dyadmino isOnBoard]) {
    if (dyadmino.orientation == kPC1atTwelveOClock || dyadmino.orientation == kPC1atSixOClock) {
      arrayOrSetToSearch = _boardNodesTwelveAndSix;
    } else if (dyadmino.orientation == kPC1atTwoOClock || dyadmino.orientation == kPC1atEightOClock) {
      arrayOrSetToSearch = _boardNodesTwoAndEight;
    } else if (dyadmino.orientation == kPC1atFourOClock || dyadmino.orientation == kPC1atTenOClock) {
      arrayOrSetToSearch = _boardNodesFourAndTen;
    }
    
  } else if ([dyadmino isInRack] || [dyadmino isInSwap]) {
    arrayOrSetToSearch = _rackFieldSprite.rackNodes;
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
  NSLog(@"%@, %@, %@", hoveringString, currentString, recentRackString);
  
  for (Dyadmino *dyadmino in self.myPlayer.dyadminoesInRack) {
    NSLog(@"%@ is in homeNode %@, tempReturn %@, belongs in swap %i", dyadmino.name, dyadmino.homeNode.name, dyadmino.tempBoardNode.name, dyadmino.belongsInSwap);
  }
  NSLog(@"current dyadmino is at %.2f, %.2f", _recentRackDyadmino.position.x, _recentRackDyadmino.position.y);
  
  for (SnapNode *snapNode in _rackFieldSprite.rackNodes) {
    NSLog(@"%@ is in position %.1f, %.1f", snapNode.name, snapNode.position.x, snapNode.position.y);
  }
  
}

@end
