//
//  ViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/20/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "SceneViewController.h"
#import "NSObject+Helper.h"
#import "MyScene.h"
#import "SceneEngine.h"
#import "Match.h"
#import "Model.h"

@interface SceneViewController () <SceneDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) SKView *mySceneView;

@end

@implementation SceneViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
    // first version will not have device orientation
  /*
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
  */
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveModel) name:UIApplicationDidEnterBackgroundNotification object:nil];

  [self createAndConfigureScene];
  [self setUpGestureRecogniser];
}

-(void)createAndConfigureScene {
    // Configure the scene view
  self.mySceneView = (SKView *)self.view;
  
  self.mySceneView.showsDrawCount = YES;
  self.mySceneView.showsFPS = YES;
  self.mySceneView.showsNodeCount = YES;
  
  self.myScene.myMatch = self.myMatch;
  self.myScene.delegate = self;
  
  [self.myScene loadAfterNewMatchRetrieved];
  
    // user defaults
    //--------------------------------------------------------------------------
  
    // ensure pcs are correct before presenting view
  NSInteger userNotation = [[NSUserDefaults standardUserDefaults] integerForKey:@"notation"];
  if ((userNotation == 1 && self.myScene.mySceneEngine.myPCMode == kPCModeLetter) ||
      (userNotation == 0 && self.myScene.mySceneEngine.myPCMode == kPCModeNumber)) {
    [self.myScene togglePCsUserShaken:NO];
  }
  
    // pivot guide
  [self.myScene handleUserWantsPivotGuides];
  
    // volume
  [self.myScene handleUserWantsVolume];
  
    //--------------------------------------------------------------------------
  
  [self.mySceneView presentScene:self.myScene];
  [self.delegate stopActivityIndicator];
//  [self.delegate removeChildViewController:nil]; // if nil, removes self.childVC
//  NSLog(@"scene presented");
}

-(void)backToMainMenu {
  [self saveModel];
  [self.mySceneView presentScene:nil];
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - event handling methods

-(void)setUpGestureRecogniser {
  UIPinchGestureRecognizer *pinchGestureRecogniser = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
  pinchGestureRecogniser.delegate = self;
  [self.mySceneView addGestureRecognizer:pinchGestureRecogniser];
}

-(void)pinched:(UIPinchGestureRecognizer *)sender {
  [self.myScene handlePinchGestureWithScale:sender.scale andVelocity:sender.velocity];
}

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
  if (motion == UIEventSubtypeMotionShake) {
//    NSLog(@"began motion is %d", motion);
  }
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
  if (motion == UIEventSubtypeMotionShake) {
//    NSLog(@"ended motion is %d", motion);
    [self.myScene togglePCsUserShaken:YES];
  }
}

-(void)orientationChanged:(NSNotification *)note {
  UIDevice *device = note.object;
  [self.myScene handleDeviceOrientationChange:device.orientation];
}

-(BOOL)shouldAutorotate {
  return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return UIInterfaceOrientationMaskAllButUpsideDown;
  } else {
    return UIInterfaceOrientationMaskAll;
  }
}

#pragma mark - model methods

-(void)saveModel {
  [self.myScene persistAllSceneDataDyadminoes];
  NSLog(@"saveModel");
  [Model saveMyModel:self.myModel];
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  NSLog(@"scene VC did receive memory warning");
  [self saveModel];
  // Release any cached data, images, etc that aren't in use.
}

@end