//
//  SonorityLogic.m
//  Dyadminoes
//
//  Created by Bennett Lin on 1/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "SonorityLogic.h"

@interface SonorityLogic ()

@end

@implementation SonorityLogic

#pragma mark - validation methods

-(NSSet *)legalChordSonoritiesFromFormationOfSonorities:(NSSet *)sonorities {
    // returns all sonorities that are legal chords, with pc and dyadmino information
    // returns empty set if no legal chords
  
  NSMutableSet *tempChordSonorities = [NSMutableSet new];
  
  for (NSSet *sonority in sonorities) {
    
    NSSet *chordSonority = [self chordSonorityForSonority:sonority];
    Chord chord = [self chordFromSonorityPlusCheckIncompleteSeventh:chordSonority];
    
    if (chord.chordType <= kChordFrenchSixth) {
      [tempChordSonorities addObject:sonority];
    }
  }
  
  return tempChordSonorities;
}

-(IllegalPlacementResult)checkIllegalPlacementFromFormationOfSonorities:(NSSet *)sonorities {

  IllegalPlacementResult mostEgregiousError = kNotIllegal;
  
  for (NSSet *sonority in sonorities) {

      // ensures no chord exceeds maximum
    if (![self validateSonorityDoesNotExceedMaximum:sonority]) {
      mostEgregiousError = kExcessNotes > mostEgregiousError ? kExcessNotes : mostEgregiousError;
      
        // ensures chord does not have double pcs
    } else if (![self validateSonorityHasNoDoublePCs:sonority]) {
      mostEgregiousError = kDoublePCs > mostEgregiousError ? kDoublePCs : mostEgregiousError;
    }
    
    NSSet *chordSonority = [self chordSonorityForSonority:sonority];
    Chord chord = [self chordFromSonorityPlusCheckIncompleteSeventh:chordSonority];
    
      // ensures chord is not illegal
    if (chord.chordType == kChordIllegalChord) {
      mostEgregiousError = kIllegalSonority > mostEgregiousError ? kIllegalSonority : mostEgregiousError;
    }
  }
  
  NSLog(@"error is %i", mostEgregiousError);
  return mostEgregiousError;
}


-(NSSet *)chordSonorityForSonority:(NSSet *)sonority {
  NSMutableSet *tempChordSonority = [NSMutableSet new];
  for (id note in sonority) {
    if ([note isKindOfClass:[NSDictionary class]]) {
      NSNumber *pc = note[@"pc"];
      [tempChordSonority addObject:pc];
    }
  }
  return [NSSet setWithSet:tempChordSonority];
}

-(NSSet *)chordSonoritiesForSonorities:(NSSet *)sonorities {
  NSMutableSet *tempChordSonorities = [NSMutableSet new];
  for (id sonority in sonorities) {
    if ([sonority isKindOfClass:[NSSet class]]) {
      NSSet *chordSonority = [self chordSonorityForSonority:(NSSet *)sonority];
      [tempChordSonorities addObject:chordSonority];
    }
  }
  return [NSSet setWithSet:tempChordSonorities];
}

-(BOOL)setOfLegalChords:(NSSet *)setofLegalChords1 isSubsetOfSetOfLegalChords:(NSSet *)setOfLegalChords2 {
    // this method will break if the chords are not all legal

  BOOL returnValue = YES;
  for (NSSet *chord1 in setofLegalChords1) {

    BOOL sonority1IsAlsoInSet2 = NO;
    for (NSSet *chord2 in setOfLegalChords2) {
      if ([self sonority:chord1 isSubsetOfSonority:chord2]) {
        sonority1IsAlsoInSet2 = YES;
      }
    }

    if (!sonority1IsAlsoInSet2) {
      returnValue = NO;
    }
  }
  
  return returnValue;
}

