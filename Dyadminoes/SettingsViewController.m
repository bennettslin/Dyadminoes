//
//  OptionsViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 5/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "SettingsViewController.h"
#import "NSObject+Helper.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *showPivotGuideSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *notationControl;
@property (weak, nonatomic) IBOutlet UISlider *musicSlider;
@property (weak, nonatomic) IBOutlet UISlider *soundEffectsSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *registerControl;

@property (weak, nonatomic) IBOutlet UIButton *removeDefaultsButton;

@end

@implementation SettingsViewController

-(void)viewDidLoad {
  [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
    // defaults are established in app delegate
    // here, just show views
  
  [self.showPivotGuideSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"pivotGuide"] animated:NO];
  self.notationControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"notation"];
  [self.musicSlider setValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"music"]];
  [self.soundEffectsSlider setValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"soundEffects"]];
  self.registerControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"register"];
}

-(IBAction)pivotGuideSwitched {
  [[NSUserDefaults standardUserDefaults] setBool:self.showPivotGuideSwitch.isOn forKey:@"pivotGuide"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

-(IBAction)notationChanged:(UISegmentedControl *)sender {
  [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:@"notation"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

-(IBAction)musicSliderTouchEnded:(UISlider *)sender {
  sender.value = [self moduloSliderValue:sender.value];
  [[NSUserDefaults standardUserDefaults] setFloat:sender.value forKey:(sender == self.musicSlider) ? @"music" : @"soundEffects"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [self soundWithVolume:sender.value andMusic:(sender == self.musicSlider)];
}

-(IBAction)registerChanged:(UISegmentedControl *)sender {
  [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:@"register"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
//  NSUInteger soundedValue = 36 + sender.selectedSegmentIndex * 12;
//  [self soundWithVolume:soundedValue andMusic:YES];
}

-(float)moduloSliderValue:(float)value {
  NSUInteger integerValue = value * 100.f;
  NSUInteger moduloValue = integerValue % 5;
  return (integerValue - moduloValue) / 100.f;
}

-(IBAction)removeDefaultsTapped:(UIButton *)sender {
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"pivotGuide"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"notation"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"music"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"soundEffects"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
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
