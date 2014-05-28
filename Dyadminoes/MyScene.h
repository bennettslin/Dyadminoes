//
//  MyScene.h
//  Dyadminoes
//

//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class SceneViewController;
@class GameEngine;
@class Player;
@class Dyadmino;
@class Match;

@protocol SceneDelegate;

@interface MyScene : SKScene

@property (strong, nonatomic) Match *myMatch;

@property (strong, nonatomic) GameEngine *ourGameEngine;
@property (strong, nonatomic) Player *myPlayer;
@property (weak, nonatomic) id <SceneDelegate> delegate;

-(void)handleDeviceOrientationChange:(UIDeviceOrientation)deviceOrientation;

@end

@protocol SceneDelegate <NSObject>

-(void)backToMainMenu;

@end