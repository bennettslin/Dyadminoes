//
//  AboutViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 5/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@property (strong, nonatomic) UITextView *textView;

@end

@implementation AboutViewController

-(void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = kPlayerLighterGreen;
  self.startingQuadrant = kQuadrantRight;
  
  [self createTextView];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self centreTitleLabelWithText:@"About" colour:kPlayerDarkGreen textAnimation:NO];
  [self centreTextView];
}

-(void)createTextView {
  self.textView = [UITextView new];
  
  self.textView.font = [UIFont fontWithName:kFontModern size:kChildVCButtonSize * 0.45];
  self.textView.textColor = kPlayerDarkGreen;
  self.textView.textAlignment = NSTextAlignmentJustified;
  self.textView.backgroundColor = [UIColor clearColor];
  self.textView.layer.borderColor = [UIColor redColor].CGColor;
  self.textView.layer.borderWidth = 2.f;
  
  self.textView.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer magna odio, dictum eget mauris at, efficitur interdum elit. Pellentesque porttitor eu dolor non interdum. Maecenas nec tincidunt turpis, vitae posuere urna. Vivamus fermentum, orci vitae facilisis ultricies, lorem nulla gravida tellus, ac tristique massa felis ut erat.\n\nSuspendisse sit amet libero quis sapien semper accumsan ut at dolor. Nunc ultrices enim sed dui auctor efficitur. Donec aliquet maximus rutrum. Aliquam ornare placerat ligula, ut fermentum augue. Nullam imperdiet nunc eu enim egestas, sed faucibus libero rhoncus.";
  
  [self.view addSubview:self.textView];
}

-(void)centreTextView {
  self.textView.frame = CGRectMake(0, 0, self.view.frame.size.width - (kChildVCSideMargin * 2), self.view.frame.size.height - kChildVCTopMargin - kChildVCBottomMargin);
  self.textView.center = CGPointMake(self.view.bounds.size.width / 2, ((self.view.bounds.size.height - kChildVCTopMargin - kChildVCBottomMargin) / 2) + kChildVCTopMargin);
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)dealloc {
  NSLog(@"About VC deallocated.");
}

@end
