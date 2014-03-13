//
//  Pile.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "GameEngine.h"
//#import "NSObject+Helper.h"
#import "Dyadmino.h"
#import "Player.h"

@interface GameEngine ()

@property (strong, nonatomic) Player *player1;
@property (strong, nonatomic) NSMutableArray *dyadminoesInPlayer1Rack;
@property (strong, nonatomic) NSMutableArray *dyadminoesInPlayer2Rack;
@property (strong, nonatomic) NSMutableSet *dyadminoesInCommonPile;

@end

@implementation GameEngine

-(id)init {
  self = [super init];
  if (self) {
      // initial setup
    self.allDyadminoes = [[NSMutableSet alloc] initWithCapacity:66];
    self.dyadminoesInCommonPile = [[NSMutableSet alloc] initWithCapacity:66];
    self.dyadminoesOnBoard = [NSMutableSet new];
    [self createPile];
    
      // FIXME: eventually change this to reflect how many players are playing
    self.dyadminoesInPlayer1Rack = [[NSMutableArray alloc] initWithCapacity:kNumDyadminoesInRack];
      //    self.dyadminoesInPlayer2Rack = [[NSMutableArray alloc] initWithCapacity:kNumDyadminoesInRack];
    self.player1 = [[Player alloc] initWithPlayerNumber:1 andDyadminoesInRack:[self getInitiallyPopulatedRack]];
  }
  return self;
}

-(void)createPile {
  SKTextureAtlas *textureAtlas = [SKTextureAtlas atlasNamed:@"DyadminoImages"];
  NSMutableArray *tempRotationArray = [[NSMutableArray alloc] initWithCapacity:3];
  
  [tempRotationArray addObject:[textureAtlas textureNamed:@"blankTileNoSo"]];
  [tempRotationArray addObject:[textureAtlas textureNamed:@"blankTileSwNe"]];
  [tempRotationArray addObject:[textureAtlas textureNamed:@"blankTileNwSe"]];
  NSArray *rotationFrameArray = [NSArray arrayWithArray:tempRotationArray];
  
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
  
    // FIXME: temporary, eventually remove
    // 58 is good
  NSUInteger getRidOfNumber = 50;
  
  for (int i = 0; i < getRidOfNumber; i++) {
    Dyadmino *dyadmino = [self.allDyadminoes anyObject];
    [self.allDyadminoes removeObject:dyadmino];
    [self.dyadminoesInCommonPile removeObject:dyadmino];
  }
}

  // TODO: currently, will break if pile count is less than number being swapped
  // TODO: make this a standalone method for populating only, NOT repopulating after swap
-(NSMutableArray *)getInitiallyPopulatedRack {
    // move this part over to the swap method
    //  if (thisRack || [thisRack count] != 0) {
    //      // first take random dyadminoes out of pile, and put them in temp array
    //    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:kNumDyadminoesInRack];
    //    for (int i = 0; i < kNumDyadminoesInRack; i++) {
    //      [tempArray addObject:[self pickRandomDyadminoOutOfCommonPile]];
    //    }
    //      // remove current dyadminoes in rack, and put them back in pile
    //    for (Dyadmino *dyadmino in thisRack) {
    //      [self.dyadminoesInCommonPile addObject:dyadmino];
    //    }
    //    [thisRack removeAllObjects];
    //      // put dyadminoes in temp array into rack
    //    thisRack = tempArray;
    //
    //      // populating player's rack
    //  } else {
  NSMutableArray *tempArray = [NSMutableArray new];
  for (int i = 0; i < kNumDyadminoesInRack; i++) {
    Dyadmino *dyadmino = [self pickRandomDyadminoOutOfCommonPile];
    if (dyadmino) {
      [tempArray addObject:dyadmino];
    }
  }
    //  }
  return tempArray;
}

-(NSUInteger)getCommonPileCount {
  return [self.dyadminoesInCommonPile count];
}

  // FIXME: obviously, this will asign players more wisely...
-(Player *)getAssignedAsPlayer {
  return self.player1;
}

#pragma mark - player interaction methods

-(Dyadmino *)pickRandomDyadminoOutOfCommonPile {
  NSUInteger dyadminoesLeftInPile = self.dyadminoesInCommonPile.count;
    // if dyadminoes left...
  if (dyadminoesLeftInPile >= 1) {
    NSUInteger randIndex = [self randomValueUpTo:dyadminoesLeftInPile];
    NSArray *tempArray = [self.dyadminoesInCommonPile allObjects];
    Dyadmino *dyadmino = (Dyadmino *)tempArray[randIndex];
    [self.dyadminoesInCommonPile removeObject:dyadmino];
    return dyadmino;
  } else {
    return nil;
  }
}

-(BOOL)putDyadminoFromCommonPileIntoRackOfPlayer:(Player *)player {
  Dyadmino *dyadmino = [self pickRandomDyadminoOutOfCommonPile];
  if (dyadmino) {
    [player.dyadminoesInRack addObject:dyadmino];
    return YES;
  } else {
    return NO;
  }
}

-(BOOL)playOnBoardThisDyadmino:(Dyadmino *)dyadmino fromRackOfPlayer:(Player *)player {
  if ([player.dyadminoesInRack containsObject:dyadmino]) {
    [self.dyadminoesOnBoard addObject:dyadmino];
    [player.dyadminoesInRack removeObject:dyadmino];
    return YES;
  }
  return NO;
}

#pragma mark - singleton method

+(GameEngine *)gameEngine {
  static dispatch_once_t pred;
  static GameEngine *shared = nil;
  dispatch_once(&pred, ^{
    shared = [[GameEngine alloc] init];
  });
  return shared;
}

@end
