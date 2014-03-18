//
//  MyScene.h
//  Dyadminoes
//

//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class GameEngine;
@class Player;

@interface MyScene : SKScene

@property (strong, nonatomic) GameEngine *ourGameEngine;
@property (strong, nonatomic) Player *myPlayer;

-(void)handleDeviceOrientationChange:(UIDeviceOrientation)deviceOrientation;

@end