//
//  MyScene.h
//  Dyadminoes
//

//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class SceneViewController;
@class SceneEngine;
@class Player;
@class Dyadmino;
@class Match;
@class SoundEngine;

@protocol SceneDelegate;

@interface MyScene : SKScene

@property (strong, nonatomic) SoundEngine *mySoundEngine;
@property (strong, nonatomic) SceneEngine *mySceneEngine;
@property (strong, nonatomic) Match *myMatch;
@property (weak, nonatomic) id <SceneDelegate> delegate;

-(void)loadAfterNewMatchRetrieved;
-(void)handleDeviceOrientationChange:(UIDeviceOrientation)deviceOrientation;
-(void)handlePinchGestureWithScale:(CGFloat)scale andVelocity:(CGFloat)velocity;
-(void)cancelPinch;
-(void)handleDoubleTap;
-(void)persistAllSceneDataDyadminoes;

-(void)togglePCsUserShaken:(BOOL)userShaken;
-(void)handleUserWantsPivotGuides;
-(void)handleUserWantsVolume;

@end

@protocol SceneDelegate <NSObject>

-(void)backToMainMenu;
-(void)stopActivityIndicator;
-(void)cancelPinchGestureRecogniser;

@end