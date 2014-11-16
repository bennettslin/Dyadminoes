//
//  Pile.h
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Helper.h"
@class Dyadmino;
@class Player;
@class SKTexture;

@interface SceneEngine : NSObject

  // dyadminoes
@property (strong, nonatomic) NSArray *allDyadminoes;
@property (nonatomic) PCMode myPCMode;

+(SceneEngine *)sharedSceneEngine;
-(SKTexture *)getCellTexture;

#pragma mark - player preference methods

/*
-(BOOL)rotateDyadminoesBasedOnDeviceOrientation:(UIDeviceOrientation)deviceOrientation;
 */

-(void)toggleBetweenLetterAndNumberMode;

@end