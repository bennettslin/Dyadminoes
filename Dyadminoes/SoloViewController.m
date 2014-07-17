//
//  SoloViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 7/1/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "SoloViewController.h"

#define kDefaultSoloName @"Ludwig van Beethoven"

@interface SoloViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *playerNameField;
@property (weak, nonatomic) IBOutlet UIButton *startGameButton;

@property (strong, nonatomic) NSUserDefaults *defaults;

@end

@implementation SoloViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.playerNameField.delegate = self;
  
  self.defaults = [NSUserDefaults standardUserDefaults];
}

-(void)viewWillAppear:(BOOL)animated {
  
    // FIXME: if no player name, try to get from Game Center *first*
  NSString *userDefaultString = [self.defaults objectForKey:@"soloName"];
  if (!userDefaultString || [userDefaultString isEqualToString:@""] || [userDefaultString isEqualToString:kDefaultSoloName]) {
    self.playerNameField.text = nil;
    [self.defaults setObject:kDefaultSoloName forKey:@"soloName"];
  } else {
    self.playerNameField.text = [self.defaults objectForKey:@"soloName"];
  }
}

-(IBAction)startGameTapped:(id)sender {
  [self.delegate startSoloGameWithPlayerName:[self.defaults objectForKey:@"soloName"]];
}

-(void)saveNewPlayerName {

  NSString *trimmedString = [self.playerNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if (![trimmedString isEqualToString:[self.defaults objectForKey:@"soloName"]]) {
    if (!trimmedString || [trimmedString isEqualToString:@""]) {
      [self.defaults setObject:kDefaultSoloName forKey:@"soloName"];
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
  [self resignTextField];
  return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self resignTextField];
}

-(void)resignTextField {
  [self.playerNameField resignFirstResponder];
  [self saveNewPlayerName];
  [self.delegate enableOverlay];
}

@end
