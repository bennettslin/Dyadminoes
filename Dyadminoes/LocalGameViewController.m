//
//  SoloViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 7/1/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "LocalGameViewController.h"

#define kPlaceholder1Name @"Main player"
#define kPlaceholder2Name @"Guest player 1"
#define kPlaceholder3Name @"Guest player 2"
#define kPlaceholder4Name @"Guest player 3"

#define kPlayer1Key @"player1Name"
#define kPlayer2Key @"player2Name"
#define kPlayer3Key @"player3Name"
#define kPlayer4Key @"player4Name"

#define kLocalGameTextFieldHeight 80.f
#define kLocalGameButtonWidth 120.f
#define kLocalGameTopPadding (kLocalGameButtonWidth * 0.05f)

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
@property (strong, nonatomic) NSArray *playerNameFields;
@property (strong, nonatomic) NSArray *playerButtons;

@property (weak, nonatomic) IBOutlet UIButton *startSelfOrPnPGameButton;
@property (strong, nonatomic) NSUserDefaults *defaults;

@property (nonatomic) NSUInteger selectedPlayerCount;

@end

@implementation LocalGameViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  /***************************************
   
   [Main player text field]
   
   ---------------------------------------
   
   [Guest player 1 text field]  (Join? button)
   [Guest player 2 text field]  (Join? button)
   [Guest player 3 text field]  (Join? button)
   
       (Start self or PnP game button)
   
   ----------------- or -----------------
   
            (Start computer game)
   
   ----------------- or -----------------
   
           (Start Game Center game)
   
   **************************************/
  
  
  self.view.backgroundColor = kPlayerLighterOrange;
  self.startingQuadrant = kQuadrantUp;
  
  self.playerKeys = @[kPlayer1Key, kPlayer2Key, kPlayer3Key, kPlayer4Key];
  self.placeholderNames = @[kPlaceholder1Name, kPlaceholder2Name, kPlaceholder3Name, kPlaceholder4Name];
  
  self.playerNameFields = @[self.player1NameField, self.player2NameField, self.player3NameField, self.player4NameField];
  for (UITextField *textField in self.playerNameFields) {
    textField.delegate = self;
    textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    NSUInteger index = [self.playerNameFields indexOfObject:textField];
    textField.placeholder = self.placeholderNames[index];
  }
  
  self.playerButtons = @[self.player1Button, self.player2Button, self.player3Button, self.player4Button];
  for (UIButton *button in self.playerButtons) {
    [button setTitle:@"Join?" forState:UIControlStateNormal];
    [button setTitle:@"Joined!" forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:24.f];
    [button.titleLabel sizeToFit];
  }
  
  self.defaults = [NSUserDefaults standardUserDefaults];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self centreTitleLabelWithText:@"New Game" colour:kPlayerDarkOrange textAnimation:NO];
  
  [self initialiseButtonAndTextFieldState];
  
  for (int i = 0; i < kMaxNumPlayers; i++) {
    
    NSString *playerKey = self.playerKeys[i];
    
      // FIXME: if no player name, get from Game Center *first*
    NSString *userDefaultName = [self.defaults objectForKey:playerKey];
    NSString *placeholderName = self.placeholderNames[i];
    UITextField *textField = self.playerNameFields[i];

    if (!userDefaultName || [userDefaultName isEqualToString:@""] || [userDefaultName isEqualToString:placeholderName]) {
      textField.text = nil;
      [self.defaults setObject:placeholderName forKey:playerKey];
    } else {
      textField.text = [self.defaults objectForKey:playerKey];
    }
  }
  
  [self centreTextFieldsAndButtons];
}

-(void)centreTextFieldsAndButtons {
  

  
  for (int i = 0; i < self.playerNameFields.count; i++) {
    
    CGFloat topPadding = i != 0 ? kLocalGameTopPadding : 0;
    
    UITextField *playerNameField = self.playerNameFields[i];
    playerNameField.frame = CGRectMake(kChildVCSideMargin, kChildVCTopMargin + (kLocalGameTextFieldHeight + topPadding) * i, self.view.frame.size.width - kChildVCSideMargin * 2 - kLocalGameButtonWidth, kLocalGameTextFieldHeight);
    playerNameField.layer.cornerRadius = kLocalGameButtonWidth * 0.125f;
    playerNameField.layer.borderColor = kPlayerLightOrange.CGColor;
    playerNameField.layer.borderWidth = 1.f;
    playerNameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kLocalGameButtonWidth * 0.125, 10)];
    playerNameField.leftViewMode = UITextFieldViewModeAlways;
    
    playerNameField.borderStyle = UITextBorderStyleNone;
    
    UIButton *playerButton = self.playerButtons[i];
    playerButton.frame = CGRectMake(0, 0, kLocalGameButtonWidth, kLocalGameTextFieldHeight);
    playerButton.center = CGPointMake(self.view.frame.size.width - kChildVCSideMargin - kLocalGameButtonWidth / 2, kChildVCTopMargin + (kLocalGameTextFieldHeight + topPadding) * (i + 0.5f));
  }
  
  [self centreStartSelfButton];
}

