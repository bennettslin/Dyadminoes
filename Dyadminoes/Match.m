//
//  Match.m
//  Dyadminoes
//
//  Created by Bennett Lin on 5/19/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Match.h"
#import "Player.h"
#import "DataCell.h"
#import "DataDyadmino.h"
#import "SonorityLogic.h"

@interface Match ()

@property (readwrite, nonatomic) NSMutableArray *pile;
@property (readwrite, nonatomic) NSMutableSet *board;
@property (readwrite, nonatomic) NSMutableSet *occupiedCells;

  // established when board is established
  // this is necessary if chords were added or extended
  // by moving board dyadminoes this turn
@property (strong, nonatomic) NSSet *preTurnChords;

@end

@implementation Match

  // persisted
@dynamic rules;
@dynamic skill;
@dynamic type;
@dynamic lastPlayed;
@dynamic players;
@dynamic currentPlayerOrder;
@dynamic gameHasEnded;
@dynamic dataDyadminoes;
@dynamic holdingIndexContainer;
@dynamic turns;
@dynamic firstDataDyadIndex;
@dynamic randomNumber1To24;

  // not persisted
@synthesize replayBoard = _replayBoard;
@synthesize replayTurn = _replayTurn;
@synthesize delegate = _delegate;
@synthesize pile = _pile;
@synthesize board = _board;
@synthesize occupiedCells = _occupiedCells;
@synthesize preTurnChords = _preTurnChords;

#pragma mark - setup methods

-(void)initialPlayers:(NSSet *)players
             andRules:(GameRules)rules
             andSkill:(GameSkill)skill
          withContext:(NSManagedObjectContext *)managedObjectContext
              forTest:(BOOL)forTest {

  [self setPlayers:players];

  if (self.players.count != players.count) {
    NSLog(@"Players not set properly.");
    abort();
    
  } else {
    self.rules = @(rules);
    self.skill = @(skill);
    self.type = (players.count == 1) ? @(kSelfGame) : @(kPnPGame);
    
    self.lastPlayed = [NSDate date];
    self.gameHasEnded = @NO;
    self.currentPlayerOrder = @0;
    self.randomNumber1To24 = @([self randomIntegerUpTo:24] + 1);
    
    self.holdingIndexContainer = [NSArray new];

    self.turns = [NSMutableArray new];
    self.replayTurn = 0;
    
    if (![self generateDataDyadminoesWithContext:managedObjectContext]) {
      NSLog(@"Data dyadminoes not generated properly.");
      abort();

    } else if (!forTest) {
      [self placeFirstDyadminoOnBoard];
      if (![self distributePileAmongstPlayers]) {
        NSLog(@"Pile not distributed amongst players properly.");
        abort();
      }
      
        // for test only
    } else {
      
    }
  }
}

-(BOOL)generateDataDyadminoesWithContext:(NSManagedObjectContext *)context {
  NSMutableSet *tempSet = [NSMutableSet new];
  
    // start index at 0 (previously started at 1)
  for (NSUInteger i = 0; i < kPileCount; i++) {
    
    DataDyadmino *dataDyad = [NSEntityDescription insertNewObjectForEntityForName:@"DataDyadmino" inManagedObjectContext:context];

    [dataDyad initWithID:i];
    [tempSet addObject:dataDyad];
  }
  
  [self setDataDyadminoes:[NSSet setWithSet:tempSet]];
  return (self.dataDyadminoes.count == kPileCount);
}

-(BOOL)distributePileAmongstPlayers {
  for (Player *player in self.players) {
    [self fillRackFromPileForPlayer:player];
    if ([(NSArray *)player.rackIndexes count] != kNumDyadminoesInRack) {
      return NO;
    }
  }
  return YES;
}

-(void)placeFirstDyadminoOnBoard {
  
  while (self.board.count == 0 && self.pile.count > 0) {
    
    NSUInteger randIndex = [self randomIntegerUpTo:self.pile.count];
    self.firstDataDyadIndex = @(randIndex);
    DataDyadmino *firstDyadmino = [self dataDyadminoForIndex:randIndex];
    firstDyadmino.myRackOrder = @(-1);
    
    if ([self.pile containsObject:firstDyadmino]) {
      struct HexCoord myHex = {0, 0};
      firstDyadmino.myHexCoord = myHex;
      
        // establish first dyadmino is out of pile and now on board
      firstDyadmino.placeStatus = @(kOnBoard);
      [self.pile removeObject:firstDyadmino];
      [self.board addObject:firstDyadmino];

      [self persistChangedPositionForBoardDataDyadmino:firstDyadmino];
    }
  }
}

#pragma mark - sonority collection methods

-(NSSet *)sonoritiesFromPlacingDyadminoID:(NSUInteger)dyadminoID
                         onBottomHexCoord:(HexCoord)bottomHexCoord
                          withOrientation:(DyadminoOrientation)orientation {
  
    // establish whether we're validating current placement or testing new one
  DataDyadmino *dataDyad = [self dataDyadminoForIndex:dyadminoID];
  
  BOOL checkedPlacementIsCurrentPlacement =
      (dataDyad.myHexCoord.x == bottomHexCoord.x &&
       dataDyad.myHexCoord.y == bottomHexCoord.y &&
       [dataDyad returnMyOrientation] == orientation);
  
  NSUInteger pc1, pc2;
  if (!checkedPlacementIsCurrentPlacement) {
    
      // temporarily place dyadmino on new cells, and remove it from original one
    pc1 = [self pcForDyadminoIndex:dyadminoID isPC1:YES];
    pc2 = [self pcForDyadminoIndex:dyadminoID isPC1:NO];
    [self updateDataCellsForRemovedDyadminoID:dyadminoID
                                  orientation:[dataDyad returnMyOrientation]
                       fromBottomCellHexCoord:dataDyad.myHexCoord];
    [self updateDataCellsForPlacedDyadminoID:dyadminoID
                                 orientation:orientation
                        onBottomCellHexCoord:bottomHexCoord];
  }
  
  NSMutableSet *tempSetOfSonorities = [NSMutableSet new];
  
//   this will check first up, then down, five axes: 1. bottom cell vertical, which is the same as top cell,
//   2. bottom cell upslant, 3. bottom cell downslant, 4. top cell upslant, 5. top cell downslant
  
  HexCoord topHexCoord = [self retrieveTopHexCoordForBottomHexCoord:bottomHexCoord andOrientation:orientation];
  
  HexCoord nextHexCoord;
  NSUInteger realOrientation = NSUIntegerMax; // change
  
  HexCoord hexCoords[2] = {topHexCoord, bottomHexCoord};
  NSUInteger whichHexCoord[10] = {((orientation >= 5 || orientation <= 1) ? 0 : 1),
                                  ((orientation >= 5 || orientation <= 1) ? 1 : 0),
                                  1, 1, 1, 1,
                                  0, 0, 0, 0};
  
  NSUInteger whichOrientation[5] = {0, 1, 2, 1, 2};
  
  for (int axis = 0; axis < 5; axis++) {
    
    NSMutableSet *tempSonority = [NSMutableSet new];
    for (int direction = 0; direction < 2; direction++) {
      
      nextHexCoord = hexCoords[(whichHexCoord[2 * axis + direction])];
      realOrientation = (direction == 0) ? (orientation + whichOrientation[axis]) % 6 : (orientation + whichOrientation[axis] + 3) % 6;
      DataCell *nextCell = [self occupiedCellForHexCoord:nextHexCoord];
      while (nextCell) {

        NSDictionary *note = @{@"pc": @(nextCell.myPC), @"dyadmino": @(nextCell.myDyadminoID)};
        if (![[SonorityLogic sharedLogic] sonority:tempSonority containsNote:note]) {
          [tempSonority addObject:note];
        }
        nextHexCoord = [self nextHexCoordFromHexCoord:nextHexCoord andAxis:realOrientation];
        nextCell = [self occupiedCellForHexCoord:nextHexCoord];
      }
    }
    
    NSSet *sonority = [NSSet setWithSet:tempSonority];
    [tempSetOfSonorities addObject:sonority];
  }
  
    // return data cells to original state
  if (!checkedPlacementIsCurrentPlacement) {
    [self updateDataCellsForRemovedDyadminoID:dyadminoID
                                  orientation:orientation
                       fromBottomCellHexCoord:bottomHexCoord];
    [self updateDataCellsForPlacedDyadminoID:dyadminoID
                                 orientation:[dataDyad returnMyOrientation]
                        onBottomCellHexCoord:dataDyad.myHexCoord];
  }
  
  return [NSSet setWithSet:tempSetOfSonorities];
}

#pragma mark - match game progression methods

-(void)fillRackFromPileForPlayer:(Player *)player {
    // reset rack order of data dyadminoes already in rack
  NSArray *dataDyadminoIndexesThisTurn = player.rackIndexes;
  
  while (dataDyadminoIndexesThisTurn.count < kNumDyadminoesInRack && self.pile.count > 0) {
    NSUInteger randIndex = [self randomIntegerUpTo:self.pile.count];
    DataDyadmino *dataDyad = self.pile[randIndex];
      // rack order is total count at the time
    dataDyad.myRackOrder = @(dataDyadminoIndexesThisTurn.count);
    
      // establish dyadmino is out of pile and in rack
    dataDyad.placeStatus = @(kInRack);
    [self.pile removeObjectAtIndex:randIndex];
    [player addToRackDataDyadmino:dataDyad];
    dataDyadminoIndexesThisTurn = player.rackIndexes;
  }
}

