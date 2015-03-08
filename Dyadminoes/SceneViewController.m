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
#import "CellBackgroundView.h"
#import "Player.h"
#import "OptionsViewController.h"
#import "HelpViewController.h"
#import "SettingsViewController.h"
#import "GameEndedViewController.h"

typedef enum chordMessageStatus {
  kAccidentalsNowhere,
  kAccidentalsFirstLine,
  kAccidentalsSecondLine,
  kAccidentalsBothLines
} ChordMessageStatus;

@interface SceneViewController () <SceneDelegate, UIGestureRecognizerDelegate, OptionsDelegate, GameEndedDelegate>

@property (strong, nonatomic) SKView *mySceneView;
@property (strong, nonatomic) UIView *playerLabelsField;
@property (strong, nonatomic) UIView *turnPileCountField;

@property (strong, nonatomic) OptionsViewController *optionsVC;
@property (strong, nonatomic) GameEndedViewController *gameEndedVC;

@property (nonatomic) CGFloat topBarPlayerLabelWidth;
@property (nonatomic) CGFloat topBarScoreLabelWidth;

@property (strong, nonatomic) UILabel *chordMessageLabel;
@property (strong, nonatomic) NSString *currentChordMessage;

@end

@implementation SceneViewController {
  BOOL _pinchStillCounts;
  CGFloat _widestPlayerLabelWidth;
}

@synthesize optionsVC = _optionsVC;
@synthesize gameEndedVC = _gameEndedVC;
@synthesize chordMessageLabel = _chordMessageLabel;

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
  self.currentChordMessage = nil;
}

-(void)createAndConfigureScene {
    // Configure the scene view
  self.mySceneView = (SKView *)self.view;
  self.mySceneView.showsDrawCount = YES;
  self.mySceneView.showsFPS = YES;
  self.mySceneView.showsNodeCount = YES;
  
  self.myScene.myMatch = self.myMatch;
  self.myScene.myDelegate = self;
  if (![self.myScene loadAfterNewMatchRetrievedForReset:NO]) {
    NSLog(@"New match not properly retrieved.");
    abort();
  }
  
  [self handleUserDefaults];
  
    //--------------------------------------------------------------------------
  
  [self.delegate setCellsShouldBeEditable:NO];
  [self.mySceneView presentScene:self.myScene];
  if (!self.mySceneView.scene) {
    NSLog(@"Scene was not properly presented.");
    abort();
  }
}

-(void)handleUserDefaults {
    // user defaults
    //--------------------------------------------------------------------------
  
    // ensure pcs are correct before presenting view
  PCMode userNotation = (PCMode)[[NSUserDefaults standardUserDefaults] integerForKey:@"notation"];
  SceneEngine *sceneEngine = [SceneEngine sharedSceneEngine];
  
  if (userNotation != sceneEngine.myPCMode) {
    [self.myScene togglePCsUserShaken:NO];
  }
  
    // pivot guide
  [self.myScene handleUserWantsPivotGuides];
  
    // volume
    //  [self.myScene handleUserWantsVolume];
}

#pragma mark - navigation methods

-(void)presentFromSceneOptionsVC {
  
  [self.myScene toggleFieldActionInProgress:YES];
  __weak typeof(self) weakSelf = self;
  void(^completion)(void) = ^void(void) {
    [weakSelf.myScene toggleFieldActionInProgress:NO];
  };
  
  [self.myScene toggleRackGoOut:YES completion:completion];
  [self.myScene toggleTopBarGoOut:YES completion:nil];
  
  [self presentChildViewController:self.optionsVC];
}

-(void)presentFromSceneGameEndedVC {
  
  [self.myScene toggleFieldActionInProgress:YES];
  __weak typeof(self) weakSelf = self;
  void(^completion)(void) = ^void(void) {
    [weakSelf.myScene toggleFieldActionInProgress:NO];
  };
  
  [self.myScene toggleRackGoOut:YES completion:completion];
  [self.myScene toggleTopBarGoOut:YES completion:nil];
  
  self.gameEndedVC.delegate = self;
  [self presentChildViewController:self.gameEndedVC];
}

