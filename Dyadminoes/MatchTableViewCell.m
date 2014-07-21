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
#import "BackgroundView.h"

  // TODO: verify this
#define kLabelWidth (kIsIPhone ? 54.f : 109.f)
#define kPlayerLabelHeightPadding 7.5f
#define kPlayerLabelWidthPadding 22.5f

@interface MatchTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *player1Label;
@property (weak, nonatomic) IBOutlet UILabel *player2Label;
@property (weak, nonatomic) IBOutlet UILabel *player3Label;
@property (weak, nonatomic) IBOutlet UILabel *player4Label;

@property (strong, nonatomic) BackgroundView *player1LabelView;
@property (strong, nonatomic) BackgroundView *player2LabelView;
@property (strong, nonatomic) BackgroundView *player3LabelView;
@property (strong, nonatomic) BackgroundView *player4LabelView;

@property (weak, nonatomic) IBOutlet UILabel *score1Label;
@property (weak, nonatomic) IBOutlet UILabel *score2Label;
@property (weak, nonatomic) IBOutlet UILabel *score3Label;
@property (weak, nonatomic) IBOutlet UILabel *score4Label;

@property (weak, nonatomic) IBOutlet UILabel *lastPlayedLabel;
@property (weak, nonatomic) IBOutlet UILabel *winnerLabel;

@property (strong, nonatomic) NSArray *playerLabelsArray;
@property (strong, nonatomic) NSArray *playerLabelViewsArray;
@property (strong, nonatomic) NSArray *scoreLabelsArray;

@end

@implementation MatchTableViewCell

-(void)awakeFromNib {
  
  self.playerLabelsArray = @[self.player1Label, self.player2Label, self.player3Label, self.player4Label];
  
  self.player1LabelView = [[BackgroundView alloc] init];
  self.player2LabelView = [[BackgroundView alloc] init];
  self.player3LabelView = [[BackgroundView alloc] init];
  self.player4LabelView = [[BackgroundView alloc] init];
  self.playerLabelViewsArray = @[self.player1LabelView, self.player2LabelView, self.player3LabelView, self.player4LabelView];
  
  self.scoreLabelsArray = @[self.score1Label, self.score2Label, self.score3Label, self.score4Label];
  
  for (int i = 0; i < 4; i++) {
    UILabel *label = self.playerLabelsArray[i];
    label.font = [UIFont fontWithName:@"FilmotypeModern" size:kIsIPhone ? 12.f : 24.f];
    BackgroundView *labelView = self.playerLabelViewsArray[i];
    [self insertSubview:labelView belowSubview:label];
  }
  
  self.lastPlayedLabel.adjustsFontSizeToFitWidth = YES;
  self.winnerLabel.font = [UIFont fontWithName:@"FilmotypeHarmony" size:kIsIPhone ? 12.f : 24.f];
  self.winnerLabel.adjustsFontSizeToFitWidth = YES;
  
    // selected colour
  UIView *customColorView = [[UIView alloc] init];
  customColorView.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:.8f alpha:.8f];
  self.selectedBackgroundView = customColorView;
  
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
      BackgroundView *labelView = self.playerLabelViewsArray[i];
      UILabel *scoreLabel = self.scoreLabelsArray[i];

        // these should be loaded only once
        // put two spaces in front of player name
      playerLabel.text = player ? player.playerName : @"";
      [playerLabel sizeToFit];
      
        // frame width can never be greater than maximum label width
      if (playerLabel.frame.size.width > kLabelWidth) {
        playerLabel.frame = CGRectMake(playerLabel.frame.origin.x, playerLabel.frame.origin.y, kLabelWidth, playerLabel.frame.size.height);
      }
      
        // make font size smaller if it can't fit
      playerLabel.adjustsFontSizeToFitWidth = YES;
      labelView.frame = CGRectMake(0, 0, playerLabel.frame.size.width + kPlayerLabelWidthPadding, playerLabel.frame.size.height + kPlayerLabelHeightPadding);
      labelView.center = CGPointMake(playerLabel.center.x, playerLabel.center.y - kPlayerLabelWidthPadding * 0.1f);
      labelView.layer.cornerRadius = labelView.frame.size.height / 2;
      labelView.clipsToBounds = YES;

        // static player colours
      if (player.resigned && self.myMatch.type != kSelfGame) {
        playerLabel.textColor = [UIColor lightGrayColor];
      } else {
        playerLabel.textColor = [self.myMatch colourForPlayer:player];
      }
      
        // background colours depending on match results
      labelView.backgroundColourCanBeChanged = YES;
      if (!self.myMatch.gameHasEnded && player == self.myMatch.currentPlayer) {
        labelView.backgroundColor = [kNeutralYellow colorWithAlphaComponent:0.5f];
      } else if (self.myMatch.gameHasEnded && [self.myMatch.wonPlayers containsObject:player]) {
        labelView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5f];
      } else {
        labelView.backgroundColor = [UIColor clearColor];
      }
      labelView.backgroundColourCanBeChanged = NO;
      
      scoreLabel.text = player ? [NSString stringWithFormat:@"%lu", (unsigned long)player.playerScore] : @"";
    }
    
    if (self.myMatch.gameHasEnded) {
      
      self.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.1f];
      
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
