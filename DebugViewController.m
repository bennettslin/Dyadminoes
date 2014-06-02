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
#import "DataDyadmino.h"
#import "SceneViewController.h"

@interface DebugViewController () <MatchDelegate>

@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *sceneButton;

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
@property (weak, nonatomic) IBOutlet UIButton *swapModeButton;
@property (weak, nonatomic) IBOutlet UIButton *replayModeButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *resignButton;

@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *lastButton;

@property (strong, nonatomic) NSArray *playerLabelsArray;
@property (strong, nonatomic) NSArray *scoreLabelsArray;
@property (strong, nonatomic) NSArray *rackLabelsArray;
@property (strong, nonatomic) NSArray *dyadminoButtonsArray;
@property (strong, nonatomic) NSArray *gamePlayButtonsArray;
@property (strong, nonatomic) NSArray *replayButtonsArray;

@property (nonatomic) BOOL swapMode;
@property (nonatomic) BOOL replayMode;

@property (weak, nonatomic) IBOutlet UILabel *turnLabel;

@end

@implementation DebugViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  self.myMatch.delegate = self;
  
  self.swapMode = YES;
  self.replayMode = YES;
  [self swapModeTapped:self.swapModeButton];
  [self replayModeTapped:self.replayModeButton];
    
  [self updateThisTurnDyadminoesLabel];

  self.dyadminoButtonsArray = @[self.dyadmino1Button, self.dyadmino2Button, self.dyadmino3Button, self.dyadmino4Button, self.dyadmino5Button, self.dyadmino6Button];

  self.gamePlayButtonsArray = @[self.undoButton, self.redoButton, self.swapModeButton, self.replayModeButton, self.resignButton, self.doneButton];
  self.replayButtonsArray = @[self.firstButton, self.backButton, self.forwardButton, self.lastButton];
  
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
  
  [self setProperties];
}

