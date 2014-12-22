//
//  ParentViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 12/22/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "ParentViewController.h"
#import "NSObject+Helper.h"

@interface ParentViewController ()

@end

@implementation ParentViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.screenWidth = [UIScreen mainScreen].bounds.size.width;
  self.screenHeight = [UIScreen mainScreen].bounds.size.height;

  self.darkOverlay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, self.screenHeight)];
  self.vcIsAnimating = NO;
  
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
  [self backToParentViewWithAnimateRemoveVC:NO];
}

-(void)backToParentViewWithAnimateRemoveVC:(BOOL)animateRemoveVC {
  
  if (!self.vcIsAnimating && self.childVC && self.overlayEnabled) {
    if (!animateRemoveVC) {
      [self fadeOverlayIn:NO];
      [self removeChildViewController:self.childVC];
    }
    
    self.childVC = nil;
  }
}

-(void)presentChildViewController:(UIViewController *)childVC {
  
  self.vcIsAnimating = YES;
  (self.childVC && self.childVC != childVC) ? [self removeChildViewController:self.childVC] : nil;
  
  self.childVC = childVC;
  
  if (![self.darkOverlay superview]) {
    [self fadeOverlayIn:YES];
  }
  
  CGFloat viewWidth = self.screenWidth * 4 / 5;
  CGFloat viewHeight = kIsIPhone ? self.screenHeight * 5 / 7 : self.screenHeight * 4 / 5;
  
  childVC.view.frame = CGRectMake(0, 0, viewWidth, viewHeight);
  childVC.view.center = CGPointMake(self.view.center.x - self.screenWidth, self.view.center.y);
  childVC.view.layer.cornerRadius = kCornerRadius;
  childVC.view.layer.masksToBounds = YES;
  
  [self.view addSubview:childVC.view];
  [self animatePresentVC:childVC];
}

-(void)animatePresentVC:(UIViewController *)childVC {
  
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    [UIView animateWithDuration:kViewControllerSpeed delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
      childVC.view.center = weakSelf.view.center;
    } completion:^(BOOL finished) {
      weakSelf.vcIsAnimating = NO;
    }];
  });
}

-(void)removeChildViewController:(UIViewController *)childVC {
  
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    [UIView animateWithDuration:kViewControllerSpeed delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
      childVC.view.center = CGPointMake(weakSelf.view.center.x + weakSelf.screenWidth, weakSelf.view.center.y);
    } completion:^(BOOL finished) {
      [childVC.view removeFromSuperview];
    }];
  });
}

-(void)fadeOverlayIn:(BOOL)fadeIn {
  
  __weak typeof(self) weakSelf = self;
  
  if (fadeIn) {
    CGFloat overlayAlpha = kIsIPhone ? 0.2f : 0.5f;
    self.darkOverlay.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.darkOverlay]; // this part is different in subclass VC
    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.darkOverlay.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:overlayAlpha];
    } completion:nil];
  } else {
    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.darkOverlay.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
      [weakSelf.darkOverlay removeFromSuperview];
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
