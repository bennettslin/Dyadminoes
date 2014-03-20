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

  // players
@property (strong, nonatomic) Player *player1;

  // dyadminoes
@property (strong, nonatomic) NSMutableSet *allDyadminoes;
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
    [self putFirstDyadminoOnBoard];
    
      // FIXME: eventually change this to reflect how many players are playing
    self.dyadminoesInPlayer1Rack = [[NSMutableArray alloc] initWithCapacity:kNumDyadminoesInRack];
      //    self.dyadminoesInPlayer2Rack = [[NSMutableArray alloc] initWithCapacity:kNumDyadminoesInRack];
    self.player1 = [[Player alloc] initWithPlayerNumber:1 andDyadminoesInRack:[self getInitiallyPopulatedRack]];
  }
  return self;
}

-(void)createPile {
  
    // create pivot guides
    // TODO: refactor into one method?
  SKNode *prePivotGuide = [self createPivotGuideNamed:@"prePivotGuide"];
  SKNode *pivotRotateGuide = [self createPivotGuideNamed:@"pivotRotateGuide"];
  SKNode *pivotAroundGuide = [self createPivotGuideNamed:@"pivotAroundGuide"];
  
    // get dyadmino textures
  SKTextureAtlas *textureAtlas = [SKTextureAtlas atlasNamed:@"DyadminoImages"];
  NSMutableArray *tempRotationArray = [[NSMutableArray alloc] initWithCapacity:3];
  [tempRotationArray addObject:[textureAtlas textureNamed:@"blankTileNoSo"]];
  [tempRotationArray addObject:[textureAtlas textureNamed:@"blankTileSwNe"]];
  [tempRotationArray addObject:[textureAtlas textureNamed:@"blankTileNwSe"]];
  NSArray *rotationFrameArray = [NSArray arrayWithArray:tempRotationArray];
  
  for (int pc1 = 0; pc1 < 12; pc1++) {
    for (int pc2 = 0; pc2 < 12; pc2++) {
      if (pc1 != pc2 && pc1 < pc2) {
        
          //get pc textures
        NSString *pc1LetterString = [NSString stringWithFormat:@"pcLetter%d", pc1];
        NSString *pc1NumberString = [NSString stringWithFormat:@"pcNumber%d", pc1];
        NSString *pc2LetterString = [NSString stringWithFormat:@"pcLetter%d", pc2];
        NSString *pc2NumberString = [NSString stringWithFormat:@"pcNumber%d", pc2];
        SKSpriteNode *pc1LetterSprite = [SKSpriteNode spriteNodeWithTexture:[textureAtlas textureNamed:pc1LetterString]];
        SKSpriteNode *pc1NumberSprite = [SKSpriteNode spriteNodeWithTexture:[textureAtlas textureNamed:pc1NumberString]];
        SKSpriteNode *pc2LetterSprite = [SKSpriteNode spriteNodeWithTexture:[textureAtlas textureNamed:pc2LetterString]];
        SKSpriteNode *pc2NumberSprite = [SKSpriteNode spriteNodeWithTexture:[textureAtlas textureNamed:pc2NumberString]];
        
          // instantiate dyadmino
        Dyadmino *dyadmino = [[Dyadmino alloc] initWithPC1:pc1 andPC2:pc2 andPCMode:kPCModeLetter andRotationFrameArray:rotationFrameArray andPC1LetterSprite:pc1LetterSprite andPC2LetterSprite:pc2LetterSprite andPC1NumberSprite:pc1NumberSprite andPC2NumberSprite:pc2NumberSprite];
        
          // assign pivot guides
        dyadmino.prePivotGuide = prePivotGuide;
        dyadmino.prePivotGuide.zPosition = -1.f;
        dyadmino.prePivotGuide.name = @"prePivotGuide";
        dyadmino.pivotRotateGuide = pivotRotateGuide;
        dyadmino.pivotRotateGuide.zPosition = -1.f;
        dyadmino.pivotRotateGuide.name = @"pivotRotateGuide";
        dyadmino.pivotAroundGuide = pivotAroundGuide;
        dyadmino.pivotAroundGuide.zPosition = -1.f;
        dyadmino.pivotAroundGuide.name = @"pivotAroundGuide";
        
          // initially put them all in the common pile
        [self.allDyadminoes addObject:dyadmino];
        [self.dyadminoesInCommonPile addObject:dyadmino];
        
          // testing purposes
        if (pc1 == 0 && pc2 == 1) {
          NSLog(@"dyadmino size oriented twelve is %f, %f", [textureAtlas textureNamed:@"blankTileNoSo"].size.width, [textureAtlas textureNamed:@"blankTileNoSo"].size.height);
          NSLog(@"dyadmino size oriented two is %f, %f", [textureAtlas textureNamed:@"blankTileSwNe"].size.width, [textureAtlas textureNamed:@"blankTileSwNe"].size.height);
          NSLog(@"dyadmino size oriented ten is %f, %f", [textureAtlas textureNamed:@"blankTileNwSe"].size.width, [textureAtlas textureNamed:@"blankTileNwSe"].size.height);
          NSLog(@"pc size is %f, %f", [textureAtlas textureNamed:pc1LetterString].size.width, [textureAtlas textureNamed:pc1LetterString].size.height);
        }
      }
    }
  }
  
    // FIXME: temporary, for testing purposes, eventually remove
    // 58 is good
  NSUInteger getRidOfNumber = 50;
  for (int i = 0; i < getRidOfNumber; i++) {
    Dyadmino *dyadmino = [self.allDyadminoes anyObject];
    [self.allDyadminoes removeObject:dyadmino];
    [self.dyadminoesInCommonPile removeObject:dyadmino];
  }
}

