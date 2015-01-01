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

@end

@implementation OptionsViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
    /*****************  kChildVCTopMargin
     
     (Help)             kUIButtonSizeChildVC
                        verticalPaddingBetweenButtons
     (Settings)
     
     (Resign game)
                      kChildVCBottomMargin
    *****************/
  
    // resign button
  
  [self.resignButton setTitle:[self.delegate resignText] forState:UIControlStateNormal];

  self.view.backgroundColor = kEndedMatchCellLightColour;
  self.startingQuadrant = kQuadrantCenter;
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  CGFloat verticalPaddingBetweenButtons = (self.view.frame.size.height - kChildVCTopMargin - kChildVCBottomMargin - (kChildVCButtonSize * 3)) / 4;
  
  NSArray *buttonsArray = @[self.helpButton, self.settingsButton, self.resignButton];
  for (int i = 0; i < buttonsArray.count; i++) {
    
    CGFloat yOrigin = kChildVCTopMargin + (kChildVCButtonSize * i) + (verticalPaddingBetweenButtons * (i + 1));
    UIButton *button = buttonsArray[i];
    button.frame = CGRectMake(0, yOrigin, self.view.frame.size.width, kChildVCButtonSize);
    button.titleLabel.font = [UIFont fontWithName:kFontModern size:kChildVCButtonSize];
    [button.titleLabel sizeToFit];
  }
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
