//
//  Pile.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "SceneEngine.h"
#import "Dyadmino.h"
#import "Player.h"
#import "AppDelegate.h"

@interface SceneEngine ()

@property (strong, nonatomic) NSMutableSet *dyadminoesInCommonPile;

@end

@implementation SceneEngine {
  NSUInteger _rotationFromDevice;
}

-(id)init {
  self = [super init];
  if (self) {
    _rotationFromDevice = 0;
      // initial setup
    self.dyadminoesInCommonPile = [[NSMutableSet alloc] initWithCapacity:kPileCount];
    
    self.myPCMode = kPCModeLetter;
    
    [self createPile];
  }
  return self;
}

-(SKTexture *)getCellTexture {
  AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
  SKTextureAtlas *textureAtlas = appDelegate.myAtlas;
  return [textureAtlas textureNamed:@"blankSpace"];
}

-(void)createPile {
  
  NSMutableArray *tempAllDyadminoes = [[NSMutableArray alloc] initWithCapacity:kPileCount];
  
    // get dyadmino textures
  AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
  SKTextureAtlas *textureAtlas = appDelegate.myAtlas;
  NSMutableArray *tempRotationArray = [[NSMutableArray alloc] initWithCapacity:3];
  [tempRotationArray addObject:[textureAtlas textureNamed:@"blankTileNoSo"]];
  [tempRotationArray addObject:[textureAtlas textureNamed:@"blankTileSwNe"]];
  [tempRotationArray addObject:[textureAtlas textureNamed:@"blankTileNwSe"]];
  NSArray *rotationFrameArray = [NSArray arrayWithArray:tempRotationArray];
  
  NSUInteger myID = 1;
  
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
        pc1LetterSprite.name = [NSString stringWithFormat:@"%i", pc1];
        pc1NumberSprite.name = [NSString stringWithFormat:@"%i", pc1];
        pc2LetterSprite.name = [NSString stringWithFormat:@"%i", pc2];
        pc2NumberSprite.name = [NSString stringWithFormat:@"%i", pc2];
        
          // instantiate dyadmino
        Dyadmino *dyadmino = [[Dyadmino alloc] initWithPC1:pc1 andPC2:pc2 andPCMode:kPCModeLetter andRotationFrameArray:rotationFrameArray andPC1LetterSprite:pc1LetterSprite andPC2LetterSprite:pc2LetterSprite andPC1NumberSprite:pc1NumberSprite andPC2NumberSprite:pc2NumberSprite];
        
        dyadmino.myID = myID;
        
//        NSLog(@"%i: %i-%i", dyadmino.myID, pc1, pc2);
        
        myID++;
        
          // initially put them all in the common pile
        [tempAllDyadminoes addObject:dyadmino];
        [self.dyadminoesInCommonPile addObject:dyadmino];
        
          // testing purposes
        /*
        if (pc1 == 0 && pc2 == 1) {
          NSLog(@"dyadmino size oriented twelve is %f, %f", [textureAtlas textureNamed:@"blankTileNoSo"].size.width, [textureAtlas textureNamed:@"blankTileNoSo"].size.height);
          NSLog(@"dyadmino size oriented two is %f, %f", [textureAtlas textureNamed:@"blankTileSwNe"].size.width, [textureAtlas textureNamed:@"blankTileSwNe"].size.height);
          NSLog(@"dyadmino size oriented ten is %f, %f", [textureAtlas textureNamed:@"blankTileNwSe"].size.width, [textureAtlas textureNamed:@"blankTileNwSe"].size.height);
          NSLog(@"pc size is %f, %f", [textureAtlas textureNamed:pc1LetterString].size.width, [textureAtlas textureNamed:pc1LetterString].size.height);
        }
        */
      }
    }
  }
  
  self.allDyadminoes = [NSArray arrayWithArray:tempAllDyadminoes];
  
    // FIXME: temporary, for testing purposes, eventually remove
    // 58 is good
//  NSUInteger getRidOfNumber = 50;
//  for (int i = 0; i < getRidOfNumber; i++) {
//    Dyadmino *dyadmino = [self.allDyadminoes anyObject];
//    [self.allDyadminoes removeObject:dyadmino];
//    [self.dyadminoesInCommonPile removeObject:dyadmino];
//  }
}

#pragma mark = player preference methods

-(BOOL)rotateDyadminoesBasedOnDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
  
  NSUInteger rotation = _rotationFromDevice;
  switch (deviceOrientation) {
    case UIDeviceOrientationPortrait:
      rotation = 0;
      break;
    case UIDeviceOrientationLandscapeRight:
      rotation = 90;
      break;
    case UIDeviceOrientationPortraitUpsideDown:
      rotation = 180;
      break;
    case UIDeviceOrientationLandscapeLeft:
      rotation = 270;
      break;
    default:
      break;
  }
  
  if (rotation != _rotationFromDevice) {
    for (Dyadmino *dyadmino in self.allDyadminoes) {
      dyadmino.pc1LetterSprite.zRotation = [self getRadiansFromDegree:rotation];
      dyadmino.pc2LetterSprite.zRotation = [self getRadiansFromDegree:rotation];
      dyadmino.pc1NumberSprite.zRotation = [self getRadiansFromDegree:rotation];
      dyadmino.pc2NumberSprite.zRotation = [self getRadiansFromDegree:rotation];
    }
    _rotationFromDevice = rotation;
    return YES;
  } else {
    return NO;
  }
}

-(void)toggleBetweenLetterAndNumberMode {

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
    // change values
  if (self.myPCMode == kPCModeLetter) {
    self.myPCMode = kPCModeNumber;
    NSLog(@"now number mode");
    [defaults setInteger:1 forKey:@"notation"];
    [defaults synchronize];
  } else if (self.myPCMode == kPCModeNumber) {
    self.myPCMode = kPCModeLetter;
    NSLog(@"now letter mode");
    [defaults setInteger:0 forKey:@"notation"];
    [defaults synchronize];
  }
  
    // change views
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



@end
