//
//  OptionsViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 12/22/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "OptionsViewController.h"

@interface OptionsViewController ()

@property (strong, nonatomic) UIButton *helpButton;
@property (strong, nonatomic) UIButton *settingsButton;
@property (strong, nonatomic) UIButton *resignButton;

@end

@implementation OptionsViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.helpButton = [UIButton new];
  [self.helpButton setTitle:@"Help" forState:UIControlStateNormal];
  [self.view addSubview:self.helpButton];
  
  self.settingsButton = [UIButton new];
  [self.settingsButton setTitle:@"Settings" forState:UIControlStateNormal];
  [self.view addSubview:self.settingsButton];
  
  self.resignButton = [UIButton new];
  [self.resignButton setTitle:@"Resign" forState:UIControlStateNormal];
  [self.view addSubview:self.resignButton];
  
  [self.helpButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.settingsButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.resignButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)buttonTapped:(UIButton *)sender {
  UIViewController *buttonVC;
  if (sender == self.helpButton) {
    buttonVC = (UIViewController *)self.delegate.helpVC;
  } else if (sender == self.settingsButton) {
    buttonVC = (UIViewController *)self.delegate.settingsVC;
  } else if (sender == self.resignButton) {
    buttonVC = nil;
  }
  
  if (!self.delegate.vcIsAnimating && self.delegate.childVC != buttonVC) {
    [self.delegate presentChildViewController:buttonVC];
  }
}

-(void)buttonTapped {
  
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];

}

@end
