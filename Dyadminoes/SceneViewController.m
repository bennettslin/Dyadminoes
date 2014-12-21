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
//#import "Model.h"
#import "CellBackgroundView.h"
#import "Player.h"

@interface SceneViewController () <SceneDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) SKView *mySceneView;
@property (strong, nonatomic) UIView *playerLabelsField;
@property (strong, nonatomic) UIView *turnPileCountField;

@property (nonatomic) CGFloat topBarPlayerLabelWidth;
@property (nonatomic) CGFloat topBarScoreLabelWidth;

@end

@implementation SceneViewController {
  BOOL _pinchStillCounts;
  CGFloat _widestPlayerLabelWidth;
}

-(void)setTopBarPlayerLabelWidth:(CGFloat)topBarPlayerLabelWidth {
  _topBarPlayerLabelWidth = topBarPlayerLabelWidth;
  _topBarScoreLabelWidth = topBarPlayerLabelWidth / 3;
}

-(void)viewDidLoad {
  [super viewDidLoad];
  
    // first version of app will not have device orientation
//  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveManagedObjectContext) name:UIApplicationDidEnterBackgroundNotification object:nil];

  [self instantiateFields];
  [self instantiatePlayerLabels];
  [self instantiateBarAndRackLabels];
  [self createAndConfigureScene];
  [self setUpGestureRecognisers];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  _pinchStillCounts = YES;
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
//  [self.myScene handleUserWantsVolume];
  
    //--------------------------------------------------------------------------
  
  [self.mySceneView presentScene:self.myScene];
}

#pragma mark - label instantiation methods

-(void)instantiateFields {
  CGRect playerLabelsFrame = CGRectMake(0, (kIsIPhone ? kTopBarHeight - kTopBarYEdgeBuffer : 0),
                                        self.view.bounds.size.width, self.view.bounds.size.height);
  self.playerLabelsField = [[UIView alloc] initWithFrame:playerLabelsFrame];
  [self.view addSubview:self.playerLabelsField];
  
  CGRect turnPileCountFrame = CGRectMake(0, (kIsIPhone ? kTopBarHeight - kTopBarYEdgeBuffer : 0),
                                         self.view.bounds.size.width, self.view.bounds.size.height);
  self.turnPileCountField = [[UIView alloc] initWithFrame:turnPileCountFrame];
  [self.view addSubview:self.turnPileCountField];
}

-(void)instantiatePlayerLabels {
  NSMutableArray *tempPlayerLabelsArray = [NSMutableArray arrayWithCapacity:kMaxNumPlayers];
  NSMutableArray *tempScoreLabelsArray = [NSMutableArray arrayWithCapacity:kMaxNumPlayers];
  for (int i = 0; i < kMaxNumPlayers; i++) {
    [tempPlayerLabelsArray addObject:[[UILabel alloc] init]];
    [tempScoreLabelsArray addObject:[[UILabel alloc] init]];
  }
  self.playerLabelsArray = [NSArray arrayWithArray:tempPlayerLabelsArray];
  self.scoreLabelsArray = [NSArray arrayWithArray:tempScoreLabelsArray];
  
  self.labelView = [[CellBackgroundView alloc] init];
}

