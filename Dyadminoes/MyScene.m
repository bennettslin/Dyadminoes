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
const CGFloat kRadian = 57.2958f;

@interface MyScene () <UIGestureRecognizerDelegate>
@end

@implementation MyScene {
  NSMutableArray *_spritesInPlayer1Rack;
  UITapGestureRecognizer *_tapRecognizer;
  NSMutableArray *_player1Rack;
}

-(id)initWithSize:(CGSize)size {    
  if (self = [super initWithSize:size]) {
    _spritesInPlayer1Rack = [[NSMutableArray alloc] initWithCapacity:kNumDyadminoesInRack];
  }
  return self;
}

-(void)didMoveToView:(SKView *)view {
  _tapRecognizer = [[UITapGestureRecognizer alloc] init];
  [_tapRecognizer addTarget:self action:@selector(handleTap:)];
  _tapRecognizer.delegate = self;
  [self.view addGestureRecognizer:_tapRecognizer];
  
  _player1Rack = [self.delegate returnPlayer1Rack];
  
  [self layoutBoard];
  [self layoutTopBar];
  [self layoutPlayerRack];
}

-(void)layoutTopBar {
    // background
  CGFloat topBarHeight = 72.f;
  SKSpriteNode *topBar = [SKSpriteNode spriteNodeWithColor:[SKColor blueColor]
                                                      size:CGSizeMake(self.frame.size.width, topBarHeight)];
  topBar.anchorPoint = CGPointZero;
  topBar.position = CGPointMake(0, self.frame.size.height - topBarHeight);
  [self addChild:topBar];
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
        [self addChild:testLabelNode];
      }
    }
  }
}

-(void)layoutPlayerRack {
    // background
  CGFloat rackHeight = 108.f;
  SKSpriteNode *rack = [SKSpriteNode spriteNodeWithColor:[SKColor purpleColor]
                                                      size:CGSizeMake(self.frame.size.width, rackHeight)];
  rack.anchorPoint = CGPointZero;
  rack.position = CGPointMake(0, 0);
  [self addChild:rack];
  
    // dyadminoes
  CGFloat xEdgeMargin = 12.f;
  CGFloat yBottomMargin = 12.f;

  for (int i = 0; i < kNumDyadminoesInRack; i++) {
    SKSpriteNode *dyadminoSprite = [SKSpriteNode spriteNodeWithImageNamed:@"blankTileNoSo"];
    CGFloat xPadding = (self.frame.size.width - (xEdgeMargin * 2) - (dyadminoSprite.size.width * kNumDyadminoesInRack)) / (kNumDyadminoesInRack - 1);
    dyadminoSprite.anchorPoint = CGPointMake(0.5, 0.5);
    dyadminoSprite.position = CGPointMake(xEdgeMargin + (i * (dyadminoSprite.size.width + xPadding)) + dyadminoSprite.size.width / 2, yBottomMargin + dyadminoSprite.size.height / 2);
    [self addChild:dyadminoSprite];
    [_spritesInPlayer1Rack addObject:dyadminoSprite];

    Dyadmino *dyadmino = _player1Rack[i];
    
    [self addPCSpritesToDyadminoSpriteForDyadmino:dyadmino];
  }
}

-(void)switchPCsOnDyadminoSprite:(SKSpriteNode *)dyadminoSprite {
  NSUInteger tempIndex = [_spritesInPlayer1Rack indexOfObject:dyadminoSprite];
  Dyadmino *dyadmino = [_player1Rack objectAtIndex:tempIndex];
  if (dyadmino.rackOrientation == 0) {
    dyadmino.rackOrientation = 1;
  } else {
    dyadmino.rackOrientation = 0;
  }
  [self addPCSpritesToDyadminoSpriteForDyadmino:dyadmino];
}

-(void)addPCSpritesToDyadminoSpriteForDyadmino:(Dyadmino *)dyadmino {
  NSUInteger topPC;
  NSUInteger bottomPC;
  if (dyadmino.rackOrientation == 0) {
    topPC = dyadmino.pc1;
    bottomPC = dyadmino.pc2;
  } else {
    topPC = dyadmino.pc2;
    bottomPC = dyadmino.pc1;
  }
  
  NSUInteger tempIndex = [_player1Rack indexOfObject:dyadmino];
  SKSpriteNode *dyadminoSprite = [_spritesInPlayer1Rack objectAtIndex:tempIndex];
  
  NSString *topPCString = [NSString stringWithFormat:@"pcLetter%i", topPC];
  NSString *bottomPCString = [NSString stringWithFormat:@"pcLetter%i", bottomPC];
  
  SKSpriteNode *topPCSprite = [SKSpriteNode spriteNodeWithImageNamed:topPCString];
  topPCSprite.anchorPoint = CGPointMake(0.5, 0.5);
  topPCSprite.position= CGPointMake(0, dyadminoSprite.size.height / 4);
  [dyadminoSprite addChild:topPCSprite];
  
  SKSpriteNode *bottomPCSprite = [SKSpriteNode spriteNodeWithImageNamed:bottomPCString];
  bottomPCSprite.anchorPoint = CGPointMake(0.5, 0.5);
  bottomPCSprite.position = CGPointMake(0, -dyadminoSprite.size.height / 4);
  [dyadminoSprite addChild:bottomPCSprite];
}

-(void)handleTap:(UIGestureRecognizer *)sender {
  CGPoint uiTouchLocation = [sender locationInView:self.view];
  CGPoint skTouchLocation = CGPointMake(uiTouchLocation.x, self.frame.size.height - uiTouchLocation.y);
  SKNode *touchNode = [self nodeAtPoint:skTouchLocation];
  
  for (SKSpriteNode *dyadminoSprite in _spritesInPlayer1Rack) {
    if ([touchNode intersectsNode:dyadminoSprite]) {
      
      SKAction *rotate180 = [SKAction rotateByAngle:180 / kRadian duration:0.15f];
      SKAction *removeChildren = [SKAction runBlock:^{
        [dyadminoSprite removeAllChildren];
      }];
      SKAction *resetOrient = [SKAction rotateToAngle:0 duration:0.f];
      SKAction *rightPCs = [SKAction runBlock:^{
        [self switchPCsOnDyadminoSprite:dyadminoSprite];
      }];
      SKAction *complete180 = [SKAction sequence:@[rotate180, removeChildren, resetOrient, rightPCs]];
      [dyadminoSprite runAction:complete180];
    }
  }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

-(void)update:(CFTimeInterval)currentTime {
}

@end
