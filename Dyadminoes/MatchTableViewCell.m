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
#import "CellBackgroundView.h"
#import "StavesView.h"
#import "UIImage+colouredImage.h"

  // TODO: verify this
#define kPlayerLabelWidth (kIsIPhone ? 54.f : 109.f)
#define kPlayerLabelHeightPadding 7.5f
#define kPlayerLabelWidthPadding 22.5f
#define kScoreLabelWidth (kPlayerLabelWidthPadding / 2)
#define kScoreLabelHeight (kScoreLabelWidth * 3)
#define kMaxNumPlayers 4

@interface MatchTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *player1Label;
@property (weak, nonatomic) IBOutlet UILabel *player2Label;
@property (weak, nonatomic) IBOutlet UILabel *player3Label;
@property (weak, nonatomic) IBOutlet UILabel *player4Label;

@property (strong, nonatomic) CellBackgroundView *player1LabelView;
@property (strong, nonatomic) CellBackgroundView *player2LabelView;
@property (strong, nonatomic) CellBackgroundView *player3LabelView;
@property (strong, nonatomic) CellBackgroundView *player4LabelView;

@property (weak, nonatomic) IBOutlet UILabel *score1Label;
@property (weak, nonatomic) IBOutlet UILabel *score2Label;
@property (weak, nonatomic) IBOutlet UILabel *score3Label;
@property (weak, nonatomic) IBOutlet UILabel *score4Label;

@property (weak, nonatomic) IBOutlet UILabel *lastPlayedLabel;

@property (strong, nonatomic) UIImageView *clefImage;
@property (strong, nonatomic) NSArray *fermataImageViewArray;

@property (strong, nonatomic) NSArray *playerLabelsArray;
@property (strong, nonatomic) NSArray *playerLabelViewsArray;
@property (strong, nonatomic) NSArray *scoreLabelsArray;

@property (strong, nonatomic) StavesView *stavesView;

@end

@implementation MatchTableViewCell

-(void)awakeFromNib {
  
    // colour when cell is selected
  UIView *customColorView = [[UIView alloc] init];
  self.selectedBackgroundView = customColorView;
  
  self.playerLabelsArray = @[self.player1Label, self.player2Label, self.player3Label, self.player4Label];
  
  self.player1LabelView = [[CellBackgroundView alloc] init];
  self.player2LabelView = [[CellBackgroundView alloc] init];
  self.player3LabelView = [[CellBackgroundView alloc] init];
  self.player4LabelView = [[CellBackgroundView alloc] init];
  self.playerLabelViewsArray = @[self.player1LabelView, self.player2LabelView, self.player3LabelView, self.player4LabelView];
  
  self.scoreLabelsArray = @[self.score1Label, self.score2Label, self.score3Label, self.score4Label];
  
  for (int i = 0; i < 4; i++) {
    UILabel *playerLabel = self.playerLabelsArray[i];
    playerLabel.font = [UIFont fontWithName:kPlayerNameFont size:kIsIPhone ? 24.f : 32.f];
    CellBackgroundView *labelView = self.playerLabelViewsArray[i];
    [self insertSubview:labelView belowSubview:playerLabel];
    
    UILabel *scoreLabel = self.scoreLabelsArray[i];
    scoreLabel.font = [UIFont fontWithName:kPlayerNameFont size:kIsIPhone ? 12.f : 20.f];
    scoreLabel.textColor = [UIColor brownColor];
    scoreLabel.frame = CGRectMake(scoreLabel.frame.origin.x, scoreLabel.frame.origin.y, kScoreLabelWidth, kScoreLabelHeight);
  }
  
  self.lastPlayedLabel.adjustsFontSizeToFitWidth = YES;
  self.lastPlayedLabel.frame = CGRectMake(self.lastPlayedLabel.frame.origin.x, (self.frame.size.height / 10) * 11,
                                          self.lastPlayedLabel.frame.size.width, self.lastPlayedLabel.frame.size.height);
  
  self.stavesView = [[StavesView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 90.f + kCellSeparatorBuffer)];
  [self insertSubview:self.stavesView belowSubview:self.selectedBackgroundView];
  
  self.clefImage = [UIImageView new];
  self.clefImage.frame = CGRectMake(kStaveXBuffer, kStaveYHeight * 4, kStaveYHeight * 4, kStaveYHeight * 4);
  [self addSubview:self.clefImage];
  
  UIImage *fermataImage = [UIImage imageNamed:@"fermata-med"];
  fermataImage = [UIImage colourImage:fermataImage withColor:kStaveEndedGameColour];
  NSMutableArray *tempFermataImageViewArray = [NSMutableArray new];
  for (int i = 0; i < 4; i++) {
    UIImageView *fermataImageView = [[UIImageView alloc] initWithImage:fermataImage];
    [tempFermataImageViewArray addObject:fermataImageView];
  }
  self.fermataImageViewArray = [NSArray arrayWithArray:tempFermataImageViewArray];
}