-(Player *)switchToNextPlayer {
  
  [self thisTurnChords];
  
  Player *currentPlayer = [self returnCurrentPlayer];
  NSUInteger index = [currentPlayer returnOrder];
  if ([self checkNumberOfPlayersStillInGame] > 1) {

    while (index < self.players.count * 2) {
      Player *nextPlayer = [self playerForIndex:(index + 1) % self.players.count];
      if ([nextPlayer returnResigned]) {
        index++;
      } else {
        self.currentPlayerOrder =@([nextPlayer returnOrder]);
        
        [self.delegate handleSwitchToNextPlayer];
        
        return nextPlayer;
      }
    }
  }
  return nil;
}

-(void)persistChangedPositionForBoardDataDyadmino:(DataDyadmino *)dataDyad {
    // this gets called in placeFirstDyadmino, resetBoard, and recordDyadminoes
  
  if ([self.board containsObject:dataDyad]) {
    
    NSNumber *lastHexX;
    NSNumber *lastHexY;
    NSNumber *lastOrientation;
    NSArray *turnChanges = dataDyad.turnChanges;
    
      // get last hexCoord and orientation
      // (must be iterated separately, because they might be in different dictionaries)
    NSInteger hexCoordCounter = turnChanges.count - 1;
    while (!(lastHexX || lastHexY) && hexCoordCounter >= 0) {
      NSDictionary *lastDictionary = (NSDictionary *)dataDyad.turnChanges[hexCoordCounter];
      lastHexX = (NSNumber *)[lastDictionary objectForKey:@"hexX"];
      lastHexY = (NSNumber *)[lastDictionary objectForKey:@"hexY"];
      hexCoordCounter--;
    }
    NSInteger orientationCounter = turnChanges.count - 1;
    while (!lastOrientation && orientationCounter >= 0) {
      NSDictionary *lastDictionary = (NSDictionary *)dataDyad.turnChanges[orientationCounter];
      lastOrientation = (NSNumber *)[lastDictionary objectForKey:@"orientation"];
      orientationCounter--;
    }
    
      // if either hexCoord position or orientation has changed, or was never established
    if ((!lastHexX || dataDyad.myHexCoord.x != [lastHexX integerValue]) ||
        (!lastHexY || dataDyad.myHexCoord.y != [lastHexY integerValue]) ||
        (!lastOrientation || [dataDyad returnMyOrientation] != [lastOrientation unsignedIntegerValue])) {
      
        // create new dictionary
      NSMutableDictionary *newDictionary = [NSMutableDictionary new];
      NSArray *turns = self.turns;
      NSNumber *thisTurn = @(turns.count); // first dyadmino turn count will be 0
      [newDictionary setObject:thisTurn forKey:@"turn"];
      
        // set object for changed hexCoord position
      if (!(lastHexX || lastHexY) || !(dataDyad.myHexCoord.x == [lastHexX integerValue] && dataDyad.myHexCoord.y == [lastHexY integerValue])) {
        NSNumber *newHexX = @(dataDyad.myHexCoord.x);
        NSNumber *newHexY = @(dataDyad.myHexCoord.y);
        [newDictionary setObject:newHexX forKey:@"hexX"];
        [newDictionary setObject:newHexY forKey:@"hexY"];
      }
      
        // set object for changed orientation
      if (!lastOrientation || [dataDyad returnMyOrientation] != [lastOrientation unsignedIntegerValue]) {
        NSNumber *newOrientation = @([dataDyad returnMyOrientation]);
        [newDictionary setObject:newOrientation forKey:@"orientation"];
      }
      
      NSMutableArray *mutableTurnChanges = [NSMutableArray arrayWithArray:dataDyad.turnChanges];
      [mutableTurnChanges addObject:[NSDictionary dictionaryWithDictionary:newDictionary]];
      dataDyad.turnChanges = [NSArray arrayWithArray:mutableTurnChanges];
    }
  }
}

-(void)endGame {
  self.currentPlayerOrder = @0;
  [self resetHoldingContainer];
  self.preTurnChords = nil;
  
    // if solo game, sole player is winner if any score at all
  if ([self returnType] == kSelfGame) {
    Player *soloPlayer = [self playerForIndex:0];
      // player only won if score greater than 0
    soloPlayer.won = ([soloPlayer returnScore] > 0) ? @YES : @NO;
    
  } else {
      // rules out that players with no points can win
    NSUInteger maxScore = 1;
    
    for (Player *player in self.players) {
      if (![player returnResigned]) {
        
        NSUInteger playerScore = [player returnScore];
        if (playerScore > maxScore) {
          maxScore = playerScore;
        }
      }
    }
    
    for (Player *player in self.players) {
      if ([player returnScore] == maxScore) {
        player.won = @YES;
      }
    }
  }
  
  self.gameHasEnded = @YES;
  [self.delegate handleEndGame];
}

#pragma mark - move query methods

-(PlacementResult)checkPlacementOfDataDyadmino:(DataDyadmino *)dataDyad
                              onBottomHexCoord:(HexCoord)bottomHexCoord
                               withOrientation:(DyadminoOrientation)orientation {

  //----------------------------------------------------------------------------
  // first check physical placement
  //----------------------------------------------------------------------------
  
  PhysicalPlacementResult physicalPlacementResult = [self validatePhysicallyPlacingDyadminoID:[dataDyad returnMyID]
                                                                              withOrientation:orientation
                                                                             onBottomHexCoord:bottomHexCoord];
  
    // if illegal physical placement, return right away
  if (physicalPlacementResult != kNoError) {
    return kIllegalPhysicalPlacement;
  }
  
  //----------------------------------------------------------------------------
  // now check for legal chords
  //----------------------------------------------------------------------------

  // original formation of sonorities
  NSSet *originalFormation;
  
    // if it's a recent rack dyadmino, it won't have an original formation
  if (![self.board containsObject:dataDyad] && ![self.holdingIndexContainer containsObject:dataDyad.myID]) {
    originalFormation = [NSSet new];
  } else {
    originalFormation = [self sonoritiesFromPlacingDyadminoID:[dataDyad returnMyID]
                                             onBottomHexCoord:dataDyad.myHexCoord
                                              withOrientation:[dataDyad returnMyOrientation]];
  }

  NSSet *originalLegalChords = [[SonorityLogic sharedLogic] legalChordSonoritiesFromFormationOfSonorities:originalFormation];
  
    // checked formation of sonorities
  NSSet *checkedFormation = [self sonoritiesFromPlacingDyadminoID:[dataDyad returnMyID]
                                                 onBottomHexCoord:bottomHexCoord
                                                  withOrientation:orientation];
  
  NSSet *checkedLegalChords = [[SonorityLogic sharedLogic] legalChordSonoritiesFromFormationOfSonorities:checkedFormation];
  
  PlacementResult tentativeResult;
  
    // establish that they are equal
  if ([[SonorityLogic sharedLogic] sonorities:originalLegalChords is:kEqual ofSonorities:checkedLegalChords]) {
    tentativeResult = kNoChange; // *not* returned right away
    
      // they are definitely *not* equal,
      // so checked chords being subset of original chords means we've broken existing chords
  } else if (![[SonorityLogic sharedLogic] sonorities:originalLegalChords is:kSubset ofSonorities:checkedLegalChords]) {
    return kBreaksExistingChords;
    
      // adds or extends new legal chords
  } else {
    tentativeResult = kAddsOrExtendsNewChords; // *not* returned right away
  }
  
  //----------------------------------------------------------------------------
  // confirm that there are no illegal sonorities
  // (this ensures that if existing chords are broken, that is returned first)
  //----------------------------------------------------------------------------
  
  IllegalPlacementResult illegalPlacementResult = [[SonorityLogic sharedLogic] checkIllegalPlacementFromFormationOfSonorities:checkedFormation];
  
  switch (illegalPlacementResult) {
    case kExcessNotes:
      return kExcessNotesResult;
      break;
    case kDoublePCs:
      return kDoublePCsResult;
      break;
    case kIllegalSonority:
      return kIllegalSonorityResult;
      break;
    default:
      break;
  }
  
  return tentativeResult;
}

-(NSAttributedString *)stringForPlacementOfDataDyadmino:(DataDyadmino *)dataDyad
                                       onBottomHexCoord:(HexCoord)bottomHexCoord
                                        withOrientation:(DyadminoOrientation)orientation
                                          withCondition:(GetNewOrExtendedChords)condition
                                      withInitialString:(NSString *)initialString
                                        andEndingString:(NSString *)endingString {
  
  NSSet *checkedFormation = [self sonoritiesFromPlacingDyadminoID:[dataDyad returnMyID]
                                                 onBottomHexCoord:bottomHexCoord
                                                  withOrientation:orientation];
  
  NSSet *checkedLegalChords = [[SonorityLogic sharedLogic] legalChordSonoritiesFromFormationOfSonorities:checkedFormation];

  NSSet *returnedChords;
  if (condition == kBothNewAndExtendedChords) {
    returnedChords = [self checkLegalChords:checkedLegalChords thatare:kBothNewAndExtendedChords ofOriginalLegalChords:[self thisTurnChords]];
    
  } else if (condition == kNeitherNewNorExtendedChords) {
    
      // check against legal chords already formed by dataDyad
    NSSet *formationOfSonorities = [self sonoritiesFromPlacingDyadminoID:[dataDyad returnMyID] onBottomHexCoord:dataDyad.myHexCoord withOrientation:[dataDyad returnMyOrientation]];
    NSSet *legalChordsFromFormation = [[SonorityLogic sharedLogic] legalChordSonoritiesFromFormationOfSonorities:formationOfSonorities];
    
    returnedChords = [self checkLegalChords:checkedLegalChords thatare:kNeitherNewNorExtendedChords ofOriginalLegalChords:legalChordsFromFormation];
  }
  
  return [[SonorityLogic sharedLogic] stringForSonorities:returnedChords
                                        withInitialString:initialString
                                          andEndingString:endingString];
}