-(NSSet *)legalChords:(NSSet *)legalChords1 notFoundInAndNotSubsetsOfLegalChords:(NSSet *)legalChords2 {
  
  NSMutableSet *tempSet = [NSMutableSet new];
  for (NSSet *chord1 in legalChords1) {
    
    BOOL thisChordInSet1IsFoundInOrASubsetOfAChordInSet2 = NO;
    for (NSSet *chord2 in legalChords2) {
      if ([self sonority:chord1 isSubsetOfSonority:chord2]) {
        thisChordInSet1IsFoundInOrASubsetOfAChordInSet2 = YES;
      }
    }
    if (!thisChordInSet1IsFoundInOrASubsetOfAChordInSet2) {
      [tempSet addObject:chord1];
    }
  }
  
  return [NSSet setWithSet:tempSet];
}

-(BOOL)validateSonorityDoesNotExceedMaximum:(NSSet *)sonority {
  return (sonority.count <= 4);
}

-(BOOL)validateSonorityHasNoDoublePCs:(NSSet *)sonority {
  NSMutableSet *pcs = [NSMutableSet new];
  for (NSDictionary *note in sonority) {
    NSNumber *pc = note[@"pc"];
    if ([pcs containsObject:pc]) {
      return NO;
    }
    [pcs addObject:pc];
  }
  return YES;
}

-(BOOL)sonority:(NSSet *)set containsNote:(NSDictionary *)dictionary {
  
  for (NSDictionary *setNote in set) {
    
    if ([setNote[@"pc"] isEqual:dictionary[@"pc"]] && [setNote[@"dyadmino"] isEqual:dictionary[@"dyadmino"]]) {
      return YES;
    }
  }
  return NO;
}

-(BOOL)sonority:(NSSet *)smaller isSubsetOfSonority:(NSSet *)larger {
    // every note in smaller sonority is also in larger sonority
    // possible that sonorities are equal
  
  for (NSDictionary *note in smaller) {
    if (![self sonority:larger containsNote:note]) {
      return NO;
    }
  }
  
  return YES;
}

-(BOOL)sonority:(NSSet *)sonority1 isEqualToSonority:(NSSet *)sonority2 {
  if (sonority1.count != sonority2.count) {
    return NO;
  }
  
  for (NSDictionary *note in sonority1) {
    if (![self sonority:sonority2 containsNote:note]) {
      return NO;
    }
  }
  
  return YES;
}

-(NSSet *)sonoritiesInSonorities:(NSSet *)larger thatAreSupersetsOfSonoritiesInSonorities:(NSSet *)smaller inclusive:(BOOL)inclusive {
  
  NSMutableSet *tempSupersetsSonorities = [NSMutableSet new];
  
  for (NSSet *largerSetSonority in larger) {
    
    BOOL smallerFoundInLarger = NO;
    for (NSSet *smallerSetSonority in smaller) {
      if ([smallerSetSonority isSubsetOfSet:largerSetSonority]) {
        
          // this confirms that the sonorities are not equal, so add it to temp set
        if (![largerSetSonority isSubsetOfSet:smallerSetSonority]) {
          [tempSupersetsSonorities addObject:largerSetSonority];
          
            // sonorities are equal, check inclusive bool
            // to decidedo whether to add it to temp set
        } else if (!inclusive) {
          smallerFoundInLarger = YES;
        }
      }
    }
    
      // sonority is missing in smaller set, add it to temp set
    if (!smallerFoundInLarger) {
      [tempSupersetsSonorities addObject:largerSetSonority];
    }
  }
  
  return [NSSet setWithSet:tempSupersetsSonorities];
  
}

#pragma mark - chord logic methods

