//
//  ChildViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 12/26/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "ChildViewController.h"

#define kCancelButtonEdge 48.f

@interface ChildViewController ()

@property (strong, nonatomic) UIButton *cancelButton;

@end

@implementation ChildViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kCancelButtonEdge, kCancelButtonEdge)];
  self.cancelButton.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:self.cancelButton];
  [self.cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - cancel button methods

-(void)cancelButtonPressed {
  [self.parentDelegate backToParentViewWithAnimateRemoveVC:YES];
}

-(void)positionCancelButtonBasedOnWidth:(CGFloat)width {
  const CGFloat padding = kCancelButtonEdge * 0.25f;
  self.cancelButton.center = CGPointMake(width - (kCancelButtonEdge * 0.5f + padding), kCancelButtonEdge * 0.5f + padding);
}

#pragma mark - system methods

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
