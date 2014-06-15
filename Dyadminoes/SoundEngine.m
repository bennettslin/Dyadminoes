//
//  SoundEngine.m
//  Dyadminoes
//
//  Created by Bennett Lin on 6/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "SoundEngine.h"
#import "Dyadmino.h"

@implementation SoundEngine

-(void)soundTouchedDyadmino:(Dyadmino *)dyadmino {
  NSLog(@"sounding %@", dyadmino.name);
  SKAction *sound = [SKAction playSoundFileNamed:@"hitCat.wav" waitForCompletion:NO];
  [self runAction:sound];
}

-(void)soundTouchedDyadminoFace:(SKSpriteNode *)dyadminoFace {
  NSLog(@"sounding note %@", dyadminoFace.name);
  SKAction *sound = [SKAction playSoundFileNamed:@"hitCatLady.wav" waitForCompletion:NO];
  [self runAction:sound];
}

@end
