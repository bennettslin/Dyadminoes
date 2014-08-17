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
#import "CellBackgroundView.h"
#import "Player.h"

@interface SceneViewController () <SceneDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) SKView *mySceneView;

@end

@implementation SceneViewController {
  BOOL _pinchStillCounts;
}

-(void)viewDidLoad {
  [super viewDidLoad];
  
    // first version of app will not have device orientation
//  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveModel) name:UIApplicationDidEnterBackgroundNotification object:nil];

  [self instantiatePlayerLabels];
  [self instantiateBarAndRackLabels];
  [self createAndConfigureScene];
  [self setUpGestureRecognisers];
}

-(void)instantiatePlayerLabels {
  NSMutableArray *tempPlayerLabelsArray = [NSMutableArray new];
  NSMutableArray *tempPlayerLabelViewsArray = [NSMutableArray new];
  NSMutableArray *tempScoreLabelsArray = [NSMutableArray new];
  for (int i = 0; i < 4; i++) {
    [tempPlayerLabelsArray addObject:[[UILabel alloc] init]];
    [tempPlayerLabelViewsArray addObject:[[CellBackgroundView alloc] init]];
    [tempScoreLabelsArray addObject:[[UILabel alloc] init]];
  }
  self.playerLabelsArray = [NSArray arrayWithArray:tempPlayerLabelsArray];
  self.playerLabelViewsArray = [NSArray arrayWithArray:tempPlayerLabelViewsArray];
  self.scoreLabelsArray = [NSArray arrayWithArray:tempScoreLabelsArray];
}

-(void)instantiateBarAndRackLabels {
  
  self.topBarMessageLabel = [UILabel new];
  self.topBarMessageLabel.frame = CGRectMake(kTopBarGeneralLeftOffset, kTopBarHeight, self.view.frame.size.width, kScenePlayerLabelFontSize * 1.25);
  self.topBarMessageLabel.font = [UIFont fontWithName:kFontHarmony size:kScenePlayerLabelFontSize * 1.25];
  self.topBarMessageLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
  self.topBarMessageLabel.adjustsFontSizeToFitWidth = YES;
  [self.view addSubview:self.topBarMessageLabel];
//  self.topBarMessageLabel.hidden = YES;

  self.ReplayTurnLabel = [UILabel new];
  self.ReplayTurnLabel.frame = CGRectMake(kReplayXEdgeBuffer, kTopBarHeight * 0.05, self.view.frame.size.width - (kReplayXEdgeBuffer * 2), kTopBarHeight);
  self.ReplayTurnLabel.font = [UIFont fontWithName:kFontHarmony size:(kIsIPhone ? 24 : 48)];
  self.ReplayTurnLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
  self.ReplayTurnLabel.textAlignment = NSTextAlignmentCenter;
  self.ReplayTurnLabel.adjustsFontSizeToFitWidth = YES;
  [self.view addSubview:self.ReplayTurnLabel];
//  self.ReplayTurnLabel.hidden = YES;
  
  self.PnPWaitLabel = [UILabel new];
  self.PnPWaitLabel.frame = CGRectMake(kPnPXEdgeBuffer, self.view.frame.size.height - (kRackHeight * 0.95), self.view.frame.size.width - (kPnPXEdgeBuffer * 2) - kLargeButtonWidth - kPnPPaddingBetweenLabelAndButton, kRackHeight);
  self.PnPWaitLabel.font = [UIFont fontWithName:kFontHarmony size:(kIsIPhone ? 96 : 192)];
  self.PnPWaitLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
  self.PnPWaitLabel.textAlignment = NSTextAlignmentCenter;
  self.PnPWaitLabel.adjustsFontSizeToFitWidth = YES;
  [self.view addSubview:self.PnPWaitLabel];
//  self.PnPWaitLabel.hidden = YES;
}

-(void)barOrRackLabel:(SceneVCLabel)sceneLabel show:(BOOL)show toFade:(BOOL)toFade withText:(NSString *)text andColour:(UIColor *)colour {
  
  UILabel *label;
  switch (sceneLabel) {
    case kTopBarMessageLabel:
      label = self.topBarMessageLabel;
      break;
    case kPnPWaitLabel:
      label = self.PnPWaitLabel;
      break;
    case kReplayTurnLabel:
      label = self.ReplayTurnLabel;
      break;
  }
  
    // make animations later
  label.text = text;
  label.textColor = colour;
  
  label.hidden = !show;
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
//  NSLog(@"sceneVC view will appear");
  _pinchStillCounts = YES;
  
  self.topBarMessageLabel.frame = CGRectMake(kTopBarGeneralLeftOffset, kTopBarHeight, self.view.frame.size.width, kScenePlayerLabelFontSize * 1.25);
  
  CGFloat desiredPnPY = (self.myMatch.type == kPnPGame && !self.myMatch.gameHasEnded) ?
      self.view.frame.size.height - (kRackHeight * 0.95) :
      self.view.frame.size.height + (kRackHeight * 0.05);
  self.PnPWaitLabel.frame = CGRectMake(kPnPXEdgeBuffer, desiredPnPY, self.view.frame.size.width - (kPnPXEdgeBuffer * 2) - kLargeButtonWidth - kPnPPaddingBetweenLabelAndButton, kRackHeight);
  
  self.ReplayTurnLabel.frame = CGRectMake(kReplayXEdgeBuffer, -kTopBarHeight * 0.95, self.view.frame.size.width - (kReplayXEdgeBuffer * 2), kTopBarHeight);
}

