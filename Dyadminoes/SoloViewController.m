//
//  SoloViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 7/1/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "SoloViewController.h"

@interface SoloViewController ()

@property (weak, nonatomic) IBOutlet UITextField *playerName;
@property (weak, nonatomic) IBOutlet UIButton *startGameButton;

@end

@implementation SoloViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(IBAction)startGameTapped:(id)sender {
  [self.delegate startSoloGame];
}

@end
