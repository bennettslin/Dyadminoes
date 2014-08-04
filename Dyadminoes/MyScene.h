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
@property (weak, nonatomic) id <SceneDelegate> myDelegate;

-(void)loadAfterNewMatchRetrieved;
-(void)handleDeviceOrientationChange:(UIDeviceOrientation)deviceOrientation;
-(void)handlePinchGestureWithScale:(CGFloat)scale andVelocity:(CGFloat)velocity andLocation:(CGPoint)location;
-(void)cancelPinch;
-(BOOL)validatePinchLocation:(CGPoint)location;

-(void)tempStoreForPlayerSceneDataDyadminoes;

-(void)togglePCsUserShaken:(BOOL)userShaken;
-(void)handleUserWantsPivotGuides;
-(void)handleUserWantsVolume;

@end

@protocol SceneDelegate <NSObject>

-(void)backToMainMenu;
-(void)stopActivityIndicator;

@end