-(void)putFirstDyadminoOnBoard {
    // board will have method for positioning dyadmino without boardNode
  Dyadmino *dyadmino = [self removeRandomDyadminoFromPile];
  [dyadmino randomiseRackOrientation];
  [self.dyadminoesOnBoard addObject:dyadmino];
}

-(SKNode *)createPivotGuideNamed:(NSString *)name {
  
  float startAngle[4] = {210, 30, 330, 150};
  float endAngle[4] = {330, 150, 30, 210};
  NSArray *colourArray = @[kGold, kGold, kDarkBlue, kDarkBlue];
  
  SKNode *pivotGuide = [SKNode new];
  pivotGuide.name = name;
  
    // this will have to change substantially...
  NSUInteger initialNumber;
  NSUInteger conditionalNumber;
  if ([pivotGuide.name isEqualToString:@"prePivotGuide"]) {
    initialNumber = 0;
    conditionalNumber = 4;
  } else if ([pivotGuide.name isEqualToString:@"pivotRotateGuide"]) {
    initialNumber = 3;
    conditionalNumber = 4;
  } else if ([pivotGuide.name isEqualToString:@"pivotAroundGuide"]) {
    initialNumber = 0;
    conditionalNumber = 1;
  } else {
    return nil;
  }

  for (int i = initialNumber; i < conditionalNumber; i++) {
    SKShapeNode *shapeNode = [SKShapeNode new];
    CGMutablePathRef shapePath = CGPathCreateMutable();
    
    CGPathAddArc(shapePath, NULL, 0.5f, 0.5f, kMaxDistanceForPivot, [self getRadiansFromDegree:startAngle[i]],
                 [self getRadiansFromDegree:endAngle[i]], NO);
    CGPathAddLineToPoint(shapePath, NULL, kMinDistanceForPivot * cosf([self getRadiansFromDegree:endAngle[i]]),
                 kMinDistanceForPivot * sinf([self getRadiansFromDegree:endAngle[i]]));
    CGPathAddArc(shapePath, NULL, 0.5f, 0.5f, kMinDistanceForPivot, [self getRadiansFromDegree:endAngle[i]],
                 [self getRadiansFromDegree:startAngle[i]], YES);
    CGPathAddLineToPoint(shapePath, NULL, kMaxDistanceForPivot * cosf([self getRadiansFromDegree:startAngle[i]]),
                 kMaxDistanceForPivot * sinf([self getRadiansFromDegree:startAngle[i]]));
    shapeNode.path = shapePath;
    shapeNode.lineWidth = 0.1f;
    shapeNode.alpha = kPivotGuideAlpha;
    shapeNode.strokeColor = [SKColor clearColor];
    shapeNode.fillColor = colourArray[i];
    [pivotGuide addChild:shapeNode];
  }
  return pivotGuide;
}

-(NSMutableArray *)getInitiallyPopulatedRack {
  NSMutableArray *playerRack = [NSMutableArray new];
  for (int i = 0; i < kNumDyadminoesInRack; i++) {
    Dyadmino *dyadmino = [self removeRandomDyadminoFromPile];
    if (dyadmino) {
      [playerRack addObject:dyadmino];
    }
  }
  return playerRack;
}

-(NSUInteger)getCommonPileCount {
  return [self.dyadminoesInCommonPile count];
}

  // FIXME: obviously, this will asign players more wisely...

-(Player *)getAssignedAsPlayer {
  return self.player1;
}

#pragma mark - player interaction methods

-(void)swapTheseDyadminoes:(NSMutableArray *)fromPlayer fromPlayer:(Player *)player {
    // dyadminoes taken out of pile
  for (NSUInteger i = 0; i < fromPlayer.count; i++) {
    [player.dyadminoesInRack addObject:[self removeRandomDyadminoFromPile]];
  }
  
    // put player dyadminoes back in pile
  for (Dyadmino *dyadmino in fromPlayer) {
    [self.dyadminoesInCommonPile addObject:dyadmino];
    [player.dyadminoesInRack removeObject:dyadmino];
  }
}

-(Dyadmino *)removeRandomDyadminoFromPile {
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

-(BOOL)putDyadminoFromPileIntoRackOfPlayer:(Player *)player {
  Dyadmino *dyadmino = [self removeRandomDyadminoFromPile];
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

#pragma mark = player preference methods

-(void)toggleBetweenLetterAndNumberMode {
  
    // FIXME: will this affect other player's view of dyadminoes?
  for (Dyadmino *dyadmino in self.allDyadminoes) {
    if (dyadmino.pcMode == kPCModeLetter) {
      dyadmino.pcMode = kPCModeNumber;
    } else {
      dyadmino.pcMode = kPCModeLetter;
    }
    [dyadmino selectAndPositionSprites];
  }
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
