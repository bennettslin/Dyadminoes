//
//  MyScene.h
//  Dyadminoes
//

//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+Helper.h"
@class SceneViewController;
@class Player;
@class Dyadmino;
@class Match;
@class SoundEngine;
@class ChildViewController;
@protocol SceneDelegate;

@interface MyScene : SKScene

@property (strong, nonatomic) SoundEngine *mySoundEngine;
@property (strong, nonatomic) Match *myMatch;

@property (weak, nonatomic) id <SceneDelegate> myDelegate;

-(BOOL)loadAfterNewMatchRetrievedForReset:(BOOL)forReset;
/*
-(void)handleDeviceOrientationChange:(UIDeviceOrientation)deviceOrientation;
 */
-(void)handlePinchGestureWithScale:(CGFloat)scale andVelocity:(CGFloat)velocity andLocation:(CGPoint)location;
-(BOOL)validatePinchLocation:(CGPoint)location;
-(void)togglePCsUserShaken:(BOOL)userShaken;
-(void)handleUserWantsPivotGuides;
-(void)presentActionSheet:(ActionSheetTag)actionSheetTag withPoints:(NSUInteger)points;

-(void)toggleRackGoOut:(BOOL)goOut completion:(void (^)(void))completion;
-(void)toggleTopBarGoOut:(BOOL)goOut completion:(void(^)(void))completion;
-(void)toggleFieldActionInProgress:(BOOL)actionInProgress;

+(id)sharedMySceneWithSize:(CGSize)size;

@end

@protocol SceneDelegate <NSObject>

-(void)backToMainMenu;
-(void)stopActivityIndicator;
-(void)setUnchangingPlayerLabelProperties;
-(void)updatePlayerLabelsWithFinalTurn:(BOOL)finalTurn andAnimatedScore:(BOOL)animated;
-(void)barOrRackLabel:(SceneVCLabel)sceneLabel show:(BOOL)show toFade:(BOOL)toFade withText:(NSString *)text andColour:(UIColor *)colour;

-(void)animateTopBarLabelsGoOut:(BOOL)goOut;
-(void)animateReplayLabelGoOut:(BOOL)goOut;
-(void)animatePnPLabelGoOut:(BOOL)goOut;
-(void)animateScoreLabelFlash:(UILabel *)scoreLabel;
-(void)showChordMessage:(NSString *)message sign:(ChordMessageSign)sign;
-(void)fadeChordMessage;

-(void)presentFromSceneOptionsVC;
-(void)presentFromSceneGameEndedVC;

@end