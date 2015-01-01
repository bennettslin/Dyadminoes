//
//  OptionsViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 12/22/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "OptionsViewController.h"

@interface OptionsViewController ()

@property (strong, nonatomic) IBOutlet UIButton *helpButton;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) IBOutlet UIButton *resignButton;

@end

@implementation OptionsViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = kEndedMatchCellLightColour;
  self.startingQuadrant = kQuadrantCenter;
}

-(IBAction)buttonTapped:(UIButton *)sender {
  
  OptionsVCOptions optionsNumber;
  if (sender == self.helpButton) {
    optionsNumber = kHelpOption;
  } else if (sender == self.settingsButton) {
    optionsNumber = kSettingsOption;
  } else if (sender == self.resignButton) {
    optionsNumber = kResignOption;
  } else {
    optionsNumber = kNoOption;
  }

  [self.delegate presentFromOptionsChildViewController:optionsNumber];
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

-(void)dealloc {
  NSLog(@"Options VC deallocated.");
}

@end
