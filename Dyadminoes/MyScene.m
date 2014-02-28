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

@interface MyScene () <UIGestureRecognizerDelegate>
@end

  // TODO: consier all cases board to board, board to rack, rack to board, rack to rack
  // TODO: probably best to have inBoard and inRack BOOLs
  // TODO: have this determined by update method

  // TODO: let dyadmino stay longer to allow for flips (check if on board)
  // TODO: if another dyadmino is tapped, it resets right away
  // TODO: make another bool status for dyadmino in action but not touched
  // TODO: dyadmino flips six ways when not locked into a node, but only two ways, when locked in
  // TODO: set dyadmino's current orientation different from rack orientation

  // put board cells on their own sprite nodes
  // TODO: establish SnapNodes for each wall type
  // TODO: board cells need coordinates

  // TODO: make swap board

@implementation MyScene {
  
  SKSpriteNode *_rackFieldSprite;
  
  NSMutableArray *_rackNodes;
  NSMutableSet *_boardNodesToSearch;
  NSMutableSet *_boardNodesTwelveAndSix;
  NSMutableSet *_boardNodesTwoAndEight;
  NSMutableSet *_boardNodesFourAndTen;
  NSMutableArray *_dyadminoesInPlayerRack;
  
    // buttons
  SKLabelNode *_togglePCModeButton;
  SKLabelNode *_swapButton;
  SKLabelNode *_doneButton;

    // touches
  UITapGestureRecognizer *_tapRecognizer;
  CGPoint _beganTouchLocation;
  CGPoint _currentTouchLocation;
  CGPoint _offsetTouchVector;
  Dyadmino *_dyadminoBeingTouched;
  
    // bools and modes
  BOOL _dyadminoFlipInAction;
  BOOL _dyadminoMoveInAction;
  BOOL _dyadminoCanStillRotate;
  DyadminoWithinSection _dyadminoBeganInSection;
  DyadminoWithinSection _dyadminoCurrentlyInSection;
  DyadminoWithinSection _dyadminoEndsInSection;
}

-(id)initWithSize:(CGSize)size {    
  if (self = [super initWithSize:size]) {
    self.pile = [[Pile alloc] init];
    _dyadminoesInPlayerRack = [self.pile populateOrCompletelySwapOutPlayer1Rack];
    _rackNodes = [[NSMutableArray alloc] initWithCapacity:kNumDyadminoesInRack];
    _boardNodesTwelveAndSix = [NSMutableSet new];
    _boardNodesTwoAndEight = [NSMutableSet new];
    _boardNodesFourAndTen = [NSMutableSet new];
  }
  return self;
}

-(void)didMoveToView:(SKView *)view {
  _tapRecognizer = [[UITapGestureRecognizer alloc] init];
  [_tapRecognizer addTarget:self action:@selector(handleTap:)];
  _tapRecognizer.delegate = self;
  [self.view addGestureRecognizer:_tapRecognizer];
  
  [self layoutBoard];
  [self layoutTopBar];
  [self layoutPlayerRack];
}

#pragma mark - layout views

-(void)layoutTopBar {
    // background
  SKSpriteNode *topBar = [SKSpriteNode spriteNodeWithColor:[SKColor blueColor]
                                                      size:CGSizeMake(self.frame.size.width, kTopBarHeight)];
  topBar.anchorPoint = CGPointZero;
  topBar.position = CGPointMake(0, self.frame.size.height - kTopBarHeight);
  [self addChild:topBar];
  
  _togglePCModeButton = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
  _togglePCModeButton.position = CGPointMake(10, 40);
  _togglePCModeButton.text = @"toggle pcMode";
  _togglePCModeButton.fontSize = 10.f;
  _togglePCModeButton.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  [topBar addChild:_togglePCModeButton];
  
  _swapButton = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
  _swapButton.position = CGPointMake(10, 10);
  _swapButton.text = @"swap dyadminoes";
  _swapButton.fontSize = 10.f;
  _swapButton.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  [topBar addChild:_swapButton];
  
  _doneButton = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
  _doneButton.position = CGPointMake(160, 10);
  _doneButton.text = @"done";
  _doneButton.fontSize = 10.f;
  _doneButton.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  [topBar addChild:_doneButton];
}

