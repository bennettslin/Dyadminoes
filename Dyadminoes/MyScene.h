//
//  MyScene.h
//  Dyadminoes
//

//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+Helper.h"
@class SceneViewController;
//@class SceneEngine;
@class Player;
@class Dyadmino;
@class Match;
@class SoundEngine;

@protocol SceneDelegate;

@interface MyScene : SKScene

@property (strong, nonatomic) SoundEngine *mySoundEngine;
//@property (strong, nonatomic) SceneEngine *mySceneEngine;
@property (strong, nonatomic) Match *myMatch;

@property (weak, nonatomic) id <SceneDelegate> myDelegate;

-(BOOL)loadAfterNewMatchRetrieved;
/*
-(void)handleDeviceOrientationChange:(UIDeviceOrientation)deviceOrientation;
 */
-(void)handlePinchGestureWithScale:(CGFloat)scale andVelocity:(CGFloat)velocity andLocation:(CGPoint)location;
-(BOOL)validatePinchLocation:(CGPoint)location;
-(void)tempStoreForPlayerSceneDataDyadminoes;
-(void)togglePCsUserShaken:(BOOL)userShaken;
-(void)handleUserWantsPivotGuides;
-(void)presentResignActionSheet;

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
-(void)showChordMessage:(NSAttributedString *)message sign:(ChordMessageSign)sign;
-(void)fadeChordMessage;

-(void)presentOptionsVC;

@end