-(NSSet *)checkLegalChords:(NSSet *)checkedLegalChords
                   thatare:(GetNewOrExtendedChords)newOrExtendedChords
     ofOriginalLegalChords:(NSSet *)originalLegalChords {
  
  switch (newOrExtendedChords) {
    case kNeitherNewNorExtendedChords:
      return [[SonorityLogic sharedLogic] legalChords:originalLegalChords thatAreEitherNewOrExtendingRelativeToLegalChords:checkedLegalChords];
    case kJustNewChords:
      return [[SonorityLogic sharedLogic] legalChords:checkedLegalChords thatAreCompletelyNotFoundInLegalChords:originalLegalChords];
      break;
    case kJustExtendedChords:
      return [[SonorityLogic sharedLogic] legalChords:checkedLegalChords thatExtendALegalChordInLegalChords:originalLegalChords];
      break;
    case kBothNewAndExtendedChords:
      return [[SonorityLogic sharedLogic] legalChords:checkedLegalChords thatAreEitherNewOrExtendingRelativeToLegalChords:originalLegalChords];
      break;
    default:
      break;
  }
  return nil;
}

-(NSUInteger)pointsForPlacingDyadmino:(DataDyadmino *)dataDyad
                     onBottomHexCoord:(HexCoord)bottomHexCoord
                      withOrientation:(DyadminoOrientation)orientation {
  
  NSLog(@"points for placing dyadmino.");
  
  NSSet *checkedFormation = [self sonoritiesFromPlacingDyadminoID:[dataDyad returnMyID]
                                                 onBottomHexCoord:bottomHexCoord
                                                  withOrientation:orientation];
  
  NSSet *checkedLegalChords = [[SonorityLogic sharedLogic] legalChordSonoritiesFromFormationOfSonorities:checkedFormation];
  return [self pointsForCheckedChords:checkedLegalChords relativeToOriginalChords:[self thisTurnChords]];
}

-(NSUInteger)pointsForAllChordsThisTurn {
  return [self pointsForCheckedChords:[self thisTurnChords] relativeToOriginalChords:self.preTurnChords];
}

-(NSUInteger)pointsForCheckedChords:(NSSet *)theseChords relativeToOriginalChords:(NSSet *)originalChords {
  
  NSUInteger points = 0;

  NSSet *justNewChords = [self checkLegalChords:theseChords thatare:kJustNewChords ofOriginalLegalChords:originalChords];
  NSSet *justExtendedChords = [self checkLegalChords:theseChords thatare:kJustExtendedChords ofOriginalLegalChords:originalChords];
  
  for (NSSet *newChord in justNewChords) {
    points += [self pointsForChordSonority:newChord extended:NO];
  }
  
  for (NSSet *extendedChord in justExtendedChords) {
    points += [self pointsForChordSonority:extendedChord extended:YES];
  }
  
  return points;
}

-(NSSet *)thisTurnChords {
    // check all dyadminoes on board, both preTurn and thisTurn
  NSMutableSet *checkedDyadminoes = [NSMutableSet setWithSet:self.board];
  for (NSNumber *dyadminoIndex in self.holdingIndexContainer) {
    DataDyadmino *dataDyad = [self dataDyadminoForIndex:[dyadminoIndex unsignedIntegerValue]];
    [checkedDyadminoes addObject:dataDyad];
  }
  
  NSMutableSet *theseChords = [NSMutableSet new];
  for (DataDyadmino *dataDyad in checkedDyadminoes) {
    NSSet *checkedFormation = [self sonoritiesFromPlacingDyadminoID:[dataDyad returnMyID]
                                                   onBottomHexCoord:dataDyad.myHexCoord
                                                    withOrientation:[dataDyad returnMyOrientation]];
    
    NSSet *checkedLegalChords = [[SonorityLogic sharedLogic] legalChordSonoritiesFromFormationOfSonorities:checkedFormation];
    [theseChords addObjectsFromArray:checkedLegalChords.allObjects];
  }
  return [NSSet setWithSet:theseChords];
}

#pragma mark - scene game progression methods

-(void)resetToStartOfTurn {
  
    // necessary in case resetting because of stranded dyadmino
  while ([self.holdingIndexContainer count] > 0) {
    [self undoLastPlayedDyadminoByReset:YES];
  }
  
  NSUInteger lastTurnIndex = [(NSArray *)self.turns count];
  [self.occupiedCells removeAllObjects];
  
  for (DataDyadmino *dataDyad in self.board) {
    dataDyad.myHexCoord = [dataDyad getHexCoordForTurn:lastTurnIndex];
    dataDyad.myOrientation = @([dataDyad getOrientationForTurn:lastTurnIndex]);
    [self updateDataCellsForPlacedDyadminoID:[dataDyad returnMyID]
                                 orientation:[dataDyad returnMyOrientation]
                        onBottomCellHexCoord:dataDyad.myHexCoord];
  }
}

-(BOOL)playDataDyadmino:(DataDyadmino *)dataDyad
       onBottomHexCoord:(HexCoord)bottomHexCoord
        withOrientation:(DyadminoOrientation)orientation {
  
    // check placement first
  if ([self checkPlacementOfDataDyadmino:dataDyad onBottomHexCoord:bottomHexCoord withOrientation:orientation] == kAddsOrExtendsNewChords) {
    
      // no problems, so place it
    if ([self moveBoardDataDyadmino:dataDyad toBottomHexCoord:bottomHexCoord withOrientation:orientation]) {
      
        // no problems, so add it to holding container
      if ([self addToHoldingContainer:dataDyad]) {
        return YES;
      }
    }
  }
  
  return NO;
}

-(BOOL)moveBoardDataDyadmino:(DataDyadmino *)dataDyad
            toBottomHexCoord:(HexCoord)bottomHexCoord
             withOrientation:(DyadminoOrientation)orientation {
  
    // remove from data dyadmino's last hexCoord and orientation
  BOOL removedWithNoissues = [self updateDataCellsForRemovedDyadminoID:[dataDyad returnMyID] orientation:[dataDyad returnMyOrientation] fromBottomCellHexCoord:dataDyad.myHexCoord];
  
    // data dyadmino placement info is strongly tied to cells
  dataDyad.myHexCoord = bottomHexCoord;
  dataDyad.myOrientation = @(orientation);
  
  BOOL placedWithNoIssues = [self updateDataCellsForPlacedDyadminoID:[dataDyad returnMyID] orientation:orientation onBottomCellHexCoord:bottomHexCoord];
  
  NSLog(@"removed with no issues %i, placed with no issues %i", removedWithNoissues, placedWithNoIssues);
  return (removedWithNoissues && placedWithNoIssues);
}

-(DataDyadmino *)undoLastPlayedDyadmino {
  return [self undoLastPlayedDyadminoByReset:NO];
}

-(DataDyadmino *)undoLastPlayedDyadminoByReset:(BOOL)byReset {
  NSArray *holdingIndexContainer = self.holdingIndexContainer;
  if (holdingIndexContainer.count > 0) {
    
    NSNumber *dyadminoIndex = [self.holdingIndexContainer lastObject];
    DataDyadmino *mostRecentlyPlayedDyadmino = [self dataDyadminoForIndex:[dyadminoIndex unsignedIntegerValue]];
    
    if (byReset || ![self strandedDyadminoesAfterRemovingDataDyadmino:mostRecentlyPlayedDyadmino]) {
      
      NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.holdingIndexContainer];
      [tempArray removeObject:dyadminoIndex];
      self.holdingIndexContainer = [NSArray arrayWithArray:tempArray];
      
      [self updateDataCellsForRemovedDyadminoID:[mostRecentlyPlayedDyadmino returnMyID]
                                    orientation:[mostRecentlyPlayedDyadmino returnMyOrientation]
                         fromBottomCellHexCoord:mostRecentlyPlayedDyadmino.myHexCoord];
      [mostRecentlyPlayedDyadmino resetHexCoord];
      [mostRecentlyPlayedDyadmino randomRackOrientation];
      return mostRecentlyPlayedDyadmino;
    }
  }
  return nil;
}

-(BOOL)passTurnBySwappingDyadminoes:(NSSet *)dyadminoesToSwap {
  
    // dyadmino must be in player's rack
  for (DataDyadmino *dataDyad in dyadminoesToSwap) {
    Player *currentPlayer = [self returnCurrentPlayer];
    if (![currentPlayer.rackIndexes containsObject:dataDyad.myID] ||
        [dataDyad.placeStatus unsignedIntegerValue] != kInRack) {
      return NO;
    }
  }
  
  NSUInteger swapContainerCount = dyadminoesToSwap.count;
  if (swapContainerCount <= self.pile.count && swapContainerCount > 0) {
    
    Player *player = [self returnCurrentPlayer];
    
      // temporarily store swapped data dyadminoes so that player doesn't get same ones back
    NSMutableArray *tempDataDyadminoes = [NSMutableArray new];
    
      // remove data dyadminoes from player rack, store in temp array
    for (DataDyadmino *dataDyad in dyadminoesToSwap) {
      dataDyad.placeStatus = @(kInPile);
      [player removeFromRackDataDyadmino:dataDyad];
      [tempDataDyadminoes addObject:dataDyad];
    }
    
      // fill player rack from pile
    [self fillRackFromPileForPlayer:player];
    
      // add data dyadminoes in temp array back to pile
    for (DataDyadmino *dataDyad in tempDataDyadminoes) {
      [self.pile addObject:dataDyad];
    }
    
    [self resetHoldingContainer];
    [self recordDyadminoesFromCurrentPlayerWithSwap:YES]; // this records turn as a pass
      // sort the board and pile
    [self sortPileArray];
    return YES;
  }
  return NO;
}