-(void)setProperties {
  
    // show turn
  if (self.myMatch.turns.count > 0) {
    Player *turnPlayer = [self.myMatch.turns[self.myMatch.replayCounter - 1] objectForKey:@"player"];
    NSArray *dyadminoesPlayed = [self.myMatch.turns[self.myMatch.replayCounter - 1] objectForKey:@"container"];
    NSString *dyadminoesPlayedString;
    if (dyadminoesPlayed.count > 0) {
      NSString *componentsString = [[dyadminoesPlayed valueForKey:kDyadminoIDKey] componentsJoinedByString:@", "];
      dyadminoesPlayedString = [NSString stringWithFormat:@"played %@", componentsString];
    } else {
      dyadminoesPlayedString = @"passed";
    }
    self.turnLabel.text = [NSString stringWithFormat:@"%@ %@ for turn %i of %lu", turnPlayer.playerName, dyadminoesPlayedString, self.myMatch.replayCounter, (unsigned long)self.myMatch.turns.count];
  }
  
    // game is still in play and not in replay mode
  if (!self.myMatch.gameHasEnded && !self.replayMode) {
    
      // not in swap mode
    if (!self.swapMode) {
      
        // initially, they're all to be shown
      [self showAllButtonsInArray:self.gamePlayButtonsArray];
      
        // hide swap mode button if holding container contains dyadminoes
      if (self.myMatch.holdingContainer.count > 0) {
        self.swapModeButton.hidden = YES;
        self.swapModeButton.enabled = NO;
      } else {
        self.swapModeButton.hidden = NO;
        self.swapModeButton.enabled = YES;
      }
      
        // undo and redo buttons
      if ([self.myMatch.undoManager canUndo]) {
        self.undoButton.enabled = YES;
        self.undoButton.hidden = NO;
      } else {
        self.undoButton.enabled = NO;
        self.undoButton.hidden = YES;
      }
      if ([self.myMatch.undoManager canRedo]) {
        self.redoButton.enabled = YES;
        self.redoButton.hidden = NO;
      } else {
        self.redoButton.enabled = NO;
        self.redoButton.hidden = YES;
      }

        //----------------------------------------------------------------------
      
        // in swap mode
    } else {      
      self.resignButton.enabled = NO;
      self.resignButton.hidden = YES;
      self.replayModeButton.enabled = NO;
      self.replayModeButton.hidden = YES;
      self.undoButton.enabled = NO;
      self.undoButton.hidden = YES;
      self.redoButton.enabled = NO;
      self.redoButton.hidden = YES;
    }
    
        //----------------------------------------------------------------------
    
      // either in swap mode or not
    
      // set whether dyadminoes are displayed
    Player *currentPlayer = self.myMatch.currentPlayer;
    for (int i = 0; i < currentPlayer.dataDyadminoesThisTurn.count; i++) {
      DataDyadmino *dyadmino = currentPlayer.dataDyadminoesThisTurn[i];
      UIButton *button = self.dyadminoButtonsArray[i];
      NSString *title = [NSString stringWithFormat:@"%li", (unsigned long)dyadmino.myID];
      [button setTitle:title forState:UIControlStateNormal];
      
      if ([self.myMatch.holdingContainer containsObject:dyadmino]) {
        button.enabled = NO;
        button.hidden = YES;
      } else {
        button.enabled = YES;
        button.hidden = NO;
      }
    }
    
      // done or pass or swap
    if (self.myMatch.holdingContainer.count > 0 && !self.swapMode) {
      [self.doneButton setTitle:@"DONE!" forState:UIControlStateNormal];
    } else if (self.swapMode) {
      [self.doneButton setTitle:@"Swap!" forState:UIControlStateNormal];
    } else {
      [self.doneButton setTitle:@"Pass" forState:UIControlStateNormal];
    }
    
      // hide replay buttons
    [self hideAllButtonsInArray:self.replayButtonsArray];
    
    self.dyadminoesInPileLabel.text = [[self.myMatch.pile valueForKey:kDyadminoIDKey] componentsJoinedByString:@", "];
    
    //--------------------------------------------------------------------------
    
  } else { // game has ended or is in replay mode
    
      // regardless of whether game has ended or is just in replay mode
    [self hideAllButtonsInArray:self.dyadminoButtonsArray];
    [self hideAllButtonsInArray:self.gamePlayButtonsArray];
    
      // show replay buttons
    [self showAllButtonsInArray:self.replayButtonsArray];
    
    self.dyadminoesInPileLabel.text = @"";
    
        //----------------------------------------------------------------------
    
      // game is in play, just in replay mode
    if (!self.myMatch.gameHasEnded) {
      
        // allow replay mode button
      if (!self.myMatch.gameHasEnded) {
        self.replayModeButton.enabled = YES;
        self.replayModeButton.hidden = NO;
      }

        //----------------------------------------------------------------------
      
        // game has ended
    } else {
      
        // show winner information
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
  }
  
    //--------------------------------------------------------------------------

    // regardless of whether game has ended
  self.dyadminoesOnBoardLabel.text = [[self.myMatch.board valueForKey:kDyadminoIDKey] componentsJoinedByString:@", "];
  
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
    rackLabel.text = [[player.dataDyadminoesThisTurn valueForKey:kDyadminoIDKey] componentsJoinedByString:@", "];
  }
}

-(void)updateThisTurnDyadminoesLabel {
  if (self.myMatch.holdingContainer.count > 0 && !self.replayMode) {
    self.thisTurnDyadminoes.text = [NSString stringWithFormat:@"Dyadminoes to play: %@", [[self.myMatch.holdingContainer valueForKey:kDyadminoIDKey] componentsJoinedByString:@", "]];
  } else {
    self.thisTurnDyadminoes.text = @"";
  }
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleEndGame {
  self.replayMode = NO;
  self.swapMode = NO;
  [self setProperties];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"realSceneSegue"]) {
    SceneViewController *sceneVC = [segue destinationViewController];
    sceneVC.myMatch = self.myMatch;
    sceneVC.myPlayer = self.myMatch.currentPlayer;
  }
}

#pragma mark - button methods

