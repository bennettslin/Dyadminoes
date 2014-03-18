//
//  ViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/20/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"

@interface ViewController ()

@property (strong, nonatomic) MyScene *myScene;

@end

@implementation ViewController {
  UIDeviceOrientation _deviceOrientation;
}

-(void)viewDidLoad {
  [super viewDidLoad];

    // log device orientation for now
  [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
}

-(void)orientationChanged:(NSNotification *)note {
  UIDevice *device = note.object;
  switch (device.orientation) {
    case UIDeviceOrientationPortrait:
      break;
    case UIDeviceOrientationLandscapeLeft:
      break;
    case UIDeviceOrientationLandscapeRight:
      break;
    case UIDeviceOrientationPortraitUpsideDown:
      break;
    case UIDeviceOrientationFaceDown:
      break;
    case UIDeviceOrientationFaceUp:
      break;
    case UIDeviceOrientationUnknown:
      break;
  }
  
}

-(BOOL)shouldAutorotate {
  return YES;
}

-(void)viewWillLayoutSubviews {
    // Configure the view.
  SKView * skView = (SKView *)self.view;
  
  skView.showsDrawCount = YES;
  skView.showsFPS = YES;
  skView.showsNodeCount = YES;
  
    // Create and configure the scene.
  self.myScene = [MyScene sceneWithSize:skView.bounds.size];
  self.myScene.scaleMode = SKSceneScaleModeAspectFill;

    // Present the scene.
  [skView presentScene:self.myScene];
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