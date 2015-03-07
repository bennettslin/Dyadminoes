//
//  OptionsViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 5/27/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "SettingsViewController.h"
#import "SoundEngine.h"
#import "AppDelegate.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *notationControl;
@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (weak, nonatomic) IBOutlet UISlider *musicSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *registerControl;
@property (weak, nonatomic) IBOutlet UIButton *removeDefaultsButton;

@end

@implementation SettingsViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = kPlayerLighterBlue;
  self.startingQuadrant = kQuadrantDown;
  
  self.removeDefaultsButton.titleLabel.font = [UIFont fontWithName:kFontModern size:kChildVCButtonSize * 0.5];
  self.removeDefaultsButton.titleLabel.text = @"Restore defaults";
  [self.removeDefaultsButton.titleLabel sizeToFit];
  self.removeDefaultsButton.frame = self.removeDefaultsButton.titleLabel.frame;
    [self.removeDefaultsButton addTarget:self action:@selector(removeDefaultsButtonPressed) forControlEvents:UIControlEventTouchDown];
  
  [self.soundSwitch setOnTintColor:kPlayerBlue];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self centreTitleLabelWithText:@"Settings" colour:kPlayerDarkBlue textAnimation:NO];
  
    // defaults are established in app delegate
    // here, just show views
  
  NSArray *labels = @[@"Sound Effects", @"Note Volume", @"Note Register", @"Note Symbols"];
  NSArray *labelDetails = @[@"blah", @"blah", @"blah", @"blah"];
  
  NSUInteger labelCountPlusPadding = labels.count + 1;
  
  NSArray *controls = @[self.soundSwitch, self.musicSlider, self.registerControl, self.notationControl];
  
  CGFloat labelHeight = kChildVCButtonSize * 0.75f;
  
    // half padding above top label and below bottom label
  CGFloat paddingBetweenLabels = (self.view.frame.size.height - kChildVCTopMargin - kChildVCBottomMargin - (labelHeight * labelCountPlusPadding)) / labelCountPlusPadding;
  
  for (int i = 0; i < labels.count; i++) {
    UILabel *label = [UILabel new];
    label.text = labels[i];
    label.font = [UIFont fontWithName:kFontModern size:kChildVCButtonSize * 0.75f];
    label.textColor = kPlayerDarkBlue;
    [label sizeToFit];
    CGFloat yOrigin = kChildVCTopMargin + (paddingBetweenLabels * 0.5f) + (paddingBetweenLabels * i) + (labelHeight * i);
    label.frame = CGRectMake(kChildVCSideMargin, yOrigin, label.frame.size.width, labelHeight);
    [self.view addSubview:label];
    
    UILabel *detailsLabel = [UILabel new];
    detailsLabel.text = labelDetails[i];
    detailsLabel.font = [UIFont fontWithName:kFontModern size:kChildVCButtonSize * 0.4f];
    detailsLabel.textColor = kPlayerDarkBlue;
    [detailsLabel sizeToFit];
    detailsLabel.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y + labelHeight, detailsLabel.frame.size.width, detailsLabel.frame.size.height);
    [self.view addSubview:detailsLabel];
    
    UIControl *control = controls[i];
    control.center = CGPointMake(self.view.frame.size.width * 0.7f, label.center.y);
  }
  
  self.removeDefaultsButton.center = CGPointMake(self.view.frame.size.width * 0.5f, self.view.frame.size.height - kChildVCBottomMargin - self.removeDefaultsButton.frame.size.height * 0.5f);
  
  [self establishControlViewsWithAnimation:NO];
}

-(IBAction)soundSwitched {
  [[NSUserDefaults standardUserDefaults] setBool:self.soundSwitch.isOn forKey:@"sound"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
    [self soundWithVolume:1.f andNotificationName:kNotificationOptionsSoundEffects];
  }
}

-(IBAction)notationChanged:(UISegmentedControl *)sender {
  [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:@"notation"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

-(IBAction)musicSliderTouchEnded:(UISlider *)sender {
  sender.value = [self moduloSliderValue:sender.value];
  [[NSUserDefaults standardUserDefaults] setFloat:sender.value forKey:@"music"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [self soundWithVolume:sender.value andNotificationName:kNotificationOptionsMusic];
}

-(IBAction)registerChanged:(UISegmentedControl *)sender {
  [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:@"register"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  NSUInteger soundedValue = 36 + sender.selectedSegmentIndex * 12;
  [self soundWithVolume:soundedValue andNotificationName:kNotificationOptionsRegister];
}

-(float)moduloSliderValue:(float)value {
  NSUInteger integerValue = value * 100.f;
  NSUInteger moduloValue = integerValue % 5;
  return (integerValue - moduloValue) / 100.f;
}

-(void)removeDefaultsButtonPressed {
  
}

-(IBAction)removeDefaultsButtonLifted:(UIButton *)sender {
  
  [[SoundEngine sharedSoundEngine] playSoundNotificationName:kNotificationButtonLifted];
  
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"notation"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"music"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sound"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"register"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  [appDelegate establishDefaults];
  
  [self establishControlViewsWithAnimation:YES];
}

-(void)establishControlViewsWithAnimation:(BOOL)animation {
  self.notationControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"notation"];
  [self.soundSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"sound"] animated:animation];
  [self.musicSlider setValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"music"] animated:animation];
  self.registerControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"register"];
}

-(void)soundWithVolume:(float)volume andNotificationName:(NotificationName)notificationName {

  [[SoundEngine sharedSoundEngine] playSoundNotificationName:notificationName];
//  NSNumber *whichNotificationObject = [NSNumber numberWithUnsignedInteger:notificationName];
//  [[NSNotificationCenter defaultCenter] postNotificationName:@"playSound" object:self userInfo:@{@"sound": whichNotificationObject}];
}

-(void)dealloc {
  NSLog(@"Settings VC deallocated.");
}

@end
