//
//  GameEndedViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 8/20/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "GameEndedViewController.h"

@interface GameEndedViewController ()

@property (strong, nonatomic) UILabel *gameEndedLabel;

@end

@implementation GameEndedViewController

-(void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = kEndedMatchCellDarkColour;
  self.startingQuadrant = kQuadrantCenter;
  
  self.gameEndedLabel = [UILabel new];
  self.gameEndedLabel.font = [UIFont fontWithName:kFontModern size:kChildVCButtonSize];
  self.gameEndedLabel.textColor = [UIColor blackColor];
  [self.gameEndedLabel sizeToFit];
  [self.view addSubview:self.gameEndedLabel];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.gameEndedLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, kChildVCButtonSize);
  self.gameEndedLabel.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
  self.gameEndedLabel.text = [self.delegate endGameResultsText];
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)dealloc {
  NSLog(@"Game Ended VC deallocated.");
}

@end
