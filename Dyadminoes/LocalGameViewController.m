//
//  SoloViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 7/1/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "LocalGameViewController.h"


#define kDefaultPlayer1Name @"Hildegard"

@interface LocalGameViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *player1NameField;
@property (weak, nonatomic) IBOutlet UITextField *player2NameField;
@property (weak, nonatomic) IBOutlet UITextField *player3NameField;
@property (weak, nonatomic) IBOutlet UITextField *player4NameField;

@property (weak, nonatomic) IBOutlet UIButton *startGameButton;

@property (strong, nonatomic) NSUserDefaults *defaults;

@end

@implementation LocalGameViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.player1NameField.delegate = self;
  
  self.defaults = [NSUserDefaults standardUserDefaults];
}

-(void)viewWillAppear:(BOOL)animated {
  
    // FIXME: if no player name, try to get from Game Center *first*
  NSString *userDefaultString = [self.defaults objectForKey:@"soloName"];
  if (!userDefaultString || [userDefaultString isEqualToString:@""] || [userDefaultString isEqualToString:kDefaultPlayer1Name]) {
    self.player1NameField.text = nil;
    [self.defaults setObject:kDefaultPlayer1Name forKey:@"soloName"];
  } else {
    self.player1NameField.text = [self.defaults objectForKey:@"soloName"];
  }
}

-(IBAction)startGameTapped:(id)sender {

    // for all practical purposes, button will be covered by textField
    // so calling resignTextField is unnecessary
  
//  [self resignTextFieldWithOverlay:NO];
  [self.delegate startLocalGameWithPlayerName:[self.defaults objectForKey:@"soloName"]];
}



-(void)saveNewPlayerName {

  NSString *trimmedString = [self.player1NameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if (![trimmedString isEqualToString:[self.defaults objectForKey:@"soloName"]]) {
    if (!trimmedString || [trimmedString isEqualToString:@""]) {
      [self.defaults setObject:kDefaultPlayer1Name forKey:@"soloName"];
    } else {
      [self.defaults setObject:trimmedString forKey:@"soloName"];
    }
    [self.defaults synchronize];
    NSLog(@"newPlayerName is '%@'", [self.defaults objectForKey:@"soloName"]);
  }
}

#pragma mark - text field delegate methods

-(void)textFieldDidBeginEditing:(UITextField *)textField {
  [self.delegate disableOverlay];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self resignTextFieldWithOverlay:YES];
  return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self resignTextFieldWithOverlay:YES];
}


  // with overlay bool is unnecessary
-(void)resignTextFieldWithOverlay:(BOOL)overlay {
  [self.player1NameField resignFirstResponder];
  [self saveNewPlayerName];
  if (overlay) {
    [self.delegate enableOverlay];
  }
}

@end