-(void)recordDyadminoesFromCurrentPlayerWithSwap:(BOOL)swap {
  [self recordDyadminoesFromCurrentPlayerWithSwap:swap bypassMinimumPointsForTest:NO];
}

-(void)recordDyadminoesFromCurrentPlayerWithSwap:(BOOL)swap bypassMinimumPointsForTest:(BOOL)bypassPointsForTest {
  
  NSUInteger pointsThisTurn = [self pointsForAllChordsThisTurn];
  
    // a pass has an empty holding container, while a resign has *no* holding container
  NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @([self returnCurrentPlayerIndex]), kTurnPlayer,
                              self.holdingIndexContainer, kTurnDyadminoes,
                              @(pointsThisTurn), kTurnPoints,
                              nil];
  
  [self addTurn:dictionary];

  self.replayTurn = [self.turns count];
  
      // this is the real condition to show that the player passes
  if ((!bypassPointsForTest && pointsThisTurn == 0) ||
      
      // this is the fake condition that allows original unit tests
      // not to have scores for each player
      (bypassPointsForTest && [(NSArray *)self.holdingIndexContainer count] == 0)) {
  
      // if solo game, ends right away
    if ([self returnType] == kSelfGame && !swap) {
      [self endGame];
      return;
    }
    
      // enough players passed to end game
      // 1. two rotations if there are dyadminoes left in pile
      // 2. one rotation if no dyadminoes are left in pile
    if ([self returnType] != kSelfGame && [self allPlayersBeforePassedOrResignedToEndGame]) {
      [self endGame];
      return;
    }
    
      // player submitted dyadminoes
  } else if ((!bypassPointsForTest && pointsThisTurn > 0) ||
       (bypassPointsForTest && [(NSArray *)self.holdingIndexContainer count] > 0)) {
    
      /// obviously scorekeeping will be more sophisticated
      /// and will consider chords formed
    Player *player = [self returnCurrentPlayer];
    NSUInteger newScore = [player returnScore] + pointsThisTurn;
    player.score = @(newScore);
    
    for (DataDyadmino *dataDyad in [self dataDyadsInIndexContainer:self.holdingIndexContainer]) {
      if ([player.rackIndexes containsObject:dataDyad.myID]) {
        dataDyad.placeStatus = @(kOnBoard);
        [player removeFromRackDataDyadmino:dataDyad];
        [self.board addObject:dataDyad];
      }
    }
    
      // persist changed position and orientation of all board dyadminoes
    for (DataDyadmino *dataDyad in self.board) {
      [self persistChangedPositionForBoardDataDyadmino:dataDyad];
    }
    
      // reset rack order
    NSArray *dataDyadminoIndexesThisTurn = player.rackIndexes;
    for (NSInteger i = 0; i < dataDyadminoIndexesThisTurn.count; i++) {
      NSNumber *number = dataDyadminoIndexesThisTurn[i];
      DataDyadmino *dataDyad = [self dataDyadminoForIndex:[number unsignedIntegerValue]];
      dataDyad.myRackOrder = @(i);
    }
    
      // if player ran out and pile is empty, then end game
    if ([self checkPlayerFirstToRunOut]) {
      [self endGame];
      return;
        // else just refill the rack
    } else {
      [self fillRackFromPileForPlayer:player];
    }
      // sort the board and pile
    [self sortPileArray];
  }
  
      // whether pass or not, game continues
  [self resetHoldingContainer];
  self.lastPlayed = [NSDate date];
  
    // resets lazily loaded preTurn chords
  self.preTurnChords = nil;
  [self switchToNextPlayer];
}

-(void)resignPlayer:(Player *)player {
  
    // a resign has *no* holding container
  if ([self returnType] != kSelfGame) {
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@([self returnCurrentPlayerIndex]), kTurnPlayer, nil];
    
    [self addTurn:dictionary];
    NSArray *turns = self.turns;
    self.replayTurn = turns.count;
  }

  player.resigned = @YES;
  NSArray *dataDyads = [self dataDyadsInIndexContainer:player.rackIndexes];
  for (DataDyadmino *dataDyad in dataDyads) {
    dataDyad.placeStatus = @(kInPile);
  }
  
  [self.pile addObjectsFromArray:dataDyads];
  [self sortPileArray];
  
  [self resetHoldingContainer];
  [player removeAllRackIndexes];
  if (![self switchToNextPlayer]) {
    [self endGame];
  }
  
  self.lastPlayed = [NSDate date];
}

#pragma mark - helper methods

-(BOOL)checkPlayerFirstToRunOut {
  Player *currentPlayer = [self returnCurrentPlayer];
  NSArray *dataDyadminoIndexesThisTurn = currentPlayer.rackIndexes;
  return (dataDyadminoIndexesThisTurn.count == 0 && self.pile.count == 0);
}

-(NSUInteger)checkNumberOfPlayersStillInGame {
  NSUInteger numberOfPlayersInGame = 0;
  for (Player *player in self.players) {
    if (![player returnResigned]) {
      numberOfPlayersInGame++;
    }
  }
  return numberOfPlayersInGame;
}

-(void)sortPileArray {
  [self sortDyadminoes:self.pile];
}

-(void)sortDyadminoes:(NSMutableArray *)array {
  NSSortDescriptor *sortByID = [[NSSortDescriptor alloc] initWithKey:@"myID" ascending:YES];
  [array sortedArrayUsingDescriptors:@[sortByID]];
}

-(NSSet *)allDataDyadminoesPhysicallyOnBoard {
  NSMutableSet *tempSet = [NSMutableSet setWithSet:self.board];
  for (NSNumber *index in self.holdingIndexContainer) {
    DataDyadmino *dataDyad = [self dataDyadminoForIndex:[index unsignedIntegerValue]];
    [tempSet addObject:dataDyad];
  }
  return [NSSet setWithSet:tempSet];
}

#pragma mark - undo manager

-(BOOL)addToHoldingContainer:(DataDyadmino *)dataDyad {
  
  NSUInteger originalCount = [(NSArray *)self.holdingIndexContainer count];
  
  NSNumber *number = @([dataDyad returnMyID]);
  if (![self holdingsContainsDataDyadmino:dataDyad]) {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.holdingIndexContainer];
    [tempArray addObject:number];
    self.holdingIndexContainer = [NSArray arrayWithArray:tempArray];
  }
  
  return ([(NSArray *)self.holdingIndexContainer count] == originalCount + 1);
}

-(void)resetHoldingContainer {
    // this ensures that there is an empty array to persist if player passes
  self.holdingIndexContainer = [NSArray new];
}

-(NSUInteger)pointsForChordSonority:(NSSet *)chordSonority extended:(BOOL)extended {
  NSUInteger points;
  
    // triad
  if (chordSonority.count == 3) {
    
    if (extended) {
      NSLog(@"This is an error. A triad never extends another chords.");
//      abort();
    }
    
    points = kPointsTriad;
    
      // seventh chord
  } else {
    points = extended ? kPointsExtendedSeventh : kPointsSeventh;
  }
  return points;
}

#pragma mark - cell methods

/*
 Match's data cells do *not* work like scene's board cells.
 
 Whereas scene removes board cells while dyadmino is hovering
 and replaces them when dyadmino eases, match's data cells are
 strongly tied to data dyadmino hexCoords and orientations,
 and will *always* reflect a legal formation.
 
 Data cells *only* know preTurn and thisTurn dyadminoes.
 Match should *never* know recent rack dyadmino, which is used
 for testing placement. AI opponent will do the same thing.
 
 When testing placement of preTurn or thisTurn dyadmino,
 Match does not take into consideration dyadmino's original
 placement on board, and only tests new placement.
 
 Data cells do not distinguish between preTurn and thisTurn dyadminoes.
 */

-(DataCell *)occupiedCellForHexCoord:(HexCoord)hexCoord {
  
  for (DataCell *dataCell in self.occupiedCells) {
    if (dataCell.hexX == hexCoord.x && dataCell.hexY == hexCoord.y) {
      return dataCell;
    }
  }
  return nil;
}

-(BOOL)updateDataCellsForPlacedDyadminoID:(NSInteger)dyadminoID
                              orientation:(DyadminoOrientation)orientation
                     onBottomCellHexCoord:(HexCoord)bottomHexCoord {
  
  NSUInteger pc1 = [self pcForDyadminoIndex:dyadminoID isPC1:YES];
  NSUInteger pc2 = [self pcForDyadminoIndex:dyadminoID isPC1:NO];
  
  HexCoord topHexCoord = [self retrieveTopHexCoordForBottomHexCoord:bottomHexCoord andOrientation:orientation];
  HexCoord cellHexCoords[2] = {topHexCoord, bottomHexCoord};
  NSInteger pcs[2] = {pc1, pc2};
  
  for (int i = 0; i < 2; i++) {
    HexCoord cellHexCoord = cellHexCoords[i];
    
    DataCell *occupiedCell = [self occupiedCellForHexCoord:cellHexCoord];
    
      // only assign if no occupied cell already
    if (!occupiedCell) {
      NSUInteger myPC;
      HexCoord hexCoord = [self hexCoordFromX:cellHexCoord.x andY:cellHexCoord.y];
      
        // assign pc to cell based on dyadmino orientation
      switch (orientation) {
        case kPC1atTwelveOClock:
        case kPC1atTwoOClock:
        case kPC1atTenOClock:
          myPC = pcs[i];
          break;
        case kPC1atSixOClock:
        case kPC1atEightOClock:
        case kPC1atFourOClock:
          myPC = pcs[(i + 1) % 2];
          break;
      }
      
      DataCell *newCell = [[DataCell alloc] initWithPC:myPC dyadminoID:dyadminoID hexCoord:hexCoord];
      [self.occupiedCells addObject:newCell];
    }
  }
  return [self validateOccupiedCells];
}