-(void)instantiateBarAndRackLabels {
  
  self.turnLabel = [UILabel new];
  self.turnLabel.font = [UIFont fontWithName:kFontHarmony size:kSceneLabelFontSize];
  self.turnLabel.adjustsFontSizeToFitWidth = YES;
  self.turnLabel.textAlignment = NSTextAlignmentRight;
  [self.turnPileCountField addSubview:self.turnLabel];
  
  self.pileCountLabel = [UILabel new];
  self.pileCountLabel.font = [UIFont fontWithName:kFontHarmony size:kSceneLabelFontSize];
  self.pileCountLabel.adjustsFontSizeToFitWidth = YES;
  self.pileCountLabel.textAlignment = NSTextAlignmentRight;
  [self.turnPileCountField addSubview:self.pileCountLabel];
  
  self.lastTurnLabel = [UILabel new];
  self.lastTurnLabel.font = [UIFont fontWithName:kFontHarmony size:kSceneMessageLabelFontSize];
  self.lastTurnLabel.textAlignment = NSTextAlignmentRight;
  self.lastTurnLabel.adjustsFontSizeToFitWidth = YES;
  [self.view insertSubview:self.lastTurnLabel aboveSubview:self.playerLabelsField];
  
  self.replayTurnLabel = [UILabel new];
  self.replayTurnLabel.font = [UIFont fontWithName:kFontHarmony size:(kIsIPhone ? 24 : 48)];
  self.replayTurnLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
  self.replayTurnLabel.textAlignment = NSTextAlignmentCenter;
  self.replayTurnLabel.adjustsFontSizeToFitWidth = YES;
  [self.view addSubview:self.replayTurnLabel];
  
  self.pnpWaitingLabel = [UILabel new];
  self.pnpWaitingLabel.textColor = [UIColor whiteColor];
  self.pnpWaitingLabel.font = [UIFont fontWithName:kFontHarmony size:(kIsIPhone ? 96 : 192)];
  self.pnpWaitingLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
  self.pnpWaitingLabel.textAlignment = NSTextAlignmentCenter;
  self.pnpWaitingLabel.adjustsFontSizeToFitWidth = YES;
  self.pnpWaitingLabel.numberOfLines = kIsIPhone ? 2 : 1;
  [self.view addSubview:self.pnpWaitingLabel];
  
  self.chordMessageLabel = [UILabel new];
  self.chordMessageLabel.textColor = [UIColor whiteColor];
  self.chordMessageLabel.font = [UIFont fontWithName:kFontModern size:kChordMessageLabelHeight];
  self.chordMessageLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
  self.chordMessageLabel.textAlignment = NSTextAlignmentCenter;
  self.chordMessageLabel.adjustsFontSizeToFitWidth = YES;
  self.chordMessageLabel.numberOfLines = kIsIPhone ? 2 : 1;
  self.chordMessageLabel.layer.borderWidth = 1.f;
  self.chordMessageLabel.layer.borderColor = [UIColor redColor].CGColor;
  [self.view addSubview:self.chordMessageLabel];
  
    // frames
  self.turnLabel.frame = CGRectMake(self.view.bounds.size.width - kTopBarXEdgeBuffer - kTopBarTurnPileLabelsWidth, kTopBarYEdgeBuffer, kTopBarTurnPileLabelsWidth, kSceneLabelFontSize * 1.25);
  
  self.pileCountLabel.frame = CGRectMake(self.view.bounds.size.width - kTopBarXEdgeBuffer - kTopBarTurnPileLabelsWidth, kTopBarYEdgeBuffer + kSceneLabelFontSize, kTopBarTurnPileLabelsWidth, kSceneLabelFontSize * 1.25);
  
  CGFloat messageLabelWidth = (kButtonWidth * 5) + kTopBarPaddingBetweenStuff + kTopBarTurnPileLabelsWidth;
  self.lastTurnLabel.frame = CGRectMake(self.view.bounds.size.width - messageLabelWidth - kTopBarXEdgeBuffer, kTopBarHeight, messageLabelWidth, kSceneMessageLabelFontSize);
  
  CGFloat desiredPnPY = ([self.myMatch returnType] == kPnPGame && ![self.myMatch returnGameHasEnded]) ?
  self.view.bounds.size.height - (kRackHeight * 0.95) :
  self.view.bounds.size.height + (kRackHeight * 0.05);
  self.pnpWaitingLabel.frame = CGRectMake(kPnPXEdgeBuffer, desiredPnPY, self.view.bounds.size.width - (kPnPXEdgeBuffer * 2) - kLargeButtonWidth - kPnPPaddingBetweenLabelAndButton, kRackHeight);
  
  self.replayTurnLabel.frame = CGRectMake(kReplayXEdgeBuffer, -kTopBarHeight * 0.95, self.view.frame.size.width - (kReplayXEdgeBuffer * 2), kTopBarHeight);
  
  self.chordMessageLabel.frame = CGRectMake(kTopBarXEdgeBuffer, self.view.bounds.size.height - kRackHeight - kChordMessageLabelHeight, self.view.bounds.size.width - (kTopBarXEdgeBuffer * 2), kChordMessageLabelHeight);
}

