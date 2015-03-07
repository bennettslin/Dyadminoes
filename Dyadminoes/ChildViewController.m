//
//  ChildViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 12/26/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "ChildViewController.h"

@interface ChildViewController ()

@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation ChildViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kCancelButtonEdge, kCancelButtonEdge)];
  [self.cancelButton setImage:[UIImage imageNamed:@"button_cancel"] forState:UIControlStateNormal];
  [self.view addSubview:self.cancelButton];
  [self.cancelButton addTarget:self action:@selector(cancelButtonLifted) forControlEvents:UIControlEventTouchUpInside];
  
  [self createTitleLabel];
}

#pragma mark - title label methods

-(void)createTitleLabel {
  
  self.titleLabel = [UILabel new];
  [self.view insertSubview:self.titleLabel belowSubview:self.cancelButton];
  self.titleLabel.layer.borderColor = [UIColor redColor].CGColor;
  self.titleLabel.layer.borderWidth = 2.f;
  self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

-(void)fadeTitleLabel {
  [UIView animateWithDuration:kConstantTime * 0.5 animations:^{
    self.titleLabel.alpha = 0.f;
  }];
}

-(void)centreTitleLabelWithText:(NSString *)text colour:(UIColor *)colour textAnimation:(BOOL)animate {
  
  const CGFloat topMarginFactor = 0.72f;
  self.titleLabel.frame = CGRectMake(0, 0, self.view.frame.size.width - (kChildVCSideMargin * 2), kChildVCTopMargin * topMarginFactor);
  self.titleLabel.font = [UIFont fontWithName:kFontModern size:kChildVCTopMargin * topMarginFactor];
  
  NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:text];
  [mutableAttributedString addAttributes:@{NSStrokeWidthAttributeName: [NSNumber numberWithFloat:-(kChildVCTopMargin * topMarginFactor / 30)],
                                           NSStrokeColorAttributeName:colour,
                                           NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, mutableAttributedString.length)];
  
  if (animate) {
    self.titleLabel.alpha = 0.f;
    self.titleLabel.attributedText = mutableAttributedString;
    [UIView animateWithDuration:kConstantTime * 0.5 animations:^{
      self.titleLabel.alpha = 1.f;
    }];

  } else {
    self.titleLabel.attributedText = mutableAttributedString;
  }

  const CGFloat padding = kCancelButtonEdge * 0.125f;
  self.titleLabel.center = CGPointMake(self.view.bounds.size.width / 2, kChildVCTopMargin * topMarginFactor / 2 + padding);
}

#pragma mark - cancel button methods

//-(void)cancelButtonPressed {
//  [[SoundEngine sharedSoundEngine] playSoundNotificationName:kNotificationButtonSunkIn];
//}

-(void)cancelButtonLifted {
//  [[SoundEngine sharedSoundEngine] playSoundNotificationName:kNotificationButtonLifted];
  [self.parentDelegate backToParentViewWithAnimateRemoveVC:YES];
}

-(void)positionCancelButtonBasedOnWidth:(CGFloat)width {
  const CGFloat padding = kCancelButtonEdge * 0.125f;
  self.cancelButton.center = CGPointMake(width - (kCancelButtonEdge * 0.5f + padding), kCancelButtonEdge * 0.5f + padding);
}

#pragma mark - system methods

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
