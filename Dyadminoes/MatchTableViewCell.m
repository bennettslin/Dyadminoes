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
@property (strong, nonatomic) NSArray *fermataLabelsArray;

@property (strong, nonatomic) CellBackgroundView *labelView;
@property (strong, nonatomic) UILabel *lastPlayedLabel;

@property (strong, nonatomic) StavesView *stavesView;
@property (strong, nonatomic) UILabel *clefLabel;
@property (strong, nonatomic) UILabel *quarterRestLabel;
@property (strong, nonatomic) UILabel *halfRestLabel;
@property (strong, nonatomic) UILabel *endBarlineLabel;
@property (strong, nonatomic) NSArray *keySigLabelsArray;
@end

@implementation MatchTableViewCell


  // FIXME: maybe put in initWithCoder instead?
-(void)awakeFromNib {
  
    // colour when cell is selected
  UIView *customColorView = [[UIView alloc] init];
  self.selectedBackgroundView = customColorView;
  self.accessoryType = UITableViewCellAccessoryNone;
  
  [self instantiatePlayerLabels];
  [self instantiateUniversalMusicSymbolLabels];
  kIsIPhone ? nil : [self instantiateIPadMusicSymbolLabels];
}

#pragma mark - view methods

-(void)setViewProperties {
  
  [self updateLastPlayedLabel];
  [self updateStaves];
  [self updateClef];
  [self updateKeySigLabel];
  [self updateBarline];
  kIsIPhone ? nil : [self updateRestLabels];
  
//  Player *player;
  for (int i = 0; i < kMaxNumPlayers; i++) {
    
    Player *player = [self.myMatch playerForIndex:i];
    
    UILabel *playerLabel = self.playerLabelsArray[i];
    UILabel *scoreLabel = self.scoreLabelsArray[i];
    UILabel *fermataLabel = self.fermataLabelsArray[i];
    
    if (!player) {
      playerLabel.text = @"";
      scoreLabel.text = @"";
      fermataLabel.hidden = YES;
      
    } else {
      
        // player label-------------------------------------------------------
      playerLabel.text = player ? player.playerName : @"";
      [playerLabel sizeToFit];
      
        // frame width can never be greater than maximum label width
      CGFloat playerLabelFrameWidth = (playerLabel.frame.size.width > kCellPlayerLabelWidth) ?
      kCellPlayerLabelWidth : playerLabel.frame.size.width;
      
      playerLabel.frame = CGRectMake(0, 0, playerLabelFrameWidth, playerLabel.frame.size.height);
      
        // static player colours, check if player resigned
      playerLabel.textColor = ([player returnResigned] && [self.myMatch returnType] != kSelfGame) ?
      kResignedGray : [self.myMatch colourForPlayer:player forLabel:YES light:NO];
      
        // score label--------------------------------------------------------
      scoreLabel.text = (player && !([player returnResigned] && [self.myMatch returnType] != kSelfGame)) ?
      [NSString stringWithFormat:@"%lu", (unsigned long)[player returnPlayerScore]] : @"";
      scoreLabel.frame = CGRectMake(0, 0, kCellPlayerSlotWidth, kStaveYHeight * 2);
      
      if ([self.myMatch returnGameHasEnded]) {
        scoreLabel.textColor = [player returnWon] ? kScoreWonGold : kScoreLostGray;
      } else {
        scoreLabel.textColor = kScoreNormalBrown;
      }

        // iPhone properties for player and score labels----------------------
      if (kIsIPhone) {
        CGFloat xPosition = self.frame.size.width - kStaveXBuffer - kCellEndBarlineWidth - kCellIPhoneScoreLabelWidth - playerLabelFrameWidth / 2;
        CGFloat yPosition = 0;
        CGFloat playerFontSize = 0;
        switch (self.myMatch.players.count) {
          case 4:
            yPosition = kStaveYHeight * (i + 3);
            playerFontSize = kStaveYHeight;
            break;
          case 3:
            yPosition = kStaveYHeight * (i * 1.5 + 3);
            playerFontSize = kStaveYHeight * 1.4;
            break;
          case 2:
            yPosition = kStaveYHeight * (i * 2 + 3.5);
            playerFontSize = kStaveYHeight * 1.8;
            break;
          case 1:
            yPosition = kStaveYHeight * 3.5;
            playerFontSize = kStaveYHeight * 2.0;
            break;
        }
        
        playerLabel.font = [UIFont fontWithName:kFontModern size:playerFontSize];
        playerLabel.center = CGPointMake(xPosition, yPosition);
        
        scoreLabel.font = [UIFont fontWithName:kFontModern size:playerFontSize * 0.9];
        scoreLabel.center = CGPointMake(self.frame.size.width - kStaveXBuffer - kCellEndBarlineWidth - kCellIPhoneScoreLabelWidth / 2, yPosition);
        
          // iPad
      } else {
        playerLabel.font = [UIFont fontWithName:kFontModern size:(kStaveYHeight * 2.25)];
        scoreLabel.font = [UIFont fontWithName:kFontModern size:kStaveYHeight * 1.5];
      }

        // labelView----------------------------------------------------------
      self.labelView.backgroundColourCanBeChanged = YES;
      if ([self.myMatch returnGameHasEnded]) {
        self.labelView.backgroundColor = [UIColor clearColor];
        
      } else {
        if ([player returnPlayerOrder] == [self.myMatch returnCurrentPlayerIndex]) {
          self.labelView.frame = CGRectMake(0, 0, playerLabelFrameWidth + kPlayerLabelWidthPadding, playerLabel.frame.size.height + kPlayerLabelHeightPadding);
          self.labelView.layer.cornerRadius = self.labelView.frame.size.height / 2.f;
          self.labelView.clipsToBounds = YES;
          
            // background colours depending on match results
          self.labelView.backgroundColor = [kMainDarkerYellow colorWithAlphaComponent:0.8f];
          
            // set labelView here for iPhone only
          if (kIsIPhone) {
            self.labelView.center = CGPointMake(playerLabel.center.x, playerLabel.center.y - (kCellRowHeight / 40.f));
          }
        }
      }
      self.labelView.backgroundColourCanBeChanged = NO;
      
        // fermata------------------------------------------------------------
      fermataLabel.hidden = !(!kIsIPhone && [self.myMatch returnGameHasEnded] && [player returnWon]);
    }
    
    kIsIPhone ? nil : [self setYPositionsForPlayerLabels];
  }
}

