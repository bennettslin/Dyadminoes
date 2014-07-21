//
//  MainTableViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 5/19/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "MyScene.h"
#import "MatchesTableViewController.h"
#import "Model.h"
#import "NSObject+Helper.h"
#import "MatchTableViewCell.h"
#import "DebugViewController.h"
#import "SceneViewController.h"

#import "SoloViewController.h"
#import "PnPViewController.h"
#import "HelpViewController.h"
#import "StoreViewController.h"
#import "RankViewController.h"
#import "OptionsViewController.h"
#import "AboutViewController.h"

#import "Match.h"

#define kTableViewXMargin (kIsIPhone ? 20.f : 20.f)
#define kTableViewTopMargin (kIsIPhone ? 122.f : 122.f)
#define kTableViewBottomMargin (kIsIPhone ? 90.f : 90.f)
#define kMainTopBarHeight (kIsIPhone ? 64.f : 86.f)
#define kMainBottomBarHeight (kIsIPhone ? 64.f : 90.f)
#define kViewControllerSpeed 0.225f
#define kMainOverlayAlpha 0.6f

@interface MatchesTableViewController () <SceneViewDelegate, DebugDelegate, MatchCellDelegate, SoloDelegate, PnPDelegate>

@property (strong, nonatomic) Model *myModel;

@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;

@property (weak, nonatomic) IBOutlet UIButton *selfGameButton;
@property (weak, nonatomic) IBOutlet UIButton *PnPGameButton;
@property (weak, nonatomic) IBOutlet UIButton *GCGameButton;

@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIButton *storeButton;
@property (weak, nonatomic) IBOutlet UIButton *rankButton;
@property (weak, nonatomic) IBOutlet UIButton *optionsButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;

@property (strong, nonatomic) UIViewController *childVC;

@property (strong, nonatomic) UIButton *highlightedBottomButton;
@property (strong, nonatomic) UIButton *darkOverlay;
@property (nonatomic) BOOL vcIsAnimating;

@property (strong, nonatomic) SoloViewController *soloVC;
@property (strong, nonatomic) PnPViewController *pnpVC;
@property (strong, nonatomic) HelpViewController *helpVC;
@property (strong, nonatomic) StoreViewController *storeVC;
@property (strong, nonatomic) RankViewController *rankVC;
@property (strong, nonatomic) OptionsViewController *optionsVC;
@property (strong, nonatomic) AboutViewController *aboutVC;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) MyScene *myScene;

@end

@implementation MatchesTableViewController {
  CGFloat _screenWidth;
  CGFloat _screenHeight;
  BOOL _overlayEnabled;
}

-(void)viewDidLoad {
  
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"KeyboardBackground"]];
  self.tableView.layer.cornerRadius = kCornerRadius;
  self.tableView.clipsToBounds = YES;
  self.tableView.backgroundColor = [UIColor clearColor];
  
  self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  self.activityIndicator.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.8f];
  self.activityIndicator.frame = CGRectMake(0, 0, 150, 150);
  self.activityIndicator.layer.cornerRadius = kCornerRadius;
  self.activityIndicator.clipsToBounds = YES;
  self.activityIndicator.center = self.view.center;
  [self.view addSubview:self.activityIndicator];
  
  _screenWidth = [UIScreen mainScreen].bounds.size.width;
  _screenHeight = [UIScreen mainScreen].bounds.size.height;
  
  self.bottomBar.backgroundColor = kFieldPurple;
  [self addGradientToView:self.bottomBar WithColour:self.bottomBar.backgroundColor andUpsideDown:NO];
  self.topBar.backgroundColor = kDarkBlue;
  [self addGradientToView:self.topBar WithColour:self.topBar.backgroundColor andUpsideDown:YES];
  
  [self addShadowToView:self.topBar upsideDown:NO];
  [self addShadowToView:self.bottomBar upsideDown:YES];
  
  self.soloVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SoloViewController"];
  self.soloVC.view.backgroundColor = [UIColor lightGrayColor];
  self.soloVC.delegate = self;
  
  self.pnpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PnPViewController"];
  self.pnpVC.view.backgroundColor = [UIColor darkGrayColor];
  self.pnpVC.delegate = self;
  
  self.helpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
  self.helpVC.view.backgroundColor = [UIColor redColor];
  
  self.storeVC = [[StoreViewController alloc] init];
  self.storeVC.view.backgroundColor = [UIColor orangeColor];
  
  self.rankVC = [[RankViewController alloc] init];
  self.rankVC.view.backgroundColor = [UIColor yellowColor];
  
  self.optionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OptionsViewController"];
  self.optionsVC.view.backgroundColor = kPlayerGreen;
  
  self.aboutVC = [[AboutViewController alloc] init];
  self.aboutVC.view.backgroundColor = [UIColor blueColor];
  
  self.darkOverlay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
  [self.darkOverlay addTarget:self action:@selector(backToMatches) forControlEvents:UIControlEventTouchDown];
  self.vcIsAnimating = NO;
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;

      // Create and configure the scene
  self.myScene = [MyScene sceneWithSize:self.view.bounds.size];
  self.myScene.scaleMode = SKSceneScaleModeAspectFill;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getModel) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
  
  _overlayEnabled = YES;
  self.myModel = [Model getMyModel];
  if (!self.myModel) {
    self.myModel = [Model new];
    [self.myModel instantiateHardCodedMatchesForDebugPurposes];
  }
  
  [self.myModel sortMyMatches];
  [self.tableView reloadData];
}