-(void)presentFromOptionsChildViewController:(OptionsVCOptions)optionsNumber {
  switch (optionsNumber) {
    case kResignOption:
      [self backToParentViewWithAnimateRemoveVC:YES];
      [self.myScene presentActionSheet:kActionSheetResignPlayer withPoints:0];
      break;
    case kHelpOption:
      [self presentChildViewController:self.helpVC];
      break;
    case kSettingsOption:
      [self presentChildViewController:self.settingsVC];
      break;
    default:
      break;
  }
}

-(void)backToParentViewWithAnimateRemoveVC:(BOOL)animateRemoveVC {
  
  if (!self.vcIsAnimating && self.childVC && self.overlayEnabled) {
    if (animateRemoveVC) {
      
      [self.myScene toggleFieldActionInProgress:YES];
      __weak typeof(self) weakSelf = self;
      void(^completion)(void) = ^void(void) {
        [weakSelf.myScene toggleFieldActionInProgress:NO];
      };
      
      [self.myScene toggleRackGoOut:NO completion:completion];
      [self.myScene toggleTopBarGoOut:NO completion:nil];
    }
  }
  
  if (self.childVC == self.settingsVC) {
    [self handleUserDefaults];
  }
  
  self.currentChordMessage = nil;
  
  [super backToParentViewWithAnimateRemoveVC:animateRemoveVC];
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
  
//  self.soundedChordLabel = [UILabel new];
//  self.soundedChordLabel.font = [UIFont fontWithName:kFontHarmony size:kSceneMessageLabelFontSize];
//  self.soundedChordLabel.textAlignment = NSTextAlignmentLeft;
//  self.soundedChordLabel.adjustsFontSizeToFitWidth = YES;
//  self.soundedChordLabel.layer.borderColor = [UIColor redColor].CGColor;
//  self.soundedChordLabel.layer.borderWidth = 2.f;
//  self.soundedChordLabel.layer.borderColor = [UIColor redColor].CGColor;
//  self.soundedChordLabel.layer.borderWidth = 2.f;
//
//  [self.view insertSubview:self.soundedChordLabel aboveSubview:self.playerLabelsField];
  
//  self.lastTurnLabel = [UILabel new];
//  self.lastTurnLabel.font = [UIFont fontWithName:kFontHarmony size:kSceneMessageLabelFontSize];
//  self.lastTurnLabel.textAlignment = NSTextAlignmentRight;
//  self.lastTurnLabel.adjustsFontSizeToFitWidth = YES;
//  [self.view insertSubview:self.lastTurnLabel aboveSubview:self.playerLabelsField];
  
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
  
    // frames
  self.turnLabel.frame = CGRectMake(self.view.bounds.size.width - kTopBarXEdgeBuffer - kTopBarTurnPileLabelsWidth, kTopBarYEdgeBuffer, kTopBarTurnPileLabelsWidth, kSceneLabelFontSize * 1.25);
  
  self.pileCountLabel.frame = CGRectMake(self.view.bounds.size.width - kTopBarXEdgeBuffer - kTopBarTurnPileLabelsWidth, kTopBarYEdgeBuffer + kSceneLabelFontSize, kTopBarTurnPileLabelsWidth, kSceneLabelFontSize * 1.25);
  
//  CGFloat messageLabelWidth = (kButtonWidth * 5) + kTopBarPaddingBetweenStuff + kTopBarTurnPileLabelsWidth;
  
//  self.soundedChordLabel.frame = CGRectMake(kTopBarXEdgeBuffer, kTopBarHeight, messageLabelWidth, kSceneMessageLabelFontSize);
  
//  self.lastTurnLabel.frame = CGRectMake(self.view.bounds.size.width - messageLabelWidth - kTopBarXEdgeBuffer, kTopBarHeight, messageLabelWidth, kSceneMessageLabelFontSize);
  
  CGFloat desiredPnPY = ([self.myMatch returnType] == kPnPGame && ![self.myMatch returnGameHasEnded]) ?
  self.view.bounds.size.height - (kRackHeight * 0.95) :
  self.view.bounds.size.height + (kRackHeight * 0.05);
  self.pnpWaitingLabel.frame = CGRectMake(kPnPXEdgeBuffer, desiredPnPY, self.view.bounds.size.width - (kPnPXEdgeBuffer * 2) - kLargeButtonWidth - kPnPPaddingBetweenLabelAndButton, kRackHeight);
  
  self.replayTurnLabel.frame = CGRectMake(kReplayXEdgeBuffer, -kTopBarHeight * 0.95, self.view.frame.size.width - (kReplayXEdgeBuffer * 2), kTopBarHeight);
}

