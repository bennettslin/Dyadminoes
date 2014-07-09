//
//  MainTableViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 5/19/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

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
#define kMainTopBarHeight (kIsIPhone ? 86.f : 86.f)

@interface MatchesTableViewController () <SceneViewDelegate, DebugDelegate, MatchCellDelegate, SoloDelegate, PnPDelegate>

@property (strong, nonatomic) Model *myModel;

@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;

@property (weak, nonatomic) IBOutlet UIButton *selfGameButton;
@property (weak, nonatomic) IBOutlet UIButton *PnPGameButton;
@property (weak, nonatomic) IBOutlet UIButton *GCGameButton;

@property (weak, nonatomic) IBOutlet UIButton *matchesButton;
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

@end

@implementation MatchesTableViewController {
  CGFloat _screenWidth;
  CGFloat _screenHeight;
}

-(void)viewDidLoad {
  
  [super viewDidLoad];
  
  self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  self.activityIndicator.color = [UIColor darkGrayColor];
  self.activityIndicator.frame = CGRectMake(0, 0, 100, 100);
  self.activityIndicator.layer.borderColor = [UIColor redColor].CGColor;
  self.activityIndicator.layer.borderWidth = 5.f;
  self.activityIndicator.center = self.view.center;
  [self.view insertSubview:self.activityIndicator aboveSubview:self.topBar];
  
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
    //  [self addChildViewController:self.soloVC];
  
  self.pnpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PnPViewController"];
  self.pnpVC.view.backgroundColor = [UIColor darkGrayColor];
  self.pnpVC.delegate = self;
//  [self addChildViewController:self.pnpVC];
  
  self.helpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
  self.helpVC.view.backgroundColor = [UIColor redColor];
//  [self addChildViewController:self.helpVC];
  
  self.storeVC = [[StoreViewController alloc] init];
  self.storeVC.view.backgroundColor = [UIColor orangeColor];
//  [self addChildViewController:self.storeVC];
  
  self.rankVC = [[RankViewController alloc] init];
  self.rankVC.view.backgroundColor = [UIColor yellowColor];
//  [self addChildViewController:self.rankVC];
  
  self.optionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OptionsViewController"];
  self.optionsVC.view.backgroundColor = [UIColor greenColor];
//  [self addChildViewController:self.optionsVC];
  
  self.aboutVC = [[AboutViewController alloc] init];
  self.aboutVC.view.backgroundColor = [UIColor blueColor];
//  [self addChildViewController:self.aboutVC];
  
    // hard coded for now
  self.darkOverlay = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, _screenWidth, _screenHeight - 100)];
  [self.darkOverlay addTarget:self action:@selector(matchesTapped:) forControlEvents:UIControlEventTouchDown];
  self.vcIsAnimating = NO;
  [self highlightBottomButton:self.matchesButton];
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getModel) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)getModel {
  NSLog(@"getModel");
  self.myModel = [Model getMyModel];
}

-(void)viewWillAppear:(BOOL)animated {
  
  if (![Model getMyModel]) {
    self.myModel = [Model new];
    [self.myModel instantiateHardCodedMatchesForDebugPurposes];
  } else {
    [self getModel];
  }
  
  [self.myModel sortMyMatches];
  [self.tableView reloadData];
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
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
  [self.activityIndicator startAnimating];
}

#pragma mark - cell delegate methods

