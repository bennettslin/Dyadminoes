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

  // TODO: verify this
#define kLabelWidth (kIsIPhone ? 54.f : 109.f)
#define kPlayerLabelHeightPadding 7.5f

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

@property (strong, nonatomic) NSArray *playerLabelsArray;
@property (strong, nonatomic) NSArray *scoreLabelsArray;

@end

@implementation MatchTableViewCell

-(void)awakeFromNib {
  
  self.playerLabelsArray = @[self.player1Label, self.player2Label, self.player3Label, self.player4Label];
  self.scoreLabelsArray = @[self.score1Label, self.score2Label, self.score3Label, self.score4Label];
  
  for (UILabel *label in self.playerLabelsArray) {
    label.layer.cornerRadius = (label.frame.size.height + kPlayerLabelHeightPadding) / 2;
    label.clipsToBounds = YES;
    label.font = [UIFont fontWithName:@"FilmotypeModern" size:kIsIPhone ? 12.f : 24.f];
  }
  
  self.lastPlayedLabel.adjustsFontSizeToFitWidth = YES;
  self.winnerLabel.font = [UIFont fontWithName:@"FilmotypeHarmony" size:kIsIPhone ? 12.f : 24.f];
  self.winnerLabel.adjustsFontSizeToFitWidth = YES;
  
  [self setProperties];
}

-(void)setProperties {
  
  self.winnerLabel.text = @"";
  
  if (self.myMatch) {
    
    for (int i = 0; i < kMaxNumPlayers; i++) {
      Player *player;
      
      if (i < self.myMatch.players.count) {
        player = self.myMatch.players[i];
      }
      
      UILabel *playerLabel = self.playerLabelsArray[i];
      UILabel *scoreLabel = self.scoreLabelsArray[i];

        // these should be loaded only once
        // put two spaces in front of player name
      playerLabel.text = player ? [NSString stringWithFormat:@"  %@", player.playerName] : @"";
      [playerLabel sizeToFit];
      
        // frame width can never be greater than maximum label width
      if (playerLabel.frame.size.width > kLabelWidth) {
        playerLabel.frame = CGRectMake(playerLabel.frame.origin.x, playerLabel.frame.origin.y,kLabelWidth, playerLabel.frame.size.height);
      }

        // make font size smaller if it can't fit
      playerLabel.adjustsFontSizeToFitWidth = YES;
      
//      playerLabel.frame = CGRectMake(playerLabel.frame.origin.x - 10.f, playerLabel.frame.origin.y, playerLabel.frame.size.width + 10.f, playerLabel.frame.size.height + kPlayerLabelHeightPadding);

        // static player colours
      if (player.resigned && self.myMatch.type != kSelfGame) {
        playerLabel.textColor = [UIColor lightGrayColor];
      } else {
        playerLabel.textColor = [self.myMatch colourForPlayer:player];
      }
      
        // background colours depending on match results
      if (!self.myMatch.gameHasEnded && player == self.myMatch.currentPlayer) {
        playerLabel.backgroundColor = kNeutralYellow;
      } else if (self.myMatch.gameHasEnded && [self.myMatch.wonPlayers containsObject:player]) {
        playerLabel.backgroundColor = [UIColor greenColor];
      } else {
        playerLabel.backgroundColor = [UIColor clearColor];
      }
      
      scoreLabel.text = player ? [NSString stringWithFormat:@"%lu", (unsigned long)player.playerScore] : @"";
    }
    
    if (self.myMatch.gameHasEnded) {
      
      self.backgroundColor = [UIColor colorWithRed:1.f green:0.9f blue:0.9f alpha:0.8f];
      
        // game ended, so lastPlayed label shows date
      self.lastPlayedLabel.text = [self returnGameEndedDateStringFromDate:self.myMatch.lastPlayed];
      self.winnerLabel.text = [self.myMatch endGameResultsText];
      
    } else {
      
      self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
      
        // game still in play, so lastPlayed label shows time since last played
      self.lastPlayedLabel.text = [self returnLastPlayedStringFromDate:self.myMatch.lastPlayed];

    }
  }
}

@end