#pragma mark - label data methods

-(void)setUnchangingPlayerLabelProperties {
  
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
    playerLabel.font = [UIFont fontWithName:kFontModern size:playerLabelHeight];
    playerLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    
    UIColor *borderColour;
    if ([player returnResigned] && [self.myMatch returnType] != kSelfGame) {
      playerLabel.textColor = kResignedGray;
    } else if (player == [self.myMatch returnCurrentPlayer] && ![self.myMatch returnGameHasEnded]) {
        //        playerLabel.textColor = [self.myMatch colourForPlayer:player forLabel:NO light:YES];
      playerLabel.textColor = [UIColor whiteColor];
//      borderColour = [self.myMatch colourForPlayer:player forLabel:YES light:NO];
      borderColour = kPianoBlack;
    } else {
      playerLabel.textColor = [self.myMatch colourForPlayer:player forLabel:YES light:NO];
      borderColour = kPianoBlack;
    }
    
    if (player) {
      NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:player.name];
      [mutableString addAttributes:@{NSStrokeWidthAttributeName: [NSNumber numberWithFloat:-(playerLabelHeight / 30)],
                                     NSStrokeColorAttributeName:borderColour} range:NSMakeRange(0, mutableString.length)];
      playerLabel.attributedText = mutableString;
    } else {
      playerLabel.text = @"";
    }
    
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
  
  [self updatePlayerLabelsWithFinalTurn:NO andAnimatedScore:NO];
}

