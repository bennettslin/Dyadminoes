//
//  ViewController.h
//  Dyadminoes
//

//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
@class Model;
@class Match;
@class Player;
@class MyScene;
//@class MyPinchGestureRecognizer;

@protocol SceneViewDelegate;

@interface SceneViewController : UIViewController

@property (strong, nonatomic) MyScene *myScene;
@property (strong, nonatomic) Model *myModel;
@property (strong, nonatomic) Match *myMatch;

@property (weak, nonatomic) id <SceneViewDelegate> delegate;

@property (strong, nonatomic) NSArray *playerLabelsArray;
@property (strong, nonatomic) NSArray *playerLabelViewsArray;
@property (strong, nonatomic) NSArray *scoreLabelsArray;

@property (strong, nonatomic) UILabel *pileCountLabel;
@property (strong, nonatomic) UILabel *turnLabel;
@property (strong, nonatomic) UILabel *topBarMessageLabel;
@property (strong, nonatomic) UILabel *PnPWaitLabel;
@property (strong, nonatomic) UILabel *ReplayTurnLabel;

@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGestureRecogniser;

@end

@protocol SceneViewDelegate <NSObject>

-(void)activityIndicatorStart:(BOOL)start;
-(void)removeChildViewController:(UIViewController *)childVC;
-(void)startAnimatingBackground;
-(void)rememberMostRecentMatch:(Match *)match;

@end