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

@interface SceneViewController () <SceneDelegate>

@property (strong, nonatomic) UIView *mainView;

@property (strong, nonatomic) SKView *mySceneView;
@property (strong, nonatomic) MyScene *myScene;

@property (strong, nonatomic) UIView *titleLogo;
@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UIButton *soloGameButton;
@property (strong, nonatomic) UIButton *passNPlayButton;
@property (strong, nonatomic) UIButton *gameCenterMatchButton;

@property (strong, nonatomic) UIButton *helpButton;
@property (strong, nonatomic) UIButton *storeButton;
@property (strong, nonatomic) UIButton *leaderboardButton;
@property (strong, nonatomic) UIButton *optionsButton;
@property (strong, nonatomic) UIButton *aboutButton;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation SceneViewController {
  UIDeviceOrientation _deviceOrientation;
}

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.mainView = [[SKView alloc] init];
  self.mainView.backgroundColor = [UIColor brownColor];
  self.mainView.frame = self.view.frame;
  
    // for title logo and text
  CGRect titleFrame;
  UIFont *titleFont;
  if (kIsIPhone) {
    titleFrame = CGRectMake(50, 50, 250, 50);
    titleFont = [UIFont fontWithName:@"AmericanTypewriter" size:20];
  } else { // kIsIPad
    titleFrame = CGRectMake(100, 50, 600, 100);
    titleFont = [UIFont fontWithName:@"AmericanTypewriter" size:40];
  }
  
  self.titleLogo = [[UIView alloc] initWithFrame:titleFrame];
  self.titleLogo.backgroundColor = [UIColor blueColor];
  [self.mainView addSubview:self.titleLogo];
  
  self.titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
  self.titleLabel.font = titleFont;
  self.titleLabel.text = @"Dyadminoes";
  self.titleLabel.textAlignment = NSTextAlignmentCenter;
  self.titleLabel.textColor = [UIColor whiteColor];
  [self.mainView addSubview:self.titleLabel];
  
    //--------------------------------------------------------------------------
  
  CGFloat buttonSide, betweenBuffer, buttonYHeight, buttonFontSize;
  if (kIsIPhone) {
    buttonSide = 75.f;
    betweenBuffer = 25.f;
    buttonYHeight = 120.f;
    buttonFontSize = 12.f;
    
  } else { // kIsIPad
    buttonSide = 150.f;
    betweenBuffer = 75.f;
    buttonYHeight = 200.f;
    buttonFontSize = 20.f;
  }
  
  self.soloGameButton = [[UIButton alloc] init];
  self.passNPlayButton = [[UIButton alloc] init];
  self.gameCenterMatchButton = [[UIButton alloc] init];
  
  self.soloGameButton.frame = CGRectMake(betweenBuffer, buttonYHeight, buttonSide, buttonSide);
  self.passNPlayButton.frame = CGRectMake(betweenBuffer*2 + buttonSide, buttonYHeight, buttonSide, buttonSide);
  self.gameCenterMatchButton.frame = CGRectMake(betweenBuffer*3 + buttonSide*2, buttonYHeight, buttonSide, buttonSide);
  
  [self.soloGameButton setTitle:@"soloGame" forState:UIControlStateNormal];
  [self.passNPlayButton setTitle:@"passNPlay" forState:UIControlStateNormal];
  [self.gameCenterMatchButton setTitle:@"gameCenter" forState:UIControlStateNormal];
  
  [self.soloGameButton.titleLabel setFont:[UIFont systemFontOfSize:buttonFontSize]];
  [self.passNPlayButton.titleLabel setFont:[UIFont systemFontOfSize:buttonFontSize]];
  [self.gameCenterMatchButton.titleLabel setFont:[UIFont systemFontOfSize:buttonFontSize]];
  
  self.soloGameButton.tag = kSoloGameButton;
  self.passNPlayButton.tag = kPassNPlayButton;
  self.gameCenterMatchButton.tag = kGameCenterMatchButton;
  
  self.soloGameButton.backgroundColor = [UIColor orangeColor];
  self.passNPlayButton.backgroundColor = [UIColor yellowColor];
  self.gameCenterMatchButton.backgroundColor = [UIColor greenColor];
  
  [self.soloGameButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
  [self.passNPlayButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
  [self.gameCenterMatchButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
  
  [self.mainView addSubview:self.soloGameButton];
  [self.mainView addSubview:self.passNPlayButton];
  [self.mainView addSubview:self.gameCenterMatchButton];
  
    //--------------------------------------------------------------------------
  
  CGFloat smallButtonSide, smallBetweenBuffer, smallButtonYHeight, smallButtonFontSize;
  if (kIsIPhone) {
    smallButtonSide = 50.f;
    smallBetweenBuffer = 10.f;
    smallButtonYHeight = self.view.frame.size.height - 100.f;
    smallButtonFontSize = 10.f;
    
  } else { // kIsIPad
    smallButtonSide = 100.f;
    smallBetweenBuffer = 40.f;
    smallButtonYHeight = self.view.frame.size.height - 150.f;
    smallButtonFontSize = 16.f;
  }
  
  self.helpButton = [[UIButton alloc] init];
  self.storeButton = [[UIButton alloc] init];
  self.leaderboardButton = [[UIButton alloc] init];
  self.optionsButton = [[UIButton alloc] init];
  self.aboutButton = [[UIButton alloc] init];
  
  self.helpButton.frame = CGRectMake(smallBetweenBuffer, smallButtonYHeight, smallButtonSide, smallButtonSide);
  self.storeButton.frame = CGRectMake(smallBetweenBuffer*2 + smallButtonSide, smallButtonYHeight, smallButtonSide, smallButtonSide);
  self.leaderboardButton.frame = CGRectMake(smallBetweenBuffer*3 + smallButtonSide*2, smallButtonYHeight, smallButtonSide, smallButtonSide);
  self.optionsButton.frame = CGRectMake(smallBetweenBuffer*4 + smallButtonSide*3, smallButtonYHeight, smallButtonSide, smallButtonSide);
  self.aboutButton.frame = CGRectMake(smallBetweenBuffer*5 + smallButtonSide*4, smallButtonYHeight, smallButtonSide, smallButtonSide);
  
  [self.helpButton setTitle:@"help" forState:UIControlStateNormal];
  [self.storeButton setTitle:@"store" forState:UIControlStateNormal];
  [self.leaderboardButton setTitle:@"leaderboard" forState:UIControlStateNormal];
  [self.optionsButton setTitle:@"options" forState:UIControlStateNormal];
  [self.aboutButton setTitle:@"about" forState:UIControlStateNormal];
  
  [self.helpButton.titleLabel setFont:[UIFont systemFontOfSize:smallButtonFontSize]];
  [self.storeButton.titleLabel setFont:[UIFont systemFontOfSize:smallButtonFontSize]];
  [self.leaderboardButton.titleLabel setFont:[UIFont systemFontOfSize:smallButtonFontSize]];
  [self.optionsButton.titleLabel setFont:[UIFont systemFontOfSize:smallButtonFontSize]];
  [self.aboutButton.titleLabel setFont:[UIFont systemFontOfSize:smallButtonFontSize]];
  
  self.helpButton.tag = kHelpButton;
  self.storeButton.tag = kStoreButton;
  self.leaderboardButton.tag = kLeaderboardButton;
  self.optionsButton.tag = kOptionsButton;
  self.aboutButton.tag = kAboutButton;
  
  self.helpButton.backgroundColor = [UIColor redColor];
  self.storeButton.backgroundColor = [UIColor orangeColor];
  self.leaderboardButton.backgroundColor = [UIColor yellowColor];
  self.optionsButton.backgroundColor = [UIColor greenColor];
  self.aboutButton.backgroundColor = [UIColor blueColor];
  
  [self.helpButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
  [self.storeButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
  [self.leaderboardButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
  [self.optionsButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
  [self.aboutButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
  
  [self.mainView addSubview:self.helpButton];
  [self.mainView addSubview:self.storeButton];
  [self.mainView addSubview:self.leaderboardButton];
  [self.mainView addSubview:self.optionsButton];
  [self.mainView addSubview:self.aboutButton];
  
  [self.view addSubview:self.mainView];
  
  self.activityIndicator = [[UIActivityIndicatorView alloc] init];
  self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
  self.activityIndicator.frame = CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2, 100, 100);
  self.activityIndicator.center = self.view.center;
  [self.view addSubview:self.activityIndicator];
}

-(void)viewWillLayoutSubviews {
  
    // Configure the scene view
  self.mySceneView = (SKView *)self.view;
  
  self.mySceneView.showsDrawCount = YES;
  self.mySceneView.showsFPS = YES;
  self.mySceneView.showsNodeCount = YES;
  
    // Create and configure the scene
  self.myScene = [MyScene sceneWithSize:self.mySceneView.bounds.size];
  self.myScene.scaleMode = SKSceneScaleModeAspectFill;
    //  self.myScene.mySceneVC = self;
  self.myScene.delegate = self;
}

-(void)buttonPressed:(UIButton *)button {
  
  NSLog(@"%@ pressed", button.titleLabel.text);
  
  [self.activityIndicator startAnimating];
  
  if (button.tag == kSoloGameButton) {
    [self presentSceneViewControllerForSoloGame];
  }
}

-(void)presentMainView {
  [self.activityIndicator startAnimating];
  NSLog(@"mySceneView is nil");
  [self.mySceneView presentScene:nil];
  NSLog(@"mainView about to be added");
  [self.view addSubview:self.mainView];
  NSLog(@"mainView finished adding");
  [self.activityIndicator stopAnimating];
}

-(void)presentSceneViewControllerForSoloGame {
  
    // Present the scene.
//  self.mainView.hidden = YES;
  [self.mainView removeFromSuperview];
  [self.mySceneView presentScene:self.myScene];
  
  [self.activityIndicator stopAnimating];
  
//  SceneViewController *sceneVC = [[SceneViewController alloc] init];
//  [self presentViewController:sceneVC animated:YES completion:nil];
    //  [self.view addSubview:sceneVC.view];
    //  NSLog(@"added child view controller");
    //  [self addChildViewController:sceneVC];
    //  NSLog(@"did move to parent view controller");
    //  [sceneVC didMoveToParentViewController:self];
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