-(void)updatePlayerLabelsWithFinalTurn:(BOOL)finalTurn andAnimatedScore:(BOOL)animated {
  
  NSUInteger pointsForThisTurnChords = [self.myMatch pointsForAllChordsThisTurn];
  
    // not DRY, repeats above
    // if less than four players, divide in three; otherwise divide in four
    // slightly larger than topBarHeight
  
    // this entire method is not DRY
  
  CGFloat playerLabelHeight = (kIsIPhone || self.myMatch.players.count < 4) ?
  (kTopBarHeight * 1.12 - (kTopBarYEdgeBuffer)) / 3 :
  (kTopBarHeight * 1.12 - (kTopBarYEdgeBuffer)) / 4;
  
  if (self.myMatch) {
    
    Player *player;
    for (int i = 0; i < kMaxNumPlayers; i++) {
      player = (i < self.myMatch.players.count) ? [self.myMatch playerForIndex:i]: nil;
      
      UILabel *playerLabel = self.playerLabelsArray[i];
      UILabel *scoreLabel = self.scoreLabelsArray[i];
      
        // colour changes if player resigned
      
      UIColor *borderColour;
      if ([player returnResigned] && [self.myMatch returnType] != kSelfGame) {
        playerLabel.textColor = kResignedGray;
      } else if (player == [self.myMatch returnCurrentPlayer] && ![self.myMatch returnGameHasEnded]) {
//        playerLabel.textColor = [self.myMatch colourForPlayer:player forLabel:NO light:YES];
        playerLabel.textColor = [UIColor whiteColor];
//        borderColour = [self.myMatch colourForPlayer:player forLabel:YES light:NO];
        borderColour = kPianoBlack;
      } else {
        playerLabel.textColor = [self.myMatch colourForPlayer:player forLabel:YES light:NO];
        borderColour = kPianoBlack;
      }

      if (player) {
        NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:player.name];
        [mutableString addAttributes:@{NSStrokeWidthAttributeName: [NSNumber numberWithFloat:-(playerLabelHeight / 30)],
                                       NSStrokeColorAttributeName:borderColour} range:NSMakeRange(0, mutableString.length)];
        playerLabel.attributedText = mutableString;
      } else {
        playerLabel.text = @"";
      }

      
      NSString *scoreText;
      
      if (!player || ([player returnResigned] && [self.myMatch returnType] != kSelfGame)) {
        scoreText = @"";
      } else if (player == [self.myMatch returnCurrentPlayer] && pointsForThisTurnChords > 0) {
        scoreText = [NSString stringWithFormat:@" %lu +%lu", (unsigned long)[player returnScore], (unsigned long)pointsForThisTurnChords];
      } else {
        scoreText = [NSString stringWithFormat:@" %lu", (unsigned long)[player returnScore]];
      }
      
      NSMutableAttributedString *mutableScoreString = [[NSMutableAttributedString alloc] initWithString:scoreText];
      [mutableScoreString addAttributes:@{NSStrokeWidthAttributeName: [NSNumber numberWithFloat:-(playerLabelHeight / 30)],
                                     NSStrokeColorAttributeName:borderColour} range:NSMakeRange(0, mutableScoreString.length)];
      
      if ([self.myMatch returnGameHasEnded]) {
        scoreLabel.textColor = [player returnWon] ? kScoreWonGold : kScoreLostGray;
      } else {
        scoreLabel.textColor = (player == [self.myMatch returnCurrentPlayer]) ? kScoreLightBrown : kScoreNormalBrown;
      }
      
        // FIXME: so that this is animated
        // score label
      if (player == [self.myMatch returnCurrentPlayer] && (finalTurn || pointsForThisTurnChords > 0)) {
        
          // upon final turn, score is animated
        if (animated) {
          scoreLabel.attributedText = mutableScoreString;
        } else {
          scoreLabel.attributedText = mutableScoreString;
        }
        
      } else {
        scoreLabel.attributedText = mutableScoreString;
      }
      
        // background colours depending on match results
      self.labelView.backgroundColourCanBeChanged = YES;
      if ([self.myMatch returnGameHasEnded]) {
        self.labelView.hidden = YES;
      } else {
        if (player == [self.myMatch returnCurrentPlayer]) {
          
          CGFloat labelWidthPadding = _topBarScoreLabelWidth / 4; // not the best way to set it, but oh well
          CGFloat labelWidth = kTopBarXEdgeBuffer + _widestPlayerLabelWidth + _topBarScoreLabelWidth + labelWidthPadding;
          self.labelView.frame = CGRectMake(0, 0, labelWidth, playerLabel.frame.size.height * 1.12);
          self.labelView.center = CGPointMake(kTopBarXEdgeBuffer + (_widestPlayerLabelWidth + _topBarScoreLabelWidth) / 2,
                                              playerLabel.center.y - (playerLabel.frame.size.height / 20.f));
          
          self.labelView.layer.cornerRadius = self.labelView.frame.size.height / 2.f;
          self.labelView.clipsToBounds = YES;
//          self.labelView.layer.borderColor = kMainDarkerYellow.CGColor;
//          self.labelView.layer.borderWidth = self.labelView.frame.size.height * 0.05f;
          UIColor *labelColour = [self.myMatch colourForPlayer:player forLabel:NO light:NO];
          [self addGradientToView:self.labelView WithColour:labelColour andUpsideDown:YES];
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
//    case kLastTurnLabel:
//      label = self.lastTurnLabel;
//      break;
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
    default:
      return;
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

-(void)showChordMessage:(NSString *)message sign:(ChordMessageSign)sign autoFade:(BOOL)autoFade {
  
  if ([message isEqualToString:self.currentChordMessage]) {
    return;
  }
  
//  message = @"Can't break B minor seventh and D(#)/E(b) diminished triadj.";
  
  if (self.chordMessageLabel) {
    UILabel *oldChordMessageLabel = self.chordMessageLabel;
    self.chordMessageLabel = nil;
    [self fadeChordMessage:oldChordMessageLabel withScroll:YES];
  }
  
  self.currentChordMessage = message;
  
  UIColor *labelColour;
  switch (sign) {
    case kChordMessageGood:
      labelColour = kChordGoodGreen;
      break;
    case kChordMessageNeutral:
      labelColour = kChordNeutralGray;
      break;
    case kChordMessageBad:
      labelColour = kChordBadRed;
      break;
    default:
      break;
  }
  
    // figure out if string is too long
  NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
  CGSize labelSize = (CGSize){self.chordMessageLabel.frame.size.width, CGFLOAT_MAX};
  
  CGRect rect = [message boundingRectWithSize:labelSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName: [UIFont fontWithName:kFontModern size:kChordMessageLabelFontSize]}
                                         context:context];
  
  self.chordMessageLabel.frame = CGRectMake(kTopBarXEdgeBuffer, self.view.bounds.size.height - kRackHeight - kChordMessageLabelHeight, self.view.bounds.size.width - (kTopBarXEdgeBuffer * 2), kChordMessageLabelHeight);
  self.chordMessageLabel.numberOfLines = 1;

    // if string is too long, divide into two lines
  if (rect.size.height > self.chordMessageLabel.frame.size.height) {
    
    self.chordMessageLabel.numberOfLines = 2;
    
    BOOL lineBroken = NO;
    NSInteger counterUp = message.length / 2;
    
    NSMutableString *mutableString = [NSMutableString stringWithString:message];
    while (!lineBroken && counterUp < message.length && ((NSInteger)message.length - counterUp) >= 0) {
      
      if ([message characterAtIndex:counterUp] == 0x0020) {
        [mutableString replaceCharactersInRange:NSMakeRange(counterUp, 1) withString:@"\n"];
        lineBroken = YES;
        
      } else if ([message characterAtIndex:(message.length - counterUp)] == 0x0020) {
        [mutableString replaceCharactersInRange:NSMakeRange((message.length - counterUp), 1) withString:@"\n"];
        lineBroken = YES;
      }

      counterUp++;
    }
    
    message = [NSString stringWithString:mutableString];
  }
  
    // add bold outline
  NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:@""];
  [mutableAttributedString appendAttributedString:[self stringWithAccidentals:message fontSize:kChordMessageLabelFontSize]];
  [mutableAttributedString addAttributes:@{NSStrokeWidthAttributeName: [NSNumber numberWithFloat:-(kChordMessageLabelFontSize / 30)],
                                           NSStrokeColorAttributeName:kPianoBlack,
                                           NSForegroundColorAttributeName:labelColour} range:NSMakeRange(0, mutableAttributedString.length)];
  
  
  if (self.chordMessageLabel.numberOfLines == 2) {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 0;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
      // ensures that accidentals, with their baseline offsets, are accommodated
    ChordMessageStatus messageStatus = [self chordMessageStatusOfString:[self stringWithPoundsAndYen:message]];
    if (messageStatus == kAccidentalsFirstLine) {
      self.chordMessageLabel.frame = CGRectMake(kTopBarXEdgeBuffer,
                                                self.view.bounds.size.height - kRackHeight - (kChordMessageLabelHeight * 2.2),
                                                self.view.bounds.size.width - (kTopBarXEdgeBuffer * 2), kChordMessageLabelHeight * 4);
      paragraphStyle.maximumLineHeight = kChordMessageLabelFontSize / 12;
      
    } else if (messageStatus == kAccidentalsSecondLine) {
      self.chordMessageLabel.frame = CGRectMake(kTopBarXEdgeBuffer,
                                                self.view.bounds.size.height - kRackHeight - (kChordMessageLabelHeight * 2.6),
                                                self.view.bounds.size.width - (kTopBarXEdgeBuffer * 2), kChordMessageLabelHeight * 4);
      paragraphStyle.maximumLineHeight = kChordMessageLabelFontSize * 2;
      
    } else if (messageStatus == kAccidentalsBothLines) {
      self.chordMessageLabel.frame = CGRectMake(kTopBarXEdgeBuffer,
                                                self.view.bounds.size.height - kRackHeight - (kChordMessageLabelHeight * 2.2),
                                                self.view.bounds.size.width - (kTopBarXEdgeBuffer * 2), kChordMessageLabelHeight * 4);
      paragraphStyle.maximumLineHeight = kChordMessageLabelFontSize;
      
    } else if (messageStatus == kAccidentalsNowhere) {
      self.chordMessageLabel.frame = CGRectMake(kTopBarXEdgeBuffer,
                                                self.view.bounds.size.height - kRackHeight - (kChordMessageLabelHeight * 2.9),
                                                self.view.bounds.size.width - (kTopBarXEdgeBuffer * 2), kChordMessageLabelHeight * 4);
      paragraphStyle.maximumLineHeight = kChordMessageLabelFontSize;
    }
    
    [mutableAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, mutableAttributedString.length)];
  }
  
  UILabel *chordMessageLabel = self.chordMessageLabel;
  chordMessageLabel.alpha = 0.f;
  chordMessageLabel.attributedText = mutableAttributedString;
  [UIView animateWithDuration:kConstantTime * 0.2f animations:^{
    chordMessageLabel.alpha = 1.f;
  } completion:^(BOOL finished) {
    
    if (autoFade) {
      
      [UIView animateWithDuration:0.001f delay:5.f options:0 animations:^{
        chordMessageLabel.alpha = 0.999f;
      } completion:^(BOOL finished) {
        
          // finished bool ensures that completion block is not called if animation is cancelled
        if (finished) {
          [self fadeChordMessage:chordMessageLabel withScroll:YES];
        }
      }];
    }
  }];
}

#pragma mark - label animation methods

-(void)fadeChordMessage {
  UILabel *oldChordMessageLabel = self.chordMessageLabel;
  self.chordMessageLabel = nil;
  [self fadeChordMessage:oldChordMessageLabel withScroll:NO];
}

-(void)fadeChordMessage:(UILabel *)messageLabel withScroll:(BOOL)scroll {
  
  [messageLabel.layer removeAllAnimations];
  self.currentChordMessage = nil;
    
  [UIView animateWithDuration:kConstantTime * 0.7f animations:^{
    if (scroll) {
      messageLabel.frame = CGRectMake(messageLabel.frame.origin.x, messageLabel.frame.origin.y - kChordMessageLabelHeight, messageLabel.frame.size.width, messageLabel.frame.size.height);
    }
    messageLabel.alpha = 0.f;
    
  } completion:^(BOOL finished) {
    messageLabel.text = @"";
    messageLabel.numberOfLines = 1;
    messageLabel.frame = CGRectMake(kTopBarXEdgeBuffer, self.view.bounds.size.height - kRackHeight - kChordMessageLabelHeight, self.view.bounds.size.width - (kTopBarXEdgeBuffer * 2), kChordMessageLabelHeight);
    messageLabel.alpha = 1.f;
  }];
}

-(void)slideAnimateView:(UIView *)movingView toDestinationXPosition:(CGFloat)xPosition durationConstant:(CGFloat)constant {
  
  CGFloat originalXPosition = movingView.frame.origin.x;
  CGFloat excessXPosition = ((xPosition - originalXPosition) / kBounceDivisor) + xPosition;
  
  [UIView animateWithDuration:(constant * 0.7f) delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    movingView.frame = CGRectMake(excessXPosition, movingView.frame.origin.y, movingView.frame.size.width, movingView.frame.size.height);
  } completion:^(BOOL finished) {
    
    [UIView animateWithDuration:(constant * 0.3f) delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
      movingView.frame = CGRectMake(xPosition, movingView.frame.origin.y, movingView.frame.size.width, movingView.frame.size.height);
    } completion:nil];
  }];
}

