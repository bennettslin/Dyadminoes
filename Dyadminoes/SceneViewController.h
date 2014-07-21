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

@protocol SceneViewDelegate;

@interface SceneViewController : UIViewController

@property (strong, nonatomic) MyScene *myScene;
@property (strong, nonatomic) Model *myModel;
@property (strong, nonatomic) Match *myMatch;
@property (strong, nonatomic) Player *myPlayer;
@property (weak, nonatomic) id <SceneViewDelegate> delegate;

@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGestureRecogniser;
@property (strong, nonatomic) UITapGestureRecognizer *doubleTapGestureRecogniser;

@end

@protocol SceneViewDelegate <NSObject>

-(void)stopActivityIndicator;
-(void)removeChildViewController:(UIViewController *)childVC;

@end