-(void)setYPositionsForPlayerLabels {
  
    // first create an array of scores
  NSMutableArray *tempScores = [NSMutableArray new];
//  for (int i = 0; i < self.myMatch.players.count; i++) {
  for (Player *player in self.myMatch.players) {
//
//    Player *player = self.myMatch.players[i];
    
      // add score only if player is in game
    if (![player returnResigned] || [self.myMatch returnType] == kSelfGame) {
      NSNumber *playerScore = [NSNumber numberWithUnsignedInteger:[player returnPlayerScore]];
      
        // ensure no double numbers
      ![tempScores containsObject:playerScore] ? [tempScores addObject:playerScore] : nil;
    }
  }
  
  NSArray *sortedScores = [tempScores sortedArrayUsingSelector:@selector(compare:)];

//  for (int i = 0; i < self.myMatch.players.count; i++) {
  
  for (Player *player in self.myMatch.players) {

//    Player *player = self.myMatch.players[i];
    
    NSUInteger index = [player returnPlayerOrder];
    UILabel *playerLabel = self.playerLabelsArray[index];
    UILabel *scoreLabel = self.scoreLabelsArray[index];
    
    NSInteger playerPosition = ([player returnResigned] && [self.myMatch returnType] != kSelfGame) ?
        -1 : [sortedScores indexOfObject:[NSNumber numberWithUnsignedInteger:[player returnPlayerScore]]] + 1;

    playerLabel.center = CGPointMake(kStaveXBuffer + kCellClefWidth + kCellKeySigWidth + ((index + 0.5) * kCellPlayerSlotWidth),
                                     [self yPositionForMaxPosition:sortedScores.count andPlayerPosition:playerPosition]);

    scoreLabel.center = CGPointMake(playerLabel.center.x, playerLabel.center.y + kStaveYHeight * 1.75f);
    
    if ([player returnPlayerOrder] == [self.myMatch returnCurrentPlayerIndex]) {
      self.labelView.center = CGPointMake(playerLabel.center.x, playerLabel.center.y - (kCellRowHeight / 40.f));
    }
  }
}

