//
//  ChildViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 12/26/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "ChildViewController.h"
#import "SoundEngine.h"

@interface ChildViewController ()

@property (strong, nonatomic) UIButton *cancelButton;

@end

@implementation ChildViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kCancelButtonEdge, kCancelButtonEdge)];
  [self.cancelButton setImage:[UIImage imageNamed:@"button_cancel"] forState:UIControlStateNormal];
  [self.view addSubview:self.cancelButton];
    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchDown];
  [self.cancelButton addTarget:self action:@selector(cancelButtonLifted) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - cancel button methods

-(void)cancelButtonPressed {
  [[SoundEngine sharedSoundEngine] playSoundNotificationName:kNotificationButtonSunkIn];
}

-(void)cancelButtonLifted {
  
  [[SoundEngine sharedSoundEngine] playSoundNotificationName:kNotificationButtonLifted];
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
