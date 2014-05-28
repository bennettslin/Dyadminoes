//
//  MainTableViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 5/19/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "MainTableViewController.h"
#import "Model.h"
#import "NSObject+Helper.h"
#import "MatchTableViewCell.h"
#import "DebugViewController.h"

#import "PnPViewController.h"
#import "HelpViewController.h"
#import "StoreViewController.h"
#import "RankViewController.h"
#import "OptionsViewController.h"
#import "AboutViewController.h"

  // all are iPad values for now
#define kTableViewXMargin (kIsIPhone ? 20.f : 20.f)
#define kTableViewTopMargin (kIsIPhone ? 122.f : 122.f)
#define kTableViewBottomMargin (kIsIPhone ? 90.f : 90.f)

@interface MainTableViewController () <DebugDelegate, MatchCellDelegate>

@property (strong, nonatomic) Model *myModel;

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

@property (strong, nonatomic) PnPViewController *pnpVC;
@property (strong, nonatomic) HelpViewController *helpVC;
@property (strong, nonatomic) StoreViewController *storeVC;
@property (strong, nonatomic) RankViewController *rankVC;
@property (strong, nonatomic) OptionsViewController *optionsVC;
@property (strong, nonatomic) AboutViewController *aboutVC;

@end

@implementation MainTableViewController {
  CGFloat _screenWidth;
  CGFloat _screenHeight;
}

-(void)viewDidLoad {
  NSLog(@"view did load");
  
  [super viewDidLoad];
  
  _screenWidth = [UIScreen mainScreen].bounds.size.width;
  _screenHeight = [UIScreen mainScreen].bounds.size.height;
  
  self.pnpVC = [[PnPViewController alloc] init];
  self.pnpVC.view.backgroundColor = [UIColor lightGrayColor];
//  [self addChildViewController:self.pnpVC];
  
  self.helpVC = [[HelpViewController alloc] init];
  self.helpVC.view.backgroundColor = [UIColor redColor];
//  [self addChildViewController:self.helpVC];
  
  self.storeVC = [[StoreViewController alloc] init];
  self.storeVC.view.backgroundColor = [UIColor orangeColor];
//  [self addChildViewController:self.storeVC];
  
  self.rankVC = [[RankViewController alloc] init];
  self.rankVC.view.backgroundColor = [UIColor yellowColor];
//  [self addChildViewController:self.rankVC];
  
  self.optionsVC = [[OptionsViewController alloc] init];
  self.optionsVC.view.backgroundColor = [UIColor greenColor];
//  [self addChildViewController:self.optionsVC];
  
  self.aboutVC = [[AboutViewController alloc] init];
  self.aboutVC.view.backgroundColor = [UIColor blueColor];
//  [self addChildViewController:self.aboutVC];
  
  self.darkOverlay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 7 / 8)];
  [self.darkOverlay addTarget:self action:@selector(matchesTapped:) forControlEvents:UIControlEventTouchDown];
  self.vcIsAnimating = NO;
  [self highlightBottomButton:self.matchesButton];
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  
    // instantiates matches only on very first launch
  NSString *path = [self dataFilePath];
  if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    [self loadSettingsFromPath:path];
  } else { // no file present, instantiate with hard code for now
    self.myModel = [[Model alloc] init];
    [self.myModel instantiateHardCodedMatchesForDebugPurposes];
  }
}

-(void)viewWillAppear:(BOOL)animated {
  [self.myModel sortMyMatches];
  [self.tableView reloadData];
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

  // FIXME: solved problem for now with scene frame rate slowing down
  // by not adding VCs through view controller containment
  // so at present, this is NOT being called, because VCs are not being added in view did load
  // this might be okay, though, so we'll see
-(void)removeAllChildVCs {
  NSLog(@"all child vcs removed");
  [self removeChildViewController:self.pnpVC];
  [self removeChildViewController:self.helpVC];
  [self removeChildViewController:self.storeVC];
  [self removeChildViewController:self.rankVC];
  [self removeChildViewController:self.optionsVC];
  [self removeChildViewController:self.aboutVC];
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

#pragma mark - cell delegate methods

-(void)removeMatch:(Match *)match {
  [self.myModel.myMatches removeObject:match];
  [self.tableView reloadData];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"sceneSegue"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Match *match = self.myModel.myMatches[indexPath.row];
    DebugViewController *debugVC = [segue destinationViewController];
    debugVC.myMatch = match;
    debugVC.delegate = self;
  }
  
//  [self removeAllChildVCs];
}

#pragma mark - archiver methods

-(NSString *)documentsDirectory {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  return [paths firstObject];
}

-(NSString *)dataFilePath {
  return [[self documentsDirectory] stringByAppendingPathComponent:@"Dyadminoes.plist"];
}

-(void)saveSettings {
  NSMutableData *data = [[NSMutableData alloc] init];
  NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
  [archiver encodeObject:self.myModel.myMatches forKey:kMatchesKey];
  [archiver finishEncoding];
  [data writeToFile:[self dataFilePath] atomically:YES];
}

-(void)loadSettingsFromPath:(NSString *)path {
//  NSLog(@"file path is %@", path);
  NSData *data = [[NSData alloc] initWithContentsOfFile:path];
  NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
  self.myModel.myMatches = [unarchiver decodeObjectForKey:kMatchesKey];
  [unarchiver finishDecoding];
}

#pragma mark - view controller methods

-(void)presentChildViewController:(UIViewController *)childVC {
  
  self.vcIsAnimating = YES;
  if (self.childVC && self.childVC != childVC) {
    [self removeChildViewController:self.childVC];
  }
  
  self.childVC = childVC;
  
  if (kIsIPhone) {
    
      // for now, just iPad view
  } else {
    
      // overlay fade in and tableview slide out go together
    if (![self.darkOverlay superview]) {
      [self fadeInOverlay];
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
  
//  [self addChildViewController:childVC];
//  [childVC didMoveToParentViewController:self];
  }
  
  [self setNeedsStatusBarAppearanceUpdate];
}

-(void)removeChildViewController:(UIViewController *)childVC {
  
//  [childVC willMoveToParentViewController:nil];
  [UIView animateWithDuration:kViewControllerSpeed delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    childVC.view.center = CGPointMake(self.view.center.x + _screenWidth, self.view.center.y);
  } completion:^(BOOL finished) {
    [childVC.view removeFromSuperview];
//    [self removeChildViewController:childVC];
  }];
  
  [self setNeedsStatusBarAppearanceUpdate];
}

-(void)fadeInOverlay {
  self.darkOverlay.backgroundColor = [UIColor clearColor];
  [self.view addSubview:self.darkOverlay];
  [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.darkOverlay.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
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
  [self slideInTableview];
}

-(IBAction)pnpGameTapped:(id)sender {
  if (!self.vcIsAnimating && ![self.childVC isKindOfClass:[PnPViewController class]]) {
    [self presentChildViewController:self.pnpVC];
  }
}

-(IBAction)gcGameTapped:(id)sender {
  [self slideOutTableview];
}

-(IBAction)matchesTapped:(id)sender {
  if (!self.vcIsAnimating && self.childVC) {
    [self highlightBottomButton:self.matchesButton];
    [self fadeOutOverlay];
    [self slideInTableview];
    [self removeChildViewController:self.childVC];
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

#pragma mark - status bar methods

-(BOOL)prefersStatusBarHidden {
  if (self.childVC) {
    return YES;
  }
  return NO;
}



@end