-(void)createAndConfigureScene {
    // Configure the scene view
  self.mySceneView = (SKView *)self.view;
  self.mySceneView.showsDrawCount = YES;
  self.mySceneView.showsFPS = YES;
  self.mySceneView.showsNodeCount = YES;
  
  self.myScene.myMatch = self.myMatch;
  self.myScene.myDelegate = self;
  
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
}

-(void)setUnchangingPlayerLabelProperties {

  CGFloat playerLabelHeight = (kTopBarHeight - (kTopBarYEdgeBuffer * 2)) / self.myMatch.players.count;
  
  for (int i = 0; i < kMaxNumPlayers; i++) {
    UILabel *playerLabel = self.playerLabelsArray[i];
    CellBackgroundView *labelView = self.playerLabelViewsArray[i];
    UILabel *scoreLabel = self.scoreLabelsArray[i];
    
    [self.view addSubview:labelView];
    [self.view addSubview:playerLabel];
    [self.view addSubview:scoreLabel];

    playerLabel.font = [UIFont fontWithName:kFontModern size:kScenePlayerLabelHeight * 1.2];
    playerLabel.adjustsFontSizeToFitWidth = YES;
    playerLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    playerLabel.frame = CGRectMake(kTopBarGeneralLeftOffset, kTopBarYEdgeBuffer + playerLabelHeight * i, kScenePlayerLabelWidth, playerLabelHeight);

    scoreLabel.font = [UIFont fontWithName:kFontModern size:kScenePlayerLabelHeight];
    scoreLabel.adjustsFontSizeToFitWidth = YES;
    scoreLabel.textColor = [UIColor brownColor];
    scoreLabel.textAlignment = NSTextAlignmentRight;
    scoreLabel.frame = CGRectMake(kTopBarGeneralLeftOffset + kScenePlayerLabelWidth, kTopBarYEdgeBuffer + playerLabelHeight * i, kSceneScoreLabelWidth, playerLabelHeight);
    
    labelView.frame = CGRectMake(0, 0, kScenePlayerLabelWidth + kPlayerLabelWidthPadding + kSceneScoreLabelWidth, kScenePlayerLabelHeight * 1.2);
    labelView.center = CGPointMake(playerLabel.center.x + kSceneScoreLabelWidth / 2,
                                   playerLabel.center.y - (kCellRowHeight / 40.f));
    
    labelView.layer.cornerRadius = labelView.frame.size.height / 2.f;
    labelView.clipsToBounds = YES;
    [self.view insertSubview:labelView atIndex:0];
  }
}

-(void)updatePlayerLabelsWithFinalTurn:(BOOL)finalTurn andAnimatedScore:(BOOL)animated {
  if (self.myMatch) {
    
    Player *player;
    for (int i = 0; i < kMaxNumPlayers; i++) {
      player = (i < self.myMatch.players.count) ? self.myMatch.players[i] : nil;
      
      UILabel *playerLabel = self.playerLabelsArray[i];
      CellBackgroundView *labelView = self.playerLabelViewsArray[i];
      UILabel *scoreLabel = self.scoreLabelsArray[i];
      
        // static player colours, check if player resigned
        // player name updated here, just in case labels were instantiated afresh
      playerLabel.text = player ? player.playerName : @"";
      playerLabel.textColor = (player.resigned && self.myMatch.type != kSelfGame) ?
      kResignedGray : [self.myMatch colourForPlayer:player];
      
      NSString *scoreText;

      if (!player || (player.resigned && self.myMatch.type != kSelfGame)) {
        scoreText = @"";
        
      } else if (player == self.myMatch.currentPlayer && self.myMatch.tempScore > 0) {
        scoreText = [NSString stringWithFormat:@"%lu + %lu", (unsigned long)player.playerScore, (unsigned long)self.myMatch.tempScore];
        
      } else {
        scoreText = [NSString stringWithFormat:@"%lu", (unsigned long)player.playerScore];
      }
//      NSLog(@"scoreText is %@", scoreText);
      
        // FIXME: so that this is animated
        // score label
      if (player == self.myMatch.currentPlayer && (finalTurn || self.myMatch.tempScore > 0)) {
        
          // upon final turn, score is animated
        if (animated) {
          scoreLabel.text = scoreText;
        } else {
          scoreLabel.text = scoreText;
        }

      } else {
        scoreLabel.text = scoreText;
      }
      
        // background colours depending on match results
      labelView.backgroundColourCanBeChanged = YES;
      if (!self.myMatch.gameHasEnded && player == self.myMatch.currentPlayer) {
        labelView.backgroundColor = [kMainDarkerYellow colorWithAlphaComponent:0.5f];
      } else if (self.myMatch.gameHasEnded && [self.myMatch.wonPlayers containsObject:player]) {
        labelView.backgroundColor = [kEndedMatchCellDarkColour colorWithAlphaComponent:0.5f];
      } else {
        labelView.backgroundColor = [UIColor clearColor];
      }
      labelView.backgroundColourCanBeChanged = NO;
    }
  }
}

