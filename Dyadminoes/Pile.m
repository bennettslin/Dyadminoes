//
//  Pile.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Pile.h"
#import "Dyadmino.h"

@implementation Pile

-(id)init {
  self = [super init];
  if (self) {

    SKTextureAtlas *textureAtlas = [SKTextureAtlas atlasNamed:@"DyadminoImages"];
    NSMutableArray *tempRotationArray = [[NSMutableArray alloc] initWithCapacity:3];
    
    [tempRotationArray addObject:[textureAtlas textureNamed:@"blankTileNoSo"]];
    [tempRotationArray addObject:[textureAtlas textureNamed:@"blankTileSwNe"]];
    [tempRotationArray addObject:[textureAtlas textureNamed:@"blankTileNwSe"]];
    NSArray *rotationFrameArray = [NSArray arrayWithArray:tempRotationArray];
    
    self.allDyadminoes = [[NSMutableSet alloc] initWithCapacity:66];
    self.dyadminoesInCommonPile = [[NSMutableSet alloc] initWithCapacity:66];
    self.dyadminoesInPlayer1Rack = [[NSMutableArray alloc] initWithCapacity:kNumDyadminoesInRack];
    
      // create dyadminoes
    for (int pc1 = 0; pc1 < 12; pc1++) {
      for (int pc2 = 0; pc2 < 12; pc2++) {
        if (pc1 != pc2 && pc1 < pc2) {
          
          NSString *pc1LetterString = [NSString stringWithFormat:@"pcLetter%d", pc1];
          NSString *pc1NumberString = [NSString stringWithFormat:@"pcNumber%d", pc1];
          NSString *pc2LetterString = [NSString stringWithFormat:@"pcLetter%d", pc2];
          NSString *pc2NumberString = [NSString stringWithFormat:@"pcNumber%d", pc2];
          
          SKSpriteNode *pc1LetterSprite = [SKSpriteNode spriteNodeWithTexture:[textureAtlas textureNamed:pc1LetterString]];
          SKSpriteNode *pc1NumberSprite = [SKSpriteNode spriteNodeWithTexture:[textureAtlas textureNamed:pc1NumberString]];
          SKSpriteNode *pc2LetterSprite = [SKSpriteNode spriteNodeWithTexture:[textureAtlas textureNamed:pc2LetterString]];
          SKSpriteNode *pc2NumberSprite = [SKSpriteNode spriteNodeWithTexture:[textureAtlas textureNamed:pc2NumberString]];
          
          Dyadmino *dyadmino = [[Dyadmino alloc] initWithPC1:pc1 andPC2:pc2 andPCMode:kPCModeLetter andRotationFrameArray:rotationFrameArray andPC1LetterSprite:pc1LetterSprite andPC2LetterSprite:pc2LetterSprite andPC1NumberSprite:pc1NumberSprite andPC2NumberSprite:pc2NumberSprite];
          
          [self.allDyadminoes addObject:dyadmino];
          [self.dyadminoesInCommonPile addObject:dyadmino];
        }
      }
    }
  }
  return self;
}

  // TODO: currently, will break if pile count is less than number being swapped
-(NSMutableArray *)populateOrCompletelySwapOutPlayer1Rack {
  if ([self.dyadminoesInPlayer1Rack count] != 0) {
      // first take random dyadminoes out of pile, and put them in temp array
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:kNumDyadminoesInRack];
    for (int i = 0; i < kNumDyadminoesInRack; i++) {
      [tempArray addObject:[self takeSingleRandomDyadminoOutOfPile]];
    }
      // remove current dyadminoes in rack, and put them back in pile
    for (Dyadmino *dyadmino in self.dyadminoesInPlayer1Rack) {
      [self.dyadminoesInCommonPile addObject:dyadmino];
    }
    [self.dyadminoesInPlayer1Rack removeAllObjects];
      // put dyadminoes in temp array into rack
    self.dyadminoesInPlayer1Rack = tempArray;
  } else {
    for (int i = 0; i < kNumDyadminoesInRack; i++) {
      Dyadmino *dyadmino = [self takeSingleRandomDyadminoOutOfPile];
      [self.dyadminoesInPlayer1Rack addObject:dyadmino];
    }
  }
  return self.dyadminoesInPlayer1Rack;
}

-(Dyadmino *)takeSingleRandomDyadminoOutOfPile {
  NSUInteger randIndex = [self randomValueUpTo:[self.dyadminoesInCommonPile count]];
  NSArray *tempArray = [self.dyadminoesInCommonPile allObjects];
  Dyadmino *dyadmino = (Dyadmino *)tempArray[randIndex];
  [self.dyadminoesInCommonPile removeObject:dyadmino];
  return dyadmino;
}

@end
