//
//  HelpViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 5/28/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "HelpViewController.h"
#import "HelpContentViewController.h"

@interface HelpViewController () <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *helpPageVC;
@property (strong, nonatomic) NSArray *helpPageTitles;
@property (strong, nonatomic) NSArray *helpPageImages;

@end

@implementation HelpViewController

-(void)viewDidLoad {
  [super viewDidLoad];

    // Create the data model
  self.helpPageTitles = @[@"Over 200 Tips and Tricks", @"Discover Hidden Features", @"Bookmark Favorite Tip", @"Free Regular Update"];
  self.helpPageImages = @[@"page1.png", @"page2.png", @"page3.png", @"page4.png"];
  
    // Create page view controller
  self.helpPageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
  self.helpPageVC.dataSource = self;

  if ([self viewControllerAtIndex:0]) {
    
      // Change the size of page view controller
    self.helpPageVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self addChildViewController:self.helpPageVC];
    [self.view addSubview:self.helpPageVC.view];
    [self.helpPageVC didMoveToParentViewController:self];
  }
}

-(void)viewWillAppear:(BOOL)animated {
  [self resetToFirstPage];
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - page view methods

-(void)resetToFirstPage {
  HelpContentViewController *startingViewController = [self viewControllerAtIndex:0];
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
  
  if (index == self.helpPageTitles.count - 1 || index == NSNotFound) {
    return nil;
  }
  
  index++;
  return [self viewControllerAtIndex:index];
}

-(HelpContentViewController *)viewControllerAtIndex:(NSUInteger)index {
  if (self.helpPageTitles.count == 0 || index >= self.helpPageTitles.count) {
    return nil;
  }
  
    // Create a new view controller and pass suitable data.
  HelpContentViewController *helpContentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpContentViewController"];
  helpContentVC.imageFile = self.helpPageImages[index];
  helpContentVC.titleText = self.helpPageTitles[index];
  helpContentVC.pageIndex = index;
  
  return helpContentVC;
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
  return self.helpPageTitles.count;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
  return 0;
}

@end
