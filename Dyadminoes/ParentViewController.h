//
//  ParentViewController.h
//  Dyadminoes
//
//  Created by Bennett Lin on 12/22/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HelpViewController;
@class OptionsViewController;
@class AboutViewController;

@interface ParentViewController : UIViewController

@property (strong, nonatomic) HelpViewController *helpVC;
@property (strong, nonatomic) OptionsViewController *optionsVC;
@property (strong, nonatomic) AboutViewController *aboutVC;
@property (strong, nonatomic) UIViewController *childVC;

@property (strong, nonatomic) UIButton *darkOverlay;
@property (assign, nonatomic) BOOL overlayEnabled;
@property (assign, nonatomic) BOOL vcIsAnimating;

@property (assign, nonatomic) CGFloat screenWidth;
@property (assign, nonatomic) CGFloat screenHeight;

-(void)backToParentViewWithAnimateRemoveVC:(BOOL)animateRemoveVC;
-(void)presentChildViewController:(UIViewController *)childVC;
-(void)animatePresentVC:(UIViewController *)childVC;
-(void)removeChildViewController:(UIViewController *)childVC;

-(void)resetDarkOverlay;

-(void)fadeOverlayIn:(BOOL)fadeIn;
-(void)removeChildVCUponEnteringBackground;

@end