-(void)layoutBoard {
  self.backgroundColor = [SKColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
  
  for (int i = 0; i < 6; i++) {
    for (int j = 0; j < 30; j++) {
      SKSpriteNode *blankCell = [SKSpriteNode spriteNodeWithImageNamed:@"blankSpace"];
      CGFloat xOffset = 0; // for odd rows
      CGFloat xPadding = 5.f;
      CGFloat yPadding = 2.8f;
      
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
      boardNodeTwelveAndSix.position = [self addThisPoint:blankCell.position toThisPoint:CGPointMake(0.f, 19.f)];
      boardNodeTwoAndEight.position = [self addThisPoint:blankCell.position toThisPoint:CGPointMake(kBoardDiagonalX, kBoardDiagonalY)];
      boardNodeFourAndTen.position = [self addThisPoint:blankCell.position toThisPoint:CGPointMake(-kBoardDiagonalX, kBoardDiagonalY)];
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

-(void)layoutPlayerRack {
  _rackFieldSprite = [SKSpriteNode spriteNodeWithColor:[SKColor purpleColor]
                                                      size:CGSizeMake(self.frame.size.width, kPlayerRackHeight)];
  _rackFieldSprite.anchorPoint = CGPointZero;
  _rackFieldSprite.position = CGPointMake(0, 0);
  [self addChild:_rackFieldSprite];
  
  CGFloat xEdgeMargin = 12.f;
//  CGFloat yBottomMargin = 12.f;
  CGFloat xIncrement = (self.frame.size.width - (2 * xEdgeMargin)) / (kNumDyadminoesInRack * 2);
  
  for (int i = 0; i < [_dyadminoesInPlayerRack count]; i++) {
    SnapNode *rackNode = [[SnapNode alloc] initWithSnapNodeType:kSnapNodeRack];
    rackNode.position = CGPointMake(xEdgeMargin + xIncrement + (2 * xIncrement * i), kPlayerRackHeight / 2);
    rackNode.name = [NSString stringWithFormat:@"rackNode no. %i", i];
    [_rackFieldSprite addChild:rackNode];
    [_rackNodes addObject:rackNode];
  }
  [self loadOrReloadRackDyadminoes];
}

-(void)loadOrReloadRackDyadminoes {
  [_rackFieldSprite removeAllChildren];
  _dyadminoesInPlayerRack = [self.pile populateOrCompletelySwapOutPlayer1Rack];
  
  for (int i = 0; i < [_dyadminoesInPlayerRack count]; i++) {
    Dyadmino *dyadmino = _dyadminoesInPlayerRack[i];
    SnapNode *rackNode = _rackNodes[i];
    dyadmino.homeNode = rackNode;
    dyadmino.moveDefaultNode = rackNode;
    dyadmino.currentNodeIfAny = rackNode;
    rackNode.currentDyadmino = dyadmino;
    dyadmino.position = dyadmino.homeNode.position;
    [_rackFieldSprite addChild:dyadmino];
  }
}

-(void)toggleBetweenLetterAndNumberMode {
  for (Dyadmino *dyadmino in self.pile.allDyadminoes) {
    if (dyadmino.pcMode == kPCModeLetter) {
      dyadmino.pcMode = kPCModeNumber;
    } else {
      dyadmino.pcMode = kPCModeLetter;
    }
    [dyadmino selectAndPositionSprites];
  }
}

#pragma mark - update

-(void)update:(CFTimeInterval)currentTime {
    // determine whether dyadmino is in rack, board, or top bar
}

#pragma mark - touch methods

-(void)handleTap:(UIGestureRecognizer *)sender {
  CGPoint uiTouchLocation = [sender locationInView:self.view];
  CGPoint skTouchLocation = CGPointMake(uiTouchLocation.x, self.frame.size.height - uiTouchLocation.y);
  SKNode *touchNode = [self nodeAtPoint:skTouchLocation];
  
  if ([touchNode intersectsNode:_swapButton]) {
    _dyadminoesInPlayerRack = [self.pile populateOrCompletelySwapOutPlayer1Rack];
    [self loadOrReloadRackDyadminoes];
  }
  
  if ([touchNode intersectsNode:_togglePCModeButton]) {
    [self toggleBetweenLetterAndNumberMode];
  }
  
  if ([touchNode intersectsNode:_doneButton]) {
    [self resetThisTouchedDyadmino:_dyadminoBeingTouched];
//    _dyadminoBeingTouched = nil;
  }
}

-(void)resetThisTouchedDyadmino:(Dyadmino *)dyadmino {
//  if (!dyadmino.currentNodeIfAny) {
//    dyadmino.currentNodeIfAny == dyadmino.moveDefaultNode;
//  }
  
  [self animateConstantTimeMoveDyadmino:dyadmino toThisPoint:dyadmino.homeNode.position];
  dyadmino.moveDefaultNode = dyadmino.homeNode;
  dyadmino.currentNodeIfAny = dyadmino.homeNode;
  dyadmino.homeNode.currentDyadmino = dyadmino;
  dyadmino.zPosition = 100;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  CGPoint uiTouchLocation = [[touches anyObject] locationInView:self.view];
  _beganTouchLocation = CGPointMake(uiTouchLocation.x, self.frame.size.height - uiTouchLocation.y);
  _currentTouchLocation = _beganTouchLocation;
  _dyadminoCanStillRotate = YES;
  
    // technically this isn't needed right now because I'm calling the getDistance method
    // but it might help distinguish which dyadmino when they're all squished together on the board
    // test if this is the case
  SKNode *touchNode = [self nodeAtPoint:_beganTouchLocation];
  
    // iterates through all dyadminoes to determine which dyadmino has being touched
  for (Dyadmino *dyadmino in _dyadminoesInPlayerRack) {
    if ([touchNode intersectsNode:dyadmino] &&
        [self getDistanceFromThisPoint:_beganTouchLocation toThisPoint:dyadmino.position] < kDistanceForTouchingDyadmino) {
        // a dyadmino has definitely been touched by this point
      if (dyadmino == _dyadminoBeingTouched) {
          //
      } else if (dyadmino != _dyadminoBeingTouched) {
        Dyadmino *previouslyTouchedDyadmino = _dyadminoBeingTouched;
        [self resetThisTouchedDyadmino:previouslyTouchedDyadmino];
        
        _dyadminoBeingTouched = dyadmino;
        _offsetTouchVector = [self fromThisPoint:_beganTouchLocation subtractThisPoint:_dyadminoBeingTouched.position];
        _dyadminoBeingTouched.zPosition = 101;
        
        if (_dyadminoBeingTouched.currentNodeIfAny.snapNodeType == kSnapNodeRack) {
          _dyadminoBeganInSection = kDyadminoWithinRack;
          _dyadminoCurrentlyInSection = kDyadminoWithinRack;
        } else {
          _dyadminoBeganInSection = kDyadminoWithinBoard;
          _dyadminoCurrentlyInSection = kDyadminoWithinBoard;
        }
      }
    }
  }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  CGPoint uiTouchLocation = [[touches anyObject] locationInView:self.view];
  _currentTouchLocation = CGPointMake(uiTouchLocation.x, self.frame.size.height - uiTouchLocation.y);
  _dyadminoCurrentlyInSection = [self determineCurrentSectionOfDyadmino:_dyadminoBeingTouched];
  
//  NSLog(@"dyadmino currently in section %i", _dyadminoCurrentlyInSection);
    // determine whether to snap out
  CGPoint reverseOffsetPoint = [self fromThisPoint:_currentTouchLocation subtractThisPoint:_offsetTouchVector];
  if (_dyadminoMoveInAction || [self getDistanceFromThisPoint:reverseOffsetPoint toThisPoint:_dyadminoBeingTouched.currentNodeIfAny.position] > kDistanceForSnapOut) {
    _dyadminoMoveInAction = YES;
    _dyadminoBeingTouched.position = [self fromThisPoint:_currentTouchLocation subtractThisPoint:_offsetTouchVector];
    _dyadminoBeingTouched.currentNodeIfAny = nil;
    _dyadminoCanStillRotate = NO;
  }
  
    // determine whether to snap in
  if (_dyadminoCurrentlyInSection == kDyadminoWithinBoard) {
      // determine which board nodes to search through
    if (_dyadminoBeingTouched.orientation == kPC1atTwelveOClock || _dyadminoBeingTouched.orientation == kPC1atSixOClock) {
      _boardNodesToSearch = _boardNodesTwelveAndSix;
    } else if (_dyadminoBeingTouched.orientation == kPC1atTwoOClock || _dyadminoBeingTouched.orientation == kPC1atEightOClock) {
      _boardNodesToSearch = _boardNodesTwoAndEight;
    } else if (_dyadminoBeingTouched.orientation == kPC1atFourOClock || _dyadminoBeingTouched.orientation == kPC1atTenOClock) {
      _boardNodesToSearch = _boardNodesFourAndTen;
    }
        // determine whether to snap dyadmino in board node (*doesn't* matter whether it came from rack or board)
    for (SnapNode *boardNode in _boardNodesToSearch) {
      if (_dyadminoMoveInAction && _dyadminoBeingTouched.currentNodeIfAny != boardNode &&
          boardNode.currentDyadmino != _dyadminoBeingTouched &&
          [self getDistanceFromThisPoint:_dyadminoBeingTouched.position toThisPoint:boardNode.position] < kDistanceForSnapIn) {
        
        SnapNode *previousNode = _dyadminoBeingTouched.currentNodeIfAny;
        if (previousNode.snapNodeType != kSnapNodeRack) {
          boardNode.currentDyadmino = _dyadminoBeingTouched;
        }
        _dyadminoBeingTouched.moveDefaultNode = boardNode;
        _dyadminoBeingTouched.currentNodeIfAny = boardNode;
        previousNode.currentDyadmino = nil;
      }
    }
  }
  
      // rearranges rack dyadminoes (*does* matter whether it came from rack or board)
  if (_dyadminoCurrentlyInSection == kDyadminoWithinRack) {
    for (SnapNode *rackNode in _rackNodes) {
      if (_dyadminoMoveInAction &&
          [self getDistanceFromThisPoint:_dyadminoBeingTouched.position toThisPoint:rackNode.position] < kDistanceForOtherRackDyadminoToMoveOver) {
        
        if (rackNode.currentDyadmino != _dyadminoBeingTouched) { // exchanging two dyadminoes
          Dyadmino *otherDyadminoToSwap = rackNode.currentDyadmino;
          SnapNode *originalRackNode = _dyadminoBeingTouched.homeNode;
          
          originalRackNode.currentDyadmino = otherDyadminoToSwap;
          otherDyadminoToSwap.currentNodeIfAny = originalRackNode;
          otherDyadminoToSwap.moveDefaultNode = originalRackNode;
          otherDyadminoToSwap.homeNode = originalRackNode;
          
          otherDyadminoToSwap.zPosition = 99;
          [self animateConstantSpeedMoveDyadmino:otherDyadminoToSwap toThisPoint:originalRackNode.position];
          otherDyadminoToSwap.zPosition = 100;
          
        } else if (!rackNode.currentDyadmino) { // filling an empty rack node
    
        }
        rackNode.currentDyadmino = _dyadminoBeingTouched;
        _dyadminoBeingTouched.moveDefaultNode = rackNode;
        _dyadminoBeingTouched.currentNodeIfAny = rackNode;
        _dyadminoBeingTouched.homeNode = rackNode;
        
//        NSLog(@"Dyadmino being touched's move default node is %@", _dyadminoBeingTouched.moveDefaultNode.name);
      }
    }
  }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self touchesEnded:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_dyadminoMoveInAction) {
    if (!_dyadminoBeingTouched.currentNodeIfAny) {
      _dyadminoBeingTouched.currentNodeIfAny = _dyadminoBeingTouched.moveDefaultNode;
    }
    [self animateConstantTimeMoveDyadmino:_dyadminoBeingTouched toThisPoint:_dyadminoBeingTouched.moveDefaultNode.position];
  } else if (_dyadminoCanStillRotate) {
    [self animateRotateDyadmino:_dyadminoBeingTouched];
  }
  _offsetTouchVector = CGPointMake(0, 0);
  _dyadminoMoveInAction = NO;
}

#pragma mark - animation methods

-(void)animateConstantTimeMoveDyadmino:(Dyadmino *)dyadmino toThisPoint:(CGPoint)point {
  SKAction *moveAction = [SKAction moveTo:point duration:0.15f];
  [dyadmino runAction:moveAction];
}

-(void)animateSnapDyadmino:(Dyadmino *)dyadmino toThisPoint:(CGPoint)point {
  SKAction *snapAction = [SKAction moveTo:point duration:0.05f];
  [dyadmino runAction:snapAction];
}

-(void)animateConstantSpeedMoveDyadmino:(Dyadmino *)dyadmino toThisPoint:(CGPoint)point {
  CGFloat distance = [self getDistanceFromThisPoint:dyadmino.position toThisPoint:point];
  SKAction *snapAction = [SKAction moveTo:point duration:0.0015f * distance];
  [dyadmino runAction:snapAction];
}

-(void)animateRotateDyadmino:(Dyadmino *)dyadmino {
  _dyadminoFlipInAction = YES;
 
  SKAction *nextFrame = [SKAction runBlock:^{
    dyadmino.orientation = (dyadmino.orientation + 1) % 6;
    [dyadmino selectAndPositionSprites];
  }];
  
  SKAction *waitTime = [SKAction waitForDuration:0.025f];
  
  SKAction *resetAction = [SKAction runBlock:^{
    _dyadminoFlipInAction = NO;
  }];
  
  SKAction *completeAction = [SKAction sequence:@[nextFrame, waitTime, nextFrame, waitTime, nextFrame, resetAction]];
  
  [dyadmino runAction:completeAction];
  dyadmino.position = dyadmino.homeNode.position;
}

#pragma mark - helper methods

-(DyadminoWithinSection)determineCurrentSectionOfDyadmino:(Dyadmino *)dyadmino {
  if (_dyadminoBeingTouched.position.y < kPlayerRackHeight) {
    return kDyadminoWithinRack;
  } else if (_dyadminoBeingTouched.position.y >= kPlayerRackHeight &&
             _dyadminoBeingTouched.position.y < self.frame.size.height - kTopBarHeight) {
    return kDyadminoWithinBoard;
  } else { // if (_dyadminoBeingTouched.position.y >= self.frame.size.height - kTopBarHeight)
    return kDyadminoWithinTopBar;
  }
}

@end