-(IBAction)homeTapped:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)dyadminoTapped:(id)sender {
  
    // doesn't matter whether in swap mode, whether swapped or played
    // will depend on done button method
  
  UIButton *senderButton = (UIButton *)sender;
  if (![self.dyadminoButtonsArray containsObject:senderButton]) {
    return;
  }
  
  NSUInteger index = [self.dyadminoButtonsArray indexOfObject:senderButton];
  if (![self.myMatch.holdingContainer containsObject:self.myMatch.currentPlayer.dataDyadminoesThisTurn[index]]) {
    [self.myMatch addToHoldingContainer:self.myMatch.currentPlayer.dataDyadminoesThisTurn[index]];
    [self setProperties];
    [self updateThisTurnDyadminoesLabel];
  }

}

-(IBAction)undoTapped:(id)sender {
  [self.myMatch undoDyadminoToHoldingContainer];
  [self setProperties];
  [self updateThisTurnDyadminoesLabel];
}

-(IBAction)redoTapped:(id)sender {
  [self.myMatch redoDyadminoToHoldingContainer];
  [self setProperties];
  [self updateThisTurnDyadminoesLabel];
}

-(IBAction)swapModeTapped:(id)sender {
  self.swapMode ^= YES;
  NSString *title = self.swapMode ? @"swap on" : @"swap off";
  UIColor *color = self.swapMode ? [UIColor orangeColor] : [UIColor lightGrayColor];
  [self.swapModeButton setTitle:title forState:UIControlStateNormal];
  [self.swapModeButton setBackgroundColor:color];
  [self.myMatch resetHoldingContainer];
  
  [self setProperties];
  [self updateThisTurnDyadminoesLabel];
}

-(IBAction)replayModeTapped:(id)sender {
  self.replayMode ^= YES;
  NSString *title = self.replayMode ? @"replay on" : @"replay off";
  UIColor *color = self.replayMode ? [UIColor orangeColor] : [UIColor lightGrayColor];
  [self.replayModeButton setTitle:title forState:UIControlStateNormal];
  [self.replayModeButton setBackgroundColor:color];
  
    // restore state
  if (!self.replayMode) {
    [self.myMatch lastOrLeaveReplay];
  }

  [self setProperties];
  [self updateThisTurnDyadminoesLabel];
}

-(IBAction)doneTapped:(id)sender {
  
    // submit for play
  if (!self.swapMode) {
    [self.myMatch recordDyadminoesFromPlayer:self.myMatch.currentPlayer];

  } else { // swap mode
      // not enough in pile!
    if (self.myMatch.holdingContainer.count > self.myMatch.pile.count) {
      UIAlertView *pileNotEnoughAlertView = [[UIAlertView alloc] initWithTitle:@"Low pile count" message:@"There aren't enough dyadminoes in the pile." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [pileNotEnoughAlertView show];
        // swap!
    } else {
      [self.myMatch swapDyadminoesFromPlayer:self.myMatch.currentPlayer];
      [self swapModeTapped:self.swapModeButton];
    }
  }
  
  [self updateThisTurnDyadminoesLabel];
  [self setProperties];
}

-(IBAction)resignButton:(id)sender {
  [self.myMatch resignPlayer:self.myMatch.currentPlayer];
  [self updateThisTurnDyadminoesLabel];
  [self setProperties];
}

-(IBAction)firstTapped:(id)sender {
  [self.myMatch first];
  [self setProperties];
}

-(IBAction)backTapped:(id)sender {
  [self.myMatch previous];
  [self setProperties];
}

-(IBAction)forwardTapped:(id)sender {
  [self.myMatch next];
  [self setProperties];
}

-(IBAction)lastTapped:(id)sender {
  [self.myMatch lastOrLeaveReplay];
  [self setProperties];
}

#pragma mark - button show/hide methods

-(void)hideAllButtonsInArray:(NSArray *)array {
  for (UIButton *button in array) {
    button.hidden = YES;
    button.enabled = NO;
  }
}

-(void)showAllButtonsInArray:(NSArray *)array {
  for (UIButton *button in array) {
    button.hidden = NO;
    button.enabled = YES;
  }
}

@end
