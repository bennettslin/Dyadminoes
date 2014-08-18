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

@interface MatchTableViewCell ()

@property (strong, nonatomic) NSArray *playerLabelsArray;
@property (strong, nonatomic) NSArray *scoreLabelsArray;
@property (strong, nonatomic) NSArray *fermataImageViewArray;

@property (strong, nonatomic) CellBackgroundView *labelView;
@property (strong, nonatomic) UILabel *lastPlayedLabel;
@property (strong, nonatomic) StavesView *stavesView;
@property (strong, nonatomic) UIImageView *clefImage;
@property (strong, nonatomic) UIImageView *quarterRestImage;
@property (strong, nonatomic) UIImageView *halfRestImage;


@end

@implementation MatchTableViewCell

-(void)awakeFromNib {
  
    // colour when cell is selected
  UIView *customColorView = [[UIView alloc] init];
  self.selectedBackgroundView = customColorView;
  self.accessoryType = UITableViewCellAccessoryNone;
  
    // labels for each player
  NSMutableArray *tempPlayerLabelsArray = [NSMutableArray new];
  NSMutableArray *tempScoreLabelsArray = [NSMutableArray new];
  
  for (int i = 0; i < kMaxNumPlayers; i++) {
    
    self.labelView = [[CellBackgroundView alloc] init];
    [self insertSubview:self.labelView atIndex:0];
    
    UILabel *playerLabel = [[UILabel alloc] init];
    playerLabel.font = [UIFont fontWithName:kFontModern size:(kIsIPhone ? (kCellRowHeight / 3.4) : (kCellRowHeight / 2.8125))];
    playerLabel.adjustsFontSizeToFitWidth = YES;
    playerLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [tempPlayerLabelsArray addObject:playerLabel];
    [self insertSubview:playerLabel aboveSubview:self.labelView];
    
    UILabel *scoreLabel = [[UILabel alloc] init];
    scoreLabel.font = [UIFont fontWithName:kFontModern size:(kCellRowHeight / 4.5)];
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    scoreLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:scoreLabel];
    [tempScoreLabelsArray addObject:scoreLabel];
  }
  
  self.playerLabelsArray = [NSArray arrayWithArray:tempPlayerLabelsArray];
  self.scoreLabelsArray = [NSArray arrayWithArray:tempScoreLabelsArray];

    // staves and clef
  self.stavesView = [[StavesView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, kCellWidth, kCellRowHeight + kCellSeparatorBuffer)];
  [self insertSubview:self.stavesView belowSubview:self.selectedBackgroundView];
  
  self.clefImage = [UIImageView new];
  self.clefImage.contentMode = UIViewContentModeScaleAspectFit;
  [self addSubview:self.clefImage];
  
  self.lastPlayedLabel = [[UILabel alloc] initWithFrame:CGRectMake(kStaveXBuffer, (kCellRowHeight / 10) * 11.5, kCellWidth - kStaveXBuffer * 2, kStaveYHeight * 2)];
  self.lastPlayedLabel.textAlignment = NSTextAlignmentRight;
  self.lastPlayedLabel.adjustsFontSizeToFitWidth = YES;
  self.lastPlayedLabel.font = [UIFont fontWithName:kFontHarmony size:(kIsIPhone ? 20.f : 22.f)];
  [self insertSubview:self.lastPlayedLabel aboveSubview:self.stavesView];
  
    // fermatas and rests are for iPad only
  if (!kIsIPhone) {
    NSMutableArray *tempFermataImageViewArray = [NSMutableArray new];
    for (int i = 0; i < kMaxNumPlayers; i++) {
      UIImageView *fermataImageView = [[UIImageView alloc] initWithImage:[UIImage colourImage:[UIImage imageNamed:@"fermata-med"] withColor:kStaveEndedGameColour]];
      fermataImageView.frame = CGRectMake(0, kStaveYHeight, kStaveYHeight * 2, kStaveYHeight * 2);
      fermataImageView.contentMode = UIViewContentModeScaleAspectFit;
      [tempFermataImageViewArray addObject:fermataImageView];
    }
    self.fermataImageViewArray = [NSArray arrayWithArray:tempFermataImageViewArray];
    
    self.quarterRestImage = [UIImageView new];
    self.quarterRestImage.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.quarterRestImage];
    
    self.halfRestImage = [UIImageView new];
    self.halfRestImage.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.halfRestImage];
  }
}

