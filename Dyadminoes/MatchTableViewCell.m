//
//  MatchTableViewCell.m
//  Dyadminoes
//
//  Created by Bennett Lin on 5/19/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "MatchTableViewCell.h"
#import "NSObject+Helper.h"
#import "Match.h"
#import "Player.h"

@interface MatchTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *player1Label;
@property (weak, nonatomic) IBOutlet UILabel *player2Label;
@property (weak, nonatomic) IBOutlet UILabel *player3Label;
@property (weak, nonatomic) IBOutlet UILabel *player4Label;

@property (weak, nonatomic) IBOutlet UILabel *score1Label;
@property (weak, nonatomic) IBOutlet UILabel *score2Label;
@property (weak, nonatomic) IBOutlet UILabel *score3Label;
@property (weak, nonatomic) IBOutlet UILabel *score4Label;

@property (weak, nonatomic) IBOutlet UILabel *lastPlayedLabel;
@property (weak, nonatomic) IBOutlet UILabel *winnerLabel;

@property (weak, nonatomic) IBOutlet UIButton *removeGameButton;

@property (strong, nonatomic) NSArray *playerLabelsArray;
@property (strong, nonatomic) NSArray *scoreLabelsArray;

@end

@implementation MatchTableViewCell

-(void)awakeFromNib {
  
  self.playerLabelsArray = @[self.player1Label, self.player2Label, self.player3Label, self.player4Label];
  self.scoreLabelsArray = @[self.score1Label, self.score2Label, self.score3Label, self.score4Label];
  
  [self setProperties];
}

-(void)setProperties {
  
  self.winnerLabel.text = @"";
  
    // because some matches will have less than four players
  for (UILabel *label in self.playerLabelsArray) {
    label.text = @"";
  }
  for (UILabel *label in self.scoreLabelsArray) {
    label.text = @"";
  }
  
  if (self.myMatch) {
    
    for (Player *player in self.myMatch.players) {
      UILabel *playerLabel = self.playerLabelsArray[[self.myMatch.players indexOfObject:player]];
      UILabel *scoreLabel = self.scoreLabelsArray[[self.myMatch.players indexOfObject:player]];

      playerLabel.text = player.playerName;

      if (player.resigned && self.myMatch.type != kSelfGame) {
        playerLabel.textColor = [UIColor lightGrayColor];
      } else if (player == self.myMatch.currentPlayer) {
        playerLabel.textColor = [UIColor orangeColor];
      } else if ([self.myMatch.wonPlayers containsObject:player]) {
        playerLabel.textColor = [UIColor greenColor];
      } else {
        playerLabel.textColor = [UIColor blackColor];
      }
      
      scoreLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)player.playerScore];
    }
    
    if (self.myMatch.gameHasEnded) {
      
      self.backgroundColor = [UIColor colorWithRed:1.f green:0.9f blue:0.9f alpha:1.f];
      
        // game ended, so lastPlayed label shows date
      self.lastPlayedLabel.text = [self returnGameEndedDateStringFromDate:self.myMatch.lastPlayed];
      self.winnerLabel.text = [self.myMatch endGameResultsText];
      
      self.removeGameButton.hidden = NO;
      self.removeGameButton.enabled = YES;
      
    } else {
      
      self.backgroundColor = [UIColor clearColor];
      
        // game still in play, so lastPlayed label shows time since last played
      self.lastPlayedLabel.text = [self returnLastPlayedStringFromDate:self.myMatch.lastPlayed];

      self.removeGameButton.hidden = YES;
      self.removeGameButton.enabled = NO;
    }
  }
}

- (IBAction)removeGameTapped:(id)sender {
  if (self.myMatch.gameHasEnded) {
    [self.delegate removeMatch:self.myMatch];
  }
}

@end