#pragma mark - Table view delegate and data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.myModel.myMatches.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 90;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *CellIdentifier = @"matchCell";
  MatchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  cell.delegate = self;
  cell.myMatch = self.myModel.myMatches[indexPath.row];
  
  [cell setProperties];
  
  cell.accessoryType = UITableViewCellAccessoryNone;
  
  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//  [tableView deselectRowAtIndexPath:indexPath animated:YES];
//  NSLog(@"did select row at index path");
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  Match *match = self.myModel.myMatches[indexPath.row];
  if (match.gameHasEnded || match.type != kGCGame) {
    return YES;
  } else {
    return NO;
  }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    Match *match = self.myModel.myMatches[indexPath.row];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self removeMatch:match];
    [self.tableView endUpdates];
  }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
  return @"Remove game";
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
  NSUInteger rowNumber;
  if ([segue.identifier isEqualToString:@"sceneSegue"]) {
    NSLog(@"prepareForSegue called");
    [self startActivityIndicator];
    
    SceneViewController *sceneVC = [segue destinationViewController];
    sceneVC.myScene = self.myScene;

    if ([sender isKindOfClass:[Match class]]) { // sender is match
      rowNumber = [self.myModel.myMatches indexOfObject:sender];
    } else { // sender is tableView cell
      NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
      rowNumber = indexPath.row;
    }
    
    [self segue:segue ToMatchWithRowNumber:rowNumber];
  }
}

-(void)segue:(UIStoryboardSegue *)segue ToMatchWithRowNumber:(NSUInteger)rowNumber {
  Match *match = self.myModel.myMatches[rowNumber];

  SceneViewController *sceneVC = [segue destinationViewController];
  sceneVC.myModel = self.myModel;
  sceneVC.myMatch = match;
  sceneVC.delegate = self;
}

-(void)backToMatches {
  
  if (!self.vcIsAnimating && self.childVC && _overlayEnabled) {
    
    [self fadeOutOverlay];
    [self slideInTopBarAndBottomBar];
    [self slideInTableview];
    
    [self removeChildViewController:self.childVC];
    self.childVC = nil;
    
      // so that overlay doesn't register when user dismisses keyboard
  } else if (!_overlayEnabled) {
    if (self.childVC == self.soloVC) {
      [self.soloVC resignTextField];
    }
  }
}

-(void)presentChildViewController:(UIViewController *)childVC {
  
  self.vcIsAnimating = YES;
  if (self.childVC && self.childVC != childVC) {
    [self removeChildViewController:self.childVC];
  }
  self.childVC = childVC;
  
    // overlay fade in and tableview slide out go together
  if (![self.darkOverlay superview]) {
    [self fadeInOverlay];
    [self slideOutTopBarAndBottomBar];
    [self slideOutTableview];
  }
  
  CGFloat viewWidth = _screenWidth * 4 / 5;
  CGFloat viewHeight = _screenHeight * 4 / 5;
  
  childVC.view.frame = CGRectMake(0, 0, viewWidth, viewHeight);
  childVC.view.center = CGPointMake(self.view.center.x - _screenWidth, self.view.center.y);
  childVC.view.layer.cornerRadius = kCornerRadius;
  childVC.view.layer.masksToBounds = YES;

  [self.view addSubview:childVC.view];
  
  [UIView animateWithDuration:kViewControllerSpeed delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
    childVC.view.center = self.view.center;
  } completion:^(BOOL finished) {
    self.vcIsAnimating = NO;
  }];
  
  [self setNeedsStatusBarAppearanceUpdate];
}

-(void)removeChildViewController:(UIViewController *)childVC {
  
  [UIView animateWithDuration:kViewControllerSpeed delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    childVC.view.center = CGPointMake(self.view.center.x + _screenWidth, self.view.center.y);
  } completion:^(BOOL finished) {
    [childVC.view removeFromSuperview];
  }];
  
  [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - view animation methods

-(void)slideOutTopBarAndBottomBar {
  [UIView animateWithDuration:kViewControllerSpeed delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    self.topBar.frame = CGRectMake(0, -kMainTopBarHeight, _screenWidth, kMainTopBarHeight);
  } completion:^(BOOL finished) {
  }];
  [UIView animateWithDuration:kViewControllerSpeed delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    self.bottomBar.frame = CGRectMake(0, _screenHeight, _screenWidth, kMainBottomBarHeight);
  } completion:^(BOOL finished) {
  }];
}

