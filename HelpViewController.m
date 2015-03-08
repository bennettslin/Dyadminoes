//
//  HelpViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 5/28/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "HelpViewController.h"
#import "HelpContentViewController.h"

#define kNumberOfHelpPages 3

@interface HelpViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *helpPageVC;

@end

@implementation HelpViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = kPlayerLighterRed;
  self.startingQuadrant = kQuadrantLeft;
  
    // Create page view controller
  self.helpPageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
  self.helpPageVC.delegate = self;
  self.helpPageVC.dataSource = self;

  if ([self viewControllerAtIndex:0]) {
    
      // Change the size of page view controller
    self.helpPageVC.view.frame = CGRectMake(0, kChildVCTopMargin, self.view.frame.size.width, self.view.frame.size.height - kChildVCTopMargin);
    
    [self addChildViewController:self.helpPageVC];
    [self.view addSubview:self.helpPageVC.view];
    [self.helpPageVC didMoveToParentViewController:self];
  }
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self resetToDefaultPage];
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - page view methods

-(void)resetToDefaultPage {
  HelpContentViewController *startingViewController = [self viewControllerAtIndex:0];
  NSString *titleLabelText = [startingViewController titleTextBasedOnPageIndex];
  [self centreTitleLabelWithText:titleLabelText colour:kPlayerDarkRed textAnimation:NO];
  NSArray *viewControllers = @[startingViewController];
  [self.helpPageVC setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
  NSUInteger index = ((HelpContentViewController *)viewController).pageIndex;
  
  if (index == 0 || index == NSNotFound) {
    return nil;
  }
  
  index--;
  return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
  NSUInteger index = ((HelpContentViewController *)viewController).pageIndex;
  
  if (index == kNumberOfHelpPages - 1 || index == NSNotFound) {
    return nil;
  }
  
  index++;
  return [self viewControllerAtIndex:index];
}

-(HelpContentViewController *)viewControllerAtIndex:(NSUInteger)index {
  if (kNumberOfHelpPages == 0 || index >= kNumberOfHelpPages) {
    return nil;
  }

  HelpContentViewController *helpContentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpContentViewController"];
  helpContentVC.pageIndex = index;
  
  return helpContentVC;
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {

  HelpContentViewController *currentVC = completed ?
      [pageViewController.viewControllers objectAtIndex:0] :
      [previousViewControllers objectAtIndex:0];
  
  NSString *titleLabelText = [currentVC titleTextBasedOnPageIndex];
  
  [self centreTitleLabelWithText:titleLabelText colour:kPlayerDarkRed textAnimation:YES];
}

-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
  
  [self fadeTitleLabel];
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
  return kNumberOfHelpPages;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
  return 0;
}

-(void)dealloc {
  NSLog(@"Help VC deallocated.");
}

@end
