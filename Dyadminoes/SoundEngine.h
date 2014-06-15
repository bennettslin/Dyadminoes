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

-(void)soundTouchedDyadmino:(Dyadmino *)dyadmino;
-(void)soundTouchedDyadminoFace:(SKSpriteNode *)dyadminoFace;

@end