-(void)slideInTopBarAndBottomBar {
  [UIView animateWithDuration:kViewControllerSpeed delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
    self.topBar.frame = CGRectMake(0, 0, _screenWidth, kMainTopBarHeight);
  } completion:^(BOOL finished) {
  }];
  [UIView animateWithDuration:kViewControllerSpeed delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
    self.bottomBar.frame = CGRectMake(0, _screenHeight - kMainBottomBarHeight, _screenWidth, kMainTopBarHeight);
  } completion:^(BOOL finished) {
  }];
}

-(void)slideOutTableview {
  [UIView animateWithDuration:kViewControllerSpeed delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.tableView.frame = CGRectMake(kTableViewXMargin, _screenHeight, _screenWidth - kTableViewXMargin * 2, _screenHeight - kTableViewTopMargin - kTableViewBottomMargin);
  } completion:^(BOOL finished) {
  }];
}

-(void)slideInTableview {
  [UIView animateWithDuration:kViewControllerSpeed delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
    self.tableView.frame = CGRectMake(kTableViewXMargin, kTableViewTopMargin, _screenWidth - kTableViewXMargin * 2, _screenHeight - kTableViewTopMargin - kTableViewBottomMargin);
  } completion:^(BOOL finished) {
  }];
}

-(void)fadeInOverlay {
  self.darkOverlay.backgroundColor = [UIColor clearColor];
  [self.view insertSubview:self.darkOverlay belowSubview:self.bottomBar];
  [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.darkOverlay.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:kMainOverlayAlpha];
  } completion:^(BOOL finished) {
  }];
}

-(void)fadeOutOverlay {
  [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.darkOverlay.backgroundColor = [UIColor clearColor];
  } completion:^(BOOL finished) {
    [self.darkOverlay removeFromSuperview];
  }];
}

-(void)startActivityIndicator {
    // hooray!
  [NSThread detachNewThreadSelector:@selector(threadStartAnimating:) toTarget:self withObject:nil];
}

-(void)threadStartAnimating:(id)data {
  self.activityIndicator.hidden = NO;
  [self.activityIndicator startAnimating];
}

-(void)stopActivityIndicator {
  NSLog(@"activityIndicator stops");
  [self.activityIndicator stopAnimating];
  self.activityIndicator.hidden = YES;
  
    // also remove startGame childVC
  [self backToMatches];
}

#pragma mark - button methods

-(IBAction)menuButtonTapped:(UIButton *)sender {
  UIViewController *buttonVC;
  if (sender == self.helpButton) {
    buttonVC = self.helpVC;
  } else if (sender == self.storeButton) {
    buttonVC = self.storeVC;
  } else if (sender == self.rankButton) {
    buttonVC = self.rankVC;
  } else if (sender == self.optionsButton) {
    buttonVC = self.optionsVC;
  } else if (sender == self.aboutButton) {
    buttonVC = self.aboutVC;
  } else if (sender == self.selfGameButton) {
    buttonVC = self.soloVC;
  } else if (sender == self.PnPGameButton) {
    buttonVC = self.pnpVC;
  } else if (sender == self.GCGameButton) {
      //
  }

  if (!self.vcIsAnimating && self.childVC != buttonVC) {
    [self presentChildViewController:buttonVC];
  }
}

#pragma mark - match creation methods

-(void)getModel {
  NSLog(@"getModel");
  self.myModel = [Model getMyModel];
}

-(void)startSoloGameWithPlayerName:(NSString *)playerName {
  Match *newMatch = [self.myModel instantiateSoloMatchWithName:playerName andRules:kGameRulesTonal andSkill:kBeginner];
    // may need to tweak with how this is viewed
  [self.myModel sortMyMatches];
  [self.tableView reloadData];
  [self performSegueWithIdentifier:@"sceneSegue" sender:newMatch];
}

-(void)startPnPGame {
  Match *newMatch = [self.myModel instantiateHardCodededPassNPlayMatchForDebugPurposes];
  [self backToMatches];
  [self.myModel sortMyMatches];
  [self.tableView reloadData];
  [self performSegueWithIdentifier:@"sceneSegue" sender:newMatch];
}

#pragma mark - delegate methods

-(void)disableOverlay {
  _overlayEnabled = NO;
}

-(void)enableOverlay {
  _overlayEnabled = YES;
}

-(void)removeMatch:(Match *)match {
  [self.myModel.myMatches removeObject:match];
  [Model saveMyModel:self.myModel];
}

#pragma mark - system methods

-(BOOL)prefersStatusBarHidden {
//  if (self.childVC) {
    return YES;
//  }
//  return NO;
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  NSLog(@"matches VC did receive memory warning");
  [Model saveMyModel:self.myModel];
}

@end
