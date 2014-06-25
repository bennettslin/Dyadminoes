//
//  SoundEngine.h
//  Dyadminoes
//
//  Created by Bennett Lin on 6/15/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
@class Dyadmino;
@class SKSpriteNode;

@interface SoundEngine : SKNode

-(void)soundSuckedDyadmino;
-(void)soundTouchedDyadmino:(Dyadmino *)dyadmino plucked:(BOOL)plucked;
-(void)soundTouchedDyadminoFace:(SKSpriteNode *)dyadminoFace plucked:(BOOL)plucked;
-(void)soundRackExchangedDyadmino;
-(void)soundPivotClickedDyadmino;
-(void)soundSettledDyadmino;
-(void)soundPCToggle;
-(void)soundDeviceOrientation;
-(void)soundSwapFieldSwoosh;
-(void)soundButton:(BOOL)tap;

@end
