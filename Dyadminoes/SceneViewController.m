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
#import "Match.h"
#import "Model.h"

@interface SceneViewController () <SceneDelegate>

@property (strong, nonatomic) SKView *mySceneView;
@property (strong, nonatomic) MyScene *myScene;

@end

@implementation SceneViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveModel) name:UIApplicationDidEnterBackgroundNotification object:nil];
  
    /// this seems to work better for scene transitions
    /// but does it get screwed up with different screen dimensions?
  [self createAndConfigureScene];
}

-(void)saveModel {
  NSLog(@"persisting all scene dyadminoes on returning to main menu");
  [self.myScene persistAllSceneDataDyadminoes];
  NSLog(@"saveModel");
  [Model saveMyModel:self.myModel];
}

-(void)createAndConfigureScene {
    // Configure the scene view
  self.mySceneView = (SKView *)self.view;
  
  self.mySceneView.showsDrawCount = YES;
  self.mySceneView.showsFPS = YES;
  self.mySceneView.showsNodeCount = YES;
  
    // Create and configure the scene
  self.myScene = [MyScene sceneWithSize:self.mySceneView.bounds.size];
  self.myScene.scaleMode = SKSceneScaleModeAspectFill;
  self.myScene.myMatch = self.myMatch;
//  self.myScene.myPlayer = self.myPlayer;
  self.myScene.delegate = self;
  [self.myScene preLoad];
  NSLog(@"about to present scene");
  [self.mySceneView presentScene:self.myScene];
  NSLog(@"scene presented");
}

-(void)backToMainMenu {
  [self saveModel];
  [self.mySceneView presentScene:nil];
  [self dismissViewControllerAnimated:YES completion:nil];
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

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

@end