-(Chord)chordFromChordSonority:(NSSet *)sonority {
  
    // root is -1 if not a chord
  NSUInteger cardinality = [sonority count];
  
    // return if legal sonority
  if (cardinality == 0) {
    return [self chordFromRoot:-1 andChordType:kChordNoChord];
  } else if (cardinality == 1) {
    return [self chordFromRoot:-1 andChordType:kChordLegalMonad];
  } else if (cardinality == 2) {
    return [self chordFromRoot:-1 andChordType:kChordLegalDyad];
  } else if (cardinality > 4) {
    return [self chordFromRoot:-1 andChordType:kChordIllegalChord];
  }
  
    // puts in pc normal form
  NSMutableArray *pcNormalForm = [NSMutableArray arrayWithArray:[sonority allObjects]];
  [pcNormalForm sortUsingSelector:@selector(compare:)];
  
    // puts in ic normal form
  NSMutableArray *icNormalForm = [[NSMutableArray alloc] initWithCapacity:cardinality];
  NSMutableArray *arrayOfSmallestICIndexes = [[NSMutableArray alloc] initWithCapacity:cardinality];
  NSUInteger smallestKnownIC = 12; // start out with the maximum
  
  for (int i = 0; i < cardinality; i++) {
    NSInteger higherNumber = [[pcNormalForm objectAtIndex:(i + 1) % cardinality] integerValue];
    NSInteger lowerNumber = [[pcNormalForm objectAtIndex:i] integerValue];
    NSInteger interval = higherNumber - lowerNumber;
    if (interval < 0) {
      interval += 12;
    }
    
    [icNormalForm addObject:[NSNumber numberWithInteger:interval]];
      // this will later help to determine ic prime form
    if (interval < smallestKnownIC) {
      smallestKnownIC = interval;
      [arrayOfSmallestICIndexes removeAllObjects];
      [arrayOfSmallestICIndexes addObject:[NSNumber numberWithInt:i]];
    } else if (interval == smallestKnownIC) {
      [arrayOfSmallestICIndexes addObject:[NSNumber numberWithInt:i]];
    }
  }

    // converts ic normal form to ic prime form
    // if there are two smallest known ICs, then find the one that has the largest known gap
  NSUInteger largestKnownGap = 0; // start out with the minimum
  int firstICIndex = 0;
  for (NSNumber *indexObject in arrayOfSmallestICIndexes) {
    int index = [indexObject intValue];
      // ensures no division by zero
    NSUInteger thisGap = (NSUInteger)icNormalForm[((index - 1) + cardinality) % cardinality];
    if (thisGap > largestKnownGap) {
      largestKnownGap = thisGap;
      firstICIndex = index;
    }
  }
  
  NSMutableArray *tempICPrimeForm = [[NSMutableArray alloc] initWithCapacity:cardinality];
  for (int i = 0; i < cardinality; i++) {
    uint thisIC = [icNormalForm[(i + firstICIndex) % cardinality] unsignedIntValue];
    [tempICPrimeForm addObject:[NSNumber numberWithUnsignedInt:thisIC]];
  }

  NSNumber *_fakeRootPC = pcNormalForm[firstICIndex];
  NSArray *icPrimeForm = [NSArray arrayWithArray:tempICPrimeForm];
  return [self chordFromFakeRootPC:_fakeRootPC andICPrimeForm:icPrimeForm];
}

-(Chord)chordFromSonorityPlusCheckIncompleteSeventh:(NSSet *)sonority {
  
  Chord chord = [self chordFromChordSonority:sonority];
  
  if (chord.chordType == kChordIllegalChord) {
    if ([self sonorityIsIncompleteSeventh:sonority]) {
      return [self chordFromRoot:-1 andChordType:kChordLegalIncompleteSeventh];
    }
  }
  return chord;
}

