//
//  OptionsViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 5/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "OptionsViewController.h"
#import "NSObject+Helper.h"
//#import <AVFoundation/AVFoundation.h>

@interface OptionsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *showPivotGuideSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *notationControl;
@property (weak, nonatomic) IBOutlet UISlider *musicSlider;
@property (weak, nonatomic) IBOutlet UISlider *soundEffectsSlider;
@property (weak, nonatomic) IBOutlet UIButton *removeDefaultsButton;
@property (strong, nonatomic) NSUserDefaults *defaults;

@end

@implementation OptionsViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  self.defaults = [NSUserDefaults standardUserDefaults];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
    // if first time setting values...
  if (![self.defaults objectForKey:@"pivotGuide"]) {
    [self.defaults setBool:YES forKey:@"pivotGuide"];
    [self.defaults synchronize];
  }
  [self.showPivotGuideSwitch setOn:[self.defaults boolForKey:@"pivotGuide"] animated:NO];
  
  if (![self.defaults objectForKey:@"notation"]) {
    [self.defaults setInteger:0 forKey:@"notation"];
    [self.defaults synchronize];
  }
  self.notationControl.selectedSegmentIndex = [self.defaults integerForKey:@"notation"];
  
  if (![self.defaults objectForKey:@"music"]) {
    [self.defaults setFloat:0.5f forKey:@"music"];
    [self.defaults synchronize];
  }
  [self.musicSlider setValue:[self.defaults floatForKey:@"music"]];
  
  if (![self.defaults objectForKey:@"soundEffects"]) {
    [self.defaults setFloat:0.5f forKey:@"soundEffects"];
    [self.defaults synchronize];
  }
  [self.soundEffectsSlider setValue:[self.defaults floatForKey:@"soundEffects"]];
}

-(IBAction)pivotGuideSwitched {
  [self.defaults setBool:self.showPivotGuideSwitch.isOn forKey:@"pivotGuide"];
  [self.defaults synchronize];
}

-(IBAction)notationChanged:(UISegmentedControl *)sender {
  NSLog(@"selected segment is %li", (long)sender.selectedSegmentIndex);
  [self.defaults setInteger:sender.selectedSegmentIndex forKey:@"notation"];
  [self.defaults synchronize];
}

-(IBAction)musicSliderTouchEnded:(UISlider *)sender {
  sender.value = [self moduloSliderValue:sender.value];
//  NSLog(@"slider value is %.2f", sender.value);
  [self.defaults setFloat:sender.value forKey:(sender == self.musicSlider) ? @"music" : @"soundEffects"];
  [self.defaults synchronize];
  [self soundWithVolume:sender.value andMusic:(sender == self.musicSlider)];
}

-(float)moduloSliderValue:(float)value {
  NSUInteger integerValue = value * 100.f;
  NSUInteger moduloValue = integerValue % 5;
  return (integerValue - moduloValue) / 100.f;
}

-(IBAction)removeDefaultsTapped:(UIButton *)sender {
  [self.defaults removeObjectForKey:@"pivotGuide"];
  [self.defaults removeObjectForKey:@"notation"];
  [self.defaults removeObjectForKey:@"music"];
  [self.defaults removeObjectForKey:@"soundEffects"];
  [self.defaults synchronize];
  
  [self.showPivotGuideSwitch setOn:YES animated:YES];
  self.notationControl.selectedSegmentIndex = 0;
  [self.soundEffectsSlider setValue:0.5f animated:YES];
  [self.musicSlider setValue:0.5f animated:YES];
}

-(void)soundWithVolume:(float)volume andMusic:(BOOL)music {
  
    // can be any two sounds that signify music versus effect
  NotificationName whichNotification = music ? kNotificationOptionsMusic : kNotificationBoardZoom;
  NSNumber *whichNotificationObject = [NSNumber numberWithUnsignedInteger:whichNotification];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"playSound" object:self userInfo:@{@"sound": whichNotificationObject}];
}

@end