-(void)setProperties {

//  NSLog(@"setProperties");
//  NSLog(@"random number is %li", (long)self.myMatch.randomNumber1To24);
  
  self.stavesView.gameHasEnded = self.myMatch.gameHasEnded;
  [self.stavesView setNeedsDisplay];
  
  UIImage *clefImage = (self.myMatch.players.count == 1) ?
      [UIImage imageNamed:@"treble-clef-med"] : [UIImage imageNamed:@"bass-clef-md"];
  UIColor *clefColour = self.myMatch.gameHasEnded ? kStaveEndedGameColour : kStaveColour;
  UIImage *colouredImage = [UIImage colourImage:clefImage withColor:clefColour];
  self.clefImage.image = colouredImage;
  self.clefImage.contentMode = UIViewContentModeScaleAspectFit;

    // remove fermatas, they will be decided later
  for (UIImageView *fermataImageView in self.fermataImageViewArray) {
    [fermataImageView removeFromSuperview];
  }
  
  if (self.myMatch) {
    
    for (int i = 0; i < kMaxNumPlayers; i++) {
      Player *player;
      
      if (i < self.myMatch.players.count) {
        player = self.myMatch.players[i];
      }
      
      UILabel *playerLabel = self.playerLabelsArray[i];
      CellBackgroundView *labelView = self.playerLabelViewsArray[i];
      UILabel *scoreLabel = self.scoreLabelsArray[i];

        // score label
      scoreLabel.text = (player && !player.resigned) ? [NSString stringWithFormat:@"%lu", (unsigned long)player.playerScore] : @"";
      scoreLabel.adjustsFontSizeToFitWidth = YES;
      
        // player label
      playerLabel.text = player ? player.playerName : @"";
      [playerLabel sizeToFit];
      
        // frame width can never be greater than maximum label width
      CGFloat playerLabelFrameWidth = (playerLabel.frame.size.width > kPlayerLabelWidth) ?
          kPlayerLabelWidth : playerLabel.frame.size.width;
      playerLabel.frame = CGRectMake(kStaveXBuffer + kStaveWidthDivision + (i * kStaveWidthDivision * 2), playerLabel.frame.origin.y, playerLabelFrameWidth, playerLabel.frame.size.height);
      
        // make font size smaller if it can't fit
      playerLabel.adjustsFontSizeToFitWidth = YES;
      labelView.frame = CGRectMake(0, 0, playerLabel.frame.size.width + kPlayerLabelWidthPadding + kScoreLabelWidth, playerLabel.frame.size.height + kPlayerLabelHeightPadding);

      labelView.layer.cornerRadius = labelView.frame.size.height / 2;
      labelView.clipsToBounds = YES;

        // static player colours, check if player resigned
      playerLabel.textColor = (player.resigned && self.myMatch.type != kSelfGame) ?
          kResignedGray : [self.myMatch colourForPlayer:player];
      
        // background colours depending on match results
      labelView.backgroundColourCanBeChanged = YES;
      if (!self.myMatch.gameHasEnded && player == self.myMatch.currentPlayer) {
        labelView.backgroundColor = [kMainDarkerYellow colorWithAlphaComponent:0.8f];
      } else if (self.myMatch.gameHasEnded && [self.myMatch.wonPlayers containsObject:player]) {
//        labelView.backgroundColor = [kEndedMatchCellDarkColour colorWithAlphaComponent:0.8f];
        labelView.backgroundColor = [UIColor clearColor]; // I've decided just fermata, no background for won player
        UIImageView *fermataImageView = self.fermataImageViewArray[i];
        [self addSubview:fermataImageView];
        
      } else {
        labelView.backgroundColor = [UIColor clearColor];
      }
      labelView.backgroundColourCanBeChanged = NO;
    }
    
    if (self.myMatch.gameHasEnded) {
      
      self.selectedBackgroundView.backgroundColor = kEndedMatchCellSelectedColour;
      self.backgroundColor = kEndedMatchCellLightColour;
      
        // game ended, so lastPlayed label shows date
      self.lastPlayedLabel.text = [self returnGameEndedDateStringFromDate:self.myMatch.lastPlayed];
      
    } else {
      self.selectedBackgroundView.backgroundColor = kMainSelectedYellow;
      self.backgroundColor = kMainLighterYellow;
      
        // game still in play, so lastPlayed label shows time since last played
      self.lastPlayedLabel.text = [self returnLastPlayedStringFromDate:self.myMatch.lastPlayed
                                                               started:(self.myMatch.turns.count == 0 ? YES : NO)];
    }
  }
  
  [self determinePlayerLabelPositionsBasedOnScores];
}