-(void)animateTopBarLabelsGoOut:(BOOL)goOut {
  
  
  
}

-(void)animateReplayLabelGoOut:(BOOL)goOut {
  
  CGFloat desiredY = goOut ? -kTopBarHeight * 0.95 : kTopBarHeight * 0.05;
  
  UIViewAnimationOptions option = goOut ? UIViewAnimationOptionCurveEaseIn : UIViewAnimationOptionCurveEaseOut;
  [UIView animateWithDuration:kConstantTime delay:0 options:option animations:^{
      self.ReplayTurnLabel.frame = CGRectMake(kReplayXEdgeBuffer, desiredY, self.view.frame.size.width - (kReplayXEdgeBuffer * 2), kTopBarHeight);
    } completion:nil];
}

-(void)animatePnPLabelGoOut:(BOOL)goOut {
  
  CGFloat desiredY = goOut ? self.view.frame.size.height + (kRackHeight * 0.05) :
      self.view.frame.size.height - (kRackHeight * 0.95);
  
  UIViewAnimationOptions option = goOut ? UIViewAnimationOptionCurveEaseIn : UIViewAnimationOptionCurveEaseOut;
  [UIView animateWithDuration:kConstantTime delay:0 options:option animations:^{
      self.PnPWaitLabel.frame = CGRectMake(kPnPXEdgeBuffer, desiredY, self.view.frame.size.width - (kPnPXEdgeBuffer * 2) - kLargeButtonWidth - kPnPPaddingBetweenLabelAndButton, kRackHeight);
    } completion:nil];
}

-(void)stopActivityIndicator {
  [self.delegate activityIndicatorStart:NO];
}

-(void)backToMainMenu {
  
  self.topBarMessageLabel.text = @"";
  self.PnPWaitLabel.text = @"";
  self.ReplayTurnLabel.text = @"";
  
  [self.delegate startAnimatingBackground];
  [self saveModel];
  [self.delegate rememberMostRecentMatch:self.myMatch];
  
  [self.mySceneView presentScene:nil];
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - event handling methods

-(void)setUpGestureRecognisers {
  self.pinchGestureRecogniser = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
  self.pinchGestureRecogniser.delegate = self;
  [self.mySceneView addGestureRecognizer:self.pinchGestureRecogniser];
}

-(void)pinched:(UIPinchGestureRecognizer *)sender {

    // verify that touches are on board
  if (sender.numberOfTouches > 1) {
    CGPoint location1 = [sender locationOfTouch:0 inView:self.view];
    CGPoint location2 = [sender locationOfTouch:1 inView:self.view];
    if (![self.myScene validatePinchLocation:location1] || ![self.myScene validatePinchLocation:location2]) {
      _pinchStillCounts = NO;
    }
  }
  
  if ([sender state] == UIGestureRecognizerStateEnded) {
    _pinchStillCounts = YES;
    
  } else if (_pinchStillCounts) {
    CGPoint midpointLocation = [sender locationInView:self.view];
    [self.myScene handlePinchGestureWithScale:sender.scale andVelocity:sender.velocity andLocation:midpointLocation];
  }
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
  if (motion == UIEventSubtypeMotionShake) {
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
  [self.myScene tempStoreForPlayerSceneDataDyadminoes];
  NSLog(@"saveModel");
  [Model saveMyModel:self.myModel];
}

#pragma mark - system methods

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
//  NSLog(@"scene VC did receive memory warning");
//  [self saveModel];
}

-(BOOL)prefersStatusBarHidden {
  return YES;
}

@end