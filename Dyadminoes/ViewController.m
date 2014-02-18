//
//  ViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/20/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"
#import "Pile.h"
#import "Dyadmino.h"

@interface ViewController () <KnowledgeOfPileDelegate>

@end

@implementation ViewController

-(void)viewDidLoad {
  [super viewDidLoad];

  self.pile = [[Pile alloc] init];

  for (Dyadmino *dyadmino in self.pile.dyadminoesInPlayer1Rack) {
  }
}

-(NSMutableArray *)returnPlayer1Rack {
  return self.pile.dyadminoesInPlayer1Rack;
}

-(BOOL)shouldAutorotate {
  return YES;
}

-(void)viewWillLayoutSubviews {
    // Configure the view.
  SKView * skView = (SKView *)self.view;
  skView.showsFPS = YES;
  skView.showsNodeCount = YES;
  
    // Create and configure the scene.
  MyScene * scene = [MyScene sceneWithSize:skView.bounds.size];
  scene.scaleMode = SKSceneScaleModeAspectFill;
  scene.delegate = self;
    // Present the scene.
  [skView presentScene:scene];
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