-(CGFloat)yPositionForMaxPosition:(NSUInteger)maxPosition andPlayerPosition:(NSInteger)playerPosition {
  
    // positions are 4, 4.5, 5, 5.5, 6 being resigned player
  CGFloat multFloat = (playerPosition == -1) ? 6 : ((maxPosition - playerPosition) / 2.f) + 4;
  return (multFloat * kStaveYHeight);
}

#pragma mark - label update methods

-(void)updateLastPlayedLabel {
  NSArray *turns = self.myMatch.turns;
  NSUInteger turn = turns.count;
  
    // backgroundColour and lastPlayedLabel are not async
  if ([self.myMatch returnGameHasEnded]) {
    self.selectedBackgroundView.backgroundColor = kEndedMatchCellSelectedColour;
    self.backgroundColor = kEndedMatchCellLightColour;
    
      // game ended, so lastPlayed label shows date
    self.lastPlayedLabel.textColor = kStaveEndedGameColour;
    self.lastPlayedLabel.text = [self returnGameEndedDateStringFromDate:self.myMatch.lastPlayed];
    
  } else {
    self.selectedBackgroundView.backgroundColor = kMainSelectedYellow;
    self.backgroundColor = kMainLighterYellow;
    
      // game still in play, so lastPlayed label shows time since last played
    self.lastPlayedLabel.textColor = kStaveColour;
    self.lastPlayedLabel.text = [self returnLastPlayedStringFromDate:self.myMatch.lastPlayed andTurn:turn];
  }
}

#pragma mark - music symbol label methods

-(void)instantiatePlayerLabels {
    // labels for each player
  NSMutableArray *tempPlayerLabelsArray = [NSMutableArray arrayWithCapacity:kMaxNumPlayers];
  NSMutableArray *tempScoreLabelsArray = [NSMutableArray arrayWithCapacity:kMaxNumPlayers];
  
  for (int i = 0; i < kMaxNumPlayers; i++) {
    
    self.labelView = [[CellBackgroundView alloc] init];
    [self insertSubview:self.labelView atIndex:0];
    
    UILabel *playerLabel = [[UILabel alloc] init];
    playerLabel.adjustsFontSizeToFitWidth = YES;
      //    playerLabel.textAlignment = kIsIPhone ? NSTextAlignmentRight : NSTextAlignmentCenter;
    playerLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [tempPlayerLabelsArray addObject:playerLabel];
    [self insertSubview:playerLabel aboveSubview:self.labelView];
    
    UILabel *scoreLabel = [[UILabel alloc] init];
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    scoreLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:scoreLabel];
    [tempScoreLabelsArray addObject:scoreLabel];
  }
  
  self.playerLabelsArray = [NSArray arrayWithArray:tempPlayerLabelsArray];
  self.scoreLabelsArray = [NSArray arrayWithArray:tempScoreLabelsArray];
}

-(void)instantiateUniversalMusicSymbolLabels {
    // staves and clef
  self.stavesView = [[StavesView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, kCellWidth, kCellRowHeight + kCellSeparatorBuffer)];
  [self insertSubview:self.stavesView belowSubview:self.selectedBackgroundView];
  
  self.clefLabel = [UILabel new];
  self.clefLabel.font = [UIFont fontWithName:kFontSonata size:kStaveYHeight * 4];
  self.clefLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
  [self addSubview:self.clefLabel];
  
  NSMutableArray *tempKeySigLabelsArray = [NSMutableArray arrayWithCapacity:6];
  for (int i = 0; i < 6; i++) {
    UILabel *keySigLabel = [UILabel new];
    keySigLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    keySigLabel.font = [UIFont fontWithName:kFontSonata size:kStaveYHeight * 3];
    [self addSubview:keySigLabel];
    [tempKeySigLabelsArray addObject:keySigLabel];
  }
  self.keySigLabelsArray = [NSArray arrayWithArray:tempKeySigLabelsArray];
  
  self.endBarlineLabel = [UILabel new];
  self.endBarlineLabel.font = [UIFont fontWithName:kFontSonata size:kStaveYHeight * 4];
  [self addSubview:self.endBarlineLabel];
  
  self.lastPlayedLabel = [[UILabel alloc] initWithFrame:CGRectMake(kStaveXBuffer, (kCellRowHeight / 10) * 11.5, kCellWidth - kStaveXBuffer * 2, kStaveYHeight * 2)];
  self.lastPlayedLabel.textAlignment = NSTextAlignmentRight;
  self.lastPlayedLabel.adjustsFontSizeToFitWidth = YES;
  self.lastPlayedLabel.font = [UIFont fontWithName:kFontHarmony size:(kIsIPhone ? 20.f : 22.f)];
  [self insertSubview:self.lastPlayedLabel aboveSubview:self.stavesView];
}

