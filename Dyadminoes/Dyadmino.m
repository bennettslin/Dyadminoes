//
//  Dyadmino.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Dyadmino.h"

@implementation Dyadmino {
  BOOL _alreadyAddedChildren;
}

-(id)initWithPC1:(NSUInteger)pc1 andPC2:(NSUInteger)pc2 andPCMode:(NSString *)pcMode andRotationFrameArray:(NSArray *)rotationFrameArray andPC1LetterSprite:(SKSpriteNode *)pc1LetterSprite andPC2LetterSprite:(SKSpriteNode *)pc2LetterSprite andPC1NumberSprite:(SKSpriteNode *)pc1NumberSprite andPC2NumberSprite:(SKSpriteNode *)pc2NumberSprite {
  self = [super init];
  if (self) {
    self.pc1 = pc1;
    self.pc2 = pc2;
    self.pcMode = pcMode;
    self.rotationFrameArray = rotationFrameArray;
    self.pc1LetterSprite = pc1LetterSprite;
    self.pc2LetterSprite = pc2LetterSprite;
    self.pc1NumberSprite = pc1NumberSprite;
    self.pc2NumberSprite = pc2NumberSprite;
    self.zPosition = 100;
    [self randomiseRackOrientation];
    [self selectAndPositionSprites];
  }
  return self;
}

-(void)selectAndPositionSprites {
  
  if ([self.pcMode isEqualToString:@"Letter"]) {
    if (!self.pc1Sprite || self.pc1Sprite == self.pc1NumberSprite) {
      _alreadyAddedChildren = YES;
      [self removeAllChildren];
      self.pc1Sprite = self.pc1LetterSprite;
      self.pc2Sprite = self.pc2LetterSprite;
      [self addChild:self.pc1Sprite];
      [self addChild:self.pc2Sprite];
    }
  } else if ([self.pcMode isEqualToString:@"Number"]) {
    if (!self.pc1Sprite || self.pc1Sprite == self.pc1LetterSprite) {
      _alreadyAddedChildren = YES;
      [self removeAllChildren];
      self.pc1Sprite = self.pc1NumberSprite;
      self.pc2Sprite = self.pc2NumberSprite;
      [self addChild:self.pc1Sprite];
      [self addChild:self.pc2Sprite];
    }
  }
  
  switch (self.rackOrientation) {
    case 0:
      self.texture = self.rotationFrameArray[0];
      self.size = self.texture.size;
      self.pc1Sprite.position = CGPointMake(0, -self.size.height / 4);
      self.pc2Sprite.position = CGPointMake(0, self.size.height / 4);
      break;
    case 1:
      self.texture = self.rotationFrameArray[1];
      self.size = self.texture.size;
      self.pc1Sprite.position = CGPointMake(-self.size.width * 1.5f / 7, -self.size.height / 6);
      self.pc2Sprite.position = CGPointMake(self.size.width * 1.5f / 7, self.size.height / 6);
      break;
    case 2:
      self.texture = self.rotationFrameArray[2];
      self.size = self.texture.size;
      self.pc1Sprite.position = CGPointMake(-self.size.width * 1.5f / 7, self.size.height / 6);
      self.pc2Sprite.position = CGPointMake(self.size.width * 1.5f / 7, -self.size.height / 6);
      break;
    case 3:
      self.texture = self.rotationFrameArray[0];
      self.size = self.texture.size;
      self.pc1Sprite.position = CGPointMake(0, self.size.height / 4);
      self.pc2Sprite.position = CGPointMake(0, -self.size.height / 4);
      break;
    case 4:
      self.texture = self.rotationFrameArray[1];
      self.size = self.texture.size;
      self.pc1Sprite.position = CGPointMake(self.size.width * 1.5f / 7, self.size.height / 6);
      self.pc2Sprite.position = CGPointMake(-self.size.width * 1.5f / 7, -self.size.height / 6);
      break;
    case 5:
      self.texture = self.rotationFrameArray[2];
      self.size = self.texture.size;
      self.pc1Sprite.position = CGPointMake(self.size.width * 1.5f / 7, -self.size.height / 6);
      self.pc2Sprite.position = CGPointMake(-self.size.width * 1.5f / 7, self.size.height / 6);
      break;
  }
}

-(void)randomiseRackOrientation { // only gets called before sprite is reloaded
  NSUInteger zeroOrOne = [self randomValueUpTo:2]; // randomise rackOrientation
  NSUInteger zeroOrThree = 0;
  if (zeroOrOne == 1) {
    zeroOrThree = 3;
  }
  self.rackOrientation = zeroOrThree;
}

#pragma mark - helper methods

  // duplicate code in myScene
-(NSUInteger)randomValueUpTo:(NSUInteger)high {
  NSUInteger randInteger = ((int) arc4random() % high);
  return randInteger;
}

@end