#pragma mark - view helper methods

-(void)determinePlayerLabelPositionsBasedOnScores {
  
  int tempPositionArray[kMaxNumPlayers] = {};
  NSUInteger maxPosition = 1;
  
  for (int i = 0; i < kMaxNumPlayers; i++) {
    if (i < self.myMatch.players.count) {
      int iPosition = tempPositionArray[i];
      iPosition++;
      tempPositionArray[i] = iPosition;
      
      for (int j = 0; j < i; j++) {
        if (i != j) {
          Player *playerI = self.myMatch.players[i];
          NSUInteger playerIScore = playerI.playerScore;
          Player *playerJ = self.myMatch.players[j];
          NSUInteger playerJScore = playerJ.playerScore;
          if (playerIScore > playerJScore) {
            
              // ensure that no other player is tied with player J
              // since that means player I was already incremented
            BOOL alreadyIncremented = NO;
            for (int k = 0; k < i; k++) {
              if (k != i && k != j) {
                if (tempPositionArray[k] == tempPositionArray[j]) {
                  alreadyIncremented = YES;
                }
              }
            }
            
            if (!alreadyIncremented) {
              int iPosition = tempPositionArray[i];
              iPosition++;
              tempPositionArray[i] = iPosition;
            }

            if (tempPositionArray[i] > maxPosition) {
              maxPosition = tempPositionArray[i];
            }

          } else if (playerJScore > playerIScore) {
            
            BOOL alreadyIncremented = NO;
            for (int k = 0; k < i; k++) {
              if (k != i && k != j) {
                if (tempPositionArray[k] == tempPositionArray[i]) {
                  alreadyIncremented = YES;
                }
              }
            }
            
            if (!alreadyIncremented) {
              int jPosition = tempPositionArray[j];
              jPosition++;
              tempPositionArray[j] = jPosition;
            }
            
            if (tempPositionArray[j] > maxPosition) {
              maxPosition = tempPositionArray[j];
            }
          }
        }
      }
    }
  }

  for (int i = 0; i < kMaxNumPlayers; i++) {
//    NSLog(@"Player %i position is %i", i, tempPositionArray[i]);

    UILabel *playerLabel = self.playerLabelsArray[i];
    CellBackgroundView *labelView = self.playerLabelViewsArray[i];
    UILabel *scoreLabel = self.scoreLabelsArray[i];
    NSUInteger position = tempPositionArray[i];

    playerLabel.frame = CGRectMake(playerLabel.frame.origin.x, [self labelHeightForMaxPosition:maxPosition andPlayerPosition:position],
                                   playerLabel.frame.size.width, playerLabel.frame.size.height);
    labelView.center = CGPointMake(playerLabel.center.x + (kScoreLabelWidth / 2), playerLabel.center.y - kPlayerLabelWidthPadding * 0.1f);
    scoreLabel.frame = CGRectMake(playerLabel.frame.origin.x + playerLabel.frame.size.width + (kPlayerLabelWidthPadding / 4), playerLabel.frame.origin.y, scoreLabel.frame.size.width, scoreLabel.frame.size.height);
    
    UIImageView *fermataImageView = self.fermataImageViewArray[i];
    if (fermataImageView.superview) {
      fermataImageView.frame = CGRectMake(playerLabel.frame.origin.x, kStaveYHeight, kStaveYHeight * 2, kStaveYHeight * 2);
      
      fermataImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
  }
}

-(CGFloat)labelHeightForMaxPosition:(NSUInteger)maxPosition andPlayerPosition:(NSUInteger)playerPosition {

  CGFloat multiplier = 0;
  
  switch (maxPosition) {
    case 4:
      multiplier = 10 - (playerPosition) - 1;
      break;
    case 3:
      multiplier = 10 - (playerPosition) - 1.5;
      break;
    case 2:
      multiplier = 10 - (playerPosition) - 2;
      break;
    case 1:
      multiplier = 10 - (playerPosition) - 2.5;
      break;
  }
  return (multiplier - 3) * kStaveYHeight - (kPlayerLabelHeightPadding * 0.25f);
}

@end
