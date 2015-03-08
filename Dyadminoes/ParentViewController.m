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
//#import "SoundEngine.h"

@interface ParentViewController () <ChildViewControllerDelegate>

@end

@implementation ParentViewController

@synthesize helpVC = _helpVC;
@synthesize settingsVC = _settingsVC;

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
  if (self.childVC) {
    if ([self.childVC isKindOfClass:LocalGameViewController.class]) {
      LocalGameViewController *localGameVC = (LocalGameViewController *)self.childVC;
      if ([localGameVC checkTextFieldFirstResponder]) {
        [localGameVC resignTextField:nil];
        return;
      }
    }
  }
  
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

  [self determineFrameForViewController:childVC];
  childVC.view.center = [self determineCenterForViewController:childVC];
  CGPoint excessCenter;
  
  CGPoint finalCenter = self.view.center;
  [self.view addSubview:childVC.view];
  
  switch (childVC.startingQuadrant) {
    case kQuadrantLeft:
      excessCenter = CGPointMake(self.view.center.x + (self.screenWidth * 0.0125f), self.view.center.y);
      break;
    case kQuadrantRight:
      excessCenter = CGPointMake(self.view.center.x - (self.screenWidth * 0.0125f), self.view.center.y);
      break;
    case kQuadrantUp:
      excessCenter = CGPointMake(self.view.center.x, self.view.center.y + (self.screenHeight * 0.0125f));
      break;
    case kQuadrantDown:
      excessCenter = CGPointMake(self.view.center.x, self.view.center.y - (self.screenHeight * 0.0125f));
      break;
      default:
      break;
  }
  
  childVC.view.alpha = 0.f;
  __weak typeof(self) weakSelf = self;
  
    // pop in from center
  if (childVC.startingQuadrant == kQuadrantCenter) {
    childVC.view.center = finalCenter;
    childVC.view.transform = CGAffineTransformMakeScale(0.75f, 0.75f);
    [UIView animateWithDuration:kViewControllerSpeed * 0.7f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
      childVC.view.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
      childVC.view.alpha = 1.f;
    } completion:^(BOOL finished) {
      [UIView animateWithDuration:kViewControllerSpeed * 0.3f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
        childVC.view.transform = CGAffineTransformMakeScale(1.f, 1.f);
      } completion:^(BOOL finished) {
        
        weakSelf.vcIsAnimating = NO;
      }];
    }];
    
      // move in from quadrant
  } else {
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
}

-(void)determineFrameForViewController:(ChildViewController *)childVC {
  CGFloat viewWidth;
  CGFloat viewHeight;

  if ([childVC isKindOfClass:[OptionsViewController class]] ||
      [childVC isKindOfClass:[GameEndedViewController class]]) {
    viewWidth = self.screenWidth * 3 / 5;
    viewHeight = kIsIPhone ? self.screenHeight * 4 / 7 : self.screenHeight * 3 / 5;
    
  } else {
    viewWidth = kIsIPhone ? self.screenWidth * 9 / 10 : self.screenWidth * 4 / 5;
    viewHeight = kIsIPhone ? self.screenHeight * 6 / 7 : self.screenHeight * 4 / 5;
  }
  
  childVC.view.frame = CGRectMake(childVC.view.frame.origin.x, childVC.view.frame.origin.y, viewWidth, viewHeight);
  
  [childVC positionCancelButtonBasedOnWidth:viewWidth];
  
  childVC.view.layer.cornerRadius = kCornerRadius;
  childVC.view.layer.masksToBounds = YES;
}

-(CGPoint)determineCenterForViewController:(ChildViewController *)childVC {
    // determine center for each kind of view controller
  CGPoint center;
  
  switch (childVC.startingQuadrant) {
    case kQuadrantLeft:
      center = CGPointMake(self.view.center.x - (self.screenWidth / 4), self.view.center.y);
      break;
    case kQuadrantRight:
      center = CGPointMake(self.view.center.x + (self.screenWidth / 4), self.view.center.y);
      break;
    case kQuadrantUp:
      center = CGPointMake(self.view.center.x, self.view.center.y - (self.screenHeight / 4));
      break;
    case kQuadrantDown:
      center = CGPointMake(self.view.center.x, self.view.center.y + (self.screenHeight / 4));
      break;
    case kQuadrantCenter:
      center = self.view.center;
      break;
    default:
      break;
  }
  
  return center;
}

-(void)removeChildViewController:(ChildViewController *)childVC {
  
//  [[SoundEngine sharedSoundEngine] playSoundNotificationName:kNotificationToggleBarOrField];
  self.vcIsAnimating = YES;
  __weak typeof(self) weakSelf = self;
  
  if (childVC.startingQuadrant == kQuadrantCenter) {
    [UIView animateWithDuration:kViewControllerSpeed * 0.9f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
      childVC.view.transform = CGAffineTransformMakeScale(0.75f, 0.75f);
      childVC.view.alpha = 0.f;
    } completion:^(BOOL finished) {
      childVC.view.transform = CGAffineTransformMakeScale(1.f, 1.f);
      weakSelf.vcIsAnimating = NO;
      [childVC.view removeFromSuperview];
    }];
    
  } else {
    [UIView animateWithDuration:kViewControllerSpeed * 0.9f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
      childVC.view.center = [weakSelf determineCenterForViewController:childVC];
      childVC.view.alpha = 0.f;
    } completion:^(BOOL finished) {
      weakSelf.vcIsAnimating = NO;
      [childVC.view removeFromSuperview];
    }];
  }
}

-(void)fadeOverlayIn:(BOOL)fadeIn {
    // when local game is created, this is called from new thread
  
  __weak typeof(self) weakSelf = self;
  
  if (fadeIn) {
    CGFloat overlayAlpha = kIsIPhone ? 0.2f : 0.5f;
    self.darkOverlay.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.darkOverlay]; // this part is different in subclass VC
    [UIView animateWithDuration:kViewControllerSpeed * 0.8f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
      weakSelf.darkOverlay.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:overlayAlpha];
    } completion:nil];

  } else {
    [UIView animateWithDuration:kViewControllerSpeed * 0.7f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
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

-(void)scaleAnimateView:(UIView *)scalingView goOut:(BOOL)goOut durationConstant:(CGFloat)constant {
  
  CGFloat scale = goOut ? .75f : 1.f;
  
  [UIView animateWithDuration:(constant * 0.7f) delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    scalingView.transform = CGAffineTransformMakeScale(scale * 1.05f, scale * 1.05f);
    scalingView.alpha = goOut ? 0.f : 1.f;
    
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:(constant * 0.3f) delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
      scalingView.transform = CGAffineTransformMakeScale(scale, scale);
      
    } completion:^(BOOL finished) {
      scalingView.transform = CGAffineTransformMakeScale(1.f, 1.f);
      scalingView.alpha = goOut ? 0.f : 1.f;
    }];
  }];
}

#pragma mark - accessor methods

-(void)setHelpVC:(HelpViewController *)helpVC {
  _helpVC = helpVC;
}

-(HelpViewController *)helpVC {
  if (!_helpVC) {
    _helpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
  }
  return _helpVC;
}

-(void)setSettingsVC:(SettingsViewController *)settingsVC {
  _settingsVC = settingsVC;
}

-(SettingsViewController *)settingsVC {
  if (!_settingsVC) {
    _settingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
  }
  return _settingsVC;
}

#pragma mark - system methods

-(BOOL)prefersStatusBarHidden {
  return YES;
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  
  self.helpVC = nil;
  self.settingsVC = nil;
}

-(void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