-(void)animateTopBarLabelsGoOut:(BOOL)goOut {
  
  CGFloat desiredPlayerLabelsX = goOut ? -(kTopBarXEdgeBuffer + _widestPlayerLabelWidth + _topBarScoreLabelWidth + _topBarScoreLabelWidth / 4 + kTopBarPaddingBetweenStuff) : 0;
  
  [self slideAnimateView:self.playerLabelsField toDestinationXPosition:desiredPlayerLabelsX durationConstant:kConstantTime];
  
//  CGFloat messageLabelWidth = (kButtonWidth * 5) + kTopBarPaddingBetweenStuff + kTopBarTurnPileLabelsWidth;
  
//  CGFloat desiredLastTurnLabelX = goOut ? self.view.frame.size.width : self.view.frame.size.width - messageLabelWidth - kTopBarXEdgeBuffer;
  
//  [self slideAnimateView:self.lastTurnLabel toDestinationXPosition:desiredLastTurnLabelX durationConstant:kConstantTime];
  
  CGFloat desiredTurnPileLabelsX = goOut ? kTopBarXEdgeBuffer + kTopBarTurnPileLabelsWidth : 0;
  
  [self slideAnimateView:self.turnPileCountField toDestinationXPosition:desiredTurnPileLabelsX durationConstant:kConstantTime];
}