#pragma mark - label data methods

-(void)setUnchangingPlayerLabelProperties {
  
//  self.keySigLabel.text = [self.myMatch keySigString];
  
  self.topBarPlayerLabelWidth = kIsIPhone ?
      self.view.bounds.size.width / 3 :
      ((self.view.bounds.size.width - (kTopBarXEdgeBuffer * 2) - kTopBarTurnPileLabelsWidth - (kButtonWidth * 5) - (kTopBarPaddingBetweenStuff * 2)) * 0.75);
  
  _widestPlayerLabelWidth = 0;
  
    // if less than four players, divide in three; otherwise divide in four
    // slightly larger than topBarHeight
  CGFloat playerLabelHeight = (kIsIPhone || self.myMatch.players.count < 4) ?
      (kTopBarHeight * 1.12 - (kTopBarYEdgeBuffer)) / 3 :
      (kTopBarHeight * 1.12 - (kTopBarYEdgeBuffer)) / 4;
  
  for (int i = 0; i < kMaxNumPlayers; i++) {
    
    Player *player = (i < self.myMatch.players.count) ? [self.myMatch playerForIndex:i] : nil;
    UILabel *playerLabel = self.playerLabelsArray[i];
    UILabel *scoreLabel = self.scoreLabelsArray[i];
    
    [self.playerLabelsField addSubview:playerLabel];
    [self.playerLabelsField addSubview:scoreLabel];
    
      // player labels----------------------------------------------------------
    playerLabel.frame = CGRectMake(kTopBarXEdgeBuffer, kTopBarYEdgeBuffer + (playerLabelHeight) * i, _topBarPlayerLabelWidth, playerLabelHeight);
    playerLabel.text = player ? player.playerName : @"";
    playerLabel.font = [UIFont fontWithName:kFontModern size:playerLabelHeight];
    playerLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    playerLabel.adjustsFontSizeToFitWidth = YES;
    [playerLabel sizeToFit];
    
    CGFloat adjustedPlayerLabelWidth = (playerLabel.frame.size.width > _topBarPlayerLabelWidth) ?
        _topBarPlayerLabelWidth : playerLabel.frame.size.width;
    playerLabel.frame = CGRectMake(kTopBarXEdgeBuffer, kTopBarYEdgeBuffer + (playerLabelHeight) * i, adjustedPlayerLabelWidth, playerLabelHeight);
    
    if (playerLabel.frame.size.width > _widestPlayerLabelWidth) {
      _widestPlayerLabelWidth = playerLabel.frame.size.width;
    }
    
    scoreLabel.font = [UIFont fontWithName:kFontModern size:playerLabelHeight * 0.9];
    scoreLabel.adjustsFontSizeToFitWidth = YES;
    scoreLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    scoreLabel.textAlignment = NSTextAlignmentRight;
  }
  
    // scoreLabel frame depends on how longest playerLabel width
  for (int i = 0; i < self.myMatch.players.count; i++) {
    UILabel *scoreLabel = self.scoreLabelsArray[i];
    UILabel *playerLabel = self.playerLabelsArray[i];
    scoreLabel.frame = CGRectMake(kTopBarXEdgeBuffer + _widestPlayerLabelWidth,
                                  kTopBarYEdgeBuffer + (playerLabel.frame.size.height * i * 1.025),
                                  _topBarScoreLabelWidth, playerLabel.frame.size.height);
  }
}