-(void)centreStartSelfButton {
  [self.startSelfOrPnPGameButton sizeToFit];
  self.startSelfOrPnPGameButton.center = CGPointMake(self.view.frame.size.width / 2, kChildVCTopMargin + kLocalGameTextFieldHeight * 4 + kLocalGameTopPadding * 3 + kChildVCButtonSize / 2);
}

#pragma mark - state change methods

-(void)saveNameForPlayerIndex:(NSUInteger)index {
  
  UITextField *textField = self.playerNameFields[index];
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
  }
}

#pragma mark - button methods

-(void)changeStartSelfOrPnPGameButtonText {
  NSUInteger numberOfPlayers = self.selectedPlayerCount;
  if (numberOfPlayers == 0) {
    [self.startSelfOrPnPGameButton setTitle:@"Choose a player" forState:UIControlStateNormal];
  } else if (numberOfPlayers == 1) {
    [self.startSelfOrPnPGameButton setTitle:@"Start solo game" forState:UIControlStateNormal];
  } else if (numberOfPlayers >= 2) {
    NSString *numberText;
    switch (numberOfPlayers) {
      case 2:
        numberText = @"two";
        break;
      case 3:
        numberText = @"three";
        break;
      case 4:
        numberText = @"four";
        break;
      default:
        break;
    }
    NSString *gameText = [NSString stringWithFormat:@"Start %@-player game", numberText];
    [self.startSelfOrPnPGameButton setTitle:gameText forState:UIControlStateNormal];
  }
  [self centreStartSelfButton];
}

-(IBAction)startSelfOrPnpGameTapped:(id)sender {
}

-(IBAction)startSelfOrPnPGameLifted:(id)sender {
  
    // ensure at least one button is selected
  BOOL atLeastOneButtonSelected = NO;
  for (UIButton *button in self.playerButtons) {
    if (button.selected) {
      atLeastOneButtonSelected = YES;
    }
  }
  
  if (!atLeastOneButtonSelected) {
    return;
  }
  
    // this resigns text field and saves names
  [self resignTextField:nil];
  
  NSMutableArray *tempSelectedPlayers = [NSMutableArray new];
  for (int i = 0; i < kMaxNumPlayers; i++) {
    UIButton *button = self.playerButtons[i];
    if (button.selected) {
      NSString *playerName = [self.defaults objectForKey:self.playerKeys[i]];
      [tempSelectedPlayers addObject:playerName];
    }
  }
  
  [self.delegate startSelfOrPnPGameWithPlayerNames:[NSArray arrayWithArray:tempSelectedPlayers]];
}

-(IBAction)buttonTapped:(UIButton *)button {
}

-(IBAction)buttonLifted:(UIButton *)button {
  
  NSUInteger index = [self.playerButtons indexOfObject:button];
  UITextField *textField = self.playerNameFields[index];
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
  
  self.startSelfOrPnPGameButton.enabled = (self.selectedPlayerCount == 0 || [self checkTextFieldFirstResponder]) ? NO : YES;
  [self changeStartSelfOrPnPGameButtonText];
}

-(void)initialiseButtonAndTextFieldState {
  
  self.selectedPlayerCount = 1;
  [self changeStartSelfOrPnPGameButtonText];
  
  self.player1Button.selected = YES;
  self.player1NameField.backgroundColor = kMainLighterYellow;
  
  for (int i = 1; i < 4; i++) {
    UIButton *button = self.playerButtons[i];
    UITextField *textField = self.playerNameFields[i];
    button.selected = NO;
    textField.backgroundColor = kEndedMatchCellLightColour;
    textField.textColor = [UIColor darkGrayColor];
  }
  
  self.startSelfOrPnPGameButton.enabled = (self.selectedPlayerCount == 0) ? NO : YES;
}

#pragma mark - text field methods

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
  return !(newString.length > (kIsIPhone ? 16 : 20));
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
  
    // automatically push join button
  UIButton *playerButton = self.playerButtons[[self.playerNameFields indexOfObject:textField]];
  playerButton.selected ? nil : [self buttonLifted:playerButton];
  
  self.startSelfOrPnPGameButton.enabled = NO;
  
  [self.delegate disableOverlay];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
  [self resignTextField:textField];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self resignTextField:textField];
  return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self resignTextField:nil];
}

-(void)resignTextField:(UITextField *)textField {
  textField = !textField ? [self checkTextFieldFirstResponder] : textField;
  
  if (textField) {
    [textField resignFirstResponder];
    
      // save names in all text fields
    for (int i = 0; i < self.playerNameFields.count; i++) {
      [self saveNameForPlayerIndex:i];
    }
    
    self.startSelfOrPnPGameButton.enabled = (self.selectedPlayerCount == 0) ? NO : YES;
    [self.delegate enableOverlay];
  }
}

-(UITextField *)checkTextFieldFirstResponder {
  
  for (UITextField *textField in self.playerNameFields) {
    if ([textField isFirstResponder]) {
      return textField;
    }
  }
  return nil;
}

-(void)dealloc {
  NSLog(@"Local VC deallocated.");
}

@end
