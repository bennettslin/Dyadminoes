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

@interface SoundEngine : NSObject

-(void)handleMusicNote:(NSUInteger)note;
-(void)handleMusicNote:(NSUInteger)note withHexCoord:(HexCoord)hexCoord;
-(void)handleMusicNote1:(NSUInteger)note1 andNote2:(NSUInteger)note2 withOrientation:(DyadminoOrientation)dyadminoOrientation;

-(void)playSoundNotificationName:(NotificationName)notificationName;
+(SoundEngine *)sharedSoundEngine;

@end