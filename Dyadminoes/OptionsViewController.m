//
//  OptionsViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 5/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "OptionsViewController.h"

@interface OptionsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *showPivotGuideSwitch;
@property (strong, nonatomic) NSUserDefaults *defaults;

@end

@implementation OptionsViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  [self.showPivotGuideSwitch addTarget:self action:@selector(pivotGuideSwitched) forControlEvents:UIControlEventValueChanged];
  
  self.defaults = [NSUserDefaults standardUserDefaults];
    // first time setting key
  if (![self.defaults objectForKey:@"pivotGuide"]) {
    [self.defaults setBool:YES forKey:@"pivotGuide"];
    [self.defaults synchronize];
  } else {
    [self.showPivotGuideSwitch setOn:[self.defaults boolForKey:@"pivotGuide"] animated:NO];
  }
}

-(void)pivotGuideSwitched {
  [self.defaults setBool:self.showPivotGuideSwitch.isOn forKey:@"pivotGuide"];
  [self.defaults synchronize];
}

@end