-(Chord)chordFromFakeRootPC:(NSNumber *)fakeRootPC andICPrimeForm:(NSArray *)icPrimeForm {
  
    // ensures that diminished triad is in right order
  if ([icPrimeForm isEqualToArray:@[@3, @6, @3]]) {
    fakeRootPC = @(([fakeRootPC unsignedIntegerValue] + 9) % 12);
    icPrimeForm = @[@3, @3, @6];
  }
  
  NSArray *legalICPrimeForms = @[@[@3, @4, @5], @[@3, @5, @4], @[@2, @3, @3, @4],
                                 @[@2, @3, @4, @3], @[@2, @4, @3, @3], @[@3, @3, @6],
                                 @[@4, @4, @4], @[@3, @3, @3, @3], @[@1, @3, @4, @4],
                                 @[@1, @4, @3, @4], @[@1, @4, @4, @3],
                                 @[@2, @4, @6], @[@2, @4, @2, @4]];
  
  NSArray *fakeRootOffsets = @[@0, @8, @2, @2, @2, @0, @0, @0, @1, @1, @1, @2, @2];

    // establish default
//  BOOL isLegalChord = NO;
  ChordType chordType = kChordIllegalChord;
  NSInteger root = -1;
  
  for (NSArray *legalICPrimeForm in legalICPrimeForms) {
    if ([icPrimeForm isEqualToArray:legalICPrimeForm]) {
//      isLegalChord = YES;
      NSUInteger index = [legalICPrimeForms indexOfObject:legalICPrimeForm];
      NSUInteger realRootPC = [fakeRootPC unsignedIntegerValue] +
                      [fakeRootOffsets[index] unsignedIntegerValue];
      if (realRootPC >= 12) {
        realRootPC -= 12;
      }
      chordType = (ChordType)index;
      root = realRootPC;
    }
  }
  return [self chordFromRoot:root andChordType:chordType];
}

-(BOOL)sonorityIsIncompleteSeventh:(NSSet *)sonority {
  
    // cardinality must be 3
  if (sonority.count != 3) {
    return NO;
  }
  
    // sonority must be illegal as a triad
  Chord chordForSonority = [self chordFromChordSonority:sonority];
  if (chordForSonority.chordType != kChordIllegalChord) {
    return NO;
  }
  
  BOOL sonorityIsIncompleteSeventh = NO;
  
  for (NSUInteger i = 0; i < 12; i++) {
    NSNumber *missingNote = [NSNumber numberWithUnsignedInteger:i];
    if (![sonority containsObject:missingNote]) {
      NSMutableSet *tempSonority = [NSMutableSet setWithSet:sonority];
      [tempSonority addObject:missingNote];
      NSSet *newSonority = [NSSet setWithSet:tempSonority];
      Chord chordForNewSonority = [self chordFromChordSonority:newSonority];
      if (chordForNewSonority.chordType != kChordIllegalChord) {
        sonorityIsIncompleteSeventh = YES;
      }
    }
  }
  
  return sonorityIsIncompleteSeventh;
}

#pragma mark - chord label methods

-(NSString *)stringForChordType:(ChordType)chordType {
  switch (chordType) {
    case kChordMinorTriad:
      return @"minor triad";
      break;
    case kChordMajorTriad:
      return @"major triad";
      break;
    case kChordHalfDiminishedSeventh:
      return @"half-diminished seventh";
      break;
    case kChordMinorSeventh:
      return @"minor seventh";
      break;
    case kChordDominantSeventh:
      return @"dominant seventh";
      break;
    case kChordDiminishedTriad:
      return @"diminished triad";
      break;
    case kChordAugmentedTriad:
      return @"augmented triad";
      break;
    case kChordFullyDiminishedSeventh:
      return @"fully diminished seventh";
      break;
    case kChordMinorMajorSeventh:
      return @"minor-major seventh";
      break;
    case kChordMajorSeventh:
      return @"major seventh";
      break;
    case kChordAugmentedMajorSeventh:
      return @"augmented major seventh";
      break;
    case kChordItalianSixth:
      return @"Italian sixth";
      break;
    case kChordFrenchSixth:
      return @"French sixth";
      break;
    case kChordNoChord:
    case kChordLegalMonad:
    case kChordLegalDyad:
    case kChordLegalIncompleteSeventh:
    case kChordIllegalChord:
      return nil;
      break;
  }
}