-(void)setProperties {
  
  NSUInteger turn = self.myMatch.turns.count;
  
    // backgroundColour and lastPlayedLabel are not async
  if (self.myMatch.gameHasEnded) {
    self.selectedBackgroundView.backgroundColor = kEndedMatchCellSelectedColour;
    self.backgroundColor = kEndedMatchCellLightColour;
    
      // game ended, so lastPlayed label shows date
    self.lastPlayedLabel.textColor = kStaveEndedGameColour;
    self.lastPlayedLabel.text = [self returnGameEndedDateStringFromDate:self.myMatch.lastPlayed andTurn:turn];
    
  } else {
    self.selectedBackgroundView.backgroundColor = kMainSelectedYellow;
    self.backgroundColor = kMainLighterYellow;
    
      // game still in play, so lastPlayed label shows time since last played
    self.lastPlayedLabel.textColor = kStaveColour;
    self.lastPlayedLabel.text = [self returnLastPlayedStringFromDate:self.myMatch.lastPlayed andTurn:turn];
  }
  
  dispatch_async(dispatch_get_main_queue(), ^{
    
    [self updateStaves];
    [self updateClef];
    
    if (!kIsIPhone) {
      [self updateRestImages];
      
        // remove fermatas for now, they will be decided with labelViews
      for (UIImageView *fermataImageView in self.fermataImageViewArray) {
        [fermataImageView removeFromSuperview];
      }
    }
    
    Player *player;
    for (int i = 0; i < kMaxNumPlayers; i++) {
      
      player = (i < self.myMatch.players.count) ? self.myMatch.players[i] : nil;
      
      UILabel *playerLabel = self.playerLabelsArray[i];
      UILabel *scoreLabel = self.scoreLabelsArray[i];
      
      if (!player) {
        playerLabel.text = @"";
        scoreLabel.text = @"";
        
      } else {
      
          // player label
        playerLabel.text = player ? player.playerName : @"";
        [playerLabel sizeToFit];
          // frame width can never be greater than maximum label width
        CGFloat playerLabelFrameWidth = (playerLabel.frame.size.width > kCellPlayerLabelWidth) ?
            kCellPlayerLabelWidth : playerLabel.frame.size.width;
        
        playerLabel.frame = CGRectMake(0, 0, playerLabelFrameWidth, playerLabel.frame.size.height);
        playerLabel.center = CGPointMake(kStaveXBuffer + kCellClefWidth + kCellKeySigWidth + ((i + 0.5) * kCellPlayerSlotWidth), playerLabel.center.y);
          // static player colours, check if player resigned
        playerLabel.textColor = (player.resigned && self.myMatch.type != kSelfGame) ?
            kResignedGray : [self.myMatch colourForPlayer:player];
        
          // score label
        scoreLabel.text = (player && !(player.resigned && self.myMatch.type != kSelfGame)) ?
        [NSString stringWithFormat:@"%lu", (unsigned long)player.playerScore] : @"";
        scoreLabel.frame = CGRectMake(0, 0, kCellPlayerSlotWidth, kScoreLabelHeight);
        
        if (self.myMatch.gameHasEnded) {
          if ([self.myMatch.wonPlayers containsObject:player]) {
            scoreLabel.textColor = kScoreWonGold;
          } else {
            scoreLabel.textColor = kScoreLostGray;
          }
        } else {
          scoreLabel.textColor = kScoreNormalBrown;
        }
        
        // labelView
        self.labelView.backgroundColourCanBeChanged = YES;
        if (self.myMatch.gameHasEnded) {
          self.labelView.backgroundColor = [UIColor clearColor];
        } else {
          if (player == self.myMatch.currentPlayer) {
            self.labelView.frame = CGRectMake(0, 0, playerLabelFrameWidth + kPlayerLabelWidthPadding, playerLabel.frame.size.height + kPlayerLabelHeightPadding);
            self.labelView.layer.cornerRadius = self.labelView.frame.size.height / 2.f;
            self.labelView.clipsToBounds = YES;
            
              // background colours depending on match results
            self.labelView.backgroundColor = [kMainDarkerYellow colorWithAlphaComponent:0.8f];
          }
        }
        self.labelView.backgroundColourCanBeChanged = NO;
        
          // fermata
        if (self.myMatch.gameHasEnded && [self.myMatch.wonPlayers containsObject:player]) {
          kIsIPhone ? nil : [self addSubview:self.fermataImageViewArray[i]];
        }
      }
      
      [self setYPositionsForPlayerLabels];
    }
  });
}

#pragma mark - background threaded methods

-(void)updateStaves {
  self.stavesView.gameHasEnded = self.myMatch.gameHasEnded;
  [self.stavesView setNeedsDisplay];
}