-(void)animateReplayLabelGoOut:(BOOL)goOut {
  
  CGFloat desiredY = goOut ? -kTopBarHeight * 0.95 : kTopBarHeight * 0.05;
  [self slideAnimateView:self.replayTurnLabel toDestinationYPosition:desiredY durationConstant:kConstantTime];
}

-(void)animatePnPLabelGoOut:(BOOL)goOut {
  
  CGFloat desiredY = goOut ? self.view.frame.size.height + (kRackHeight * 0.05) :
      self.view.frame.size.height - (kRackHeight * 0.95);
  
  [self slideAnimateView:self.pnpWaitingLabel toDestinationYPosition:desiredY durationConstant:kConstantTime];
}

-(void)animateScoreLabelFlash:(UILabel *)scoreLabel {
  
}

#pragma mark - label helper methods

-(ChordMessageStatus)chordMessageStatusOfString:(NSString *)string {
  
  BOOL accidentalsInFirstLine = NO;
  BOOL accidentalsInSecondLine = NO;
  BOOL inSecondLine = NO;
  
  for (int i = 0; i < string.length; i++) {
    unichar myChar = [string characterAtIndex:i];
    if (myChar == (unichar)163 || myChar == (unichar)165) {
      if (!inSecondLine) {
        accidentalsInFirstLine = YES;
      } else {
        accidentalsInSecondLine = YES;
      }
    } else if (myChar == 0x000a) {
      inSecondLine = YES;
    }
  }
  
  if (inSecondLine) {
    if (accidentalsInFirstLine && accidentalsInSecondLine) {
      return kAccidentalsBothLines;
    } else if (accidentalsInFirstLine) {
      return kAccidentalsFirstLine;
    } else if (accidentalsInSecondLine) {
      return kAccidentalsSecondLine;
    } else {
      NSLog(@"in second line, no accidentals");
      return kAccidentalsNowhere;
    }
  } else {
    NSLog(@"not in second line, no accidentals");
    return kAccidentalsNowhere;
  }
}