-(NSString *)stringForChord:(Chord)chord {
  
  NSInteger root = chord.root;
  ChordType chordType = chord.chordType;
  
  NSString *rootString;
  
  if (chordType == kChordFullyDiminishedSeventh) {
    switch (root) {
      case 0:
      case 3:
      case 6:
      case 9:
        rootString = @"C$D(#)/E(b)$F(#)/G(b)$A";
        break;
      case 1:
      case 4:
      case 7:
      case 10:
        rootString = @"C(#)/D(b)$E$G$A(#)/B(b)";
        break;
      case 2:
      case 5:
      case 8:
      case 11:
        rootString = @"D$F$G(#)/A(b)$B";
        break;
    }
    
  } else if (chordType == kChordAugmentedTriad) {
    switch (root) {
      case 0:
      case 4:
      case 8:
        rootString = @"C$E$G(#)/A(b)";
        break;
      case 1:
      case 5:
      case 9:
        rootString = @"C(#)/D(b)$F$A";
        break;
      case 2:
      case 6:
      case 10:
        rootString = @"D$F(#)/G(b)$A(#)/B(b)";
        break;
      case 3:
      case 7:
      case 11:
        rootString = @"D(#)/E(b)$G$B";
        break;
    }
    
  } else if (chordType == kChordFrenchSixth) {
    switch (root) {
      case 0:
      case 6:
        rootString = @"C$F(#)/G(b)";
        break;
      case 1:
      case 7:
        rootString = @"C(#)/D(b)$G";
        break;
      case 2:
      case 8:
        rootString = @"D$G(#)/A(b)";
        break;
      case 3:
      case 9:
        rootString = @"D(#)/E(b)$A";
        break;
      case 4:
      case 10:
        rootString = @"E$A(#)/B(b)";
        break;
      case 5:
      case 11:
        rootString = @"F$B";
        break;
    }
    
  } else if (chordType < kChordNoChord) {
    switch (root) {
      case 0:
        rootString = @"C";
        break;
      case 1:
        rootString = @"C(#)/D(b)";
        break;
      case 2:
        rootString = @"D";
        break;
      case 3:
        rootString = @"D(#)/E(b)";
        break;
      case 4:
        rootString = @"E";
        break;
      case 5:
        rootString = @"F";
        break;
      case 6:
        rootString = @"F(#)/G(b)";
        break;
      case 7:
        rootString = @"G";
        break;
      case 8:
        rootString = @"G(#)/A(b)";
        break;
      case 9:
        rootString = @"A";
        break;
      case 10:
        rootString = @"A(#)/B(b)";
        break;
      case 11:
        rootString = @"B";
        break;
    }
  }
  return [NSString stringWithFormat:@"%@ %@", rootString, [self stringForChordType:chordType]];
}

-(NSAttributedString *)stringWithAccidentals:(NSString *)myString fontSize:(CGFloat)size {
  
    // first replace all instances of (#) and (b) with pound and yen characters
  unichar pound[1] = {(unichar)163};
  unichar yen[1] = {(unichar)165};
  
  myString = [myString stringByReplacingOccurrencesOfString:@"(#)" withString:[NSString stringWithCharacters:pound length:1]];
  myString = [myString stringByReplacingOccurrencesOfString:@"(b)" withString:[NSString stringWithCharacters:yen length:1]];
  
  NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:myString];
  
  for (int i = 0; i < myString.length; i++) {
    unichar myChar = [myString characterAtIndex:i];
    
    if (myChar == (unichar)163) {
      [attString replaceCharactersInRange:NSMakeRange(i, 1) withString:[self stringForMusicSymbol:kSymbolSharp]];
      [attString addAttribute:NSBaselineOffsetAttributeName value:@(size / 2.75) range:NSMakeRange(i, 1)];
      [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontSonata size:size * 0.95f] range:NSMakeRange(i, 1)];
      
    } else if (myChar == (unichar)165) {
      [attString replaceCharactersInRange:NSMakeRange(i, 1) withString:[self stringForMusicSymbol:kSymbolFlat]];
      [attString addAttribute:NSBaselineOffsetAttributeName value:@(size / 5.4) range:NSMakeRange(i, 1)];
      [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontSonata size:size * 1.15f] range:NSMakeRange(i, 1)];
      
    } else if (myChar == (unichar)36) { // dollar sign turns into bullet
      [attString replaceCharactersInRange:NSMakeRange(i, 1) withString:[self stringForMusicSymbol:kSymbolBullet]];
      [attString addAttribute:NSKernAttributeName value:@(-size * .05) range:NSMakeRange(i, 1)];
    }
  }
  
  return attString;
}

