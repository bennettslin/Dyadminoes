//
//  DebugViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 5/19/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "DebugViewController.h"
#import "NSObject+Helper.h"
#import "Match.h"
#import "Player.h"

@interface DebugViewController () <MatchDelegate>

@property (weak, nonatomic) IBOutlet UILabel *player1Name;
@property (weak, nonatomic) IBOutlet UILabel *player2Name;
@property (weak, nonatomic) IBOutlet UILabel *player3Name;
@property (weak, nonatomic) IBOutlet UILabel *player4Name;

@property (weak, nonatomic) IBOutlet UILabel *score1Label;
@property (weak, nonatomic) IBOutlet UILabel *score2Label;
@property (weak, nonatomic) IBOutlet UILabel *score3Label;
@property (weak, nonatomic) IBOutlet UILabel *score4Label;

@property (weak, nonatomic) IBOutlet UILabel *rack1Label;
@property (weak, nonatomic) IBOutlet UILabel *rack2Label;
@property (weak, nonatomic) IBOutlet UILabel *rack3Label;
@property (weak, nonatomic) IBOutlet UILabel *rack4Label;

@property (weak, nonatomic) IBOutlet UILabel *thisTurnDyadminoes;

@property (weak, nonatomic) IBOutlet UILabel *dyadminoesOnBoardLabel;
@property (weak, nonatomic) IBOutlet UILabel *dyadminoesInPileLabel;

@property (weak, nonatomic) IBOutlet UILabel *winnerLabel;

@property (weak, nonatomic) IBOutlet UIButton *dyadmino1Button;
@property (weak, nonatomic) IBOutlet UIButton *dyadmino2Button;
@property (weak, nonatomic) IBOutlet UIButton *dyadmino3Button;
@property (weak, nonatomic) IBOutlet UIButton *dyadmino4Button;
@property (weak, nonatomic) IBOutlet UIButton *dyadmino5Button;
@property (weak, nonatomic) IBOutlet UIButton *dyadmino6Button;

@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;
@property (weak, nonatomic) IBOutlet UIButton *swapAllButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *resignButton;

@property (strong, nonatomic) NSArray *playerLabelsArray;
@property (strong, nonatomic) NSArray *scoreLabelsArray;
@property (strong, nonatomic) NSArray *rackLabelsArray;
@property (strong, nonatomic) NSArray *dyadminoButtonsArray;

@property (strong, nonatomic) NSMutableArray *holdingContainer;

@end

@implementation DebugViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  self.myMatch.delegate = self;
    
  self.holdingContainer = [[NSMutableArray alloc] initWithCapacity:kNumDyadminoesInRack];
  [self updateHoldingContainerLabel];

  self.dyadminoButtonsArray = @[self.dyadmino1Button, self.dyadmino2Button, self.dyadmino3Button, self.dyadmino4Button, self.dyadmino5Button, self.dyadmino6Button];
  
  [self hideAllDyadminoButtons];
  
  self.playerLabelsArray = @[self.player1Name, self.player2Name, self.player3Name, self.player4Name];
  self.scoreLabelsArray = @[self.score1Label, self.score2Label, self.score3Label, self.score4Label];
  self.rackLabelsArray = @[self.rack1Label, self.rack2Label, self.rack3Label, self.rack4Label];
  
  for (UILabel *label in self.playerLabelsArray) {
    label.text = @"";
  }
  
  for (UILabel *label in self.scoreLabelsArray) {
    label.text = @"";
  }
  
  for (UILabel *label in self.rackLabelsArray) {
    label.text = @"";
  }
  
  self.winnerLabel.text = @"";
  
  if (self.myMatch.wonPlayers.count > 0) {
    [self hideAllButtonsForEndGame];
  }
  
  [self setProperties];
}

