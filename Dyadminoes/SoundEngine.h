//
//  SoundEngine.h
//  Dyadminoes
//
//  Created by Bennett Lin on 6/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "NSObject+Helper.h"

@interface SoundEngine : SKNode

-(void)handleMusicNote:(NSUInteger)note;
-(void)handleMusicNote1:(NSUInteger)note1 andNote2:(NSUInteger)note2 withOrientation:(DyadminoOrientation)dyadminoOrientation;

+(SoundEngine *)sharedSoundEngine;

@end