-(NSAttributedString *)stringForSonorities:(NSSet *)sonorities
                         withInitialString:(NSString *)initialString
                           andEndingString:(NSString *)endingString {
  
  NSMutableAttributedString *initialText = [[NSMutableAttributedString alloc] initWithString:initialString];
//  [initialText addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontModern size:kChordMessageLabelFontSize] range:NSMakeRange(0, initialText.length)];
  
  NSSet *chords = [self chordSonoritiesForSonorities:sonorities];
  NSAttributedString *chordsText = [self stringForLegalChords:chords];
  
  NSMutableAttributedString *endingText = [[NSMutableAttributedString alloc] initWithString:endingString];
//  [endingText addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontModern size:kChordMessageLabelFontSize] range:NSMakeRange(0, endingText.length)];
  
  [initialText appendAttributedString:chordsText];
  [initialText appendAttributedString:endingText];
  
  return initialText;
}

-(NSAttributedString *)stringForLegalChords:(NSSet *)chords {
  
    // sort chords based on chord type
  NSMutableArray *tempDictionaryArray = [NSMutableArray new];
  for (NSSet *chordSonority in chords) {
    Chord chord = [self chordFromSonorityPlusCheckIncompleteSeventh:chordSonority];
    NSNumber *chordTypeNumber = @(chord.chordType);
    NSDictionary *chordDictionary = @{@"chordSonority":chordSonority, @"chordType":chordTypeNumber};
    [tempDictionaryArray addObject:chordDictionary];
  }
  NSArray *dictionaryArray = [NSArray arrayWithArray:tempDictionaryArray];
  NSSortDescriptor *chordTypeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"chordType" ascending:YES];
  NSArray *sortedArray = [dictionaryArray sortedArrayUsingDescriptors:@[chordTypeDescriptor]];
  
  NSMutableArray *tempStringArray = [NSMutableArray new];
  for (int i = 0; i < sortedArray.count; i++) {
    NSDictionary *chordDictionary = sortedArray[i];
    if ([chordDictionary[@"chordType"] unsignedIntegerValue] <= kChordFrenchSixth) {
      NSSet *chordSonority = chordDictionary[@"chordSonority"];
      Chord chord = [self chordFromSonorityPlusCheckIncompleteSeventh:chordSonority];
      NSString *string = [self stringForChord:chord];
      NSString *finalString;
      
        // _____
        // _____ and _____
        // _____, _____, and _____
      
        // last string in list
      if (i == 0 && sortedArray.count == 1) {
        finalString = string;
      } else if (i == 0 && sortedArray.count == 2) {
        finalString = [NSString stringWithFormat:@"%@ ", string];
      } else if ((i == sortedArray.count - 1) && sortedArray.count > 1) {
        finalString = [NSString stringWithFormat:@"and %@", string];
      } else {
        finalString = [NSString stringWithFormat:@"%@, ", string];
      }
      
      NSAttributedString *attributedString = [self stringWithAccidentals:finalString fontSize:kChordMessageLabelFontSize];
      [tempStringArray addObject:attributedString];
    }
  }
  
  NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:@""];
  for (int i = 0; i < tempStringArray.count; i++) {
    [mutableAttributedString appendAttributedString:tempStringArray[i]];
  }

  return mutableAttributedString;
}

#pragma mark - singleton method

+(id)sharedLogic {
  static SonorityLogic *shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[self alloc] init];
  });
  return shared;
}

@end
