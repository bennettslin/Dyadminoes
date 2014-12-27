//
//  ParentViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 12/22/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "ParentViewController.h"
#import "NSObject+Helper.h"
#import "LocalGameViewController.h"
#import "OptionsViewController.h"
#import "HelpViewController.h"
#import "SettingsViewController.h"
#import "AboutViewController.h"
#import "ChildViewController.h"
#import "GameEndedViewController.h"

typedef enum axis {
  kAxisCenter,
  kAxisX,
  kAxisY
} Axis;

@interface ParentViewController () <ChildViewControllerDelegate>

@end

@implementation ParentViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.screenWidth = [UIScreen mainScreen].bounds.size.width;
  self.screenHeight = [UIScreen mainScreen].bounds.size.height;

  self.darkOverlay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, self.screenHeight)];
  self.vcIsAnimating = NO;
  
  self.helpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
  
  self.settingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
  
  [self.darkOverlay addTarget:self action:@selector(backToParentView) forControlEvents:UIControlEventTouchDown];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeChildVCUponEnteringBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self resetDarkOverlay];
  self.overlayEnabled = YES;
}

#pragma mark - navigation methods

-(void)backToParentView {
  [self backToParentViewWithAnimateRemoveVC:YES];
}

-(void)backToParentViewWithAnimateRemoveVC:(BOOL)animateRemoveVC {
  
  if (!self.vcIsAnimating && self.childVC && self.overlayEnabled) {
    if (animateRemoveVC) {
      [self fadeOverlayIn:NO];
      [self removeChildViewController:self.childVC];
    }
    
    self.childVC = nil;
  }
}

-(void)presentChildViewController:(ChildViewController *)childVC {
  
  self.vcIsAnimating = YES;
  (self.childVC && self.childVC != childVC) ? [self removeChildViewController:self.childVC] : nil;
  
  self.childVC = childVC;
  self.childVC.parentDelegate = self;
  
  if (![self.darkOverlay superview]) {
    [self fadeOverlayIn:YES];
  }
  
  [self animatePresentVC:childVC];
}

-(void)animatePresentVC:(ChildViewController *)childVC {
  
    // FIXME: use axis to determine whether to scale by x, y, or center
  Axis axis = [self determineFrameAndAxisForViewController:childVC];
  [self.view addSubview:childVC.view];
  
  CGPoint excessCenter = CGPointMake(self.view.center.x + (self.screenWidth * 0.0125f), self.view.center.y);
  CGPoint finalCenter = self.view.center;
  
  childVC.view.alpha = 0.f;
  __weak typeof(self) weakSelf = self;
  [UIView animateWithDuration:kViewControllerSpeed * 0.7f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    childVC.view.center = excessCenter;
    childVC.view.alpha = 1.f;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:kViewControllerSpeed * 0.3f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
      childVC.view.center = finalCenter;
    } completion:^(BOOL finished) {

      weakSelf.vcIsAnimating = NO;
    }];
  }];
}

-(Axis)determineFrameAndAxisForViewController:(ChildViewController *)childVC {
  CGFloat viewWidth = self.screenWidth * 4 / 5;
  CGFloat viewHeight = kIsIPhone ? self.screenHeight * 5 / 7 : self.screenHeight * 4 / 5;
  Axis returnAxis = kAxisCenter;
  
    // determine colour, frame, and origin center for each kind of view controller
  if ([childVC isKindOfClass:[LocalGameViewController class]]) {
    childVC.view.backgroundColor = kEndedMatchCellLightColour;
    
  } else if ([childVC isKindOfClass:[SettingsViewController class]]) {
    childVC.view.backgroundColor = kPlayerGreen;
    
  } else if ([childVC isKindOfClass:[AboutViewController class]]) {
    childVC.view.backgroundColor = [UIColor blueColor];
    
  } else if ([childVC isKindOfClass:[HelpViewController class]]) {
    childVC.view.backgroundColor = [UIColor redColor];
    
  } else if ([childVC isKindOfClass:[OptionsViewController class]]) {
    childVC.view.backgroundColor = kPlayerGreen;
    
  } else if ([childVC isKindOfClass:[GameEndedViewController class]]) {
    childVC.view.backgroundColor = [UIColor lightGrayColor];
  }
  
  childVC.view.frame = CGRectMake(0, 0, viewWidth, viewHeight);
  [childVC positionCancelButtonBasedOnWidth:viewWidth];

  childVC.view.center = CGPointMake(self.view.center.x - (self.screenWidth / 4), self.view.center.y);
  childVC.view.layer.cornerRadius = kCornerRadius;
  childVC.view.layer.masksToBounds = YES;
  
  return returnAxis;
}

-(void)removeChildViewController:(UIViewController *)childVC {
  
  __weak typeof(self) weakSelf = self;
  [UIView animateWithDuration:kViewControllerSpeed delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    childVC.view.center = CGPointMake(weakSelf.view.center.x + (weakSelf.screenWidth / 4), weakSelf.view.center.y);
    childVC.view.alpha = 0.f;
  } completion:^(BOOL finished) {
    [childVC.view removeFromSuperview];
  }];
}

-(void)fadeOverlayIn:(BOOL)fadeIn {
    // when local game is created, this is called from new thread
  
  __weak typeof(self) weakSelf = self;
  
  if (fadeIn) {
    CGFloat overlayAlpha = kIsIPhone ? 0.2f : 0.5f;
    self.darkOverlay.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.darkOverlay]; // this part is different in subclass VC
    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
      weakSelf.darkOverlay.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:overlayAlpha];
    } completion:nil];

  } else {
    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
      weakSelf.darkOverlay.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
      [weakSelf resetDarkOverlay];
    }];
  }
}

-(void)resetDarkOverlay {
  self.darkOverlay.backgroundColor = [UIColor clearColor];
  [self.darkOverlay removeFromSuperview];
}

#pragma mark - notification methods

-(void)removeChildVCUponEnteringBackground {
  if (self.childVC) {
    self.darkOverlay.backgroundColor = [UIColor clearColor];
    [self.darkOverlay removeFromSuperview];
    self.overlayEnabled = YES;
    
    [self.childVC.view removeFromSuperview];
    self.childVC = nil;
  }
}

#pragma mark - helper methods

-(void)slideAnimateView:(UIView *)movingView toDestinationYPosition:(CGFloat)yPosition durationConstant:(CGFloat)constant {
  
  CGFloat originalYPosition = movingView.frame.origin.y;
  CGFloat excessYPosition = ([movingView isKindOfClass:[UITableView class]]) ?
  yPosition + (kCellHeight / (kBounceDivisor * 1.4f)) :
  ((yPosition - originalYPosition) / kBounceDivisor) + yPosition;
  
  [UIView animateWithDuration:(constant * 0.7f) delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    movingView.frame = CGRectMake(movingView.frame.origin.x, excessYPosition, movingView.frame.size.width, movingView.frame.size.height);
  } completion:^(BOOL finished) {
    
    [UIView animateWithDuration:(constant * 0.3f) delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
      movingView.frame = CGRectMake(movingView.frame.origin.x, yPosition, movingView.frame.size.width, movingView.frame.size.height);
    } completion:nil];
  }];
}

#pragma mark - system methods

-(BOOL)prefersStatusBarHidden {
  return YES;
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

-(void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