-(void)instantiateIPadMusicSymbolLabels {
  NSMutableArray *tempFermataLabelsArray = [NSMutableArray new];
  for (int i = 0; i < kMaxNumPlayers; i++) {
    UILabel *fermataLabel = [UILabel new];
    fermataLabel.text = [self stringForMusicSymbol:kSymbolFermata];
    fermataLabel.font = [UIFont fontWithName:kFontSonata size:kStaveYHeight * 4];
    fermataLabel.textColor = kStaveEndedGameColour;
    fermataLabel.textAlignment = NSTextAlignmentCenter;
    fermataLabel.frame = CGRectMake(kStaveXBuffer + kCellClefWidth + kCellKeySigWidth + (i * kCellPlayerSlotWidth),
                                    (kIsIPhone ? -0.5: 0), kCellPlayerSlotWidth, kStaveYHeight * 4);
    fermataLabel.hidden = YES;
    [self addSubview:fermataLabel];
    [tempFermataLabelsArray addObject:fermataLabel];
  }
  self.fermataLabelsArray = [NSArray arrayWithArray:tempFermataLabelsArray];
  
  self.quarterRestLabel = [UILabel new];
  self.quarterRestLabel.text = [self stringForMusicSymbol:kSymbolQuarterRest];
  self.quarterRestLabel.font = [UIFont fontWithName:kFontSonata size:kStaveYHeight * 4];
  self.quarterRestLabel.textAlignment = NSTextAlignmentCenter;
  self.quarterRestLabel.frame = CGRectMake(0, 0, kCellPlayerSlotWidth, kCellHeight);
  self.quarterRestLabel.hidden = YES;
  [self addSubview:self.quarterRestLabel];
  
  self.halfRestLabel = [UILabel new];
  self.halfRestLabel.text = [self stringForMusicSymbol:kSymbolHalfRest];
  self.halfRestLabel.font = [UIFont fontWithName:kFontSonata size:kStaveYHeight * 4];
  self.halfRestLabel.textAlignment = NSTextAlignmentCenter;
  self.halfRestLabel.frame = CGRectMake(0, 0, kCellPlayerSlotWidth, kCellHeight);
  self.halfRestLabel.hidden = YES;
  [self addSubview:self.halfRestLabel];
}

-(void)updateStaves {
  self.stavesView.gameHasEnded = [self.myMatch returnGameHasEnded];
  [self.stavesView setNeedsDisplay];
}

-(void)updateClef {
  MusicSymbol symbol = [self musicSymbolForMatchType:[self.myMatch returnType]];
  self.clefLabel.text = [self stringForMusicSymbol:symbol];
  self.clefLabel.textColor = [self.myMatch returnGameHasEnded] ? kStaveEndedGameColour : kStaveColour;
  
  CGFloat tenorFactor = (symbol == kSymbolTenorClef) ? -1 : 0;
  self.clefLabel.frame = CGRectMake(kStaveXBuffer, kStaveYHeight * (1.5 + tenorFactor),
                                    kCellWidth - (kStaveXBuffer * 2), kCellHeight);
}