-(NSString *)stringWithPoundsAndYen:(NSString *)myString {
    // first replace all instances of (#) and (b) with pound and yen characters
  unichar pound[1] = {(unichar)163};
  unichar yen[1] = {(unichar)165};
  
  myString = [myString stringByReplacingOccurrencesOfString:@"(#)" withString:[NSString stringWithCharacters:pound length:1]];
  myString = [myString stringByReplacingOccurrencesOfString:@"(b)" withString:[NSString stringWithCharacters:yen length:1]];
  
  return myString;
}

-(NSAttributedString *)stringWithAccidentals:(NSString *)myString fontSize:(CGFloat)size {
  
  myString = [self stringWithPoundsAndYen:myString];
  
  NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:myString];
  
  for (int i = 0; i < myString.length; i++) {
    unichar myChar = [myString characterAtIndex:i];
    
    if (myChar == (unichar)163) {
      [attString replaceCharactersInRange:NSMakeRange(i, 1) withString:[self stringForMusicSymbol:kSymbolSharp]];
      [attString addAttribute:NSBaselineOffsetAttributeName value:@(size / 2.75) range:NSMakeRange(i, 1)]; // was size / 2.75
      [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontSonata size:size * 0.95f] range:NSMakeRange(i, 1)];
      
    } else if (myChar == (unichar)165) {
      [attString replaceCharactersInRange:NSMakeRange(i, 1) withString:[self stringForMusicSymbol:kSymbolFlat]];
      [attString addAttribute:NSBaselineOffsetAttributeName value:@(size / 5.4) range:NSMakeRange(i, 1)]; // was size / 5.4
      [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontSonata size:size * 1.15f] range:NSMakeRange(i, 1)];
      
    } else if (myChar == (unichar)36) { // dollar sign turns into bullet
      [attString replaceCharactersInRange:NSMakeRange(i, 1) withString:[self stringForMusicSymbol:kSymbolBullet]];
        //      [attString addAttribute:NSKernAttributeName value:@(-size * .05) range:NSMakeRange(i, 1)];
    }
  }
  
  return attString;
}

