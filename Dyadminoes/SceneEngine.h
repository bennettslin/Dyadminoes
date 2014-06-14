//
//  Pile.h
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Dyadmino;
@class Player;

@interface SceneEngine : NSObject

  // dyadminoes
@property (strong, nonatomic) NSArray *allDyadminoes;

#pragma mark - player preference methods

-(void)rotateDyadminoesBasedOnDeviceOrientation:(UIDeviceOrientation)deviceOrientation;
-(void)toggleBetweenLetterAndNumberMode;

@end