-(void)updateClef {
  UIImage *finalImage = [self.delegate returnClefImageForMatchType:self.myMatch.type andGameEnded:self.myMatch.gameHasEnded];

  switch (self.myMatch.type) {
        // treble
    case kSelfGame:
      self.clefImage.frame = CGRectMake(0 - (kStaveXBuffer / 8), kStaveYHeight * (kIsIPhone ? 1.7 : 2.2), kStaveYHeight * 6.3, kStaveYHeight * 6.3);
      break;
      
        // bass
    case kPnPGame:
      self.clefImage.frame = CGRectMake(kStaveXBuffer, kStaveYHeight * (kIsIPhone ? 2.5 : 3), kStaveYHeight * 3.25, kStaveYHeight * 3.25);
      break;
    case kGCFriendGame:
      break;
    case kGCRandomGame:
      break;
    default:
      break;
  }
  
  self.clefImage.image = finalImage;
}

-(void)updateRestImages {

  UIColor *finalColour = self.myMatch.gameHasEnded ? kStaveEndedGameColour : kStaveColour;
  
  UIImage *quarterRest = [UIImage imageNamed:@"quarter-rest"];
  UIImage *halfRest = [UIImage imageNamed:@"half-rest.gif"];
  
  self.quarterRestImage.image = [UIImage colourImage:quarterRest withColor:finalColour];
  self.halfRestImage.image = [UIImage colourImage:halfRest withColor:finalColour];
  
  self.quarterRestImage.hidden = (self.myMatch.players.count % 2 == 0);
  self.halfRestImage.hidden = (self.myMatch.players.count > 2);
  
  CGFloat xFactor = ((self.myMatch.players.count == 1) ? 1.5 : 3.5);
  self.quarterRestImage.frame = CGRectMake(0, 0, 35, 35);
  self.halfRestImage.frame = CGRectMake(0, 0, 35, 35);
  
  self.quarterRestImage.center = CGPointMake(kStaveXBuffer + kCellClefWidth + kCellKeySigWidth + kCellPlayerSlotWidth * xFactor, kCellHeight / 2);
  self.halfRestImage.center = CGPointMake(kStaveXBuffer + kCellClefWidth + kCellKeySigWidth + kCellPlayerSlotWidth * 2.5, kCellHeight / 2);
}

#pragma mark - view helper methods

-(void)setYPositionsForPlayerLabels {
  
    // first create an array of scores
  NSMutableArray *tempScores = [NSMutableArray new];
  for (int i = 0; i < self.myMatch.players.count; i++) {
    Player *player = self.myMatch.players[i];
    
      // add score only if player is in game
    if (!player.resigned || self.myMatch.type == kSelfGame) {
      NSNumber *playerScore = [NSNumber numberWithUnsignedInteger:player.playerScore];
      
        // ensure no double numbers
      ![tempScores containsObject:playerScore] ? [tempScores addObject:playerScore] : nil;
    }
  }
  
  NSArray *sortedScores = [tempScores sortedArrayUsingSelector:@selector(compare:)];

  for (int i = 0; i < self.myMatch.players.count; i++) {
    
    Player *player = self.myMatch.players[i];
    UILabel *playerLabel = self.playerLabelsArray[i];
    UILabel *scoreLabel = self.scoreLabelsArray[i];
    NSInteger playerPosition = (player.resigned && self.myMatch.type != kSelfGame) ?
        -1 : [sortedScores indexOfObject:[NSNumber numberWithUnsignedInteger:player.playerScore]] + 1;

    CGFloat centerX = playerLabel.center.x;
    playerLabel.center = CGPointMake(centerX, [self yPositionForMaxPosition:sortedScores.count andPlayerPosition:playerPosition]);
    if (player == self.myMatch.currentPlayer) {
      self.labelView.center = CGPointMake(centerX, playerLabel.center.y - (kCellRowHeight / 40.f));
    }
    scoreLabel.center = CGPointMake(centerX, playerLabel.center.y + kStaveYHeight * 1.75f);
    
    if (!kIsIPhone) {
      UIImageView *fermataImageView = self.fermataImageViewArray[i];
      if (fermataImageView.superview) {
        fermataImageView.center = CGPointMake(playerLabel.center.x, fermataImageView.center.y);
      }
    }
  }
}

-(CGFloat)yPositionForMaxPosition:(NSUInteger)maxPosition andPlayerPosition:(NSInteger)playerPosition {
  
    // positions are 4, 4.5, 5, 5.5, 6 being resigned player
  CGFloat multFloat = (playerPosition == -1) ? 6 : ((maxPosition - playerPosition) / 2.f) + 4;
  return (multFloat * kStaveYHeight);
}

@end
