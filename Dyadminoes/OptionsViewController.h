//
//  OptionsViewController.h
//  Dyadminoes
//
//  Created by Bennett Lin on 12/22/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+Helper.h"
#import "ChildViewController.h"
@class SettingsViewController;
@class HelpViewController;

@protocol OptionsDelegate <NSObject>

-(NSString *)resignText;
-(void)presentFromOptionsChildViewController:(OptionsVCOptions)optionsNumber;

@end

@interface OptionsViewController : ChildViewController

@property (strong, nonatomic) IBOutlet UIButton *resignButton;
@property (weak, nonatomic) id<OptionsDelegate> delegate;

@end
