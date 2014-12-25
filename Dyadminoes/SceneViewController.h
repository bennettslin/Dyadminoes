//
//  ViewController.h
//  Dyadminoes
//

//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <CoreData/CoreData.h>
#import "ParentViewController.h"

@class Match;
@class Player;
@class MyScene;
@class CellBackgroundView;

@protocol SceneViewDelegate;

@interface SceneViewController : ParentViewController

@property (strong, nonatomic) MyScene *myScene;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Match *myMatch;

@property (weak, nonatomic) id <SceneViewDelegate> delegate;

@property (strong, nonatomic) NSArray *playerLabelsArray;
@property (strong, nonatomic) NSArray *scoreLabelsArray;
@property (strong, nonatomic) CellBackgroundView *labelView;

@property (strong, nonatomic) UILabel *pileCountLabel;
@property (strong, nonatomic) UILabel *turnLabel;

@property (strong, nonatomic) UILabel *lastTurnLabel;
@property (strong, nonatomic) UILabel *pnpWaitingLabel;
@property (strong, nonatomic) UILabel *replayTurnLabel;
@property (strong, nonatomic) UILabel *chordMessageLabel;

@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGestureRecogniser;

@end

@protocol SceneViewDelegate <NSObject>

@property (assign, nonatomic) BOOL cellsShouldBeEditable;

-(void)activityIndicatorStart:(BOOL)start;
-(void)removeChildViewController:(UIViewController *)childVC;
-(void)startAnimatingBackground;
-(void)rememberMostRecentMatch:(Match *)match;
-(void)reloadTable;

@end