-(void)updatePlayerLabelsWithFinalTurn:(BOOL)finalTurn andAnimatedScore:(BOOL)animated {
  
  if (self.myMatch) {
    
    Player *player;
    for (int i = 0; i < kMaxNumPlayers; i++) {
      player = (i < self.myMatch.players.count) ? [self.myMatch playerForIndex:i]: nil;
      
      UILabel *playerLabel = self.playerLabelsArray[i];
      UILabel *scoreLabel = self.scoreLabelsArray[i];
      
        // colour changes if player resigned
      playerLabel.textColor = ([player returnResigned] && [self.myMatch returnType] != kSelfGame) ?
          kResignedGray : [self.myMatch colourForPlayer:player];
      
      NSString *scoreText;
      
      if (!player || ([player returnResigned] && [self.myMatch returnType] != kSelfGame)) {
        scoreText = @"";
      } else if (player == [self.myMatch returnCurrentPlayer] && [self.myMatch returnTempScore] > 0) {
        scoreText = [NSString stringWithFormat:@"%lu + %lu", (unsigned long)[player returnPlayerScore], (unsigned long)[self.myMatch returnTempScore]];
      } else {
        scoreText = [NSString stringWithFormat:@"%lu", (unsigned long)[player returnPlayerScore]];
      }
      
      if ([self.myMatch returnGameHasEnded]) {
        scoreLabel.textColor = [player returnWon] ? kScoreWonGold : kScoreLostGray;
      } else {
        scoreLabel.textColor = kScoreNormalBrown;
      }
      
        // FIXME: so that this is animated
        // score label
      if (player == [self.myMatch returnCurrentPlayer] && (finalTurn || [self.myMatch returnTempScore] > 0)) {
        
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
      self.labelView.backgroundColourCanBeChanged = YES;
      if ([self.myMatch returnGameHasEnded]) {
        self.labelView.backgroundColor = [UIColor clearColor];
        
      } else {
        if (player == [self.myMatch returnCurrentPlayer]) {
          self.labelView.backgroundColor = [kMainDarkerYellow colorWithAlphaComponent:0.8f];
          
          CGFloat labelWidthPadding = _topBarScoreLabelWidth / 4; // not the best way to set it, but oh well
          CGFloat labelWidth = kTopBarXEdgeBuffer + _widestPlayerLabelWidth + _topBarScoreLabelWidth + labelWidthPadding;
          self.labelView.frame = CGRectMake(0, 0, labelWidth, playerLabel.frame.size.height * 1.12);
          self.labelView.center = CGPointMake(kTopBarXEdgeBuffer + (_widestPlayerLabelWidth + _topBarScoreLabelWidth) / 2,
                                              playerLabel.center.y - (playerLabel.frame.size.height / 20.f));
          
          self.labelView.layer.cornerRadius = self.labelView.frame.size.height / 2.f;
          self.labelView.clipsToBounds = YES;
          [self.playerLabelsField insertSubview:self.labelView atIndex:0];
        }
      }
      self.labelView.backgroundColourCanBeChanged = NO;
    }
  }
}

-(void)barOrRackLabel:(SceneVCLabel)sceneLabel show:(BOOL)show toFade:(BOOL)toFade withText:(NSString *)text andColour:(UIColor *)colour {
  
  UILabel *label;
  switch (sceneLabel) {
    case kLastTurnLabel:
      label = self.lastTurnLabel;
      break;
    case kPnPWaitingLabel:
      label = self.pnpWaitingLabel;
      break;
    case kReplayTurnLabel:
      label = self.replayTurnLabel;
      break;
    case kTopBarTurnLabel:
      label = self.turnLabel;
      break;
    case kTopBarPileCountLabel:
      label = self.pileCountLabel;
      break;
  }
  
    // make animations later
  label.text = text;
  label.textColor = colour;
  
  if (toFade) {
    
    [label.layer removeAllAnimations];
    label.hidden = NO;
    label.alpha = 0.f;
    
    [UIView animateWithDuration:2.f delay:0.f options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAutoreverse animations:^{
      label.alpha = 1.f;
    } completion:^(BOOL finished) {
      label.alpha = 0.f;
    }];

  } else {
    label.hidden = !show;
  }
}

-(void)showChordMessage:(NSAttributedString *)message sign:(ChordMessageSign)sign {
  self.chordMessageLabel.attributedText = message;
  UIColor *labelColour;
  switch (sign) {
    case kChordMessageGood:
      labelColour = [UIColor greenColor];
      break;
    case kChordMessageNeutral:
      labelColour = [UIColor whiteColor];
      break;
    case kChordMessageBad:
      labelColour = [UIColor redColor];
      break;
    default:
      break;
  }
  
  self.chordMessageLabel.textColor = labelColour;
}

-(void)fadeChordMessage {
  self.chordMessageLabel.text = @"";
}

#pragma mark - label animation methods

-(void)animateTopBarLabelsGoOut:(BOOL)goOut {
  
    // _topBarScoreLabelWidth / 4 is labelView padding
  CGFloat desiredPlayerLabelsX = goOut ? -(kTopBarXEdgeBuffer + _widestPlayerLabelWidth + _topBarScoreLabelWidth + _topBarScoreLabelWidth / 4 + kTopBarPaddingBetweenStuff) : 0;
  UIViewAnimationOptions option = goOut ?
  UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState :
  UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState;
  [UIView animateWithDuration:kConstantTime - 0.05 delay:0.05 options:option animations:^{
    self.playerLabelsField.frame = CGRectMake(desiredPlayerLabelsX, (kIsIPhone ? kTopBarHeight - kTopBarYEdgeBuffer : 0), self.view.frame.size.width, self.view.frame.size.height);
  } completion:nil];
  
  CGFloat messageLabelWidth = (kButtonWidth * 5) + kTopBarPaddingBetweenStuff + kTopBarTurnPileLabelsWidth;
  CGFloat desiredMessageLabelX = goOut ? self.view.frame.size.width : self.view.frame.size.width - messageLabelWidth - kTopBarXEdgeBuffer;
  
  [UIView animateWithDuration:kConstantTime delay:0 options:option animations:^{
  self.lastTurnLabel.frame = CGRectMake(desiredMessageLabelX, kTopBarHeight, messageLabelWidth, kSceneMessageLabelFontSize);
  } completion:nil];
  
  CGFloat desiredTurnPileLabelsX = goOut ? kTopBarXEdgeBuffer + kTopBarTurnPileLabelsWidth : 0;
  [UIView animateWithDuration:kConstantTime delay:0 options:option animations:^{
    self.turnPileCountField.frame = CGRectMake(desiredTurnPileLabelsX, (kIsIPhone ? kTopBarHeight - kTopBarYEdgeBuffer : 0), self.view.frame.size.width, self.view.frame.size.height);
  } completion:nil];
}

-(void)animateReplayLabelGoOut:(BOOL)goOut {
  
  CGFloat desiredY = goOut ? -kTopBarHeight * 0.95 : kTopBarHeight * 0.05;
  
  UIViewAnimationOptions option = goOut ? UIViewAnimationOptionCurveEaseIn : UIViewAnimationOptionCurveEaseOut;
  [UIView animateWithDuration:kConstantTime delay:0 options:option animations:^{
      self.replayTurnLabel.frame = CGRectMake(kReplayXEdgeBuffer, desiredY, self.view.frame.size.width - (kReplayXEdgeBuffer * 2), kTopBarHeight);
    } completion:nil];
}

-(void)animatePnPLabelGoOut:(BOOL)goOut {
  
  CGFloat desiredY = goOut ? self.view.frame.size.height + (kRackHeight * 0.05) :
      self.view.frame.size.height - (kRackHeight * 0.95);
  
  UIViewAnimationOptions option = goOut ? UIViewAnimationOptionCurveEaseIn : UIViewAnimationOptionCurveEaseOut;
  [UIView animateWithDuration:kConstantTime delay:0 options:option animations:^{
      self.pnpWaitingLabel.frame = CGRectMake(kPnPXEdgeBuffer, desiredY, self.view.frame.size.width - (kPnPXEdgeBuffer * 2) - kLargeButtonWidth - kPnPPaddingBetweenLabelAndButton, kRackHeight);
    } completion:nil];
}

-(void)animateScoreLabelFlash:(UILabel *)scoreLabel {
  
}

#pragma mark - mainVC methods

-(void)stopActivityIndicator {
  [self.delegate activityIndicatorStart:NO];
}

-(void)backToMainMenu {
  
  self.lastTurnLabel.text = @"";
  self.pnpWaitingLabel.text = @"";
  self.replayTurnLabel.text = @"";
  
  [self.delegate startAnimatingBackground];
  [self saveManagedObjectContext];
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

-(void)saveManagedObjectContext {
  NSError *error = nil;
  if (![self.managedObjectContext save:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
}

#pragma mark - system methods

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

-(BOOL)prefersStatusBarHidden {
  return YES;
}

-(void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end