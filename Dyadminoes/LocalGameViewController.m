//
//  SoloViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 7/1/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "LocalGameViewController.h"
#import "NSObject+Helper.h"

#define kPlaceholder1Name @"Clara"
#define kPlaceholder2Name @"Igor"
#define kPlaceholder3Name @"Miles"
#define kPlaceholder4Name @"Astrud"

#define kPlayer1Key @"player1Name"
#define kPlayer2Key @"player2Name"
#define kPlayer3Key @"player3Name"
#define kPlayer4Key @"player4Name"

@interface LocalGameViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *player1NameField;
@property (weak, nonatomic) IBOutlet UITextField *player2NameField;
@property (weak, nonatomic) IBOutlet UITextField *player3NameField;
@property (weak, nonatomic) IBOutlet UITextField *player4NameField;
@property (weak, nonatomic) IBOutlet UIButton *player1Button;
@property (weak, nonatomic) IBOutlet UIButton *player2Button;
@property (weak, nonatomic) IBOutlet UIButton *player3Button;
@property (weak, nonatomic) IBOutlet UIButton *player4Button;

@property (strong, nonatomic) NSArray *playerKeys;
@property (strong, nonatomic) NSArray *placeholderNames;
@property (strong, nonatomic) NSArray *textFields;
@property (strong, nonatomic) NSArray *playerButtons;

@property (weak, nonatomic) IBOutlet UIButton *startGameButton;
@property (strong, nonatomic) NSUserDefaults *defaults;

@property (nonatomic) NSUInteger selectedPlayerCount;

@end

@implementation LocalGameViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = kEndedMatchCellLightColour;
  
  self.playerKeys = @[kPlayer1Key, kPlayer2Key, kPlayer3Key, kPlayer4Key];
  self.placeholderNames = @[kPlaceholder1Name, kPlaceholder2Name, kPlaceholder3Name, kPlaceholder4Name];
  
  self.textFields = @[self.player1NameField, self.player2NameField, self.player3NameField, self.player4NameField];
  for (UITextField *textField in self.textFields) {
    textField.delegate = self;
    textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    NSUInteger index = [self.textFields indexOfObject:textField];
    textField.placeholder = self.placeholderNames[index];
  }
  
  self.playerButtons = @[self.player1Button, self.player2Button, self.player3Button, self.player4Button];
  
  self.defaults = [NSUserDefaults standardUserDefaults];
}

-(void)viewWillAppear:(BOOL)animated {
  
  [self initialiseButtonAndTextFieldState];
  
  for (int i = 0; i < kMaxNumPlayers; i++) {
    
    NSString *playerKey = self.playerKeys[i];
    
      // FIXME: if no player name, get from Game Center *first*
    NSString *userDefaultName = [self.defaults objectForKey:playerKey];
    NSString *placeholderName = self.placeholderNames[i];
    UITextField *textField = self.textFields[i];

    if (!userDefaultName || [userDefaultName isEqualToString:@""] || [userDefaultName isEqualToString:placeholderName]) {
      textField.text = nil;
      [self.defaults setObject:placeholderName forKey:playerKey];
    } else {
      textField.text = [self.defaults objectForKey:playerKey];
    }
  }
  
}

#pragma mark - state change methods

-(void)saveNameForPlayerIndex:(NSUInteger)index {
  
  UITextField *textField = self.textFields[index];
  NSString *playerKey = self.playerKeys[index];
  NSString *placeholderName = self.placeholderNames[index];
  
  NSString *trimmedString = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if (![trimmedString isEqualToString:[self.defaults objectForKey:playerKey]]) {
    if (!trimmedString || [trimmedString isEqualToString:@""]) {
      [self.defaults setObject:placeholderName forKey:playerKey];
    } else {
      [self.defaults setObject:trimmedString forKey:playerKey];
    }
    [self.defaults synchronize];
    NSLog(@"newPlayerName is '%@'", [self.defaults objectForKey:playerKey]);
  }
}

#pragma mark - button methods

-(IBAction)startGameTapped:(id)sender {
  
  NSMutableArray *tempSelectedPlayers = [NSMutableArray new];
  for (int i = 0; i < kMaxNumPlayers; i++) {
    UIButton *button = self.playerButtons[i];
    if (button.selected) {
      NSString *playerName = [self.defaults objectForKey:self.playerKeys[i]];
      [tempSelectedPlayers addObject:playerName];
    }
  }
  if (tempSelectedPlayers.count > 0) {
    [self.delegate startLocalGameWithPlayerNames:tempSelectedPlayers];
  }
//  [self.delegate startLocalGameWithPlayerName:[self.defaults objectForKey:kPlayer1Key]];
}

-(IBAction)buttonTapped:(UIButton *)button {
  
  NSUInteger index = [self.playerButtons indexOfObject:button];
  UITextField *textField = self.textFields[index];
  if (button.selected) {
    button.selected = NO;
    textField.backgroundColor = kEndedMatchCellLightColour;
    textField.textColor = [UIColor darkGrayColor];
    self.selectedPlayerCount--;
    
  } else {
    button.selected = YES;
    textField.backgroundColor = kMainLighterYellow;
    textField.textColor = [UIColor blackColor];
    self.selectedPlayerCount++;
  }
  
  UITextField *firstResponder = [self checkTextFieldFirstResponder];
  if (!firstResponder) {
    self.startGameButton.enabled = (self.selectedPlayerCount == 0) ? NO : YES;
  }
}

-(void)initialiseButtonAndTextFieldState {
  
  self.selectedPlayerCount = 1;
  self.startGameButton.enabled = YES;
  
  self.player1Button.selected = YES;
  self.player1NameField.backgroundColor = kMainLighterYellow;
  
  for (int i = 1; i < 4; i++) {
    UIButton *button = self.playerButtons[i];
    UITextField *textField = self.textFields[i];
    button.selected = NO;
    textField.backgroundColor = kEndedMatchCellLightColour;
    textField.textColor = [UIColor darkGrayColor];
  }
}

#pragma mark - text field methods

-(void)textFieldDidBeginEditing:(UITextField *)textField {
  self.startGameButton.enabled = NO;
  
  [self.delegate disableOverlay];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self resignTextField];
  return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self resignTextField];
}

-(void)resignTextField {
  
  UITextField *textField = [self checkTextFieldFirstResponder];
  if (textField) {
    [textField resignFirstResponder];
    NSUInteger index = [self.textFields indexOfObject:textField];
    [self saveNameForPlayerIndex:index];
    
    self.startGameButton.enabled = YES;
    [self.delegate enableOverlay];
  }
}

-(UITextField *)checkTextFieldFirstResponder {
  
  for (UITextField *textField in self.textFields) {
    if ([textField isFirstResponder]) {
      return textField;
    }
  }
  return nil;
}

@end
