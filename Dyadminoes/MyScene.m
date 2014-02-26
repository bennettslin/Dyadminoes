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

#define kNumDyadminoesInRack 6

@interface MyScene () <UIGestureRecognizerDelegate>
@end

  // TODO: have variable for chosen dyadmino sprite

  // put board cells on their own sprite nodes
  // TODO: establish SnapNodes for each wall type, and each rack slot
  // name wall types, and rack slot types
  // TODO: subclass DyadminoSprite and SnapNodes

@implementation MyScene {
  
  SKSpriteNode *_rackFieldSprite;
  NSMutableArray *_dyadminoesInPlayerRack;
  
    // buttons
  SKLabelNode *_switchPCModeButton;
  SKLabelNode *_swapButton;

    // touches
  UITapGestureRecognizer *_tapRecognizer;
  
    // bools and modes
  
  Dyadmino *_dyadminoBeingTouched;
  BOOL _moveInAction;
  BOOL _swapInAction;
//  BOOL _moveInAction;
}

-(id)initWithSize:(CGSize)size {    
  if (self = [super initWithSize:size]) {
    self.pile = [[Pile alloc] init];
    _dyadminoesInPlayerRack = [self.pile populateOrCompletelySwapOutPlayer1Rack];
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
  CGFloat topBarHeight = 72.f;
  SKSpriteNode *topBar = [SKSpriteNode spriteNodeWithColor:[SKColor blueColor]
                                                      size:CGSizeMake(self.frame.size.width, topBarHeight)];
  topBar.anchorPoint = CGPointZero;
  topBar.position = CGPointMake(0, self.frame.size.height - topBarHeight);
  [self addChild:topBar];
  
  _switchPCModeButton = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
  _switchPCModeButton.position = CGPointMake(10, 40);
  _switchPCModeButton.text = @"switch between letter and number";
  _switchPCModeButton.fontSize = 10.f;
  _switchPCModeButton.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  [topBar addChild:_switchPCModeButton];
  
  _swapButton = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
  _swapButton.position = CGPointMake(10, 10);
  _swapButton.text = @"swap dyadminoes";
  _swapButton.fontSize = 10.f;
  _swapButton.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  [topBar addChild:_swapButton];
}

-(void)layoutBoard {
  self.backgroundColor = [SKColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
  
  for (int i = 0; i < 6; i++) {
    for (int j = 0; j < 30; j++) {
      SKSpriteNode *blankSpace = [SKSpriteNode spriteNodeWithImageNamed:@"blankSpace"];
      CGFloat xOffset = 0; // for odd rows
      CGFloat xPadding = 4.f;
      CGFloat yPadding = 2.f;
      
      if (j % 2 == 0) {
        xOffset = blankSpace.size.width * 0.75f + xPadding;
      }
      
      blankSpace.anchorPoint = CGPointMake(0.5, 0.5);
      blankSpace.position = CGPointMake(i * (blankSpace.size.width * 1.5f + 2.f * xPadding) + xOffset, j * (blankSpace.size.height / 2.f + yPadding));
      [self addChild:blankSpace];
      
        // for testing purposes only
      if (i == 2 && j == 15) {
        SKLabelNode *testLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        testLabelNode.position = blankSpace.position;
        testLabelNode.text = @"C";
        testLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        [self addChild:testLabelNode];
      }
    }
  }
}

-(void)layoutPlayerRack {
  CGFloat rackHeight = 108.f;
  _rackFieldSprite = [SKSpriteNode spriteNodeWithColor:[SKColor purpleColor]
                                                      size:CGSizeMake(self.frame.size.width, rackHeight)];
  _rackFieldSprite.anchorPoint = CGPointZero;
  _rackFieldSprite.position = CGPointMake(0, 0);
  [self addChild:_rackFieldSprite];
  [self loadOrReloadRackDyadminoes];
}

-(void)loadOrReloadRackDyadminoes {
  [_rackFieldSprite removeAllChildren];
  _dyadminoesInPlayerRack = [self.pile populateOrCompletelySwapOutPlayer1Rack];
  
  CGFloat xEdgeMargin = 12.f;
  CGFloat yBottomMargin = 12.f;
  
  for (int i = 0; i < [_dyadminoesInPlayerRack count]; i++) {
    Dyadmino *dyadmino = _dyadminoesInPlayerRack[i];
//    dyadmino.pcMode = _pcMode;
    CGFloat xPadding = (self.frame.size.width - (xEdgeMargin * 2) - (dyadmino.size.width * kNumDyadminoesInRack)) / (kNumDyadminoesInRack - 1);
    dyadmino.position = CGPointMake(xEdgeMargin + (i * (dyadmino.size.width + xPadding)) + dyadmino.size.width / 2, yBottomMargin + dyadmino.size.height / 2);
    [_rackFieldSprite addChild:dyadmino];
  }
}

-(void)switchBetweenLetterAndNumberMode {
  for (Dyadmino *dyadmino in self.pile.allDyadminoes) {
    if ([dyadmino.pcMode isEqualToString:@"Letter"]) {
      dyadmino.pcMode = @"Number";
    } else {
      dyadmino.pcMode = @"Letter";
    }
    [dyadmino selectAndPositionSprites];
  }
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
  
  if ([touchNode intersectsNode:_switchPCModeButton]) {
    [self switchBetweenLetterAndNumberMode];
  }
  
  for (Dyadmino *dyadmino in _dyadminoesInPlayerRack) {
    if ([touchNode intersectsNode:dyadmino] && _swapInAction == NO) {
      [self dyadminoRotateAnimation:dyadmino];
    }
  }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint uiTouchLocation = [touch locationInView:self.view];
  CGPoint skTouchLocation = CGPointMake(uiTouchLocation.x, self.frame.size.height - uiTouchLocation.y);
  SKNode *touchNode = [self nodeAtPoint:skTouchLocation];
  for (Dyadmino *dyadmino in _dyadminoesInPlayerRack) {
    if ([touchNode intersectsNode:dyadmino]) {
      _dyadminoBeingTouched = dyadmino;
    }
  }
  _dyadminoBeingTouched.zPosition = 101;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint uiTouchLocation = [touch locationInView:self.view];
  CGPoint skTouchLocation = CGPointMake(uiTouchLocation.x, self.frame.size.height - uiTouchLocation.y);
  _dyadminoBeingTouched.position = skTouchLocation;
  
  NSLog(@"touch is at %f, %f", skTouchLocation.x, skTouchLocation.y);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  _dyadminoBeingTouched.zPosition = 100;
  _dyadminoBeingTouched = nil;
}

#pragma mark - animation methods

-(void)dyadminoRotateAnimation:(Dyadmino *)dyadmino {
  _swapInAction = YES;
 
  SKAction *nextFrame = [SKAction runBlock:^{
    dyadmino.rackOrientation = (dyadmino.rackOrientation + 1) % 6;
    [dyadmino selectAndPositionSprites];
  }];
  
  SKAction *resetAction = [SKAction runBlock:^{
    _swapInAction = NO;
  }];
  
  SKAction *completeAction = [SKAction sequence:@[nextFrame, nextFrame, nextFrame, resetAction]];
  [dyadmino runAction:completeAction];
}

#pragma mark - update

-(void)update:(CFTimeInterval)currentTime {
}

#pragma mark - helper methods

-(NSUInteger)randomValueUpTo:(NSUInteger)high {
  NSUInteger randInteger = ((int) arc4random() % high);
  return randInteger;
}

@end
