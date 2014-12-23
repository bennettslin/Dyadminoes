//
//  OptionsViewController.h
//  Dyadminoes
//
//  Created by Bennett Lin on 12/22/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SettingsViewController;
@class HelpViewController;

@protocol OptionsDelegate <NSObject>

@property (strong, nonatomic) SettingsViewController *settingsVC;
@property (strong, nonatomic) HelpViewController *helpVC;

@property (strong, nonatomic) UIViewController *childVC;
@property (assign, nonatomic) BOOL vcIsAnimating;

-(void)presentChildViewController:(UIViewController *)childVC;

@end

@interface OptionsViewController : UIViewController

@property (weak, nonatomic) id<OptionsDelegate> delegate;

@end