-(BOOL)updateDataCellsForRemovedDyadminoID:(NSInteger)dyadminoID
                               orientation:(DyadminoOrientation)orientation
                    fromBottomCellHexCoord:(HexCoord)bottomHexCoord {
  
  HexCoord topHexCoord = [self retrieveTopHexCoordForBottomHexCoord:bottomHexCoord andOrientation:orientation];
  HexCoord cellHexCoords[2] = {topHexCoord, bottomHexCoord};
  
  for (int i = 0; i < 2; i++) {
    HexCoord cellHexCoord = cellHexCoords[i];
    DataCell *occupiedCell = [self occupiedCellForHexCoord:cellHexCoord];
    
      // only remove if cell dyadmino is dyadmino
    if (occupiedCell && [occupiedCell isOccupiedByDyadminoID:dyadminoID]) {
      [self.occupiedCells removeObject:occupiedCell];
    }
  }
  
  return [self validateOccupiedCells];
}

-(BOOL)validateOccupiedCells {
    // confirm no cell has same pc and dyadmino
  
    // contains arrays like @[@(pc), @(dyadmino)];
  NSMutableSet *presentPCsAndDyadminoes = [NSMutableSet new];
  
    // contains arrays like @[@(hexX), @(hexY)];
  NSMutableSet *presentHexCoords = [NSMutableSet new];
  
  for (DataCell *dataCell in self.occupiedCells) {
    NSArray *pcAndDyadmino = @[@(dataCell.myPC), @(dataCell.myDyadminoID)];
    if ([presentPCsAndDyadminoes containsObject:pcAndDyadmino]) {
      return NO;
    } else {
      [presentPCsAndDyadminoes addObject:pcAndDyadmino];
    }
    
    NSArray *hexCoord = @[@(dataCell.hexX), @(dataCell.hexY)];
    if ([presentHexCoords containsObject:hexCoord]) {
      return NO;
    } else {
      [presentHexCoords addObject:hexCoord];
    }
  }
  
    // confirm no cell has same hexX and hexY
  return YES;
}

-(NSSet *)neighboursTouchingDyadmino:(DataDyadmino *)dataDyad {
  HexCoord topHexCoord = [self retrieveTopHexCoordForBottomHexCoord:dataDyad.myHexCoord
                                                     andOrientation:[dataDyad returnMyOrientation]];
  HexCoord cellHexCoords[2] = {topHexCoord, dataDyad.myHexCoord};
  
  NSMutableSet *tempSet = [NSMutableSet new];

  for (int h = 0; h < 2; h++) {
    HexCoord hexCoord = cellHexCoords[h];

    NSInteger xHex = hexCoord.x;
    NSInteger yHex = hexCoord.y;
    
      // this includes cell and its eight surrounding cells (thinking in terms of square grid)
    for (NSInteger i = xHex - 1; i <= xHex + 1; i++) {
      for (NSInteger j = yHex - 1; j <= yHex + 1; j++) {
          // this excludes cell itself and the two far cells
        if (!(i == xHex && j == yHex) &&
            !(i == xHex - 1 && j == yHex - 1) &&
            !(i == xHex + 1 && j == yHex + 1)) {
          
          DataCell *occupiedCell = [self occupiedCellForHexCoord:[self hexCoordFromX:i andY:j]];
          
          if (occupiedCell && occupiedCell.myDyadminoID != [dataDyad returnMyID]) {
            DataDyadmino *dataDyad = [self dataDyadminoForIndex:occupiedCell.myDyadminoID];
            [tempSet addObject:dataDyad];
          }
        }
      }
    }
  }
  return [NSSet setWithSet:tempSet];
}

-(PhysicalPlacementResult)validatePhysicallyPlacingDyadminoID:(NSUInteger)dyadminoID
                                              withOrientation:(DyadminoOrientation)orientation
                                             onBottomHexCoord:(HexCoord)bottomHexCoord {
  
  HexCoord topHexCoord = [self retrieveTopHexCoordForBottomHexCoord:bottomHexCoord andOrientation:orientation];
  HexCoord cellHexCoords[2] = {topHexCoord, bottomHexCoord};
  
  PhysicalPlacementResult result = kErrorLoneDyadmino;
  for (int i = 0; i < 2; i++) {
    HexCoord cellHexCoord = cellHexCoords[i];
    DataCell *cell = [self occupiedCellForHexCoord:cellHexCoord];
    
      // first check if stacked on another dyadmino
    if (cell && cell.myDyadminoID != dyadminoID) {
      return kErrorStackedDyadminoes; // return right away
    }
    
      // if not stacked, then as long as it has one neighbour, there's no error
    if ([self neighboursOfHexCoord:cellHexCoord notOccupiedByDyadminoID:dyadminoID]) {
      result = kNoError; // wait to return
    }
  }
  
    // no neighbour; is it the first dyadmino?
  if (result == kErrorLoneDyadmino) {
    return [self.delegate isFirstAndOnlyDyadminoID:dyadminoID] ? kNoError : kErrorLoneDyadmino;
  } else {
    return result;
  }
}

-(NSSet *)neighboursOfHexCoord:(HexCoord)hexCoord notOccupiedByDyadminoID:(NSUInteger)dyadminoID {
  
  NSMutableSet *tempSet = [NSMutableSet new];
  
  NSInteger xHex = hexCoord.x;
  NSInteger yHex = hexCoord.y;
    // this includes cell and its eight surrounding cells (thinking in terms of square grid)
  for (NSInteger i = xHex - 1; i <= xHex + 1; i++) {
    for (NSInteger j = yHex - 1; j <= yHex + 1; j++) {
        // this excludes cell itself and the two far cells
      if (!(i == xHex && j == yHex) &&
          !(i == xHex - 1 && j == yHex - 1) &&
          !(i == xHex + 1 && j == yHex + 1)) {
        
        DataCell *occupiedCell = [self occupiedCellForHexCoord:[self hexCoordFromX:i andY:j]];
        
        if (occupiedCell && occupiedCell.myDyadminoID != dyadminoID) {
          [tempSet addObject:occupiedCell];
        }
      }
    }
  }
  
  return (tempSet.count > 0) ? [NSSet setWithSet:tempSet] : nil;
}

-(NSSet *)surroundingCellsOfSurroundingCellsOfDyadminoBottomHexCoord:(HexCoord)bottomHexCoord
                                                      andOrientation:(DyadminoOrientation)orientation {
  
  NSSet *surroundingCells = [self surroundingCellsOfDyadminoBottomHexCoord:bottomHexCoord andOrientation:orientation];
  
  HexCoord topHexCoord = [self retrieveTopHexCoordForBottomHexCoord:bottomHexCoord
                                                     andOrientation:orientation];
  
  HexCoord hexCoords[2] = {topHexCoord, bottomHexCoord};
  
    // for now, just add them all
  NSMutableSet *tempSurroundingCellsOfSurroundingCells = [NSMutableSet new];
  for (DataCell *surroundingCell in surroundingCells) {
    NSSet *surroundingCellsOfSurroundingCell = [self surroundingCellsOfHexCoord:surroundingCell.hexCoord
                                                               ignoringHexCoord:surroundingCell.hexCoord];
    
    for (DataCell *surroundingCellOfSurroundingCell in surroundingCellsOfSurroundingCell) {
      
      if (![surroundingCellOfSurroundingCell
            isContainedRegardlessOfPCAndDyadminoInfoInSet:tempSurroundingCellsOfSurroundingCells]) {
        [tempSurroundingCellsOfSurroundingCells addObject:surroundingCellOfSurroundingCell];
      }
    }
  }

    // at this point, set contains first cells and surrounding cells
  NSMutableSet *tempFinalSet = [NSMutableSet setWithSet:tempSurroundingCellsOfSurroundingCells];
  for (DataCell *dataCell in tempSurroundingCellsOfSurroundingCells) {
    
      // remove surrounding cells from set
    for (DataCell *surroundingCell in surroundingCells) {
      if (surroundingCell.hexX == dataCell.hexX && surroundingCell.hexY == dataCell.hexY) {
        [tempFinalSet removeObject:dataCell];
      }
    }
    
      // remove first cells from set
    for (int i = 0; i < 2; i++) {
      HexCoord hexCoord = hexCoords[i];
      if (dataCell.hexX == hexCoord.x && dataCell.hexY == hexCoord.y) {
        [tempFinalSet removeObject:dataCell];
      }
    }
  }
  
  return [NSSet setWithSet:tempFinalSet];
}

-(NSSet *)surroundingCellsOfDyadminoBottomHexCoord:(HexCoord)bottomHexCoord
                                    andOrientation:(DyadminoOrientation)orientation {
  
  HexCoord topHexCoord = [self retrieveTopHexCoordForBottomHexCoord:bottomHexCoord
                                                     andOrientation:orientation];
  
  HexCoord hexCoords[2] = {topHexCoord, bottomHexCoord};
  
  NSMutableSet *tempSet = [NSMutableSet new];
  
  for (int i = 0; i < 2; i++) {
    HexCoord thisHexCoord = hexCoords[i];
    HexCoord otherHexCoord = hexCoords[(i + 1) % 2];
    
    NSSet *surroundingCells = [self surroundingCellsOfHexCoord:thisHexCoord ignoringHexCoord:otherHexCoord];
    for (DataCell *surroundingCell in surroundingCells) {
      if (![surroundingCell isContainedRegardlessOfPCAndDyadminoInfoInSet:tempSet]) {
        [tempSet addObject:surroundingCell];
      }
    }
  }

  return [NSSet setWithSet:tempSet];
}

