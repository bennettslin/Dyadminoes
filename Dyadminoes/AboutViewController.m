//
//  AboutViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 5/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

-(void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = kPlayerLighterGreen;
  self.startingQuadrant = kQuadrantRight;
  
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)dealloc {
  NSLog(@"About VC deallocated.");
}

@end
