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
#import "Face.h"

@interface SceneEngine () <DyadminoSceneDelegate>

@property (readwrite, nonatomic) PCMode myPCMode;
@property (strong, nonatomic) NSArray *rotationFrameArray;
@property (strong, nonatomic) NSArray *rotationFrameLockedArray;

@end

@implementation SceneEngine {
  NSUInteger _rotationFromDevice;
}

-(id)init {
  self = [super init];
  if (self) {
    _rotationFromDevice = 0;
    
    self.myPCMode = [[NSUserDefaults standardUserDefaults] integerForKey:@"notation"];
    self.allDyadminoes = [self createPile];
    if (self.allDyadminoes.count != kPileCount) {
      NSLog(@"Scene dyadminoes were not created properly.");
      abort();
    }
  }
  return self;
}

-(NSArray *)createPile {
  
  NSMutableArray *tempAllDyadminoes = [[NSMutableArray alloc] initWithCapacity:kPileCount];
  
    // get dyadmino textures
  NSMutableArray *tempRotationArray = [[NSMutableArray alloc] initWithCapacity:3];
  [tempRotationArray addObject:[self textureForTextureDyadmino:kTextureDyadminoNoSo]];
  [tempRotationArray addObject:[self textureForTextureDyadmino:kTextureDyadminoSwNe]];
  [tempRotationArray addObject:[self textureForTextureDyadmino:kTextureDyadminoNwSe]];
  self.rotationFrameArray = [NSArray arrayWithArray:tempRotationArray];
  
  NSMutableArray *tempRotationLockedArray = [[NSMutableArray alloc] initWithCapacity:3];
  [tempRotationLockedArray addObject:[self textureForTextureDyadmino:kTextureDyadminoLockedNoSo]];
  [tempRotationLockedArray addObject:[self textureForTextureDyadmino:kTextureDyadminoLockedSwNe]];
  [tempRotationLockedArray addObject:[self textureForTextureDyadmino:kTextureDyadminoLockedNwSe]];
  self.rotationFrameLockedArray = [NSArray arrayWithArray:tempRotationLockedArray];
  
    // dyadmino IDs start from 0
  NSUInteger myID = 0;
  
  for (int pc1 = 0; pc1 < 12; pc1++) {
    for (int pc2 = pc1 + 1; pc2 < 12; pc2++) {
      if (pc1 < pc2) {
        
          // instantiate dyadmino
        Dyadmino *dyadmino = [[Dyadmino alloc] initWithPC1:pc1
                                                    andPC2:pc2
                                          andSceneDelegate:self];
        dyadmino.myID = myID;
        myID++;
        
        [tempAllDyadminoes addObject:dyadmino];
      }
    }
  }
  
  return [NSArray arrayWithArray:tempAllDyadminoes];
}

#pragma mark - texture methods

-(SKTexture *)getCellTexture {
  AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
  SKTextureAtlas *textureAtlas = appDelegate.myAtlas;
  return [textureAtlas textureNamed:@"blankSpace"];
}

-(SKTexture *)textureForTextureCell:(TextureCell)textureCell {
    // FIXME: there is no locked texture cell
  
  AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
  SKTextureAtlas *textureAtlas = appDelegate.myAtlas;
  
  switch (textureCell) {
    case kTextureCell:
      return [textureAtlas textureNamed:@"blankSpace"];
      break;
    case kTextureCellLocked:
      return [textureAtlas textureNamed:@"blankSpaceLocked"];
      break;
  }
  return nil;
}

-(SKTexture *)textureForTextureDyadmino:(TextureDyadmino)textureDyadmino {
  
  AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
  SKTextureAtlas *textureAtlas = appDelegate.myAtlas;
  
  switch (textureDyadmino) {
    case kTextureDyadminoNoSo:
      return [textureAtlas textureNamed:@"blankTileNoSo"];
      break;
    case kTextureDyadminoSwNe:
      return [textureAtlas textureNamed:@"blankTileSwNe"];
      break;
    case kTextureDyadminoNwSe:
      return [textureAtlas textureNamed:@"blankTileNwSe"];
      break;

    case kTextureDyadminoLockedNoSo:
      return [textureAtlas textureNamed:@"blankTileLockedNoSo"];
      break;
    case kTextureDyadminoLockedSwNe:
      return [textureAtlas textureNamed:@"blankTileLockedSwNe"];
      break;
    case kTextureDyadminoLockedNwSe:
      return [textureAtlas textureNamed:@"blankTileLockedNwSe"];
      break;
  }
  return nil;
}

-(SKTexture *)textureForPC:(NSInteger)pc {
  
  AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
  SKTextureAtlas *textureAtlas = appDelegate.myAtlas;
  
    // pc must be between 0 and 11
  if (pc >= 0 && pc < 12) {
    
    NSString *filename;
    switch (self.myPCMode) {
      case kPCModeLetter:
        filename = [NSString stringWithFormat:@"pcLetter%ld", (long)pc];
        break;
      case kPCModeNumber:
        filename = [NSString stringWithFormat:@"pcNumber%ld", (long)pc];
      default:
        break;
    }
    return [textureAtlas textureNamed:filename];
    
  } else {
    return nil;
  }
}

#pragma mark - player preference methods

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
    [dyadmino selectAndPositionSpritesZRotation:0.f];
  }
}

#pragma mark - singleton method

+(SceneEngine *)sharedSceneEngine {
  static dispatch_once_t pred;
  static SceneEngine *shared = nil;
  dispatch_once(&pred, ^{
    shared = [[SceneEngine alloc] init];
  });
  return shared;
}

@end