-(void)updateKeySigLabel {
  
    // yields number between 0 and 11
  NSUInteger keySig = ([self.myMatch returnRandomNumber1To24] - 1) / 2;
    // sharps are 0-5, flats are 6-11
  MusicSymbol symbol = (keySig < 6) ? kSymbolSharp : kSymbolFlat;
  
  for (int i = 0; i < 6; i++) {
    UILabel *keySigLabel = self.keySigLabelsArray[i];
    if ((symbol == kSymbolSharp && i < keySig) ||
        (symbol == kSymbolFlat && i <= (keySig - 6))) {
      keySigLabel.text = [self stringForMusicSymbol:symbol];
      keySigLabel.textColor = [self.myMatch returnGameHasEnded] ? kStaveEndedGameColour : kStaveColour;
      CGFloat factor = [self stavePositionForAccidentalIndex:i];
      keySigLabel.frame = CGRectMake(kStaveXBuffer + kCellClefWidth + ((i + 0.5) * kCellKeySigWidth / 6.5),
                                     kStaveYHeight * factor * 0.5,
                                     kCellKeySigWidth / 2, kCellHeight / 2);
    } else {
      keySigLabel.text = @"";
    }
  }
}

-(CGFloat)stavePositionForAccidentalIndex:(NSUInteger)index {
  
  CGFloat finalValue = 0;
  
    // sharps
  if ([self.myMatch returnRandomNumber1To24] <= 12) {
      //------------------------------------------------------------------------
      // even or odd index (default is tenor clef)
    finalValue = (index % 2 == 0) ?
        6 - index * 0.5 :
        2.5 - index * 0.5;
      //------------------------------------------------------------------------
    
      // all other keys but tenor clef have first and third accidentals raised
    if ([self.myMatch returnType] != kGCFriendGame) {
      finalValue = (index == 0 || index == 2) ? (finalValue - 7) : finalValue;
    }
    
    // flats
  } else {
      //------------------------------------------------------------------------
      // even or odd index (default is tenor clef)
    finalValue = (index % 2 == 0) ?
        3 + index * 0.5 :
        -0.5 + index * 0.5;
      //------------------------------------------------------------------------
  }
  
  switch ([self.myMatch returnType]) {
    case kSelfGame: // treble clef
      finalValue = finalValue + 1;
      break;
    case kPnPGame: // alto clef
      finalValue = finalValue + 2;
      break;
    case kGCRandomGame: // bass clef
      finalValue = finalValue + 3;
      break;
    default:
      break;
  }

  return finalValue;
}

-(void)updateBarline {
  if ([self.myMatch returnGameHasEnded]) {
    self.endBarlineLabel.font = [UIFont fontWithName:kFontSonata size:kStaveYHeight * 4.0];
    self.endBarlineLabel.text = [self stringForMusicSymbol:kSymbolEndBarline];
    self.endBarlineLabel.textAlignment = NSTextAlignmentRight;
    self.endBarlineLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    self.endBarlineLabel.frame = CGRectMake(self.frame.size.width - kStaveXBuffer - kCellEndBarlineWidth * 2 + (kStaveXBuffer * 0.025),
                                            (kStaveYHeight * 1.5) - (kCellHeight / 150.f),
                                            kCellEndBarlineWidth * 2, kCellHeight);
    self.endBarlineLabel.textColor = ([self.myMatch returnGameHasEnded]) ? kStaveEndedGameColour : kStaveColour;
    
  } else {
    self.endBarlineLabel.text = @"";
  }
}

-(void)updateRestLabels {
  UIColor *finalColour = [self.myMatch returnGameHasEnded] ? kStaveEndedGameColour : kStaveColour;
  self.quarterRestLabel.textColor = finalColour;
  self.quarterRestLabel.hidden = (self.myMatch.players.count % 2 == 0);
  
  self.halfRestLabel.textColor = finalColour;
  self.halfRestLabel.hidden = (self.myMatch.players.count > 2);
  
  CGFloat xFactor = ((self.myMatch.players.count == 1) ? 1.5 : 3.5);
  self.quarterRestLabel.center = CGPointMake(kStaveXBuffer + kCellClefWidth + kCellKeySigWidth + kCellPlayerSlotWidth * xFactor, kCellHeight / 2 - kStaveYHeight / 2);
  self.halfRestLabel.center = CGPointMake(kStaveXBuffer + kCellClefWidth + kCellKeySigWidth + kCellPlayerSlotWidth * 2.5,kCellHeight / 2 - kStaveYHeight / 2 - (kCellHeight / 150.f));
}

@end