-(void)setProperties {
  
    // does this adequately hide buttons when rack is less than full?
  if (!self.myMatch.gameHasEnded) {
    Player *currentPlayer = self.myMatch.currentPlayer;
    for (int i = 0; i < currentPlayer.dyadminoesInRack.count; i++) {
      UIButton *button = self.dyadminoButtonsArray[i];
      NSString *title = [NSString stringWithFormat:@"%li", (long)[currentPlayer.dyadminoesInRack[i] integerValue]];
      [button setTitle:title forState:UIControlStateNormal];
      button.enabled = YES;
      button.hidden = NO;
    }
  } else { // game has ended
    [self hideAllDyadminoButtons];
    if (self.myMatch.wonPlayers.count > 0) {
      
      NSMutableArray *wonPlayerNames = [[NSMutableArray alloc] initWithCapacity:self.myMatch.wonPlayers.count];
      for (Player *player in self.myMatch.wonPlayers) {
        [wonPlayerNames addObject:player.playerName];
      }
      
      NSString *wonPlayers = [wonPlayerNames componentsJoinedByString:@" and "];
      self.winnerLabel.text = [NSString stringWithFormat:@"%@ won!", wonPlayers];
    } else {
      self.winnerLabel.text = @"Game ended in draw.";
    }
  }

  self.dyadminoesInPileLabel.text = [self.myMatch.pile componentsJoinedByString:@", "];
  self.dyadminoesOnBoardLabel.text = [self.myMatch.board componentsJoinedByString:@", "];
  
  for (Player *player in self.myMatch.players) {
    NSUInteger playerIndex = [self.myMatch.players indexOfObject:player];
    UILabel *playerLabel = self.playerLabelsArray[playerIndex];
    UILabel *scoreLabel = self.scoreLabelsArray[playerIndex];
    UILabel *rackLabel = self.rackLabelsArray[playerIndex];
    
    playerLabel.text = player.playerName;
    
    if (player.resigned) {
      playerLabel.textColor = [UIColor lightGrayColor];
    } else if (player == self.myMatch.currentPlayer) {
      playerLabel.textColor = [UIColor orangeColor];
    } else if ([self.myMatch.wonPlayers containsObject:player]) {
      playerLabel.textColor = [UIColor greenColor];
    } else {
      playerLabel.textColor = [UIColor blackColor];
    }

    scoreLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)player.playerScore];
    rackLabel.text = [player.dyadminoesInRack componentsJoinedByString:@", "];
  }
}

-(void)updateHoldingContainerLabel {
  if (self.holdingContainer.count > 0) {
    self.thisTurnDyadminoes.text = [NSString stringWithFormat:@"Dyadminoes to play: %@", [self.holdingContainer componentsJoinedByString:@", "]];
  } else {
    self.thisTurnDyadminoes.text = @"";
  }
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleEndGame {
  [self hideAllButtonsForEndGame];
  [self setProperties];
}

#pragma mark - button methods

-(IBAction)dyadminoTapped:(id)sender {
  UIButton *senderButton = (UIButton *)sender;
  if (![self.dyadminoButtonsArray containsObject:senderButton]) {
    return;
  }
  
  NSUInteger index = [self.dyadminoButtonsArray indexOfObject:senderButton];
  if (![self.holdingContainer containsObject:self.myMatch.currentPlayer.dyadminoesInRack[index]]) {
    [self.holdingContainer addObject:self.myMatch.currentPlayer.dyadminoesInRack[index]];
    senderButton.hidden = YES;
    senderButton.enabled = NO;
    [self updateHoldingContainerLabel];
  }
}

-(IBAction)undoTapped:(id)sender {
}

-(IBAction)redoTapped:(id)sender {
}

-(IBAction)swapAllTapped:(id)sender {
}

-(IBAction)doneTapped:(id)sender {
  [self.myMatch recordDyadminoes:self.holdingContainer fromPlayer:self.myMatch.currentPlayer];
  [self.holdingContainer removeAllObjects];
  [self updateHoldingContainerLabel];
  [self setProperties];
}

- (IBAction)resignButton:(id)sender {
  [self.myMatch resignPlayer:self.myMatch.currentPlayer];
  [self.holdingContainer removeAllObjects];
  [self setProperties];
}

-(void)hideAllButtonsForEndGame {
  self.undoButton.hidden = YES;
  self.undoButton.enabled = NO;
  self.redoButton.hidden = YES;
  self.redoButton.enabled = NO;
  self.swapAllButton.hidden = YES;
  self.swapAllButton.enabled = NO;
  self.doneButton.hidden = YES;
  self.doneButton.enabled = NO;
  self.resignButton.hidden = YES;
  self.resignButton.enabled = NO;
}

-(void)hideAllDyadminoButtons {
  for (UIButton *button in self.dyadminoButtonsArray) {
    [button setTitle:@"" forState:UIControlStateNormal];
    button.hidden = YES;
    button.enabled = NO;
  }
}

@end