-(NSSet *)surroundingCellsOfHexCoord:(HexCoord)thisHexCoord ignoringHexCoord:(HexCoord)otherHexCoord {
    // if no hex coord to ignore, just pass in thisHexCoord again as that parameter
  
  NSMutableSet *tempSet = [NSMutableSet new];
  
  HexCoord surroundingHexCoords[6] = {[self hexCoordFromX:thisHexCoord.x andY:thisHexCoord.y + 1],
    [self hexCoordFromX:thisHexCoord.x + 1 andY:thisHexCoord.y],
    [self hexCoordFromX:thisHexCoord.x + 1 andY:thisHexCoord.y - 1],
    [self hexCoordFromX:thisHexCoord.x andY:thisHexCoord.y - 1],
    [self hexCoordFromX:thisHexCoord.x - 1 andY:thisHexCoord.y],
    [self hexCoordFromX:thisHexCoord.x - 1 andY:thisHexCoord.y + 1]};
  
  for (int j = 0; j < 6; j++) {
    
    HexCoord surroundingHexCoord = surroundingHexCoords[j];
    
      // don't include the other dyadmino hexCoord
    if (!(surroundingHexCoord.x == otherHexCoord.x && surroundingHexCoord.y == otherHexCoord.y)) {

        // pc and dyadmino information doesn't matter
      DataCell *dataCell = [[DataCell alloc] initWithPC:12 dyadminoID:66 hexCoord:surroundingHexCoord];
      
        // don't include overlapping cells more than once
      if (![dataCell isContainedRegardlessOfPCAndDyadminoInfoInSet:tempSet]) {
        [tempSet addObject:dataCell];
      }
    }
  }

  return [NSSet setWithSet:tempSet];
}

-(HexCoord)nextHexCoordFromHexCoord:(HexCoord)hexCoord andAxis:(NSUInteger)axis {
  HexCoord nextHexCoord;
  switch (axis) {
    case 0:
      nextHexCoord = [self hexCoordFromX:hexCoord.x andY:hexCoord.y + 1];
      break;
    case 1:
      nextHexCoord = [self hexCoordFromX:hexCoord.x + 1 andY:hexCoord.y];
      break;
    case 2:
      nextHexCoord = [self hexCoordFromX:hexCoord.x + 1 andY:hexCoord.y - 1];
      break;
    case 3:
      nextHexCoord = [self hexCoordFromX:hexCoord.x andY:hexCoord.y - 1];
      break;
    case 4:
      nextHexCoord = [self hexCoordFromX:hexCoord.x - 1 andY:hexCoord.y];
      break;
    case 5:
    default:
      nextHexCoord = [self hexCoordFromX:hexCoord.x - 1 andY:hexCoord.y + 1];
      break;
  }
  return nextHexCoord;
}

#pragma mark - turns methods

-(void)addTurn:(NSDictionary *)turn {
  NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.turns];
  [tempArray addObject:turn];
  self.turns = [NSArray arrayWithArray:tempArray];
}

#pragma mark - replay methods

-(void)startReplay {
  NSArray *turns = self.turns;
  self.replayTurn = turns.count;
  self.replayBoard = [NSMutableSet setWithSet:self.board];
}

-(void)leaveReplay {
  NSArray *turns = self.turns;
  self.replayTurn = turns.count;
  self.replayBoard = nil;
}

-(void)first {
  if (self.replayTurn == 0) { // in case the replay is before any turn made
    return;
  }
  
  self.replayTurn = 1;
  [self.replayBoard removeAllObjects];
  [self.replayBoard addObject:[self dataDyadminoForIndex:[self returnFirstDataDyadIndex]]];
  NSArray *holdingContainer = [self.turns[self.replayTurn - 1] objectForKey:kTurnDyadminoes];
  for (DataDyadmino *dataDyad in [self dataDyadsInIndexContainer:holdingContainer]) {
    if (![self.replayBoard containsObject:dataDyad]) {
      [self.replayBoard addObject:dataDyad];
    }
  }
}

-(BOOL)previous {
  
  if (self.replayTurn <= 1) {
    return NO;
    
  } else {
    NSArray *holdingContainer = [self.turns[self.replayTurn - 1] objectForKey:kTurnDyadminoes];
    for (DataDyadmino *dataDyad in [self dataDyadsInIndexContainer:holdingContainer]) {
      if ([self.replayBoard containsObject:dataDyad]) {
        [self.replayBoard removeObject:dataDyad];
      }
    }
    self.replayTurn--;
    return YES;
  }
}

-(BOOL)next {
  NSArray *turns = self.turns;
  if (self.replayTurn >= turns.count) {
    return NO;
    
  } else {
    self.replayTurn++;
    NSArray *holdingContainer = [self.turns[self.replayTurn - 1] objectForKey:kTurnDyadminoes];
    for (DataDyadmino *dataDyad in [self dataDyadsInIndexContainer:holdingContainer]) {
      if (![self.replayBoard containsObject:dataDyad]) {
        [self.replayBoard addObject:dataDyad];
      }
    }
    return YES;
  }
}

-(void)last {
  NSArray *turns = self.turns;
  self.replayTurn = turns.count;
  for (int i = 0; i < turns.count; i++) {
    NSArray *holdingContainer = [self.turns[i] objectForKey:kTurnDyadminoes];
    for (DataDyadmino *dataDyad in [self dataDyadsInIndexContainer:holdingContainer]) {
      if (![self.replayBoard containsObject:dataDyad]) {
        [self.replayBoard addObject:dataDyad];
      }
    }
  }
}

#pragma mark - scene query methods

-(NSUInteger)wonPlayersCount {
  NSUInteger counter = 0;
  for (Player *player in self.players) {
    if ([player returnWon]) {
      counter++;
    }
  }
  return counter;
}

-(Player *)playerForIndex:(NSUInteger)index {
  for (Player *player in self.players) {
    if ([player returnOrder] == index) {
      return player;
    }
  }
  return nil;
}

-(Player *)returnCurrentPlayer {
  return [self playerForIndex:[self returnCurrentPlayerIndex]];
}

-(DataDyadmino *)mostRecentDyadminoPlayed {
  NSNumber *lastDyadminoPlayedIndex = [self.holdingIndexContainer lastObject];
  return [self dataDyadminoForIndex:[lastDyadminoPlayedIndex unsignedIntegerValue]];
}

-(BOOL)strandedDyadminoesAfterRemovingDataDyadmino:(DataDyadmino *)dataDyadmino {
  
    // temporarily remove dyadmino from cell
  [self updateDataCellsForRemovedDyadminoID:[dataDyadmino returnMyID] orientation:[dataDyadmino returnMyOrientation] fromBottomCellHexCoord:dataDyadmino.myHexCoord];
  
  DataDyadmino *firstDataDyad = [self dataDyadminoForIndex:[self returnFirstDataDyadIndex]];
  NSMutableArray *tempArray = [NSMutableArray new];
  [tempArray addObject:firstDataDyad];
  NSUInteger checkedIndex = 0;
  
  while (checkedIndex < tempArray.count) {
    NSSet *neighbours = [self neighboursTouchingDyadmino:[tempArray objectAtIndex:checkedIndex]];
    for (DataDyadmino *dataDyad in neighbours) {
      if (![tempArray containsObject:dataDyad]) {
        [tempArray addObject:dataDyad];
      }
    }
    checkedIndex++;
  }
  
    // return dyadmino to cell
  [self updateDataCellsForPlacedDyadminoID:[dataDyadmino returnMyID] orientation:[dataDyadmino returnMyOrientation] onBottomCellHexCoord:dataDyadmino.myHexCoord];

  NSLog(@"tempArray count is %lu, board count is %lu, holding count is %lu", (unsigned long)tempArray.count, (unsigned long)self.board.count, (unsigned long)[self.holdingIndexContainer count]);
  
    // value should be all board and rack dyadminoes, minus dyadmino being undone
  return (tempArray.count < self.board.count + [self.holdingIndexContainer count] - 1);
}

-(DataDyadmino *)dataDyadminoForIndex:(NSUInteger)index {
  for (DataDyadmino *dataDyadmino in self.dataDyadminoes) {
    if ([dataDyadmino returnMyID] == index) {
      return dataDyadmino;
    }
  }
  return nil;
}

-(UIColor *)colourForPlayer:(Player *)player forLabel:(BOOL)forLabel light:(BOOL)light {
  if ([self.players containsObject:player]) {
    
    NSUInteger playerIndex = [player returnOrder];
    NSUInteger randomIndex = (playerIndex + [self returnRandomNumber1To24]) % 4;
    return [self colourForIndex:randomIndex forLabel:forLabel light:light];
  }
  return nil;
}

-(UIColor *)colourForIndex:(NSUInteger)index forLabel:(BOOL)forLabel light:(BOOL)light {
  if (forLabel) {
    switch (index) {
      case 0:
        return kPlayerBlue;
        break;
      case 1:
        return kPlayerRed;
        break;
      case 2:
        return kPlayerGreen;
        break;
      case 3:
        return kPlayerOrange;
        break;
      default:
        return nil;
        break;
    }
  } else {
    switch (index) {
      case 0:
        return light ? kPlayerLighterBlue : kPlayerLightBlue;
        break;
      case 1:
        return light ? kPlayerLighterRed : kPlayerLightRed;
        break;
      case 2:
        return light ? kPlayerLighterGreen : kPlayerLightGreen;
        break;
      case 3:
        return light ? kPlayerLighterOrange : kPlayerLightOrange;
        break;
      default:
        return nil;
        break;
    }
  }
}

