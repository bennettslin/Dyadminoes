//
//  ParentViewController.h
//  Dyadminoes
//
//  Created by Bennett Lin on 12/22/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HelpViewController;
@class SettingsViewController;
@class AboutViewController;
@class ChildViewController;

@interface ParentViewController : UIViewController

@property (strong, nonatomic) HelpViewController *helpVC;
@property (strong, nonatomic) SettingsViewController *settingsVC;
@property (strong, nonatomic) AboutViewController *aboutVC;
@property (strong, nonatomic) ChildViewController *childVC;

@property (strong, nonatomic) UIButton *darkOverlay;
@property (assign, nonatomic) BOOL overlayEnabled;
@property (assign, nonatomic) BOOL vcIsAnimating;

@property (assign, nonatomic) CGFloat screenWidth;
@property (assign, nonatomic) CGFloat screenHeight;

-(void)backToParentViewWithAnimateRemoveVC:(BOOL)animateRemoveVC;
-(void)presentChildViewController:(ChildViewController *)childVC;
-(void)removeChildViewController:(ChildViewController *)childVC;

-(void)resetDarkOverlay;

-(void)fadeOverlayIn:(BOOL)fadeIn;
-(void)removeChildVCUponEnteringBackground;

-(void)slideAnimateView:(UIView *)movingView toDestinationYPosition:(CGFloat)yPosition durationConstant:(CGFloat)constant;

-(void)scaleAnimateView:(UIView *)scalingView goOut:(BOOL)goOut durationConstant:(CGFloat)constant;

@end