-(void)removeMatch:(Match *)match {
  [self.myModel.myMatches removeObject:match];
  [self.tableView reloadData];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
  NSUInteger rowNumber;
  if ([segue.identifier isEqualToString:@"sceneSegue"]) {
    [self startActivityIndicator];
    
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

-(void)startActivityIndicator {
  NSLog(@"activity indicator starts");

  [self.activityIndicator startAnimating];
}

-(void)stopActivityIndicator {
  [self.activityIndicator stopAnimating];
  [self.activityIndicator removeFromSuperview];
  NSLog(@"activity indicator stops");
}

#pragma mark - view controller methods

-(void)presentChildViewController:(UIViewController *)childVC {
  
  self.vcIsAnimating = YES;
  if (self.childVC && self.childVC != childVC) {
    [self removeChildViewController:self.childVC];
  }
  self.childVC = childVC;
  
    // overlay fade in and tableview slide out go together
  if (![self.darkOverlay superview]) {
    [self fadeInOverlay];
    [self slideUpTopBar];
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

-(void)slideUpTopBar {
  [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    self.topBar.frame = CGRectMake(0, -kMainTopBarHeight, _screenWidth, kMainTopBarHeight);
  } completion:^(BOOL finished) {
  }];
}

-(void)slideDownTopBar {
  [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
    self.topBar.frame = CGRectMake(0, 0, _screenWidth, kMainTopBarHeight);
  } completion:^(BOOL finished) {
  }];
}

-(void)fadeInOverlay {
  self.darkOverlay.backgroundColor = [UIColor clearColor];
  [self.view insertSubview:self.darkOverlay belowSubview:self.bottomBar];
  [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.darkOverlay.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:kBoardCoverAlpha];
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

  // FIXME: slide in and out animations not working when simultaneous with overlay fade in and out
  // but does work by itself
-(void)slideOutTableview {
//  NSLog(@"slide out");
  [UIView animateWithDuration:kViewControllerSpeed delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.tableView.frame = CGRectMake(kTableViewXMargin, _screenHeight, _screenWidth - kTableViewXMargin * 2, _screenHeight - kTableViewTopMargin - kTableViewBottomMargin);
  } completion:^(BOOL finished) {
//    NSLog(@"slide out completed");
  }];
}

-(void)slideInTableview {
//  NSLog(@"slide in");
  [UIView animateWithDuration:kViewControllerSpeed delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
    self.tableView.frame = CGRectMake(kTableViewXMargin, kTableViewTopMargin, _screenWidth - kTableViewXMargin * 2, _screenHeight - kTableViewTopMargin - kTableViewBottomMargin);
  } completion:^(BOOL finished) {
//    NSLog(@"slide in completed");
  }];
}

#pragma mark - button methods

-(IBAction)selfGameTapped:(id)sender {
//  [self slideInTableview];
  if (!self.vcIsAnimating && ![self.childVC isKindOfClass:[SoloViewController class]]) {
    [self presentChildViewController:self.soloVC];
  }
}

-(IBAction)pnpGameTapped:(id)sender {
  if (!self.vcIsAnimating && ![self.childVC isKindOfClass:[PnPViewController class]]) {
    [self presentChildViewController:self.pnpVC];
  }
}

-(IBAction)gcGameTapped:(id)sender {
//  [self slideOutTableview];
}

-(IBAction)matchesTapped:(id)sender {
  NSLog(@"matches tapped called");
  if (!self.vcIsAnimating && self.childVC) {
    
    [self fadeOutOverlay];
    [self slideDownTopBar];
    [self slideInTableview];
    
    [self highlightBottomButton:self.matchesButton];
    [self removeChildViewController:self.childVC];
    NSLog(@"self.childVC is nil from matches tapped");
    self.childVC = nil;
  }
}

-(IBAction)helpTapped:(id)sender {
  if (!self.vcIsAnimating && ![self.childVC isKindOfClass:[HelpViewController class]]) {
    [self highlightBottomButton:sender];
    [self presentChildViewController:self.helpVC];
  }
}

-(IBAction)storeTapped:(id)sender {
  if (!self.vcIsAnimating && ![self.childVC isKindOfClass:[StoreViewController class]]) {
    [self highlightBottomButton:sender];
    [self presentChildViewController:self.storeVC];
  }
}

-(IBAction)rankTapped:(id)sender {
  if (!self.vcIsAnimating && ![self.childVC isKindOfClass:[RankViewController class]]) {
    [self highlightBottomButton:sender];
    [self presentChildViewController:self.rankVC];
  }
}

-(IBAction)optionsTapped:(id)sender {
  if (!self.vcIsAnimating && ![self.childVC isKindOfClass:[OptionsViewController class]]) {
    [self highlightBottomButton:sender];
    [self presentChildViewController:self.optionsVC];
  }
}

-(IBAction)aboutTapped:(id)sender {
  if (!self.vcIsAnimating && ![self.childVC isKindOfClass:[AboutViewController class]]) {
    [self highlightBottomButton:sender];
    [self presentChildViewController:self.aboutVC];
  }
}

-(void)highlightBottomButton:(UIButton *)button {
  if (self.highlightedBottomButton != button) {
    self.highlightedBottomButton.backgroundColor = [UIColor clearColor];
    button.backgroundColor = [UIColor yellowColor];
    self.highlightedBottomButton = button;
  }
}

#pragma mark - match creation methods

-(void)startSoloGame {
  Match *newMatch = [self.myModel instantiateHardCodededSoloMatchForDebugPurposes];
    // may need to tweak with how this is viewed
  [self matchesTapped:nil];
  [self.myModel sortMyMatches];
  [self.tableView reloadData];
  [self performSegueWithIdentifier:@"sceneSegue" sender:newMatch];
}

-(void)startPnPGame {
  Match *newMatch = [self.myModel instantiateHardCodededPassNPlayMatchForDebugPurposes];
  [self matchesTapped:nil];
  [self.myModel sortMyMatches];
  [self.tableView reloadData];
  [self performSegueWithIdentifier:@"sceneSegue" sender:newMatch];
}

#pragma mark - status bar methods

-(BOOL)prefersStatusBarHidden {
  if (self.childVC) {
    return YES;
  }
  return NO;
}

@end