-(BOOL)boardDyadminoesHaveMovedSinceStartOfTurn {
  
  NSUInteger index = [(NSArray *)self.turns count];
  for (DataDyadmino *dataDyad in self.board) {
    HexCoord persistedHexCoord = [dataDyad getHexCoordForTurn:index];
    DyadminoOrientation persistedOrientation = [dataDyad getOrientationForTurn:index];
    if (dataDyad.myHexCoord.x != persistedHexCoord.x || dataDyad.myHexCoord.y != persistedHexCoord.y || [dataDyad returnMyOrientation] != persistedOrientation) {
      return YES;
    }
  }
  return NO;
}

-(BOOL)allPlayersBeforePassedOrResignedToEndGame {
  
  NSUInteger indexOfNextPlayer = ([self returnCurrentPlayerIndex] + 1) % self.players.count;
    // find player other than current player who is still in game
  Player *activeOtherPlayer;
  while (!activeOtherPlayer && indexOfNextPlayer != [self returnCurrentPlayerIndex]) {
    Player *nextPlayer = [self playerForIndex:indexOfNextPlayer];
    if (![nextPlayer returnResigned]) {
      activeOtherPlayer = nextPlayer;
    }
    indexOfNextPlayer = (indexOfNextPlayer + 1) % self.players.count;
  }
  
  if (!activeOtherPlayer) {
    return YES;
  }
  
  NSInteger turnIndex = [(NSArray *)self.turns count] - 1;
  NSUInteger numberOfSightingsOfActiveOtherPlayer = 0;
  NSUInteger numberOfSightingsOfActiveOtherPlayerNeededToEndMatch = (self.pile.count > 0) ? 2 : 1;
  BOOL everyonePassedOrResignedSoFar = YES;
  
  while (turnIndex >= 0 && everyonePassedOrResignedSoFar &&
         numberOfSightingsOfActiveOtherPlayer < numberOfSightingsOfActiveOtherPlayerNeededToEndMatch) {
    NSDictionary *turn = [self.turns objectAtIndex:turnIndex];
    NSArray *indexContainer = [turn objectForKey:kTurnDyadminoes];
    
      // return no if this player scored
    if (indexContainer && indexContainer.count > 0) {
      everyonePassedOrResignedSoFar = NO;
    }
    
    Player *playerInRotation = [self playerForIndex:[[turn objectForKey:kTurnPlayer] unsignedIntegerValue]];
    if (playerInRotation == activeOtherPlayer) {
      numberOfSightingsOfActiveOtherPlayer++;
    }
    
    turnIndex--;
  }
  
    // did not run out of turns, and everyone passed or resigned
    // in every turn after the active other player was first sighted
    // the required number of times
  return ((numberOfSightingsOfActiveOtherPlayer == numberOfSightingsOfActiveOtherPlayerNeededToEndMatch) && everyonePassedOrResignedSoFar);
}

#pragma mark - label methods

-(NSString *)endGameResultsText {
  
  NSString *resultsText;
    // there are winners if there is any score at all
  
  if ([self wonPlayersCount] > 0) {
    
    NSMutableArray *wonPlayerNames = [[NSMutableArray alloc] initWithCapacity:[self wonPlayersCount]];
    for (Player *player in self.players) {
      [player returnWon] ? [wonPlayerNames addObject:player.name] : nil;
    }
    
    NSString *wonPlayers = [wonPlayerNames componentsJoinedByString:@" and "];
    resultsText = [NSString stringWithFormat:@"%@ won!", wonPlayers];
    
      // solo game with no score
  } else if ([self returnType] == kSelfGame) {
    resultsText = @"Scoreless game.";
    
  } else {
    resultsText = @"Draw game.";
  }
  
  return resultsText;
}

-(NSString *)turnTextLastPlayed:(BOOL)lastPlayed {
  Player *turnPlayer = [self playerForIndex:[[self.turns[self.replayTurn - 1] objectForKey:kTurnPlayer] unsignedIntegerValue]];
  NSArray *dyadminoesPlayed;
  
  NSUInteger points = 0;
  if ([self.turns[self.replayTurn - 1] objectForKey:kTurnDyadminoes]) {
    dyadminoesPlayed = [self.turns[self.replayTurn - 1] objectForKey:kTurnDyadminoes];
    points = [[self.turns[self.replayTurn - 1] objectForKey:kTurnPoints] unsignedIntegerValue];
  }
  
  NSString *dyadminoesPlayedString;
  if (points > 0) {
    
    dyadminoesPlayedString = [NSString stringWithFormat:@"scored %lu %@", (unsigned long)points, ((points == 1) ? @"point" : @"points")];
  } else if (!dyadminoesPlayed) {
    dyadminoesPlayedString = @"resigned";
  } else if (dyadminoesPlayed.count == 0) {
    dyadminoesPlayedString = @"passed";
  }
  
  if (lastPlayed) {
    if (dyadminoesPlayed.count > 0) {
      return [NSString stringWithFormat:@"%@ last %@.", turnPlayer.name, dyadminoesPlayedString];
    } else {
      return [NSString stringWithFormat:@"%@ %@ last turn.", turnPlayer.name, dyadminoesPlayedString];
    }
    
  } else {
    NSArray *turns = self.turns;
    return [NSString stringWithFormat:@"%@ %@ for turn %lu of %lu.", turnPlayer.name, dyadminoesPlayedString, (unsigned long)self.replayTurn, (unsigned long)turns.count];
  }
}

#pragma mark - getter methods

-(GameRules)returnRules {
  return (GameRules)[self.rules unsignedIntegerValue];
}

-(GameSkill)returnSkill {
  return (GameSkill)[self.skill unsignedIntegerValue];
}

-(GameType)returnType {
  return (GameType)[self.type unsignedIntegerValue];
}

-(NSUInteger)returnCurrentPlayerIndex {
  return [self.currentPlayerOrder unsignedIntegerValue];
}

-(BOOL)returnGameHasEnded {
  return [self.gameHasEnded boolValue];
}

-(NSUInteger)returnFirstDataDyadIndex {
  return [self.firstDataDyadIndex unsignedIntegerValue];
}

-(NSInteger)returnRandomNumber1To24 {
  return [self.randomNumber1To24 integerValue];
}

#pragma mark - custom accessor methods

-(NSMutableSet *)replayBoard {
  if (!_replayBoard) {
    _replayBoard = [NSMutableSet new];
  }
  return _replayBoard;
}

-(void)setReplayBoard:(NSMutableSet *)replayBoard {
  _replayBoard = replayBoard;
}

-(id<MatchDelegate>)delegate {
  return _delegate;
}

-(void)setDelegate:(id<MatchDelegate>)delegate {
  _delegate = delegate;
}

-(NSArray *)pile {
  if (!_pile) {
    _pile = [NSMutableArray new];
    for (DataDyadmino *dataDyad in self.dataDyadminoes) {
      if ([dataDyad returnPlaceStatus] == kInPile) {
        [_pile addObject:dataDyad];
      }
    }
  }
  return _pile;
}

-(void)setPile:(NSMutableArray *)pile {
  _pile = pile;
}

-(NSSet *)preTurnChords {
  if (!_preTurnChords) {
    NSUInteger lastTurnIndex = [(NSArray *)self.turns count];
    
    NSMutableSet *tempChords = [NSMutableSet new];
    
    for (NSNumber *dyadminoIndex in self.holdingIndexContainer) {
      DataDyadmino *dataDyad = [self dataDyadminoForIndex:[dyadminoIndex unsignedIntegerValue]];
      [self updateDataCellsForRemovedDyadminoID:[dataDyad returnMyID]
                                    orientation:[dataDyad returnMyOrientation]
                         fromBottomCellHexCoord:dataDyad.myHexCoord];
    }
    
      // temporarily change data cells
    for (DataDyadmino *dataDyad in self.board) {
      [self updateDataCellsForRemovedDyadminoID:[dataDyad returnMyID]
                                    orientation:[dataDyad returnMyOrientation]
                         fromBottomCellHexCoord:dataDyad.myHexCoord];
    }
    
    for (DataDyadmino *dataDyad in self.board) {
      [self updateDataCellsForPlacedDyadminoID:[dataDyad returnMyID]
                                   orientation:[dataDyad getOrientationForTurn:lastTurnIndex]
                          onBottomCellHexCoord:[dataDyad getHexCoordForTurn:lastTurnIndex]];
    }
    
      // get all legal chords from temporary board arrangement
    for (DataDyadmino *dataDyad in self.board) {
      
      NSSet *preTurnFormation = [self sonoritiesFromPlacingDyadminoID:[dataDyad returnMyID] onBottomHexCoord:[dataDyad getHexCoordForTurn:lastTurnIndex] withOrientation:[dataDyad getOrientationForTurn:lastTurnIndex]];
      NSSet *preTurnLegalChords = [[SonorityLogic sharedLogic] legalChordSonoritiesFromFormationOfSonorities:preTurnFormation];
      
      [tempChords addObjectsFromArray:preTurnLegalChords.allObjects];
    }
    
      // restore data cells
    for (DataDyadmino *dataDyad in self.board) {
      [self updateDataCellsForRemovedDyadminoID:[dataDyad returnMyID]
                                    orientation:[dataDyad getOrientationForTurn:lastTurnIndex]
                         fromBottomCellHexCoord:[dataDyad getHexCoordForTurn:lastTurnIndex]];
    }
    
    for (DataDyadmino *dataDyad in self.board) {
      [self updateDataCellsForPlacedDyadminoID:[dataDyad returnMyID]
                                   orientation:[dataDyad returnMyOrientation]
                          onBottomCellHexCoord:dataDyad.myHexCoord];
    }
    
    for (NSNumber *dyadminoIndex in self.holdingIndexContainer) {
      DataDyadmino *dataDyad = [self dataDyadminoForIndex:[dyadminoIndex unsignedIntegerValue]];
      [self updateDataCellsForPlacedDyadminoID:[dataDyad returnMyID]
                                   orientation:[dataDyad returnMyOrientation]
                          onBottomCellHexCoord:dataDyad.myHexCoord];
    }
    
    _preTurnChords = [NSSet setWithSet:tempChords];
  }
  return _preTurnChords;
}