#pragma mark - mainVC methods

-(void)stopActivityIndicator {
  [self.delegate activityIndicatorStart:NO];
}

-(void)backToMainMenu {
  
//  self.lastTurnLabel.text = @"";
  self.pnpWaitingLabel.text = @"";
  self.replayTurnLabel.text = @"";
  
  [self.delegate startAnimatingBackground];
  [self.delegate setCellsShouldBeEditable:YES];
  [self saveManagedObjectContext];
  [self.delegate rememberMostRecentMatch:self.myMatch];
  [self.delegate reloadTable];
  
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

#pragma mark - accessor methods

-(void)setOptionsVC:(OptionsViewController *)optionsVC {
  _optionsVC = optionsVC;
}

-(OptionsViewController *)optionsVC {
  if (!_optionsVC) {
    _optionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OptionsViewController"];
    _optionsVC.delegate = self;
  }
  return _optionsVC;
}

-(void)setGameEndedVC:(GameEndedViewController *)gameEndedVC {
  _gameEndedVC = gameEndedVC;
}

-(GameEndedViewController *)gameEndedVC {
  if (!_gameEndedVC) {
    _gameEndedVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GameEndedViewController"];
  }
  return _gameEndedVC;
}

-(void)setChordMessageLabel:(UILabel *)chordMessageLabel {
  _chordMessageLabel = chordMessageLabel;
}

-(UILabel *)chordMessageLabel {
  if (!_chordMessageLabel) {
    _chordMessageLabel = [UILabel new];
    _chordMessageLabel.textColor = [UIColor whiteColor];
    _chordMessageLabel.font = [UIFont fontWithName:kFontModern size:kChordMessageLabelFontSize];
    _chordMessageLabel.textAlignment = NSTextAlignmentCenter;
    _chordMessageLabel.adjustsFontSizeToFitWidth = YES;
    _chordMessageLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    
    [self.view addSubview:_chordMessageLabel];
    _chordMessageLabel.frame = CGRectMake(kTopBarXEdgeBuffer, self.view.bounds.size.height - kRackHeight - kChordMessageLabelHeight, self.view.bounds.size.width - (kTopBarXEdgeBuffer * 2), kChordMessageLabelHeight);
  }
  return _chordMessageLabel;
}

#pragma mark - delegate methods

-(NSString *)resignText {
  return [self.myMatch returnType] == kSelfGame ?
  @"End game" : @"Resign";
}

-(NSString *)endGameResultsText {
  return [self.myMatch endGameResultsText];
}

#pragma mark - system methods

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end