-(void)setPreTurnChords:(NSSet *)preTurnChords {
  _preTurnChords = preTurnChords;
}

-(NSSet *)board {
  if (!_board) {
    _board = [NSMutableSet new];
    for (DataDyadmino *dataDyad in self.dataDyadminoes) {
      if ([dataDyad returnPlaceStatus] == kOnBoard) {
        [_board addObject:dataDyad];
        [self updateDataCellsForPlacedDyadminoID:[dataDyad returnMyID]
                                     orientation:[dataDyad returnMyOrientation]
                            onBottomCellHexCoord:dataDyad.myHexCoord];
      }
    }
    [self preTurnChords];
  }
  return _board;
}

-(void)setBoard:(NSMutableSet *)board {
  _board = board;
}

-(NSSet *)occupiedCells {
  if (!_occupiedCells) {
    
    _occupiedCells = [NSMutableSet new];
    NSMutableSet *dataDyadsOnBoard = [NSMutableSet setWithSet:self.board];
    
      // add objects in holding container
    for (NSNumber *dyadIndex in self.holdingIndexContainer) {
      DataDyadmino *dataDyad = [self dataDyadminoForIndex:[dyadIndex unsignedIntegerValue]];
      [dataDyadsOnBoard addObject:dataDyad];
    }
    
    for (DataDyadmino *dataDyad in dataDyadsOnBoard) {
      
      DyadminoOrientation orientation = (DyadminoOrientation)[dataDyad returnMyOrientation];
      HexCoord topHexCoord = [self retrieveTopHexCoordForBottomHexCoord:dataDyad.myHexCoord andOrientation:orientation];
      HexCoord cellHexCoords[2] = {topHexCoord, dataDyad.myHexCoord};
      
      for (int i = 0; i < 2; i++) {
        HexCoord cellHexCoord = cellHexCoords[i];
        NSUInteger dyadminoID = [dataDyad.myID unsignedIntegerValue];
        NSUInteger pc = [self pcForDyadminoIndex:dyadminoID isPC1:(BOOL)(orientation <= 1 || orientation >= 5 ? (i + 1) % 2 : i)];
        DataCell *newCell = [[DataCell alloc] initWithPC:pc dyadminoID:dyadminoID hexCoord:cellHexCoord];
        
//        NSLog(@"pc:%lu, dyadID:%lu, hex:%li, %li", (unsigned long)newCell.myPC, (unsigned long)newCell.myDyadminoID, (long)newCell.hexX, (long)newCell.hexY);
        
        [_occupiedCells addObject:newCell];
      }
    }
  }
  return _occupiedCells;
}

-(void)setOccupiedCells:(NSMutableSet *)occupiedCells {
  _occupiedCells = occupiedCells;
}

-(NSUInteger)replayTurn {
  if (!_replayTurn) {
    _replayTurn = 0;
  }
  return _replayTurn;
}

-(void)setReplayTurn:(NSUInteger)replayTurn {
  _replayTurn = replayTurn;
}

#pragma mark = holding container helper methods

-(BOOL)holdingsContainsDataDyadmino:(DataDyadmino *)dataDyad {
  return [self.holdingIndexContainer containsObject:@([dataDyad returnMyID])];
}

-(NSArray *)dataDyadsInIndexContainer:(NSArray *)holdingContainer {
  
  NSMutableArray *tempArray = [NSMutableArray new];
  for (NSNumber *number in holdingContainer) {
    DataDyadmino *dataDyad = [self dataDyadminoForIndex:[number unsignedIntegerValue]];
    [tempArray addObject:dataDyad];
  }
  return [NSArray arrayWithArray:tempArray];
}

#pragma mark - test methods

-(BOOL)testAddToHoldingContainer:(DataDyadmino *)dataDyad {
  return [self addToHoldingContainer:dataDyad];
}

-(DataDyadmino *)testUndoLastPlayedDyadmino {
  return [self undoLastPlayedDyadminoByReset:YES];
}

-(void)testRecordDyadminoesFromCurrentPlayerWithSwap:(BOOL)swap {
  [self recordDyadminoesFromCurrentPlayerWithSwap:swap bypassMinimumPointsForTest:YES];
}

-(void)testPersistChangedPositionForBoardDataDyadmino:(DataDyadmino *)dataDyad {
  [self persistChangedPositionForBoardDataDyadmino:dataDyad];
}

-(void)testEndGame {
  [self endGame];
}

-(PhysicalPlacementResult)testValidatePhysicallyPlacingDyadminoID:(NSUInteger)dyadminoID
                                                  withOrientation:(DyadminoOrientation)orientation
                                                 onBottomHexCoord:(HexCoord)bottomHexCoord {
  return [self validatePhysicallyPlacingDyadminoID:dyadminoID withOrientation:orientation onBottomHexCoord:bottomHexCoord];
}

-(NSSet *)testSonoritiesFromPlacingDyadminoID:(NSUInteger)dyadminoID
                             onBottomHexCoord:(HexCoord)bottomHexCoord
                              withOrientation:(DyadminoOrientation)orientation {
  return [self sonoritiesFromPlacingDyadminoID:dyadminoID
                              onBottomHexCoord:bottomHexCoord
                               withOrientation:orientation];
}

-(NSSet *)testSurroundingCellsOfDyadminoBottomHexCoord:(HexCoord)bottomHexCoord
                                        andOrientation:(DyadminoOrientation)orientation {
  return [self surroundingCellsOfDyadminoBottomHexCoord:bottomHexCoord andOrientation:orientation];
}

-(NSSet *)testSurroundingCellsOfSurroundingCellsOfDyadminoBottomHexCoord:(HexCoord)bottomHexCoord
                                                          andOrientation:(DyadminoOrientation)orientation {
  return [self surroundingCellsOfSurroundingCellsOfDyadminoBottomHexCoord:bottomHexCoord andOrientation:orientation];
}

-(BOOL)testPlayDataDyadmino:(DataDyadmino *)placedDataDyad anywherePhysicallyLegalByDataDyadmino:(DataDyadmino *)nextToDataDyad {
  
    // make sure this is a current rack dyadmino
  Player *player = [self returnCurrentPlayer];
  if (![player.rackIndexes containsObject:placedDataDyad.myID]) {
    return NO;
  }
  
  NSSet *surroundingCells = [self surroundingCellsOfDyadminoBottomHexCoord:nextToDataDyad.myHexCoord
                                                            andOrientation:[nextToDataDyad returnMyOrientation]];
  
  for (DataCell *dataCell in surroundingCells) {
    for (DyadminoOrientation orientation = kPC1atTwelveOClock; orientation <= kPC1atTenOClock; orientation++) {
      
      BOOL validPlace = [self validatePhysicallyPlacingDyadminoID:[placedDataDyad returnMyID]
                                                  withOrientation:orientation onBottomHexCoord:dataCell.hexCoord];
      if (validPlace) {
        [self playDataDyadmino:placedDataDyad onBottomHexCoord:dataCell.hexCoord withOrientation:orientation];
        return YES;
      }
    }
    
  }
  return NO;
}

-(BOOL)testUpdateDataCellsForPlacedDyadminoID:(NSInteger)dyadminoID
                                  orientation:(DyadminoOrientation)orientation
                         onBottomCellHexCoord:(HexCoord)bottomHexCoord {

  return [self updateDataCellsForPlacedDyadminoID:dyadminoID
                                      orientation:orientation
                             onBottomCellHexCoord:bottomHexCoord];
}

-(BOOL)testUpdateDataCellsForRemovedDyadminoID:(NSInteger)dyadminoID
                                   orientation:(DyadminoOrientation)orientation
                        fromBottomCellHexCoord:(HexCoord)bottomHexCoord {

  return [self updateDataCellsForRemovedDyadminoID:dyadminoID
                                       orientation:orientation
                            fromBottomCellHexCoord:bottomHexCoord];
}

-(BOOL)testStrandedDyadminoesAfterRemovingDataDyadmino:(DataDyadmino *)dataDyadmino {
  return [self strandedDyadminoesAfterRemovingDataDyadmino:dataDyadmino];
}

-(void)logLegalChordSonorities:(NSSet *)legalChordSonorities withInitialString:(NSString *)initialString {
  NSLog(@"%@ is %@.", initialString, [[SonorityLogic sharedLogic] testStringForLegalChordSonoritiesWithSonorities:legalChordSonorities]);
}

@end

@implementation Turns

+(Class)transformedValueClass {
  return [NSArray class];
}

+(BOOL)allowsReverseTransformation {
  return YES;
}

-(id)transformedValue:(id)value {
  return [NSKeyedArchiver archivedDataWithRootObject:value];
}

-(id)reverseTransformedValue:(id)value {
  return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end

@implementation HoldingIndexContainer

+(Class)transformedValueClass {
  return [NSArray class];
}

+(BOOL)allowsReverseTransformation {
  return YES;
}

-(id)transformedValue:(id)value {
  return [NSKeyedArchiver archivedDataWithRootObject:value];
}

-(id)reverseTransformedValue:(id)value {
  return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end

@implementation ArrayOfChordsAndPoints

+(Class)transformedValueClass {
  return [NSArray class];
}

+(BOOL)allowsReverseTransformation {
  return YES;
}

-(id)transformedValue:(id)value {
  return [NSKeyedArchiver archivedDataWithRootObject:value];
}

-(id)reverseTransformedValue:(id)value {
  return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end